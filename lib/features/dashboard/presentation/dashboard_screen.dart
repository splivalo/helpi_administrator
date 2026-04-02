import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';

/// GA-style analytics — date-range selector, line chart with comparison,
/// metric chips (orders / revenue / active seniors), and KPI cards.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

// ── Date range presets ──
enum _RangePreset { last7, thisMonth, lastMonth, custom }

// ── Metric selector ──
enum _Metric { orders, revenue, activeSeniors }

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  _RangePreset _preset = _RangePreset.last7;
  _Metric _metric = _Metric.orders;
  bool _showComparison = false;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;

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

  /// Returns a value per day in [from..to] (inclusive) for the active metric.
  List<double> _dailyValues(
    List<OrderModel> orders,
    List<SeniorModel> seniors,
    DateTime from,
    DateTime to,
  ) {
    final days = to.difference(from).inDays + 1;
    final result = List.filled(days, 0.0);

    switch (_metric) {
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
          final student = o.student;
          if (student == null) continue;
          for (final s in o.sessions) {
            if (s.status == SessionStatus.cancelled) continue;
            final d = DateTime(s.date.year, s.date.month, s.date.day);
            final idx = d.difference(from).inDays;
            if (idx >= 0 && idx < days) {
              final rate = s.weekday == 7
                  ? student.sundayHourlyRate
                  : student.hourlyRate;
              result[idx] += s.durationHours * rate;
            }
          }
        }
      case _Metric.activeSeniors:
        // Unique seniors who had a non-cancelled session on that day
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

  String _fmtVal(double v) {
    if (_metric == _Metric.revenue) return '€${v.toStringAsFixed(2)}';
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 900;

    final allOrders = ref.watch(ordersProvider);
    final allSeniors = ref.watch(seniorsProvider);

    final currentValues = _dailyValues(
      allOrders,
      allSeniors,
      _rangeStart,
      _rangeEnd,
    );
    final currentTotal = currentValues.fold(0.0, (a, b) => a + b);

    final compValues = _showComparison
        ? _dailyValues(allOrders, allSeniors, _compStart, _compEnd)
        : <double>[];
    final compTotal = compValues.fold(0.0, (a, b) => a + b);
    final pct = _showComparison ? _pctChange(currentTotal, compTotal) : 0.0;

    // KPI cards data
    final ordersInRange = allOrders.where((o) {
      final d = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
      return !d.isBefore(_rangeStart) && !d.isAfter(_rangeEnd);
    }).length;

    double revenueInRange = 0;
    final seniorIds = <String>{};
    for (final o in allOrders) {
      for (final s in o.sessions) {
        if (s.status == SessionStatus.cancelled) continue;
        final d = DateTime(s.date.year, s.date.month, s.date.day);
        if (!d.isBefore(_rangeStart) && !d.isAfter(_rangeEnd)) {
          seniorIds.add(o.senior.id);
          if (o.student != null) {
            final rate = s.weekday == 7
                ? o.student!.sundayHourlyRate
                : o.student!.hourlyRate;
            revenueInRange += s.durationHours * rate;
          }
        }
      }
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
            const SizedBox(height: 4),
            Text(
              '${_fmtDate(_rangeStart)} – ${_fmtDate(_rangeEnd)}',
              style: TextStyle(fontSize: 13, color: HelpiTheme.textSecondary),
            ),
            const SizedBox(height: 16),

            // ── Line chart card ──
            _buildChartCard(
              theme,
              currentValues,
              compValues,
              currentTotal,
              pct,
            ),
            const SizedBox(height: 24),

            // ── KPI cards ──
            _buildKpiRow(
              isWide: isWide,
              ordersInRange: ordersInRange,
              revenueInRange: revenueInRange,
              activeSeniorsInRange: seniorIds.length,
              pctOrders: _showComparison
                  ? _pctChange(
                      ordersInRange.toDouble(),
                      allOrders
                          .where((o) {
                            final d = DateTime(
                              o.createdAt.year,
                              o.createdAt.month,
                              o.createdAt.day,
                            );
                            return !d.isBefore(_compStart) &&
                                !d.isAfter(_compEnd);
                          })
                          .length
                          .toDouble(),
                    )
                  : null,
            ),
          ],
        ),
      ),
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

    return Wrap(
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
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  CHART CARD (metric chips + comparison toggle + line chart)
  // ═══════════════════════════════════════════════════════════

  Widget _buildChartCard(
    ThemeData theme,
    List<double> currentValues,
    List<double> compValues,
    double currentTotal,
    double pct,
  ) {
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
          // ── Metric selector chips ──
          Wrap(
            spacing: 8,
            children: [
              _metricChip(AppStrings.analyticsOrders, _Metric.orders),
              _metricChip(AppStrings.analyticsRevenue, _Metric.revenue),
              _metricChip(
                AppStrings.analyticsActiveSeniors,
                _Metric.activeSeniors,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Comparison toggle ──
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 40,
                child: Switch(
                  value: _showComparison,
                  onChanged: (v) => setState(() => _showComparison = v),
                  activeColor: HelpiTheme.accent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.analyticsCompare,
                style: const TextStyle(
                  fontSize: 13,
                  color: HelpiTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Total + % ──
          Row(
            children: [
              Text(
                _fmtVal(currentTotal),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: HelpiTheme.textPrimary,
                ),
              ),
              if (_showComparison) ...[
                const SizedBox(width: 12),
                _PercentBadge(pct: pct),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ── Line chart ──
          SizedBox(
            height: 220,
            child: _buildLineChart(currentValues, compValues),
          ),

          // ── Legend ──
          if (_showComparison) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(
                  color: HelpiTheme.accent,
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

  Widget _metricChip(String label, _Metric m) {
    final selected = _metric == m;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: HelpiTheme.pastelTeal,
      labelStyle: TextStyle(
        color: selected ? HelpiTheme.accent : HelpiTheme.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        fontSize: 13,
      ),
      side: BorderSide(color: selected ? HelpiTheme.accent : HelpiTheme.border),
      onSelected: (_) {
        HapticFeedback.selectionClick();
        setState(() => _metric = m);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  FL_CHART LINE CHART
  // ═══════════════════════════════════════════════════════════

  Widget _buildLineChart(List<double> current, List<double> comp) {
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
      // Main line
      LineChartBarData(
        spots: currentSpots,
        isCurved: true,
        curveSmoothness: 0.25,
        color: HelpiTheme.accent,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: current.length <= 31,
          getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
            radius: 3,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: HelpiTheme.accent,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: HelpiTheme.accent.withValues(alpha: 0.08),
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
    // Show ~5-7 labels on X axis
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
                  _metric == _Metric.revenue
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
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((s) {
                final isComp = s.barIndex == 1;
                final d = (isComp ? _compStart : _rangeStart).add(
                  Duration(days: s.x.toInt()),
                );
                return LineTooltipItem(
                  '${d.day}.${d.month}.\n${_fmtVal(s.y)}',
                  TextStyle(
                    color: isComp
                        ? HelpiTheme.textSecondary
                        : HelpiTheme.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  KPI ROW
  // ═══════════════════════════════════════════════════════════

  Widget _buildKpiRow({
    required bool isWide,
    required int ordersInRange,
    required double revenueInRange,
    required int activeSeniorsInRange,
    required double? pctOrders,
  }) {
    final cards = [
      _KpiCard(
        icon: Icons.receipt_long_outlined,
        label: AppStrings.analyticsOrders,
        value: '$ordersInRange',
        color: HelpiTheme.statusProcessingText,
        bgColor: HelpiTheme.statusProcessingBg,
        pct: pctOrders,
      ),
      _KpiCard(
        icon: Icons.euro_outlined,
        label: AppStrings.analyticsRevenue,
        value: '€${revenueInRange.toStringAsFixed(2)}',
        color: HelpiTheme.statusActiveText,
        bgColor: HelpiTheme.statusActiveBg,
      ),
      _KpiCard(
        icon: Icons.elderly_outlined,
        label: AppStrings.analyticsActiveSeniors,
        value: '$activeSeniorsInRange',
        color: HelpiTheme.accent,
        bgColor: HelpiTheme.pastelTeal,
      ),
    ];

    if (isWide) {
      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }
    return Column(
      children: cards
          .map(
            (c) =>
                Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
          )
          .toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  KPI CARD
// ═══════════════════════════════════════════════════════════════

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    this.pct,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final double? pct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (pct != null) _PercentBadge(pct: pct!),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: HelpiTheme.textSecondary,
            ),
          ),
        ],
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
