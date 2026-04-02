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
import 'package:helpi_admin/core/widgets/widgets.dart';

/// GA-style analytics — date-range selector, 3 stacked line charts
/// (orders / revenue / active seniors) with comparison overlay.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

// ── Date range presets ──
enum _RangePreset { last7, thisMonth, lastMonth, custom }

// ── Metric types ──
enum _Metric { orders, revenue, activeSeniors }

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  _RangePreset _preset = _RangePreset.last7;
  bool _showComparison = false;
  bool _showNetRevenue = false;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;

  // ── Pricing constants (source of truth) ──
  // Senior pays:
  static const double _seniorWeekdayRate = 14.0;
  static const double _seniorSundayRate = 16.0;
  // Student receives:
  static const double _studentWeekdayRate = 7.40;
  static const double _studentSundayRate = 11.10;
  // Costs:
  static const double _studentServicePct = 0.18; // 18% student service fee
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

  @override
  void initState() {
    super.initState();
    _applyPreset(_RangePreset.last7);
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
              final isSunday = s.weekday == DateTime.sunday;
              final seniorRate = isSunday
                  ? _seniorSundayRate
                  : _seniorWeekdayRate;
              final gross = s.durationHours * seniorRate;

              if (_showNetRevenue) {
                // Exact per-session neto:
                // gross − Stripe fee − student pay − studentski servis (18%)
                final stripeFee = gross * _stripePct + _stripeFixed;
                final studentRate = isSunday
                    ? _studentSundayRate
                    : _studentWeekdayRate;
                final studentPay = s.durationHours * studentRate;
                final studentService = studentPay * _studentServicePct;
                result[idx] += gross - stripeFee - studentPay - studentService;
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
      appBar: AppBar(
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
              style: TextStyle(fontSize: 13, color: HelpiTheme.textSecondary),
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
                  color: HelpiTheme.textSecondary,
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
              title: _showNetRevenue
                  ? AppStrings.analyticsHelpiNeto
                  : AppStrings.analyticsRevenue,
              icon: Icons.euro_outlined,
              lineColor: HelpiTheme.statusActiveText,
              bgColor: HelpiTheme.statusActiveBg,
              currentValues: revenueData,
              compValues: revenueComp,
              pct: pctRevenue,
              headerTrailing: _netoToggle(),
            ),
            const SizedBox(height: 16),

            // ── Active seniors chart ──
            _buildMetricChartCard(
              theme: theme,
              metric: _Metric.activeSeniors,
              title: AppStrings.analyticsActiveSeniors,
              icon: Icons.elderly_outlined,
              lineColor: HelpiTheme.accent,
              bgColor: HelpiTheme.pastelTeal,
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
    final studentServices = List.filled(days, 0.0);
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

        final isSunday = s.weekday == DateTime.sunday;
        final seniorRate = isSunday ? _seniorSundayRate : _seniorWeekdayRate;
        final gross = s.durationHours * seniorRate;
        final stripe = gross * _stripePct + _stripeFixed;
        final studentRate = isSunday ? _studentSundayRate : _studentWeekdayRate;
        final sPay = s.durationHours * studentRate;
        final sService = sPay * _studentServicePct;

        grossRevs[idx] += gross;
        stripeFees[idx] += stripe;
        studentPays[idx] += sPay;
        studentServices[idx] += sService;
        netoRevs[idx] += gross - stripe - sPay - sService;
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
        studentService: studentServices[i],
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
            color: selected ? Colors.white : HelpiTheme.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
          side: BorderSide(
            color: selected ? HelpiTheme.accent : HelpiTheme.border,
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
    return GestureDetector(
      onTap: () => setState(() => _showComparison = !_showComparison),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 20,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _showComparison ? HelpiTheme.accent : HelpiTheme.border,
            ),
            alignment: _showComparison
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
          Builder(
            builder: (ctx) {
              final isWide = MediaQuery.sizeOf(ctx).width >= 600;
              return Text(
                isWide
                    ? AppStrings.analyticsCompare
                    : AppStrings.analyticsCompareShort,
                style: const TextStyle(
                  fontSize: 12,
                  color: HelpiTheme.textSecondary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  NETO TOGGLE (inside Revenue card header)
  // ═══════════════════════════════════════════════════════════

  Widget _netoToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showNetRevenue = !_showNetRevenue),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 20,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _showNetRevenue ? HelpiTheme.accent : HelpiTheme.border,
            ),
            alignment: _showNetRevenue
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
          const SizedBox(width: 6),
          Builder(
            builder: (ctx) {
              final isWide = MediaQuery.sizeOf(ctx).width >= 600;
              return Text(
                isWide
                    ? AppStrings.analyticsHelpiNeto
                    : AppStrings.analyticsNetoShort,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: _showNetRevenue
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: _showNetRevenue
                      ? HelpiTheme.accent
                      : HelpiTheme.textSecondary,
                ),
              );
            },
          ),
        ],
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
  }) {
    final total = currentValues.fold(0.0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiTheme.border),
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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: lineColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: HelpiTheme.textSecondary,
                    ),
                  ),
                  if (headerTrailing != null) ...[
                    const SizedBox(width: 10),
                    headerTrailing,
                  ],
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
                  color: HelpiTheme.border,
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
          style: const TextStyle(color: HelpiTheme.textSecondary),
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
            color: Colors.white,
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
          color: HelpiTheme.border,
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
            color: HelpiTheme.border.withValues(alpha: 0.5),
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
                  style: const TextStyle(
                    fontSize: 10,
                    color: HelpiTheme.textSecondary,
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
                    style: const TextStyle(
                      fontSize: 10,
                      color: HelpiTheme.textSecondary,
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
                  color: HelpiTheme.border.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                    radius: 4,
                    color: lineColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
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
    final color = isUp
        ? const Color(0xFF2E7D32)
        : (isDown ? HelpiTheme.statusCancelledText : HelpiTheme.textSecondary);
    final bg = isUp
        ? const Color(0xFFE8F5E9)
        : (isDown
              ? HelpiTheme.statusCancelledBg
              : HelpiTheme.border.withValues(alpha: 0.3));
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
          style: const TextStyle(fontSize: 12, color: HelpiTheme.textSecondary),
        ),
      ],
    );
  }
}
