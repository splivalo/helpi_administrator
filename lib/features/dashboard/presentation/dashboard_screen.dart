import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';

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
    final completedCount = MockData.orders
        .where((o) => o.status == OrderStatus.completed)
        .length;
    final expiringStudents = MockData.students
        .where(
          (s) =>
              s.contractStatus == ContractStatus.expiring ||
              s.contractStatus == ContractStatus.expired,
        )
        .toList();

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
                      color: HelpiTheme.statusActiveText,
                      bgColor: HelpiTheme.statusActiveBg,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.check_circle_outline,
                      label: AppStrings.completedOrders,
                      value: '$completedCount',
                      color: HelpiTheme.statusCompletedText,
                      bgColor: HelpiTheme.statusCompletedBg,
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
                      color: HelpiTheme.primary,
                      bgColor: const Color(0xFFFFE8E5),
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
                          color: HelpiTheme.statusActiveText,
                          bgColor: HelpiTheme.statusActiveBg,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.check_circle_outline,
                          label: AppStrings.completedOrders,
                          value: '$completedCount',
                          color: HelpiTheme.statusCompletedText,
                          bgColor: HelpiTheme.statusCompletedBg,
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
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // ── Nedavne narudžbe ──
            _SectionHeader(title: AppStrings.recentOrders),
            const SizedBox(height: 8),
            ...MockData.orders
                .where((o) => o.status == OrderStatus.processing)
                .map((order) => _RecentOrderCard(order: order, theme: theme)),

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
//  RECENT ORDER CARD
// ═══════════════════════════════════════════════════════════════
class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard({required this.order, required this.theme});
  final OrderModel order;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${order.scheduledDate.day.toString().padLeft(2, '0')}.${order.scheduledDate.month.toString().padLeft(2, '0')}.${order.scheduledDate.year}';
    final timeStr =
        '${order.scheduledStart.hour.toString().padLeft(2, '0')}:${order.scheduledStart.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiTheme.border),
      ),
      child: Row(
        children: [
          // ── Senior info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.orderNumber(order.orderNumber),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: HelpiTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.senior.fullName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: HelpiTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: HelpiTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$dateStr  $timeStr',
                      style: const TextStyle(
                        fontSize: 13,
                        color: HelpiTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Status chip ──
          _buildStatusChip(order.status),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(HelpiTheme.chipRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  EXPIRING CONTRACT CARD
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(
          color: isExpired ? HelpiTheme.statusCancelledText : HelpiTheme.border,
        ),
      ),
      child: Row(
        children: [
          // ── Student icon ──
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isExpired
                  ? HelpiTheme.statusCancelledBg
                  : HelpiTheme.statusProcessingBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school,
              color: isExpired
                  ? HelpiTheme.statusCancelledText
                  : HelpiTheme.statusProcessingText,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isExpired
                      ? AppStrings.contractExpired
                      : AppStrings.contractExpires(dateStr),
                  style: TextStyle(
                    fontSize: 13,
                    color: isExpired
                        ? HelpiTheme.statusCancelledText
                        : HelpiTheme.statusProcessingText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // ── Action ──
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  HelpiTheme.statusBadgeRadius,
                ),
              ),
            ),
            child: Text(
              AppStrings.renewContract,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
