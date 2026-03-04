import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/features/orders/presentation/order_detail_screen.dart';
import 'package:helpi_admin/features/students/presentation/student_detail_screen.dart';

/// Admin Dashboard — pregled statistika i nedavnih narudžbi.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 900;

    // Grid columns: >=1200 → 3, >=900 → 2, else 1
    final gridColumns = screenWidth >= 1200 ? 3 : (screenWidth >= 900 ? 2 : 1);

    final processingCount = MockData.orders
        .where((o) => o.status == OrderStatus.processing)
        .length;
    final activeCount = MockData.orders
        .where((o) => o.status == OrderStatus.active)
        .length;
    final expiringStudents = MockData.students
        .where(
          (s) =>
              s.contractStatus == ContractStatus.expiring ||
              s.contractStatus == ContractStatus.expired,
        )
        .toList();

    // ── Studenti koji su radili ovaj mjesec ──
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1);
    final activeStudentMap =
        <String, ({StudentModel student, int sessions, int hours})>{};
    for (final order in MockData.orders) {
      if (order.student == null) continue;
      for (final session in order.sessions) {
        if (session.status == SessionStatus.cancelled) continue;
        if (!session.date.isBefore(monthStart) &&
            session.date.isBefore(monthEnd)) {
          final sid = order.student!.id;
          final prev = activeStudentMap[sid];
          activeStudentMap[sid] = (
            student: order.student!,
            sessions: (prev?.sessions ?? 0) + 1,
            hours: (prev?.hours ?? 0) + session.durationHours,
          );
        }
      }
    }
    final activeStudentsList = activeStudentMap.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.dashboardTitle),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          const NotificationBell(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── KPI kartice ──
            if (isWide)
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.hourglass_top,
                      label: AppStrings.ordersProcessing,
                      value: '$processingCount',
                      color: HelpiTheme.statusProcessingText,
                      bgColor: HelpiTheme.statusProcessingBg,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.play_circle_outline,
                      label: AppStrings.activeOrders,
                      value: '$activeCount',
                      color: HelpiTheme.accent,
                      bgColor: HelpiTheme.pastelTeal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.school_outlined,
                      label: AppStrings.totalStudents,
                      value: '${MockData.students.length}',
                      color: HelpiTheme.accent,
                      bgColor: HelpiTheme.pastelTeal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.elderly_outlined,
                      label: AppStrings.totalSeniors,
                      value: '${MockData.seniors.length}',
                      color: HelpiTheme.accent,
                      bgColor: HelpiTheme.pastelTeal,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.hourglass_top,
                          label: AppStrings.ordersProcessing,
                          value: '$processingCount',
                          color: HelpiTheme.statusProcessingText,
                          bgColor: HelpiTheme.statusProcessingBg,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.play_circle_outline,
                          label: AppStrings.activeOrders,
                          value: '$activeCount',
                          color: HelpiTheme.accent,
                          bgColor: HelpiTheme.pastelTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.school_outlined,
                          label: AppStrings.totalStudents,
                          value: '${MockData.students.length}',
                          color: HelpiTheme.accent,
                          bgColor: HelpiTheme.pastelTeal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.elderly_outlined,
                          label: AppStrings.totalSeniors,
                          value: '${MockData.seniors.length}',
                          color: HelpiTheme.accent,
                          bgColor: HelpiTheme.pastelTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // ── Narudžbe u obradi ──
            _SectionHeader(title: AppStrings.processingOrders),
            const SizedBox(height: 8),
            _buildCardSection(
              gridColumns: gridColumns,
              children: MockData.orders
                  .where((o) => o.status == OrderStatus.processing)
                  .map((order) => _RecentOrderCard(order: order, theme: theme))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // ── Aktivni studenti ovaj mjesec ──
            if (activeStudentsList.isNotEmpty) ...[
              _SectionHeader(title: AppStrings.activeStudentsThisMonth),
              const SizedBox(height: 8),
              _buildCardSection(
                gridColumns: gridColumns,
                children: activeStudentsList
                    .map(
                      (entry) => _ActiveStudentCard(
                        student: entry.student,
                        sessionCount: entry.sessions,
                        totalHours: entry.hours,
                        theme: theme,
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),

            // ── Ugovori koji ističu ──
            if (expiringStudents.isNotEmpty) ...[
              _SectionHeader(title: AppStrings.expiringContracts),
              const SizedBox(height: 8),
              _buildCardSection(
                gridColumns: gridColumns,
                children: expiringStudents
                    .map(
                      (student) =>
                          _ExpiringContractCard(student: student, theme: theme),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a list or grid of cards depending on [_isGridView].
  Widget _buildCardSection({
    required int gridColumns,
    required List<Widget> children,
  }) {
    if (!_isGridView || gridColumns <= 1) {
      return Column(children: children);
    }

    // Build rows of [gridColumns] items
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += gridColumns) {
      final end = (i + gridColumns < children.length)
          ? i + gridColumns
          : children.length;
      final rowItems = children.sublist(i, end);
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i + gridColumns < children.length ? 10 : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = 0; j < gridColumns; j++) ...[
                if (j > 0) const SizedBox(width: 10),
                Expanded(
                  child: j < rowItems.length ? rowItems[j] : const SizedBox(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
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
//  SECTION HEADER
// ═══════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: HelpiTheme.textPrimary,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  RECENT ORDER CARD (matches _OrderListCard from orders_screen)
// ═══════════════════════════════════════════════════════════════
class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard({required this.order, required this.theme});
  final OrderModel order;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final dateStr = formatDate(order.scheduledDate);
    final timeStr = formatTimeOfDay(order.scheduledStart);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          border: Border.all(color: HelpiTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: order number + status ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.orderNumber(order.orderNumber),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                StatusBadge.order(order.status),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Details + Arrow ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Senior ──
                      Row(
                        children: [
                          const Icon(
                            Icons.elderly,
                            size: 18,
                            color: HelpiTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.senior.fullName,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // ── Student ──
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 18,
                            color: order.student != null
                                ? HelpiTheme.textSecondary
                                : HelpiTheme.statusCancelledText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.student?.fullName ??
                                AppStrings.noStudentAssigned,
                            style: TextStyle(
                              fontSize: 14,
                              color: order.student != null
                                  ? HelpiTheme.textPrimary
                                  : HelpiTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // ── Date + Time ──
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: HelpiTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$dateStr  $timeStr  ·  ${order.durationHours}h',
                            style: const TextStyle(
                              fontSize: 13,
                              color: HelpiTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ── Service chips ──
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: order.services
                            .map((s) => ServiceChip(type: s))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                // ── Arrow ──
                const Icon(
                  Icons.chevron_right,
                  color: HelpiTheme.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  EXPIRING CONTRACT CARD (matches _StudentCard style)
// ═══════════════════════════════════════════════════════════════
class _ExpiringContractCard extends StatelessWidget {
  const _ExpiringContractCard({required this.student, required this.theme});
  final StudentModel student;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isExpired = student.contractStatus == ContractStatus.expired;
    final dateStr = student.contractExpiryDate != null
        ? formatDate(student.contractExpiryDate!)
        : '';

    final (Color chipTextColor, Color chipBgColor, String chipLabel) = isExpired
        ? (
            HelpiTheme.statusCancelledText,
            HelpiTheme.statusCancelledBg,
            AppStrings.contractExpired,
          )
        : (
            HelpiTheme.statusProcessingText,
            HelpiTheme.statusProcessingBg,
            AppStrings.contractExpires(dateStr),
          );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDetailScreen(student: student),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          border: Border.all(color: HelpiTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Avatar + Name + Chip ──
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: HelpiTheme.pastelTeal,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      student.firstName[0] + student.lastName[0],
                      style: const TextStyle(
                        color: HelpiTheme.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    student.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: chipBgColor,
                    border: Border.all(
                      color: chipTextColor.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(
                      HelpiTheme.statusBadgeRadius,
                    ),
                  ),
                  child: Text(
                    chipLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: chipTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Details + Chevron ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Rating + Jobs ──
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: HelpiTheme.starYellow,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${student.avgRating}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${student.completedJobs} ${AppStrings.studentCompletedJobs.toLowerCase()}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: HelpiTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ── Phone ──
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: HelpiTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              student.phone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: HelpiTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          PhoneCallButton(phone: student.phone),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ── Email ──
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: HelpiTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              student.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: HelpiTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          EmailCopyButton(email: student.email),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Chevron ──
                const Icon(
                  Icons.chevron_right,
                  color: HelpiTheme.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ACTIVE STUDENT THIS MONTH CARD (matches _StudentCard style)
// ═══════════════════════════════════════════════════════════════
class _ActiveStudentCard extends StatelessWidget {
  const _ActiveStudentCard({
    required this.student,
    required this.sessionCount,
    required this.totalHours,
    required this.theme,
  });

  final StudentModel student;
  final int sessionCount;
  final int totalHours;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDetailScreen(student: student),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          border: Border.all(color: HelpiTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Avatar + Name + Contract chip ──
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: HelpiTheme.pastelTeal,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      student.firstName[0] + student.lastName[0],
                      style: const TextStyle(
                        color: HelpiTheme.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    student.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge.contract(student.contractStatus),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Details + Chevron ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Rating + Sessions ──
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: HelpiTheme.starYellow,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${student.avgRating}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$sessionCount ${AppStrings.sessionsCount}  ·  $totalHours ${AppStrings.hoursCount}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: HelpiTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ── Phone ──
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: HelpiTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              student.phone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: HelpiTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          PhoneCallButton(phone: student.phone),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ── Email ──
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: HelpiTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              student.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: HelpiTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          EmailCopyButton(email: student.email),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Chevron ──
                const Icon(
                  Icons.chevron_right,
                  color: HelpiTheme.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
