import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';

/// Admin Analytics — KPI overview + weekly/monthly charts + avg rating.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late DateTime _currentWeekStart;
  late DateTime _currentMonthStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
    _currentMonthStart = DateTime(now.year, now.month);
  }

  // ═══════════════════════════════════════════════════════════
  //  DATA HELPERS
  // ═══════════════════════════════════════════════════════════

  double _hoursInRange(List<OrderModel> orders, DateTime from, DateTime to) {
    double sum = 0;
    for (final order in orders) {
      for (final s in order.sessions) {
        if (s.status == SessionStatus.cancelled) continue;
        final d = DateTime(s.date.year, s.date.month, s.date.day);
        if (!d.isBefore(from) && d.isBefore(to)) {
          sum += s.durationHours;
        }
      }
    }
    return sum;
  }

  List<double> _weeklyHours(List<OrderModel> orders, DateTime weekStart) {
    final result = List.filled(7, 0.0);
    final weekEnd = weekStart.add(const Duration(days: 7));
    for (final order in orders) {
      for (final s in order.sessions) {
        if (s.status == SessionStatus.cancelled) continue;
        final d = DateTime(s.date.year, s.date.month, s.date.day);
        if (!d.isBefore(weekStart) && d.isBefore(weekEnd)) {
          final dayIndex = d.difference(weekStart).inDays;
          if (dayIndex >= 0 && dayIndex < 7) {
            result[dayIndex] += s.durationHours;
          }
        }
      }
    }
    return result;
  }

  List<_WeekRange> _monthlyWeeks(List<OrderModel> orders, DateTime monthStart) {
    final weeks = <_WeekRange>[];
    var ws = monthStart.subtract(Duration(days: monthStart.weekday - 1));
    final nextMonth = (monthStart.month == 12)
        ? DateTime(monthStart.year + 1, 1)
        : DateTime(monthStart.year, monthStart.month + 1);

    while (ws.isBefore(nextMonth)) {
      final we = ws.add(const Duration(days: 7));
      final hours = _hoursInRange(orders, ws, we);
      weeks.add(_WeekRange(from: ws, to: we, hours: hours));
      ws = we;
    }
    return weeks;
  }

  double _avgStudentRating(List<StudentModel> students) {
    final rated = students.where((s) => s.avgRating > 0).toList();
    if (rated.isEmpty) return 0;
    return rated.fold(0.0, (sum, s) => sum + s.avgRating) / rated.length;
  }

  double _pctChange(double current, double prev) {
    if (prev == 0 && current == 0) return 0;
    if (prev == 0) return 100;
    return ((current - prev) / prev) * 100;
  }

  void _prevWeek() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  void _prevMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      final m = _currentMonthStart.month;
      final y = _currentMonthStart.year;
      _currentMonthStart = m == 1 ? DateTime(y - 1, 12) : DateTime(y, m - 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      final m = _currentMonthStart.month;
      final y = _currentMonthStart.year;
      _currentMonthStart = m == 12 ? DateTime(y + 1, 1) : DateTime(y, m + 1);
    });
  }

  String _fmtDateCompact(DateTime d) => '${d.day}.${d.month}.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 900;

    final allOrders = ref.watch(ordersProvider);
    final allStudents = ref.watch(studentsProvider);
    final allSeniors = ref.watch(seniorsProvider);

    final processingCount = allOrders
        .where((o) => o.status == OrderStatus.processing)
        .length;
    final activeCount = allOrders
        .where((o) => o.status == OrderStatus.active)
        .length;

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
            // ── KPI kartice ──
            _buildKpiRow(
              isWide: isWide,
              processingCount: processingCount,
              activeCount: activeCount,
              studentCount: allStudents.length,
              seniorCount: allSeniors.length,
            ),
            const SizedBox(height: 24),

            // ── Charts ──
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildWeeklyChart(theme, allOrders)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMonthlyChart(theme, allOrders)),
                ],
              )
            else ...[
              _buildWeeklyChart(theme, allOrders),
              const SizedBox(height: 16),
              _buildMonthlyChart(theme, allOrders),
            ],

            const SizedBox(height: 24),

            // ── Average student rating ──
            _buildRatingSection(theme, allStudents),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  KPI ROW
  // ═══════════════════════════════════════════════════════════

  Widget _buildKpiRow({
    required bool isWide,
    required int processingCount,
    required int activeCount,
    required int studentCount,
    required int seniorCount,
  }) {
    final cards = [
      _KpiCard(
        icon: Icons.hourglass_top,
        label: AppStrings.ordersProcessing,
        value: '$processingCount',
        color: HelpiTheme.statusProcessingText,
        bgColor: HelpiTheme.statusProcessingBg,
      ),
      _KpiCard(
        icon: Icons.play_circle_outline,
        label: AppStrings.activeOrders,
        value: '$activeCount',
        color: HelpiTheme.statusActiveText,
        bgColor: HelpiTheme.statusActiveBg,
      ),
      _KpiCard(
        icon: Icons.school_outlined,
        label: AppStrings.totalStudents,
        value: '$studentCount',
        color: HelpiTheme.accent,
        bgColor: HelpiTheme.pastelTeal,
      ),
      _KpiCard(
        icon: Icons.elderly_outlined,
        label: AppStrings.totalSeniors,
        value: '$seniorCount',
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
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  WEEKLY BAR CHART
  // ═══════════════════════════════════════════════════════════

  Widget _buildWeeklyChart(ThemeData theme, List<OrderModel> orders) {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    final dailyHours = _weeklyHours(orders, _currentWeekStart);
    final totalHours = dailyHours.fold(0.0, (a, b) => a + b);
    final maxH = dailyHours.reduce((a, b) => a > b ? a : b);

    final prevStart = _currentWeekStart.subtract(const Duration(days: 7));
    final prevHours = _weeklyHours(orders, prevStart);
    final prevTotal = prevHours.fold(0.0, (a, b) => a + b);
    final pct = _pctChange(totalHours, prevTotal);

    final dayLabels = ['P', 'U', 'S', 'Č', 'P', 'S', 'N'];

    return _ChartCard(
      title: AppStrings.analyticsWeeklyTitle,
      periodLabel:
          '${_fmtDateCompact(_currentWeekStart)} – ${_fmtDateCompact(weekEnd)}',
      onPrev: _prevWeek,
      onNext: _nextWeek,
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final h = dailyHours[i];
                final barRatio = maxH > 0 ? h / maxH : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (h > 0)
                          Text(
                            '${h.toStringAsFixed(0)}h',
                            style: const TextStyle(
                              fontSize: 10,
                              color: HelpiTheme.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: maxH > 0 ? 100 * barRatio : 0,
                          constraints: const BoxConstraints(minHeight: 4),
                          decoration: BoxDecoration(
                            color: h > 0
                                ? HelpiTheme.accent
                                : HelpiTheme.border,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayLabels[i],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: HelpiTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          _ComparisonRow(pct: pct),
          const SizedBox(height: 8),
          _TotalRow(
            label: AppStrings.analyticsTotalHours(
              totalHours.toStringAsFixed(1),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  MONTHLY BAR CHART
  // ═══════════════════════════════════════════════════════════

  Widget _buildMonthlyChart(ThemeData theme, List<OrderModel> orders) {
    final weeks = _monthlyWeeks(orders, _currentMonthStart);
    final totalHours = weeks.fold(0.0, (s, w) => s + w.hours);
    final maxH = weeks.isEmpty
        ? 1.0
        : weeks.map((w) => w.hours).reduce((a, b) => a > b ? a : b);

    final prevMonth = _currentMonthStart.month == 1
        ? DateTime(_currentMonthStart.year - 1, 12)
        : DateTime(_currentMonthStart.year, _currentMonthStart.month - 1);
    final prevWeeks = _monthlyWeeks(orders, prevMonth);
    final prevTotal = prevWeeks.fold(0.0, (s, w) => s + w.hours);
    final pct = _pctChange(totalHours, prevTotal);

    final monthLabel =
        '${AppStrings.monthName(_currentMonthStart.month)} ${_currentMonthStart.year}';

    return _ChartCard(
      title: AppStrings.analyticsMonthlyTitle,
      periodLabel: monthLabel,
      onPrev: _prevMonth,
      onNext: _nextMonth,
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeks.asMap().entries.map((entry) {
                final w = entry.value;
                final barRatio = maxH > 0 ? w.hours / maxH : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (w.hours > 0)
                          Flexible(
                            child: Text(
                              '${w.hours.toStringAsFixed(0)}h',
                              style: const TextStyle(
                                fontSize: 10,
                                color: HelpiTheme.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: maxH > 0 ? 100 * barRatio : 0,
                          constraints: const BoxConstraints(minHeight: 4),
                          decoration: BoxDecoration(
                            color: w.hours > 0
                                ? HelpiTheme.accent
                                : HelpiTheme.border,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _fmtDateCompact(w.from),
                          style: const TextStyle(
                            fontSize: 9,
                            color: HelpiTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _ComparisonRow(pct: pct),
          const SizedBox(height: 8),
          _TotalRow(
            label: AppStrings.analyticsTotalHours(
              totalHours.toStringAsFixed(1),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  AVERAGE RATING SECTION
  // ═══════════════════════════════════════════════════════════

  Widget _buildRatingSection(ThemeData theme, List<StudentModel> students) {
    final avg = _avgStudentRating(students);
    final ratedCount = students.where((s) => s.avgRating > 0).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiTheme.border),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.analyticsRatingTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                avg > 0 ? avg.toStringAsFixed(1) : '-',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: avg > 0 ? HelpiTheme.starYellow : HelpiTheme.border,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (i) {
                      final fill = avg - i;
                      return Icon(
                        fill >= 1
                            ? Icons.star
                            : (fill >= 0.5
                                  ? Icons.star_half
                                  : Icons.star_border),
                        size: 22,
                        color: HelpiTheme.starYellow,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$ratedCount ${AppStrings.totalStudents.toLowerCase()}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: HelpiTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DATA MODEL
// ═══════════════════════════════════════════════════════════════

class _WeekRange {
  const _WeekRange({required this.from, required this.to, required this.hours});
  final DateTime from;
  final DateTime to;
  final double hours;
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
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

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
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
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
//  CHART CARD
// ═══════════════════════════════════════════════════════════════

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.periodLabel,
    required this.onPrev,
    required this.onNext,
    required this.child,
  });

  final String title;
  final String periodLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiTheme.border),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: HelpiTheme.textSecondary,
                ),
                onPressed: onPrev,
                splashRadius: 20,
              ),
              Text(periodLabel, style: theme.textTheme.bodyMedium),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: HelpiTheme.textSecondary,
                ),
                onPressed: onNext,
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  COMPARISON ROW
// ═══════════════════════════════════════════════════════════════

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({required this.pct});
  final double pct;

  @override
  Widget build(BuildContext context) {
    final isUp = pct > 0;
    final isDown = pct < 0;
    final icon = isUp
        ? Icons.trending_up
        : (isDown ? Icons.trending_down : Icons.trending_flat);
    final color = isUp
        ? const Color(0xFF2E7D32)
        : (isDown ? HelpiTheme.statusCancelledText : HelpiTheme.textSecondary);
    final label = pct.abs() < 0.1
        ? AppStrings.analyticsNoChange
        : '${isUp ? '+' : ''}${pct.toStringAsFixed(0)}% ${AppStrings.analyticsPrevPeriod}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TOTAL ROW
// ═══════════════════════════════════════════════════════════════

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: HelpiTheme.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}
