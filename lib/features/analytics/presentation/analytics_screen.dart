import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/excel_export_service.dart';
import 'package:helpi_admin/core/network/api_client.dart';
import 'package:helpi_admin/core/network/api_endpoints.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';

/// GA-style analytics — date-range selector, 3 stacked line charts
/// (orders / revenue / active seniors) with comparison overlay.
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

// ── Date range presets ──
enum _RangePreset { last7, thisMonth, lastMonth, custom }

// ── Metric types ──
enum _Metric { orders, revenue, activeSeniors }

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  _RangePreset _preset = _RangePreset.last7;
  bool _showComparison = false;
  bool _showEarnings = false;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;

  final _api = ApiClient();

  // ── Pricing (loaded from API, defaults match backend seed) ──
  // Senior pays:
  double _seniorWeekdayRate = 14.0;
  double _seniorSundayRate = 21.0;
  // Student receives fixed rates (editable in Settings)
  double _studentWeekdayRate = 7.40;
  double _studentSundayRate = 11.10;
  // VAT:
  bool _vatEnabled = false;
  double _vatPercentage = 0;
  // Intermediary margin (studentservis cut):
  double _intermediaryPct = 0.18; // 18% default
  // TODO(neto-exact): Stripe fee is currently estimated using the formula
  // 1.5% + €0.25 (EEA standard rate). For exact figures:
  //   1. Backend: add a StripeFee decimal column to PaymentTransaction
  //   2. Backend: handle "charge.succeeded" in StripeWebhookController,
  //      retrieve BalanceTransaction and persist its fee field
  //   3. API: return stripeFee in the session/payment DTO
  //   4. Frontend: read the actual fee from the API instead of this formula
  // Non-EEA cards are charged 3.25% + €0.25, so the formula underestimates
  // the fee for ~18% of transactions (see Stripe dashboard — Order #30, #24).
  static const double _stripePct = 0.015; // 1.5%
  static const double _stripeFixed = 0.25; // €0.25 per charge (per session)

  int _lastPricingVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadPricing();
    _applyPreset(_RangePreset.last7);
  }

  Future<void> _loadPricing() async {
    try {
      final response = await _api.get(ApiEndpoints.pricingConfigurations);
      final list = response.data as List<dynamic>;
      if (list.isEmpty) return;
      final cfg = list.first as Map<String, dynamic>;
      if (!mounted) return;
      final seniorW = (cfg['jobHourlyRate'] as num?)?.toDouble() ?? 14.0;
      final seniorS = (cfg['sundayHourlyRate'] as num?)?.toDouble() ?? 21.0;
      final stuW = (cfg['studentHourlyRate'] as num?)?.toDouble() ?? 7.40;
      final stuS =
          (cfg['studentSundayHourlyRate'] as num?)?.toDouble() ?? 11.10;
      setState(() {
        _seniorWeekdayRate = seniorW;
        _seniorSundayRate = seniorS;
        _studentWeekdayRate = stuW;
        _studentSundayRate = stuS;
        _vatEnabled = cfg['vatEnabled'] == true;
        _vatPercentage = (cfg['vatPercentage'] as num?)?.toDouble() ?? 0;
        _intermediaryPct =
            ((cfg['intermediaryPercentage'] as num?)?.toDouble() ?? 18) / 100;
      });
    } catch (_) {
      // keep defaults
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  RANGE HELPERS
  // ═══════════════════════════════════════════════════════════

  void _applyPreset(_RangePreset p) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (p) {
      case _RangePreset.last7:
        _rangeStart = today.subtract(const Duration(days: 6));
        _rangeEnd = today;
      case _RangePreset.thisMonth:
        _rangeStart = DateTime(now.year, now.month);
        _rangeEnd = today;
      case _RangePreset.lastMonth:
        final m = now.month == 1 ? 12 : now.month - 1;
        final y = now.month == 1 ? now.year - 1 : now.year;
        _rangeStart = DateTime(y, m);
        _rangeEnd = DateTime(
          now.year,
          now.month,
        ).subtract(const Duration(days: 1));
      case _RangePreset.custom:
        return; // keep current range
    }
    _preset = p;
  }

  int get _rangeDays => _rangeEnd.difference(_rangeStart).inDays + 1;

  DateTime get _compStart => _rangeStart.subtract(Duration(days: _rangeDays));
  DateTime get _compEnd => _rangeStart.subtract(const Duration(days: 1));

  bool _hasCompleteSessionPricingSnapshot(SessionModel session) {
    return session.hourlyRate > 0 && session.studentHourlyRate > 0;
  }

  double _resolveSeniorRate(SessionModel session) {
    if (_hasCompleteSessionPricingSnapshot(session)) return session.hourlyRate;
    final isSunday = session.weekday == DateTime.sunday;
    return isSunday ? _seniorSundayRate : _seniorWeekdayRate;
  }

  double _resolveStudentRate(SessionModel session) {
    if (_hasCompleteSessionPricingSnapshot(session)) {
      return session.studentHourlyRate;
    }
    final isSunday = session.weekday == DateTime.sunday;
    return isSunday ? _studentSundayRate : _studentWeekdayRate;
  }

  double _resolveCompanyEarnings(SessionModel session) {
    final gross = session.durationHours * _resolveSeniorRate(session);
    final vatDeduction = _vatEnabled
        ? gross * (_vatPercentage / (100 + _vatPercentage))
        : 0.0;
    final stripeFee = gross * _stripePct + _stripeFixed;
    final studentPay = session.durationHours * _resolveStudentRate(session);
    final intermediaryFee = studentPay * _intermediaryPct;

    return gross - vatDeduction - stripeFee - studentPay - intermediaryFee;
  }

  // ═══════════════════════════════════════════════════════════
  //  DATA EXTRACTION
  // ═══════════════════════════════════════════════════════════

  List<double> _dailyValues(
    _Metric metric,
    List<OrderModel> orders,
    List<SeniorModel> seniors,
    DateTime from,
    DateTime to,
  ) {
    final days = to.difference(from).inDays + 1;
    final result = List.filled(days, 0.0);

    switch (metric) {
      case _Metric.orders:
        for (final o in orders) {
          final d = DateTime(
            o.createdAt.year,
            o.createdAt.month,
            o.createdAt.day,
          );
          final idx = d.difference(from).inDays;
          if (idx >= 0 && idx < days) result[idx] += 1;
        }
      case _Metric.revenue:
        for (final o in orders) {
          if (o.student == null) continue;
          for (final s in o.sessions) {
            if (s.status == SessionStatus.cancelled) continue;
            final d = DateTime(s.date.year, s.date.month, s.date.day);
            final idx = d.difference(from).inDays;
            if (idx >= 0 && idx < days) {
              final seniorRate = _resolveSeniorRate(s);
              final gross = s.durationHours * seniorRate;

              if (_showEarnings) {
                result[idx] += _resolveCompanyEarnings(s);
              } else {
                result[idx] += gross;
              }
            }
          }
        }
      case _Metric.activeSeniors:
        final daySets = List.generate(days, (_) => <String>{});
        for (final o in orders) {
          for (final s in o.sessions) {
            if (s.status == SessionStatus.cancelled) continue;
            final d = DateTime(s.date.year, s.date.month, s.date.day);
            final idx = d.difference(from).inDays;
            if (idx >= 0 && idx < days) {
              daySets[idx].add(o.senior.id);
            }
          }
        }
        for (var i = 0; i < days; i++) {
          result[i] = daySets[i].length.toDouble();
        }
    }
    return result;
  }

  double _pctChange(double current, double prev) {
    if (prev == 0 && current == 0) return 0;
    if (prev == 0) return 100;
    return ((current - prev) / prev) * 100;
  }

  String _fmtVal(_Metric metric, double v) {
    if (metric == _Metric.revenue) return '€${v.toStringAsFixed(2)}';
    return v.toStringAsFixed(0);
  }

  String _fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}';

  Future<void> _pickCustomRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _rangeStart, end: _rangeEnd),
    );
    if (!context.mounted) return;
    if (picked != null) {
      setState(() {
        _rangeStart = picked.start;
        _rangeEnd = picked.end;
        _preset = _RangePreset.custom;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allOrders = ref.watch(ordersProvider);
    final allSeniors = ref.watch(seniorsProvider);

    // Reload pricing when SettingsChanged fires (via SignalR)
    final pv = ref.watch(pricingVersionProvider);
    if (pv != _lastPricingVersion) {
      _lastPricingVersion = pv;
      if (pv > 0) _loadPricing();
    }

    // Current period data
    final ordersData = _dailyValues(
      _Metric.orders,
      allOrders,
      allSeniors,
      _rangeStart,
      _rangeEnd,
    );
    final revenueData = _dailyValues(
      _Metric.revenue,
      allOrders,
      allSeniors,
      _rangeStart,
      _rangeEnd,
    );
    final seniorsData = _dailyValues(
      _Metric.activeSeniors,
      allOrders,
      allSeniors,
      _rangeStart,
      _rangeEnd,
    );

    // Comparison period data
    final ordersComp = _showComparison
        ? _dailyValues(
            _Metric.orders,
            allOrders,
            allSeniors,
            _compStart,
            _compEnd,
          )
        : <double>[];
    final revenueComp = _showComparison
        ? _dailyValues(
            _Metric.revenue,
            allOrders,
            allSeniors,
            _compStart,
            _compEnd,
          )
        : <double>[];
    final seniorsComp = _showComparison
        ? _dailyValues(
            _Metric.activeSeniors,
            allOrders,
            allSeniors,
            _compStart,
            _compEnd,
          )
        : <double>[];

    // % changes
    double? pctOrders;
    double? pctRevenue;
    double? pctSeniors;
    if (_showComparison) {
      pctOrders = _pctChange(
        ordersData.fold(0.0, (a, b) => a + b),
        ordersComp.fold(0.0, (a, b) => a + b),
      );
      pctRevenue = _pctChange(
        revenueData.fold(0.0, (a, b) => a + b),
        revenueComp.fold(0.0, (a, b) => a + b),
      );
      pctSeniors = _pctChange(
        seniorsData.fold(0.0, (a, b) => a + b),
        seniorsComp.fold(0.0, (a, b) => a + b),
      );
    }

    return Scaffold(
      appBar: HelpiAppBar(
        title: Text(AppStrings.dashboardTitle),
        actions: const [NotificationBell()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Date range preset chips ──
            _buildRangeChips(context),
            const SizedBox(height: 8),
            Text(
              '${_fmtDate(_rangeStart)} – ${_fmtDate(_rangeEnd)}',
              style: TextStyle(
                fontSize: 13,
                color: HelpiColors.of(context).textSecondary,
              ),
            ),

            // ── Comparison toggle + Export icon ──
            Row(
              children: [
                _comparisonToggle(),
                const Spacer(),
                IconButton(
                  onPressed: () => _exportToExcel(allOrders, allSeniors),
                  icon: const Icon(Icons.download_outlined),
                  tooltip: 'Export Excel',
                  iconSize: 20,
                  color: HelpiColors.of(context).textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Orders chart ──
            _buildMetricChartCard(
              theme: theme,
              metric: _Metric.orders,
              title: AppStrings.analyticsOrders,
              icon: Icons.receipt_long_outlined,
              lineColor: HelpiTheme.statusProcessingText,
              bgColor: HelpiTheme.statusProcessingBg,
              currentValues: ordersData,
              compValues: ordersComp,
              pct: pctOrders,
            ),
            const SizedBox(height: 16),

            // ── Revenue chart ──
            _buildMetricChartCard(
              theme: theme,
              metric: _Metric.revenue,
              title: _showEarnings
                  ? AppStrings.analyticsEarnings
                  : AppStrings.analyticsRevenue,
              icon: Icons.euro_outlined,
              lineColor: HelpiTheme.statusActiveText,
              bgColor: HelpiTheme.statusActiveBg,
              currentValues: revenueData,
              compValues: revenueComp,
              pct: pctRevenue,
              headerTrailing: _earningsToggle(),
              hideTitle: true,
            ),
            const SizedBox(height: 16),

            // ── Active seniors chart ──
            _buildMetricChartCard(
              theme: theme,
              metric: _Metric.activeSeniors,
              title: AppStrings.analyticsActiveSeniors,
              icon: Icons.elderly_outlined,
              lineColor: HelpiTheme.accent,
              bgColor: HelpiColors.of(context).pastelTeal,
              currentValues: seniorsData,
              compValues: seniorsComp,
              pct: pctSeniors,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  EXCEL EXPORT
  // ═══════════════════════════════════════════════════════════

  List<AnalyticsDayRow> _buildExportRows(
    List<OrderModel> orders,
    DateTime from,
    DateTime to,
  ) {
    final days = to.difference(from).inDays + 1;
    final orderCounts = List.filled(days, 0.0);
    final grossRevs = List.filled(days, 0.0);
    final stripeFees = List.filled(days, 0.0);
    final studentPays = List.filled(days, 0.0);
    final netoRevs = List.filled(days, 0.0);
    final seniorSets = List.generate(days, (_) => <String>{});

    for (final o in orders) {
      // Orders count
      final od = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
      final oIdx = od.difference(from).inDays;
      if (oIdx >= 0 && oIdx < days) orderCounts[oIdx] += 1;

      // Revenue + seniors
      if (o.student == null) continue;
      for (final s in o.sessions) {
        if (s.status == SessionStatus.cancelled) continue;
        final d = DateTime(s.date.year, s.date.month, s.date.day);
        final idx = d.difference(from).inDays;
        if (idx < 0 || idx >= days) continue;

        seniorSets[idx].add(o.senior.id);

        final seniorRate = _resolveSeniorRate(s);
        final gross = s.durationHours * seniorRate;
        final stripe = gross * _stripePct + _stripeFixed;
        final studentRate = _resolveStudentRate(s);
        final sPay = s.durationHours * studentRate;

        final vatDed = _vatEnabled
            ? gross * (_vatPercentage / (100 + _vatPercentage))
            : 0.0;
        grossRevs[idx] += gross;
        stripeFees[idx] += stripe;
        studentPays[idx] += sPay;
        netoRevs[idx] +=
            gross - vatDed - stripe - sPay - (sPay * _intermediaryPct);
      }
    }

    return List.generate(
      days,
      (i) => AnalyticsDayRow(
        date: from.add(Duration(days: i)),
        orders: orderCounts[i],
        grossRevenue: grossRevs[i],
        stripeFee: stripeFees[i],
        studentPay: studentPays[i],
        studentService: 0,
        helpiNeto: netoRevs[i],
        activeSeniors: seniorSets[i].length.toDouble(),
      ),
    );
  }

  Future<void> _exportToExcel(
    List<OrderModel> orders,
    List<SeniorModel> seniors,
  ) async {
    final currentRows = _buildExportRows(orders, _rangeStart, _rangeEnd);

    List<AnalyticsDayRow>? compRows;
    if (_showComparison) {
      compRows = _buildExportRows(orders, _compStart, _compEnd);
    }

    await ExcelExportService.exportAnalytics(
      currentData: currentRows,
      rangeStart: _rangeStart,
      rangeEnd: _rangeEnd,
      compData: compRows,
      compStart: _showComparison ? _compStart : null,
      compEnd: _showComparison ? _compEnd : null,
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  DATE RANGE CHIPS
  // ═══════════════════════════════════════════════════════════

  Widget _buildRangeChips(BuildContext context) {
    Widget chip(String label, _RangePreset p, {bool isCustom = false}) {
      final selected = _preset == p;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          selectedColor: HelpiTheme.accent,
          labelStyle: TextStyle(
            color: selected
                ? Colors.white
                : HelpiColors.of(context).textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
          side: BorderSide(
            color: selected
                ? HelpiTheme.accent
                : HelpiColors.of(context).border,
          ),
          onSelected: (_) {
            HapticFeedback.selectionClick();
            if (isCustom) {
              _pickCustomRange(context);
            } else {
              setState(() => _applyPreset(p));
            }
          },
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(AppStrings.analyticsLast7Days, _RangePreset.last7),
          chip(AppStrings.analyticsThisMonth, _RangePreset.thisMonth),
          chip(AppStrings.analyticsLastMonth, _RangePreset.lastMonth),
          chip(
            AppStrings.analyticsCustomRange,
            _RangePreset.custom,
            isCustom: true,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  COMPARISON TOGGLE
  // ═══════════════════════════════════════════════════════════

  Widget _comparisonToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HelpiSwitch(
          value: _showComparison,
          onChanged: (v) => setState(() => _showComparison = v),
        ),
        const SizedBox(width: 8),
        Builder(
          builder: (ctx) {
            final isWide = MediaQuery.sizeOf(ctx).width >= 600;
            return Text(
              isWide
                  ? AppStrings.analyticsCompare
                  : AppStrings.analyticsCompareShort,
              style: TextStyle(
                fontSize: 12,
                color: HelpiColors.of(context).textSecondary,
              ),
            );
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  EARNINGS TOGGLE (inside Revenue card header)
  // ═══════════════════════════════════════════════════════════

  Widget _earningsToggle() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _showEarnings = !_showEarnings),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showEarnings ? 0.35 : 1.0,
              child: Text(
                AppStrings.analyticsRevenue,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: HelpiColors.of(context).textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 20,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: HelpiTheme.accent,
              ),
              alignment: _showEarnings
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showEarnings ? 1.0 : 0.35,
              child: Text(
                AppStrings.analyticsEarnings,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: HelpiColors.of(context).textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  METRIC CHART CARD
  // ═══════════════════════════════════════════════════════════

  Widget _buildMetricChartCard({
    required ThemeData theme,
    required _Metric metric,
    required String title,
    required IconData icon,
    required Color lineColor,
    required Color bgColor,
    required List<double> currentValues,
    required List<double> compValues,
    required double? pct,
    Widget? headerTrailing,
    bool hideTitle = false,
  }) {
    final total = currentValues.fold(0.0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HelpiColors.of(context).surface,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiColors.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Builder(
            builder: (ctx) {
              final isWide = MediaQuery.sizeOf(ctx).width >= 600;

              final totalWidget = Text(
                _fmtVal(metric, total),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: lineColor,
                ),
              );

              final headerRow = Row(
                children: [
                  Builder(
                    builder: (iconCtx) {
                      final isDark =
                          Theme.of(iconCtx).brightness == Brightness.dark;
                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark
                              ? lineColor.withValues(alpha: 0.15)
                              : bgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: lineColor, size: 20),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  if (!hideTitle)
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: HelpiColors.of(ctx).textSecondary,
                      ),
                    ),
                  if (!hideTitle && headerTrailing != null)
                    const SizedBox(width: 10),
                  ?headerTrailing,
                  const Spacer(),
                  totalWidget,
                  if (isWide && pct != null) ...[
                    const SizedBox(width: 8),
                    _PercentBadge(pct: pct),
                  ],
                ],
              );

              if (isWide || pct == null) return headerRow;

              // Mobile: badge below, right-aligned
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  headerRow,
                  const SizedBox(height: 2),
                  _PercentBadge(pct: pct),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Line chart ──
          SizedBox(
            height: 180,
            child: _buildLineChart(
              metric,
              lineColor,
              currentValues,
              compValues,
            ),
          ),

          // ── Legend ──
          if (_showComparison) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(
                  color: lineColor,
                  label: AppStrings.analyticsCurrent,
                ),
                const SizedBox(width: 20),
                _LegendDot(
                  color: HelpiColors.of(context).border,
                  label: AppStrings.analyticsPrevious,
                  isDashed: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  FL_CHART LINE CHART
  // ═══════════════════════════════════════════════════════════

  Widget _buildLineChart(
    _Metric metric,
    Color lineColor,
    List<double> current,
    List<double> comp,
  ) {
    if (current.isEmpty) {
      return Center(
        child: Text(
          AppStrings.analyticsNoData,
          style: TextStyle(color: HelpiColors.of(context).textSecondary),
        ),
      );
    }

    final allValues = [...current, ...comp];
    final maxY = allValues.isEmpty
        ? 10.0
        : (allValues.reduce(math.max) * 1.15).clamp(1.0, double.infinity);

    final currentSpots = current
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final lines = <LineChartBarData>[
      LineChartBarData(
        spots: currentSpots,
        isCurved: true,
        curveSmoothness: 0.25,
        color: lineColor,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: current.length <= 31,
          getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
            radius: 3,
            color: HelpiColors.of(context).surface,
            strokeWidth: 2,
            strokeColor: lineColor,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: lineColor.withValues(alpha: 0.08),
        ),
      ),
    ];

    // Comparison line (dashed)
    if (_showComparison && comp.isNotEmpty) {
      final compSpots = comp
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();
      lines.add(
        LineChartBarData(
          spots: compSpots,
          isCurved: true,
          curveSmoothness: 0.25,
          color: HelpiColors.of(context).border,
          barWidth: 2,
          isStrokeCapRound: true,
          dashArray: [6, 4],
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    final days = current.length;
    final step = (days / 6).ceil().clamp(1, days);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        lineBarsData: lines,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (v) => FlLine(
            color: HelpiColors.of(context).border.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: maxY / 4,
              getTitlesWidget: (value, meta) {
                if (value == maxY) return const SizedBox.shrink();
                return Text(
                  metric == _Metric.revenue
                      ? '€${value.toStringAsFixed(0)}'
                      : value.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 10,
                    color: HelpiColors.of(context).textSecondary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: step.toDouble(),
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= days) return const SizedBox.shrink();
                final d = _rangeStart.add(Duration(days: i));
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${d.day}.${d.month}.',
                    style: TextStyle(
                      fontSize: 10,
                      color: HelpiColors.of(context).textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((i) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: HelpiColors.of(context).border.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                    radius: 4,
                    color: lineColor,
                    strokeWidth: 2,
                    strokeColor: HelpiColors.of(context).surface,
                  ),
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xEE333333),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItems: (spots) {
              return spots.map((s) {
                final isComp = s.barIndex == 1;
                final d = (isComp ? _compStart : _rangeStart).add(
                  Duration(days: s.x.toInt()),
                );
                return LineTooltipItem(
                  '${d.day}.${d.month}.  ${_fmtVal(metric, s.y)}',
                  TextStyle(
                    color: isComp ? Colors.white70 : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PERCENT BADGE
// ═══════════════════════════════════════════════════════════════

class _PercentBadge extends StatelessWidget {
  const _PercentBadge({required this.pct});
  final double pct;

  @override
  Widget build(BuildContext context) {
    final isUp = pct > 0;
    final isDown = pct < 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isUp
        ? const Color(0xFF2E7D32)
        : (isDown
              ? HelpiTheme.statusCancelledText
              : HelpiColors.of(context).textSecondary);
    final bg = isDark
        ? color.withValues(alpha: 0.15)
        : (isUp
              ? const Color(0xFFE8F5E9)
              : (isDown
                    ? HelpiTheme.statusCancelledBg
                    : HelpiColors.of(context).border.withValues(alpha: 0.3)));
    final icon = isUp
        ? Icons.trending_up
        : (isDown ? Icons.trending_down : Icons.trending_flat);
    final label = pct.abs() < 0.1
        ? '0%'
        : '${isUp ? '+' : ''}${pct.toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  LEGEND DOT
// ═══════════════════════════════════════════════════════════════

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.isDashed = false,
  });
  final Color color;
  final String label;
  final bool isDashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: isDashed
                ? Border(
                    bottom: BorderSide(
                      color: color,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  )
                : null,
            borderRadius: isDashed ? null : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: HelpiColors.of(context).textSecondary,
          ),
        ),
      ],
    );
  }
}
