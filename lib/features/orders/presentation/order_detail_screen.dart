import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';

/// Order Detail Screen — detalji narudžbe + dodjela studenta.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});
  final OrderModel order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_order.scheduledDate.day.toString().padLeft(2, '0')}.${_order.scheduledDate.month.toString().padLeft(2, '0')}.${_order.scheduledDate.year}';
    final timeStr =
        '${_order.scheduledStart.hour.toString().padLeft(2, '0')}:${_order.scheduledStart.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.orderNumber(_order.orderNumber))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status chip ──
            Row(
              children: [
                Text(
                  AppStrings.orderStatus,
                  style: const TextStyle(
                    fontSize: 14,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                _buildOrderStatusChip(_order.status),
              ],
            ),
            const SizedBox(height: 20),

            // ── Senior info sekcija ──
            _SectionCard(
              title: AppStrings.orderSenior,
              icon: Icons.elderly,
              children: [
                _InfoRow(
                  label: AppStrings.seniorName,
                  value: _order.senior.fullName,
                ),
                _InfoRow(
                  label: AppStrings.seniorPhone,
                  value: _order.senior.phone,
                ),
                _InfoRow(
                  label: AppStrings.seniorAddress,
                  value: _order.senior.address,
                ),
                if (_order.senior.hasOrderer) ...[
                  const Divider(height: 16),
                  Text(
                    AppStrings.ordererInfo,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: HelpiTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    label: AppStrings.seniorName,
                    value: _order.senior.ordererFullName,
                  ),
                  if (_order.senior.ordererPhone != null)
                    _InfoRow(
                      label: AppStrings.seniorPhone,
                      value: _order.senior.ordererPhone!,
                    ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // ── Student info / dodjela ──
            _SectionCard(
              title: AppStrings.orderStudent,
              icon: Icons.school,
              children: [
                if (_order.student != null) ...[
                  _InfoRow(
                    label: AppStrings.studentName,
                    value: _order.student!.fullName,
                  ),
                  _InfoRow(
                    label: AppStrings.studentPhone,
                    value: _order.student!.phone,
                  ),
                  _InfoRow(
                    label: AppStrings.studentRating,
                    value:
                        '${_order.student!.avgRating}/5 (${_order.student!.totalReviews})',
                  ),
                  const SizedBox(height: 8),
                  if (_order.status == OrderStatus.active)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showAssignSheet(),
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: Text(AppStrings.reassignStudent),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              HelpiTheme.statusBadgeRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                ] else ...[
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: HelpiTheme.statusCancelledText,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.noStudentAssigned,
                        style: TextStyle(
                          color: HelpiTheme.statusCancelledText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAssignSheet(),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: Text(AppStrings.assignStudent),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // ── Detalji narudžbe ──
            _SectionCard(
              title: AppStrings.orderDetails,
              icon: Icons.receipt_long,
              children: [
                _InfoRow(label: AppStrings.orderDate, value: dateStr),
                _InfoRow(label: AppStrings.orderTime, value: timeStr),
                _InfoRow(
                  label: AppStrings.orderDuration,
                  value: AppStrings.hoursFormat('${_order.durationHours}'),
                ),
                _InfoRow(
                  label: AppStrings.orderFrequency,
                  value: _frequencyLabel(),
                ),
                _InfoRow(
                  label: AppStrings.seniorAddress,
                  value: _order.address,
                ),
                if (_order.notes != null && _order.notes!.isNotEmpty)
                  _InfoRow(label: AppStrings.orderNotes, value: _order.notes!),
              ],
            ),
            const SizedBox(height: 12),

            // ── Usluge ──
            _SectionCard(
              title: AppStrings.orderServices,
              icon: Icons.work_outline,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _order.services.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: HelpiTheme.chipBg,
                        borderRadius: BorderRadius.circular(
                          HelpiTheme.pillRadius,
                        ),
                      ),
                      child: Text(
                        _serviceLabel(s),
                        style: const TextStyle(
                          fontSize: 14,
                          color: HelpiTheme.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Dani (za recurring) ──
            if (_order.dayEntries.isNotEmpty) ...[
              _SectionCard(
                title: AppStrings.orderDate,
                icon: Icons.date_range,
                children: _order.dayEntries.map((entry) {
                  final dayName = _dayName(entry.dayOfWeek);
                  final startStr =
                      '${entry.startTime.hour.toString().padLeft(2, '0')}:${entry.startTime.minute.toString().padLeft(2, '0')}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            dayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '$startStr  ·  ${entry.durationHours}h',
                          style: const TextStyle(
                            fontSize: 14,
                            color: HelpiTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  ASSIGN STUDENT BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════
  void _showAssignSheet() {
    // Filter available students based on availability
    final availableStudents = MockData.students
        .where((s) => s.isActive && s.contractStatus == ContractStatus.active)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(HelpiTheme.bottomSheetRadius),
        ),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (ctx, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Handle ──
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: HelpiTheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.suggestedStudents,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Student list ──
                  Expanded(
                    child: availableStudents.isEmpty
                        ? Center(
                            child: Text(
                              AppStrings.noStudentsFound,
                              style: const TextStyle(
                                color: HelpiTheme.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollCtrl,
                            itemCount: availableStudents.length,
                            itemBuilder: (ctx, i) {
                              final student = availableStudents[i];
                              return _StudentAssignCard(
                                student: student,
                                onAssign: () => _assignStudent(student, ctx),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _assignStudent(StudentModel student, BuildContext sheetContext) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        title: Text(AppStrings.confirm),
        content: Text(AppStrings.assignConfirm(student.fullName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(sheetContext);
              setState(() {
                _order = OrderModel(
                  id: _order.id,
                  orderNumber: _order.orderNumber,
                  senior: _order.senior,
                  student: student,
                  status: OrderStatus.active,
                  frequency: _order.frequency,
                  services: _order.services,
                  createdAt: _order.createdAt,
                  scheduledDate: _order.scheduledDate,
                  scheduledStart: _order.scheduledStart,
                  durationHours: _order.durationHours,
                  notes: _order.notes,
                  address: _order.address,
                  endDate: _order.endDate,
                  dayEntries: _order.dayEntries,
                );
              });
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildOrderStatusChip(OrderStatus status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(HelpiTheme.chipRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _frequencyLabel() {
    switch (_order.frequency) {
      case FrequencyType.oneTime:
        return AppStrings.oneTime;
      case FrequencyType.recurring:
        return AppStrings.recurring;
      case FrequencyType.recurringWithEnd:
        if (_order.endDate != null) {
          final d = _order.endDate!;
          return AppStrings.recurringWithEnd(
            '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}',
          );
        }
        return AppStrings.recurring;
    }
  }

  String _serviceLabel(ServiceType type) {
    switch (type) {
      case ServiceType.shopping:
        return AppStrings.serviceShopping;
      case ServiceType.houseHelp:
        return AppStrings.serviceHouseHelp;
      case ServiceType.companionship:
        return AppStrings.serviceCompanionship;
      case ServiceType.walk:
        return AppStrings.serviceWalk;
      case ServiceType.escort:
        return AppStrings.serviceEscort;
      case ServiceType.other:
        return AppStrings.serviceOther;
    }
  }

  String _dayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return AppStrings.dayMonFull;
      case 2:
        return AppStrings.dayTueFull;
      case 3:
        return AppStrings.dayWedFull;
      case 4:
        return AppStrings.dayThuFull;
      case 5:
        return AppStrings.dayFriFull;
      case 6:
        return AppStrings.daySatFull;
      case 7:
        return AppStrings.daySunFull;
      default:
        return '';
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  SECTION CARD
// ═══════════════════════════════════════════════════════════════
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              Icon(icon, size: 20, color: HelpiTheme.accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HelpiTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  INFO ROW
// ═══════════════════════════════════════════════════════════════
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: HelpiTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STUDENT ASSIGN CARD (bottom sheet)
// ═══════════════════════════════════════════════════════════════
class _StudentAssignCard extends StatelessWidget {
  const _StudentAssignCard({required this.student, required this.onAssign});
  final StudentModel student;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiTheme.border),
      ),
      child: Row(
        children: [
          // ── Avatar ──
          Container(
            width: 44,
            height: 44,
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
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Info ──
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
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: HelpiTheme.starYellow,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${student.avgRating}  ·  ${student.completedJobs} ${AppStrings.studentCompletedJobs.toLowerCase()}',
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

          // ── Assign button ──
          ElevatedButton(
            onPressed: onAssign,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  HelpiTheme.statusBadgeRadius,
                ),
              ),
            ),
            child: Text(
              AppStrings.assignStudent,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
