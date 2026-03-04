import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/widgets/contact_actions.dart';

/// Order Detail Screen — detalji narudžbe + dodjela studenta.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});
  final OrderModel order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel _order;
  bool _sessionsExpanded = true;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_order.scheduledDate.day.toString().padLeft(2, '0')}.${_order.scheduledDate.month.toString().padLeft(2, '0')}.${_order.scheduledDate.year}';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                AppStrings.orderNumber(_order.orderNumber),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildOrderStatusChip(_order.status),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Orderer (if exists) ──
            if (_order.senior.hasOrderer) ...[
              _SectionCard(
                title: AppStrings.seniorOrdererTitle,
                icon: Icons.people,
                children: [
                  _InfoRow(
                    label: AppStrings.seniorOrdererFirstName,
                    value: _order.senior.ordererFirstName ?? '',
                  ),
                  if (_order.senior.ordererLastName != null)
                    _InfoRow(
                      label: AppStrings.seniorOrdererLastName,
                      value: _order.senior.ordererLastName!,
                    ),
                  if (_order.senior.ordererEmail != null)
                    _InfoRow(
                      label: AppStrings.seniorOrdererEmail,
                      value: _order.senior.ordererEmail!,
                      trailing: EmailCopyButton(
                        email: _order.senior.ordererEmail!,
                      ),
                    ),
                  if (_order.senior.ordererPhone != null)
                    _InfoRow(
                      label: AppStrings.seniorOrdererPhone,
                      value: _order.senior.ordererPhone!,
                      trailing: PhoneCallButton(
                        phone: _order.senior.ordererPhone!,
                      ),
                    ),
                  if (_order.senior.ordererAddress != null)
                    _InfoRow(
                      label: AppStrings.seniorOrdererAddress,
                      value: _order.senior.ordererAddress!,
                    ),
                  if (_order.senior.ordererGender != null)
                    _InfoRow(
                      label: AppStrings.seniorOrdererGender,
                      value: _order.senior.ordererGender == Gender.male
                          ? AppStrings.genderMale
                          : AppStrings.genderFemale,
                    ),
                  if (_order.senior.ordererDateOfBirth != null)
                    _InfoRow(
                      label: AppStrings.seniorOrdererDob,
                      value:
                          '${_order.senior.ordererDateOfBirth!.day.toString().padLeft(2, '0')}.${_order.senior.ordererDateOfBirth!.month.toString().padLeft(2, '0')}.${_order.senior.ordererDateOfBirth!.year}.',
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // ── Service user (senior) ──
            _SectionCard(
              title: AppStrings.seniorServiceUser,
              icon: Icons.elderly,
              children: [
                _InfoRow(
                  label: AppStrings.seniorFirstName,
                  value: _order.senior.firstName,
                ),
                _InfoRow(
                  label: AppStrings.seniorLastName,
                  value: _order.senior.lastName,
                ),
                if (!_order.senior.hasOrderer)
                  _InfoRow(
                    label: AppStrings.seniorOrdererEmail,
                    value: _order.senior.email,
                    trailing: EmailCopyButton(email: _order.senior.email),
                  ),
                _InfoRow(
                  label: AppStrings.seniorPhone,
                  value: _order.senior.phone,
                  trailing: PhoneCallButton(phone: _order.senior.phone),
                ),
                _InfoRow(
                  label: AppStrings.seniorAddress,
                  value: _order.senior.address,
                ),
                _InfoRow(
                  label: AppStrings.seniorOrdererGender,
                  value: _order.senior.gender == Gender.male
                      ? AppStrings.genderMale
                      : AppStrings.genderFemale,
                ),
                _InfoRow(
                  label: AppStrings.seniorOrdererDob,
                  value:
                      '${_order.senior.dateOfBirth.day.toString().padLeft(2, '0')}.${_order.senior.dateOfBirth.month.toString().padLeft(2, '0')}.${_order.senior.dateOfBirth.year}.',
                ),
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
                    label: AppStrings.studentFirstName,
                    value: _order.student!.firstName,
                  ),
                  _InfoRow(
                    label: AppStrings.studentLastName,
                    value: _order.student!.lastName,
                  ),
                  _InfoRow(
                    label: AppStrings.studentEmail,
                    value: _order.student!.email,
                    trailing: EmailCopyButton(email: _order.student!.email),
                  ),
                  _InfoRow(
                    label: AppStrings.studentPhone,
                    value: _order.student!.phone,
                    trailing: PhoneCallButton(phone: _order.student!.phone),
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
                      ),
                    ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.person_off_outlined,
                            size: 36,
                            color: HelpiTheme.border,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.noStudentAssigned,
                            style: const TextStyle(
                              color: HelpiTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAssignSheet(),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: Text(AppStrings.assignStudent),
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

                // ── Usluge ──
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          AppStrings.orderServices,
                          style: const TextStyle(
                            fontSize: 13,
                            color: HelpiTheme.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _order.services.map((s) {
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Termini (sessions) ──
            if (_order.sessions.isNotEmpty) _buildSessionsSection(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TERMINI (SESSIONS) SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSessionsSection() {
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
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _sessionsExpanded = !_sessionsExpanded);
            },
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 20,
                  color: HelpiTheme.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.sessionsTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HelpiTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  _sessionsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: HelpiTheme.textSecondary,
                ),
              ],
            ),
          ),
          if (_order.frequency != FrequencyType.oneTime) ...[
            const SizedBox(height: 6),
            Text(
              AppStrings.sessionsMonthlySubtitle,
              style: const TextStyle(
                fontSize: 12,
                color: HelpiTheme.textSecondary,
              ),
            ),
          ],
          if (_sessionsExpanded) ...[
            const SizedBox(height: 16),
            ..._order.sessions.asMap().entries.map((mapEntry) {
              final isLast = mapEntry.key == _order.sessions.length - 1;
              final session = mapEntry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: _buildSessionCard(session),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    final isCompleted = session.status == SessionStatus.completed;
    final isCancelled = session.status == SessionStatus.cancelled;

    final dateStr =
        '${_dayName(session.weekday)}, '
        '${session.date.day.toString().padLeft(2, '0')}.'
        '${session.date.month.toString().padLeft(2, '0')}.'
        '${session.date.year}.';

    final timeStr =
        '${session.startTime.hour.toString().padLeft(2, '0')}:'
        '${session.startTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCancelled ? const Color(0xFFFAFAFA) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HelpiTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: date + status badge
          Row(
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle
                    : isCancelled
                    ? Icons.cancel
                    : Icons.schedule,
                size: 18,
                color: isCompleted
                    ? HelpiTheme.statusActiveText
                    : isCancelled
                    ? HelpiTheme.primary
                    : const Color(0xFF1976D2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateStr,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isCancelled
                        ? HelpiTheme.textSecondary
                        : HelpiTheme.textPrimary,
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              _sessionStatusBadge(session.status),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: time · duration
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              '$timeStr  ·  ${session.durationHours}h',
              style: const TextStyle(
                fontSize: 13,
                color: HelpiTheme.textSecondary,
              ),
            ),
          ),

          // Row 3: student name
          if (session.studentName != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: HelpiTheme.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    session.studentName!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: HelpiTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Row 4: action buttons (only for upcoming)
          if (session.status == SessionStatus.upcoming) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Row(
                children: [
                  _SessionActionButton(
                    icon: Icons.edit_calendar,
                    label: AppStrings.sessionReschedule,
                    color: HelpiTheme.accent,
                    onTap: () => _showRescheduleSheet(session),
                  ),
                  const SizedBox(width: 12),
                  _SessionActionButton(
                    icon: Icons.cancel_outlined,
                    label: AppStrings.sessionCancel,
                    color: HelpiTheme.primary,
                    onTap: () => _confirmCancelSession(session),
                  ),
                ],
              ),
            ),
          ],

          // Row 4b: reactivate button (only for cancelled)
          if (session.status == SessionStatus.cancelled) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: _SessionActionButton(
                icon: Icons.replay,
                label: AppStrings.sessionReactivate,
                color: const Color(0xFF1976D2),
                onTap: () => _confirmReactivateSession(session),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sessionStatusBadge(SessionStatus status) {
    final String label;
    final Color textColor;
    final Color bgColor;

    switch (status) {
      case SessionStatus.upcoming:
        label = AppStrings.sessionStatusUpcoming;
        textColor = const Color(0xFF1976D2);
        bgColor = const Color(0xFFE3F2FD);
      case SessionStatus.completed:
        label = AppStrings.sessionStatusCompleted;
        textColor = HelpiTheme.statusActiveText;
        bgColor = HelpiTheme.statusActiveBg;
      case SessionStatus.cancelled:
        label = AppStrings.sessionStatusCancelled;
        textColor = HelpiTheme.statusCancelledText;
        bgColor = HelpiTheme.statusCancelledBg;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(HelpiTheme.statusBadgeRadius),
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

  // ═══════════════════════════════════════════════════════════════
  //  SESSION ACTIONS — CANCEL & RESCHEDULE
  // ═══════════════════════════════════════════════════════════════

  void _updateSession(SessionModel oldSession, SessionModel newSession) {
    final updatedSessions = _order.sessions.map((s) {
      return s.id == oldSession.id ? newSession : s;
    }).toList();

    setState(() {
      _order = OrderModel(
        id: _order.id,
        orderNumber: _order.orderNumber,
        senior: _order.senior,
        student: _order.student,
        status: _order.status,
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
        sessions: updatedSessions,
      );
      final idx = MockData.orders.indexWhere((o) => o.id == _order.id);
      if (idx != -1) MockData.orders[idx] = _order;
    });
  }

  void _confirmCancelSession(SessionModel session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        title: Text(AppStrings.sessionCancel),
        content: Text(AppStrings.sessionCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateSession(
                session,
                session.copyWith(status: SessionStatus.cancelled),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HelpiTheme.primary,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  void _confirmReactivateSession(SessionModel session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        title: Text(AppStrings.sessionReactivate),
        content: Text(AppStrings.sessionReactivateConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateSession(
                session,
                session.copyWith(status: SessionStatus.upcoming),
              );
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

  void _showRescheduleSheet(SessionModel session) {
    DateTime selectedDate = session.date;
    TimeOfDay selectedTime = session.startTime;
    String? selectedStudentName = session.studentName;

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
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final dateLabel =
                '${selectedDate.day.toString().padLeft(2, '0')}.'
                '${selectedDate.month.toString().padLeft(2, '0')}.'
                '${selectedDate.year}';
            final timeLabel =
                '${selectedTime.hour.toString().padLeft(2, '0')}:'
                '${selectedTime.minute.toString().padLeft(2, '0')}';

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    AppStrings.sessionRescheduleTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Date picker row ──
                  _RescheduleRow(
                    icon: Icons.calendar_today,
                    label: AppStrings.sessionNewDate,
                    value: dateLabel,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── Time picker row ──
                  _RescheduleRow(
                    icon: Icons.access_time,
                    label: AppStrings.sessionNewTime,
                    value: timeLabel,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setSheetState(() => selectedTime = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── Student selector (scrollable list) ──
                  Text(
                    AppStrings.sessionSelectStudent,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: HelpiTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        // "Keep current" option
                        if (session.studentName != null)
                          _StudentRadioTile(
                            name: session.studentName!,
                            subtitle: AppStrings.sessionKeepCurrentStudent,
                            isSelected:
                                selectedStudentName == session.studentName,
                            onTap: () {
                              setSheetState(() {
                                selectedStudentName = session.studentName;
                              });
                            },
                          ),
                        // Available students
                        ...availableStudents
                            .where((s) => s.fullName != session.studentName)
                            .map(
                              (student) => _StudentRadioTile(
                                name: student.fullName,
                                subtitle:
                                    '★ ${student.avgRating}  ·  ${student.completedJobs} poslova',
                                isSelected:
                                    selectedStudentName == student.fullName,
                                onTap: () {
                                  setSheetState(() {
                                    selectedStudentName = student.fullName;
                                  });
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Confirm button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (!context.mounted) return;
                        _updateSession(
                          session,
                          session.copyWith(
                            date: selectedDate,
                            weekday: selectedDate.weekday,
                            startTime: selectedTime,
                            studentName: () => selectedStudentName,
                          ),
                        );
                      },
                      child: Text(AppStrings.confirm),
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
                  sessions: _order.sessions,
                );
                // Persist to MockData so all screens see the change
                final idx = MockData.orders.indexWhere(
                  (o) => o.id == _order.id,
                );
                if (idx != -1) MockData.orders[idx] = _order;
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
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
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
  const _InfoRow({required this.label, required this.value, this.trailing});
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: trailing != null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: HelpiTheme.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
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
          GestureDetector(
            onTap: onAssign,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: HelpiTheme.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: HelpiTheme.accent.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_add,
                    size: 14,
                    color: HelpiTheme.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.assignStudent,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HelpiTheme.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SESSION ACTION BUTTON (small tappable label)
// ═══════════════════════════════════════════════════════════════
class _SessionActionButton extends StatelessWidget {
  const _SessionActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
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
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  RESCHEDULE ROW (date / time picker trigger)
// ═══════════════════════════════════════════════════════════════
class _RescheduleRow extends StatelessWidget {
  const _RescheduleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HelpiTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: HelpiTheme.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: HelpiTheme.textSecondary,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: HelpiTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STUDENT RADIO TILE (for reschedule student selector)
// ═══════════════════════════════════════════════════════════════
class _StudentRadioTile extends StatelessWidget {
  const _StudentRadioTile({
    required this.name,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? HelpiTheme.pastelTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? HelpiTheme.accent : HelpiTheme.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: isSelected ? HelpiTheme.accent : HelpiTheme.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: HelpiTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
