import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/widgets/contact_actions.dart';
import 'package:helpi_admin/features/orders/presentation/order_detail_screen.dart';
import 'package:helpi_admin/features/students/presentation/student_detail_screen.dart';

/// Admin Dashboard — pregled statistika i nedavnih narudžbi.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

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
      appBar: AppBar(title: Text(AppStrings.dashboardTitle)),
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
                      label: AppStrings.processingOrders,
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
                          label: AppStrings.processingOrders,
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
            ...MockData.orders
                .where((o) => o.status == OrderStatus.processing)
                .map((order) => _RecentOrderCard(order: order, theme: theme)),

            const SizedBox(height: 24),

            // ── Aktivni studenti ovaj mjesec ──
            if (activeStudentsList.isNotEmpty) ...[
              _SectionHeader(title: AppStrings.activeStudentsThisMonth),
              const SizedBox(height: 8),
              ...activeStudentsList.map(
                (entry) => _ActiveStudentCard(
                  student: entry.student,
                  sessionCount: entry.sessions,
                  totalHours: entry.hours,
                  theme: theme,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Ugovori koji ističu ──
            if (expiringStudents.isNotEmpty) ...[
              _SectionHeader(title: AppStrings.expiringContracts),
              const SizedBox(height: 8),
              ...expiringStudents.map(
                (student) =>
                    _ExpiringContractCard(student: student, theme: theme),
              ),
            ],
          ],
        ),
      ),
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

  String _serviceLabel(ServiceType type) => switch (type) {
    ServiceType.shopping => AppStrings.serviceShopping,
    ServiceType.houseHelp => AppStrings.serviceHouseHelp,
    ServiceType.companionship => AppStrings.serviceCompanionship,
    ServiceType.walk => AppStrings.serviceWalk,
    ServiceType.escort => AppStrings.serviceEscort,
    ServiceType.other => AppStrings.serviceOther,
  };

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${order.scheduledDate.day.toString().padLeft(2, '0')}.${order.scheduledDate.month.toString().padLeft(2, '0')}.${order.scheduledDate.year}';
    final timeStr =
        '${order.scheduledStart.hour.toString().padLeft(2, '0')}:${order.scheduledStart.minute.toString().padLeft(2, '0')}';

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
                _buildStatusChip(order.status),
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
                                  : HelpiTheme.statusCancelledText,
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
                        children: order.services.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: HelpiTheme.textSecondary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: HelpiTheme.textSecondary.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: Text(
                              _serviceLabel(s),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: HelpiTheme.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
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

  Widget _buildStatusChip(OrderStatus status) {
    Color textColor;
    Color bgColor;
    String label;

    switch (status) {
      case OrderStatus.processing:
        textColor = HelpiTheme.statusProcessingText;
        bgColor = HelpiTheme.statusProcessingBg;
        label = AppStrings.statusProcessing;
      case OrderStatus.active:
        textColor = HelpiTheme.statusActiveText;
        bgColor = HelpiTheme.statusActiveBg;
        label = AppStrings.statusActive;
      case OrderStatus.completed:
        textColor = HelpiTheme.statusCompletedText;
        bgColor = HelpiTheme.statusCompletedBg;
        label = AppStrings.statusCompleted;
      case OrderStatus.cancelled:
        textColor = HelpiTheme.statusCancelledText;
        bgColor = HelpiTheme.statusCancelledBg;
        label = AppStrings.statusCancelled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(HelpiTheme.statusBadgeRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
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
        ? '${student.contractExpiryDate!.day.toString().padLeft(2, '0')}.${student.contractExpiryDate!.month.toString().padLeft(2, '0')}.${student.contractExpiryDate!.year}'
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
        child: Row(
          children: [
            // ── Avatar ──
            Container(
              width: 48,
              height: 48,
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
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
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
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: HelpiTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        student.phone,
                        style: const TextStyle(
                          fontSize: 13,
                          color: HelpiTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      PhoneCallButton(phone: student.phone),
                    ],
                  ),
                  const SizedBox(height: 2),
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

            // ── Arrow ──
            const Icon(Icons.chevron_right, color: HelpiTheme.textSecondary),
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

  (Color, Color, String) _contractChip(ContractStatus status) {
    return switch (status) {
      ContractStatus.active => (
        HelpiTheme.statusActiveText,
        HelpiTheme.statusActiveBg,
        AppStrings.contractActive,
      ),
      ContractStatus.expired => (
        HelpiTheme.statusCancelledText,
        HelpiTheme.statusCancelledBg,
        AppStrings.contractExpired,
      ),
      ContractStatus.expiring => (
        HelpiTheme.statusProcessingText,
        HelpiTheme.statusProcessingBg,
        AppStrings.contractExpiring,
      ),
      ContractStatus.none => (
        HelpiTheme.textSecondary,
        HelpiTheme.chipBg,
        AppStrings.contractNone,
      ),
      ContractStatus.deactivated => (
        HelpiTheme.statusCancelledText,
        HelpiTheme.statusCancelledBg,
        AppStrings.contractDeactivated,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (chipTextColor, chipBgColor, chipLabel) = _contractChip(
      student.contractStatus,
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
        child: Row(
          children: [
            // ── Avatar ──
            Container(
              width: 48,
              height: 48,
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
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
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
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: HelpiTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        student.phone,
                        style: const TextStyle(
                          fontSize: 13,
                          color: HelpiTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      PhoneCallButton(phone: student.phone),
                    ],
                  ),
                  const SizedBox(height: 2),
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

            // ── Arrow ──
            const Icon(Icons.chevron_right, color: HelpiTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
