import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/services/preferences_service.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/features/orders/presentation/create_order_screen.dart';

/// Order Detail Screen — detalji narudžbe + dodjela studenta.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});
  final OrderModel order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _prefs = PreferencesService.instance;
  static const _screenKey = 'orderDetail';
  static const _sectionCount = 6;

  late OrderModel _order;
  bool _sessionsExpanded = true;
  late List<int> _sectionOrder;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    final saved = _prefs.getSectionOrder(_screenKey);
    if (saved != null && saved.length == _sectionCount) {
      _sectionOrder = saved;
    } else {
      _sectionOrder = List.generate(_sectionCount, (i) => i);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            StatusBadge.order(_order.status, size: StatusBadgeSize.large),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 22),
            tooltip: AppStrings.editOrderTitle,
            onPressed: _showEditOrderModal,
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_customize, size: 22),
            tooltip: AppStrings.editLayout,
            onPressed: _showReorderSheet,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final allSections = _buildAllSections();
          final sections = <Widget>[
            for (final idx in _sectionOrder) allSections[idx],
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < sections.length; i++) ...[
                  sections[i],
                  if (i < sections.length - 1) const SizedBox(height: 12),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SECTION REORDER HELPERS
  // ─────────────────────────────────────────────────────────

  static List<String> get _sectionLabels => [
    AppStrings.seniorOrdererTitle,
    AppStrings.seniorServiceUser,
    AppStrings.orderStudent,
    AppStrings.orderDetails,
    AppStrings.sessionsTitle,
    AppStrings.adminActions,
  ];

  static const _sectionIcons = [
    Icons.people,
    Icons.elderly,
    Icons.school,
    Icons.receipt_long,
    Icons.calendar_month,
    Icons.admin_panel_settings,
  ];

  List<Widget> _buildAllSections() {
    return [
      _buildOrdererSection(),
      _buildServiceUserSection(),
      _buildStudentSection(),
      _buildOrderDetailsSection(),
      if (_order.sessions.isNotEmpty)
        _buildSessionsSection()
      else
        const SizedBox.shrink(),
      _buildAdminActionsSection(),
    ];
  }

  void _showReorderSheet() {
    final tempOrder = List<int>.from(_sectionOrder);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    Widget buildContent(BuildContext ctx, StateSetter setSheetState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isWide)
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: DragHandle(),
            ),
          const SizedBox(height: 8),
          Text(
            AppStrings.sectionLayoutTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.sectionLayoutHint,
            style: TextStyle(fontSize: 13, color: HelpiTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: _sectionCount * 56.0,
            child: ReorderableListView.builder(
              shrinkWrap: true,
              itemCount: tempOrder.length,
              onReorder: (oldIndex, newIndex) {
                setSheetState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = tempOrder.removeAt(oldIndex);
                  tempOrder.insert(newIndex, item);
                });
              },
              itemBuilder: (_, i) {
                final sectionIdx = tempOrder[i];
                return ListTile(
                  key: ValueKey(sectionIdx),
                  leading: Icon(
                    _sectionIcons[sectionIdx],
                    color: HelpiTheme.accent,
                    size: 20,
                  ),
                  title: Text(
                    _sectionLabels[sectionIdx],
                    style: const TextStyle(fontSize: 14),
                  ),
                  dense: true,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionChipButton(
                  icon: Icons.restart_alt,
                  label: AppStrings.resetDefault,
                  color: HelpiTheme.accent,
                  outlined: true,
                  onTap: () {
                    setSheetState(() {
                      tempOrder.clear();
                      tempOrder.addAll(List.generate(_sectionCount, (i) => i));
                    });
                  },
                ),
                const SizedBox(width: 12),
                ActionChipButton(
                  icon: Icons.check,
                  label: AppStrings.save,
                  color: HelpiTheme.primary,
                  onTap: () {
                    setState(() {
                      _sectionOrder = List.from(tempOrder);
                    });
                    _prefs.setSectionOrder(_screenKey, _sectionOrder);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (isWide) {
      showDialog<void>(
        context: context,
        builder: (ctx) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
              child: StatefulBuilder(
                builder: (ctx, setSheetState) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: buildContent(ctx, setSheetState),
                  );
                },
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet<void>(
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
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: buildContent(ctx, setSheetState),
                ),
              );
            },
          );
        },
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  //  EDIT ORDER MODAL (dialog on desktop / bottom sheet on mobile)
  // ─────────────────────────────────────────────────────────
  void _showEditOrderModal() {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    final formWidget = CreateOrderScreen(existingOrder: _order, isModal: true);

    if (isWide) {
      showDialog<OrderModel>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 750),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
              child: formWidget,
            ),
          ),
        ),
      ).then((result) {
        if (!context.mounted) return;
        if (result != null) setState(() => _order = result);
      });
    } else {
      showModalBottomSheet<OrderModel>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(HelpiTheme.bottomSheetRadius),
          ),
        ),
        builder: (ctx) =>
            FractionallySizedBox(heightFactor: 0.92, child: formWidget),
      ).then((result) {
        if (!context.mounted) return;
        if (result != null) setState(() => _order = result);
      });
    }
  }

  // ─────────────────────────────────────────────────────────
  //  ORDERER SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildOrdererSection() {
    if (!_order.senior.hasOrderer) return const SizedBox.shrink();
    return SectionCard(
      title: AppStrings.seniorOrdererTitle,
      icon: Icons.people,
      children: [
        ResponsiveFieldGrid(
          children: [
            InfoField(
              label: AppStrings.seniorOrdererFirstName,
              value: _order.senior.ordererFirstName ?? '',
            ),
            if (_order.senior.ordererLastName != null)
              InfoField(
                label: AppStrings.seniorOrdererLastName,
                value: _order.senior.ordererLastName!,
              ),
            if (_order.senior.ordererEmail != null)
              InfoField(
                label: AppStrings.seniorOrdererEmail,
                value: _order.senior.ordererEmail!,
                trailing: EmailCopyButton(email: _order.senior.ordererEmail!),
              ),
            if (_order.senior.ordererPhone != null)
              InfoField(
                label: AppStrings.seniorOrdererPhone,
                value: _order.senior.ordererPhone!,
                trailing: PhoneCallButton(phone: _order.senior.ordererPhone!),
              ),
            if (_order.senior.ordererAddress != null)
              InfoField(
                label: AppStrings.seniorOrdererAddress,
                value: _order.senior.ordererAddress!,
              ),
            if (_order.senior.ordererGender != null)
              InfoField(
                label: AppStrings.seniorOrdererGender,
                value: _order.senior.ordererGender == Gender.male
                    ? AppStrings.genderMale
                    : AppStrings.genderFemale,
              ),
            if (_order.senior.ordererDateOfBirth != null)
              InfoField(
                label: AppStrings.seniorOrdererDob,
                value: formatDateDot(_order.senior.ordererDateOfBirth!),
              ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SERVICE USER SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildServiceUserSection() {
    return SectionCard(
      title: AppStrings.seniorServiceUser,
      icon: Icons.elderly,
      children: [
        ResponsiveFieldGrid(
          children: [
            InfoField(
              label: AppStrings.seniorFirstName,
              value: _order.senior.firstName,
            ),
            InfoField(
              label: AppStrings.seniorLastName,
              value: _order.senior.lastName,
            ),
            if (!_order.senior.hasOrderer)
              InfoField(
                label: AppStrings.seniorOrdererEmail,
                value: _order.senior.email,
                trailing: EmailCopyButton(email: _order.senior.email),
              ),
            InfoField(
              label: AppStrings.seniorPhone,
              value: _order.senior.phone,
              trailing: PhoneCallButton(phone: _order.senior.phone),
            ),
            InfoField(
              label: AppStrings.seniorAddress,
              value: _order.senior.address,
            ),
            InfoField(
              label: AppStrings.seniorOrdererGender,
              value: _order.senior.gender == Gender.male
                  ? AppStrings.genderMale
                  : AppStrings.genderFemale,
            ),
            InfoField(
              label: AppStrings.seniorOrdererDob,
              value: formatDateDot(_order.senior.dateOfBirth),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  STUDENT SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildStudentSection() {
    return SectionCard(
      title: AppStrings.orderStudent,
      icon: Icons.school,
      children: [
        if (_order.student != null) ...[
          ResponsiveFieldGrid(
            children: [
              InfoField(
                label: AppStrings.studentFirstName,
                value: _order.student!.firstName,
              ),
              InfoField(
                label: AppStrings.studentLastName,
                value: _order.student!.lastName,
              ),
              InfoField(
                label: AppStrings.studentEmail,
                value: _order.student!.email,
                trailing: EmailCopyButton(email: _order.student!.email),
              ),
              InfoField(
                label: AppStrings.studentPhone,
                value: _order.student!.phone,
                trailing: PhoneCallButton(phone: _order.student!.phone),
              ),
              InfoField(
                label: AppStrings.studentRating,
                value:
                    '${_order.student!.avgRating}/5 (${_order.student!.totalReviews})',
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_order.status == OrderStatus.active)
            ActionChipButton(
              icon: Icons.swap_horiz,
              label: AppStrings.reassignStudent,
              color: HelpiTheme.accent,
              outlined: true,
              onTap: () => _showAssignSheet(),
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
                    style: const TextStyle(color: HelpiTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          ActionChipButton(
            icon: Icons.person_add,
            label: AppStrings.assignStudent,
            color: HelpiTheme.accent,
            onTap: () => _showAssignSheet(),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  ORDER DETAILS SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildOrderDetailsSection() {
    final dateStr = formatDate(_order.scheduledDate);
    return SectionCard(
      title: AppStrings.orderDetails,
      icon: Icons.receipt_long,
      children: [
        ResponsiveFieldGrid(
          children: [
            InfoField(label: AppStrings.orderDate, value: dateStr),
            InfoField(
              label: AppStrings.orderFrequency,
              value: _frequencyLabel(),
            ),
            InfoField(label: AppStrings.seniorAddress, value: _order.address),
            if (_order.notes != null && _order.notes!.isNotEmpty)
              InfoField(label: AppStrings.orderNotes, value: _order.notes!),
            InfoField(
              label: AppStrings.orderServices,
              value: _order.services.map((s) => serviceLabel(s)).join(', '),
            ),
          ],
        ),
      ],
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
          InkWell(
            borderRadius: BorderRadius.circular(8),
            hoverColor: HelpiTheme.accent.withAlpha(10),
            splashColor: HelpiTheme.accent.withAlpha(20),
            mouseCursor: SystemMouseCursors.click,
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
        '${_dayName(session.weekday)}, ${formatDateDot(session.date)}';

    final timeStr = formatTimeOfDay(session.startTime);

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
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isCancelled
                              ? HelpiTheme.textSecondary
                              : HelpiTheme.textPrimary,
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (session.isModified) ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: AppStrings.sessionModified,
                        child: Icon(
                          Icons.history,
                          size: 16,
                          color: HelpiTheme.accent.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
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
  //  ADMIN ACTIONS SECTION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAdminActionsSection() {
    final isCancelled = _order.status == OrderStatus.cancelled;
    final isArchived = _order.status == OrderStatus.archived;
    final isCompleted = _order.status == OrderStatus.completed;
    final canCancel = !isCancelled && !isArchived && !isCompleted;
    final canArchive = isCancelled || isCompleted;

    return SectionCard(
      title: AppStrings.adminActions,
      icon: Icons.admin_panel_settings,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (canCancel)
              ActionChipButton(
                icon: Icons.cancel_outlined,
                label: AppStrings.cancelOrderBtn,
                color: HelpiTheme.primary,
                onTap: _confirmCancelOrder,
              ),
            if (isArchived)
              ActionChipButton(
                icon: Icons.unarchive,
                label: AppStrings.studentUnarchive,
                color: HelpiTheme.accent,
                onTap: _confirmUnarchiveOrder,
              )
            else
              ActionChipButton(
                icon: Icons.archive,
                label: AppStrings.studentArchive,
                color: HelpiTheme.textSecondary,
                onTap: () => canArchive
                    ? _confirmArchiveOrder()
                    : _showArchiveBlockedDialog(),
              ),
          ],
        ),
      ],
    );
  }

  void _showArchiveBlockedDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        title: Text(AppStrings.archiveOrderBlockedTitle),
        content: Text(AppStrings.archiveOrderBlockedMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelOrder() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        title: Text(AppStrings.cancelOrderConfirmTitle),
        content: Text(AppStrings.cancelOrderConfirmMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppStrings.cancelOrderBtn,
              style: const TextStyle(color: HelpiTheme.primary),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true || !mounted) return;
      setState(() {
        final updatedSessions = _order.sessions.map((s) {
          if (s.status == SessionStatus.upcoming) {
            return s.copyWith(status: SessionStatus.cancelled);
          }
          return s;
        }).toList();

        _order = OrderModel(
          id: _order.id,
          orderNumber: _order.orderNumber,
          senior: _order.senior,
          student: _order.student,
          status: OrderStatus.cancelled,
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
    });
  }

  void _confirmArchiveOrder() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        title: Text(AppStrings.archiveConfirmTitle),
        content: Text(AppStrings.archiveConfirmMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.studentArchive),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true || !mounted) return;
      _rebuildOrder(status: OrderStatus.archived);
    });
  }

  void _confirmUnarchiveOrder() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        title: Text(AppStrings.unarchiveConfirmTitle),
        content: Text(AppStrings.unarchiveConfirmMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.studentUnarchive),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true || !mounted) return;
      // Restore to previous meaningful status
      final hasUpcoming = _order.sessions.any(
        (s) => s.status == SessionStatus.upcoming,
      );
      _rebuildOrder(
        status: hasUpcoming ? OrderStatus.active : OrderStatus.completed,
      );
    });
  }

  void _rebuildOrder({OrderStatus? status, List<SessionModel>? sessions}) {
    setState(() {
      _order = OrderModel(
        id: _order.id,
        orderNumber: _order.orderNumber,
        senior: _order.senior,
        student: _order.student,
        status: status ?? _order.status,
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
        sessions: sessions ?? _order.sessions,
      );
      final idx = MockData.orders.indexWhere((o) => o.id == _order.id);
      if (idx != -1) MockData.orders[idx] = _order;
    });
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

  bool _isStudentAvailableForSession(SessionModel session) {
    if (_order.student == null) return true;
    final student = _order.student!;
    if (student.availability.isEmpty) return true;
    final dayAvail = student.availability.where(
      (a) => a.dayOfWeek == session.weekday,
    );
    if (dayAvail.isEmpty || !dayAvail.first.isEnabled) return false;
    final avail = dayAvail.first;
    final startMin = session.startTime.hour * 60 + session.startTime.minute;
    final fromMin = avail.from.hour * 60 + avail.from.minute;
    final toMin = avail.to.hour * 60 + avail.to.minute;
    return startMin >= fromMin && startMin < toMin;
  }

  void _confirmReactivateSession(SessionModel session) {
    if (!_isStudentAvailableForSession(session)) {
      // Student not available → open reschedule sheet directly
      _showRescheduleSheet(session.copyWith(status: SessionStatus.upcoming));
      return;
    }
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
    // Snap to nearest 15-min interval
    TimeOfDay selectedTime = TimeOfDay(
      hour: session.startTime.hour,
      minute: (session.startTime.minute ~/ 15) * 15,
    );
    String? selectedStudentName = session.studentName;

    final allActiveStudents = MockData.students
        .where((s) => s.isActive && s.contractStatus == ContractStatus.active)
        .toList();

    final isWide = MediaQuery.sizeOf(context).width >= 600;

    Widget buildContent(
      BuildContext ctx,
      StateSetter setSheetState, [
      ScrollController? scrollCtrl,
    ]) {
      final dateLabel = formatDate(selectedDate);
      final timeLabel = formatTimeOfDay(selectedTime);

      // Filter students by availability for the selected day & time
      final filteredStudents = allActiveStudents.where((student) {
        if (student.availability.isEmpty) return true;
        final dayMatches = student.availability.where(
          (a) => a.dayOfWeek == selectedDate.weekday,
        );
        if (dayMatches.isEmpty) return false;
        final avail = dayMatches.first;
        if (!avail.isEnabled) return false;
        final selMin = selectedTime.hour * 60 + selectedTime.minute;
        final fromMin = avail.from.hour * 60 + avail.from.minute;
        final toMin = avail.to.hour * 60 + avail.to.minute;
        return selMin >= fromMin && selMin < toMin;
      }).toList();

      // Check if current student is available for selected slot
      final currentStudentAvailable =
          session.studentName != null &&
          (() {
            final current = allActiveStudents.where(
              (s) => s.fullName == session.studentName,
            );
            if (current.isEmpty) return false;
            final student = current.first;
            if (student.availability.isEmpty) return true;
            final dayMatches = student.availability.where(
              (a) => a.dayOfWeek == selectedDate.weekday,
            );
            if (dayMatches.isEmpty) return false;
            final avail = dayMatches.first;
            if (!avail.isEnabled) return false;
            final selMin = selectedTime.hour * 60 + selectedTime.minute;
            final fromMin = avail.from.hour * 60 + avail.from.minute;
            final toMin = avail.to.hour * 60 + avail.to.minute;
            return selMin >= fromMin && selMin < toMin;
          })();

      // If current student not available, clear selection
      if (!currentStudentAvailable &&
          selectedStudentName == session.studentName) {
        selectedStudentName = filteredStudents.isNotEmpty
            ? filteredStudents
                  .where((s) => s.fullName != session.studentName)
                  .firstOrNull
                  ?.fullName
            : null;
      }

      final studentListChildren = <Widget>[
        // "Keep current" option (only if available for this slot)
        if (session.studentName != null && currentStudentAvailable)
          _StudentRadioTile(
            name: session.studentName!,
            subtitle: AppStrings.sessionKeepCurrentStudent,
            isSelected: selectedStudentName == session.studentName,
            onTap: () {
              setSheetState(() {
                selectedStudentName = session.studentName;
              });
            },
          ),
        // Filtered students
        if (filteredStudents
                .where((s) => s.fullName != session.studentName)
                .isEmpty &&
            !currentStudentAvailable)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              AppStrings.noStudentsForSlot,
              style: const TextStyle(
                color: HelpiTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ...filteredStudents
            .where((s) => s.fullName != session.studentName)
            .map(
              (student) => _StudentRadioTile(
                name: student.fullName,
                subtitle:
                    '★ ${student.avgRating}  ·  ${student.completedJobs} poslova',
                isSelected: selectedStudentName == student.fullName,
                onTap: () {
                  setSheetState(() {
                    selectedStudentName = student.fullName;
                  });
                },
              ),
            ),
      ];

      return Column(
        mainAxisSize: scrollCtrl != null ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isWide)
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: DragHandle(),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppStrings.sessionRescheduleTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),

          // ── Date picker row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _RescheduleRow(
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
          ),
          const SizedBox(height: 12),

          // ── Time picker row (15-min intervals) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _RescheduleRow(
              icon: Icons.access_time,
              label: AppStrings.sessionNewTime,
              value: timeLabel,
              onTap: () async {
                final picked = await _showTimeGrid(ctx, selectedTime);
                if (picked != null) {
                  setSheetState(() => selectedTime = picked);
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Student selector label ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppStrings.sessionSelectStudent,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: HelpiTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Student list (responsive) ──
          if (scrollCtrl != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  controller: scrollCtrl,
                  children: studentListChildren,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView(
                  shrinkWrap: true,
                  children: studentListChildren,
                ),
              ),
            ),
          const SizedBox(height: 24),

          // ── Confirm button ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: ActionChipButton(
                icon: Icons.check,
                label: AppStrings.confirm,
                color: HelpiTheme.primary,
                onTap: () {
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
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    if (isWide) {
      showDialog<void>(
        context: context,
        builder: (ctx) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
              child: StatefulBuilder(
                builder: (ctx, setSheetState) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: buildContent(ctx, setSheetState),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    } else {
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
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            expand: false,
            builder: (ctx, scrollCtrl) {
              return StatefulBuilder(
                builder: (ctx, setSheetState) {
                  return buildContent(ctx, setSheetState, scrollCtrl);
                },
              );
            },
          );
        },
      );
    }
  }

  /// Custom time picker grid with 15-minute intervals (7:00 – 21:00).
  Future<TimeOfDay?> _showTimeGrid(
    BuildContext ctx,
    TimeOfDay currentTime,
  ) async {
    final slots = <TimeOfDay>[];
    for (int h = 7; h <= 21; h++) {
      for (int m = 0; m < 60; m += 15) {
        if (h == 21 && m > 0) break;
        slots.add(TimeOfDay(hour: h, minute: m));
      }
    }

    return showDialog<TimeOfDay>(
      context: ctx,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.selectTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2.2,
                          ),
                      itemCount: slots.length,
                      itemBuilder: (_, i) {
                        final slot = slots[i];
                        final isSelected =
                            slot.hour == currentTime.hour &&
                            slot.minute == currentTime.minute;
                        return Material(
                          color: isSelected
                              ? HelpiTheme.primary
                              : HelpiTheme.surface,
                          borderRadius: BorderRadius.circular(
                            HelpiTheme.pillRadius,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              HelpiTheme.pillRadius,
                            ),
                            onTap: () => Navigator.pop(dialogCtx, slot),
                            child: Center(
                              child: Text(
                                formatTimeOfDay(slot),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : HelpiTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  AVAILABILITY HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Returns the order's schedule slots as (dayOfWeek, startTime) pairs.
  List<({int dayOfWeek, TimeOfDay startTime})> _orderSlots() {
    if (_order.dayEntries.isNotEmpty) {
      return _order.dayEntries
          .map((e) => (dayOfWeek: e.dayOfWeek, startTime: e.startTime))
          .toList();
    }
    return [
      (
        dayOfWeek: _order.scheduledDate.weekday,
        startTime: _order.scheduledStart,
      ),
    ];
  }

  /// Classify student availability for this order.
  ///   full          – covers all days at the right times
  ///   differentTimes – covers all days but some at wrong times
  ///   unavailable    – doesn't cover one or more days
  _StudentAvail _classifyStudent(StudentModel student) {
    if (student.availability.isEmpty) return _StudentAvail.full;
    final slots = _orderSlots();
    bool allTimesMatch = true;
    for (final slot in slots) {
      final dayEntries = student.availability.where(
        (a) => a.dayOfWeek == slot.dayOfWeek,
      );
      if (dayEntries.isEmpty || !dayEntries.first.isEnabled) {
        return _StudentAvail.unavailable;
      }
      final avail = dayEntries.first;
      final selMin = slot.startTime.hour * 60 + slot.startTime.minute;
      final fromMin = avail.from.hour * 60 + avail.from.minute;
      final toMin = avail.to.hour * 60 + avail.to.minute;
      if (selMin < fromMin || selMin >= toMin) {
        allTimesMatch = false;
      }
    }
    return allTimesMatch ? _StudentAvail.full : _StudentAvail.differentTimes;
  }

  // ═══════════════════════════════════════════════════════════════
  //  ASSIGN STUDENT (single-modal flow with back navigation)
  // ═══════════════════════════════════════════════════════════════
  void _showAssignSheet() {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    void onConfirmed(
      StudentModel student,
      List<SessionInstancePreview> previewSessions,
    ) {
      if (!context.mounted) return;
      setState(() {
        final updatedSessions = _order.sessions.map((s) {
          if (s.status != SessionStatus.upcoming) return s;

          // Find matching preview session by date
          final preview = previewSessions.where(
            (p) =>
                p.date.year == s.date.year &&
                p.date.month == s.date.month &&
                p.date.day == s.date.day,
          );

          if (preview.isEmpty) {
            return s.copyWith(studentName: () => student.fullName);
          }

          final p = preview.first;

          if (p.isSkipped) {
            return s.copyWith(
              status: SessionStatus.cancelled,
              studentName: () => student.fullName,
              isModified: true,
            );
          }

          if (p.rescheduledStart != null) {
            return s.copyWith(
              startTime: p.rescheduledStart,
              studentName: () => student.fullName,
              isModified: true,
            );
          }

          if (p.substituteStudent != null) {
            return s.copyWith(
              studentName: () => p.substituteStudent!.fullName,
              isModified: true,
            );
          }

          return s.copyWith(studentName: () => student.fullName);
        }).toList();

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
          sessions: updatedSessions,
        );
        final idx = MockData.orders.indexWhere((o) => o.id == _order.id);
        if (idx != -1) MockData.orders[idx] = _order;
      });
    }

    // Classify & filter out unavailable
    final activeStudents = MockData.students
        .where((s) => s.isActive && s.contractStatus == ContractStatus.active)
        .toList();
    final classified = <(StudentModel, _StudentAvail)>[];
    for (final s in activeStudents) {
      final avail = _classifyStudent(s);
      if (avail != _StudentAvail.unavailable) classified.add((s, avail));
    }
    classified.sort((a, b) {
      final aIdx = a.$2.index;
      final bIdx = b.$2.index;
      if (aIdx != bIdx) return aIdx.compareTo(bIdx);
      return b.$1.avgRating.compareTo(a.$1.avgRating);
    });

    if (isWide) {
      showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 750),
            child: _OrderAssignFlowSheet(
              order: _order,
              classified: classified,
              useDialog: true,
              onAssignDirect: (student) {
                _assignStudent(student, ctx);
              },
              onAssignConfirmed: (student, sessions) {
                Navigator.pop(ctx);
                onConfirmed(student, sessions);
              },
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(HelpiTheme.bottomSheetRadius),
          ),
        ),
        builder: (ctx) => _OrderAssignFlowSheet(
          order: _order,
          classified: classified,
          useDialog: false,
          onAssignDirect: (student) {
            _assignStudent(student, ctx);
          },
          onAssignConfirmed: (student, sessions) {
            Navigator.pop(ctx);
            onConfirmed(student, sessions);
          },
        ),
      );
    }
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
                // Propagate student to all upcoming sessions
                final updatedSessions = _order.sessions.map((s) {
                  if (s.status == SessionStatus.upcoming) {
                    return s.copyWith(studentName: () => student.fullName);
                  }
                  return s;
                }).toList();

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
                  sessions: updatedSessions,
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

  String _frequencyLabel() {
    switch (_order.frequency) {
      case FrequencyType.oneTime:
        return AppStrings.oneTime;
      case FrequencyType.recurring:
        return AppStrings.recurring;
      case FrequencyType.recurringWithEnd:
        if (_order.endDate != null) {
          return AppStrings.recurringWithEnd(formatDate(_order.endDate!));
        }
        return AppStrings.recurring;
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
//  STUDENT ASSIGN CARD (bottom sheet)
// ═══════════════════════════════════════════════════════════════
//  STUDENT AVAILABILITY CATEGORY
// ═══════════════════════════════════════════════════════════════
enum _StudentAvail { full, differentTimes, unavailable }

// ═══════════════════════════════════════════════════════════════
//  STUDENT ASSIGN CARD (bottom sheet)
// ═══════════════════════════════════════════════════════════════
class _StudentAssignCard extends StatelessWidget {
  const _StudentAssignCard({
    required this.student,
    required this.avail,
    required this.onAssign,
  });
  final StudentModel student;
  final _StudentAvail avail;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final String availLabel;
    final Color availColor;
    final IconData availIcon;
    final String buttonLabel;
    final IconData buttonIcon;

    if (avail == _StudentAvail.full) {
      availLabel = AppStrings.availableAllDays;
      availColor = HelpiTheme.accent;
      availIcon = Icons.check_circle_outline;
      buttonLabel = AppStrings.assignStudent;
      buttonIcon = Icons.person_add;
    } else {
      availLabel = AppStrings.availableDifferentTimes;
      availColor = const Color(0xFFE65100);
      availIcon = Icons.schedule;
      buttonLabel = AppStrings.reviewSessions;
      buttonIcon = Icons.calendar_month;
    }

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
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: availColor.withValues(alpha: 0.08),
                    border: Border.all(
                      color: availColor.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(
                      HelpiTheme.statusBadgeRadius,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(availIcon, size: 12, color: availColor),
                      const SizedBox(width: 4),
                      Text(
                        availLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: availColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Action button ──
          Material(
            color: availColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              hoverColor: availColor.withValues(alpha: 0.15),
              splashColor: availColor.withValues(alpha: 0.2),
              mouseCursor: SystemMouseCursors.click,
              onTap: onAssign,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: availColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(buttonIcon, size: 14, color: availColor),
                    const SizedBox(width: 4),
                    Text(
                      buttonLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: availColor,
                      ),
                    ),
                  ],
                ),
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
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        hoverColor: color.withValues(alpha: 0.15),
        splashColor: color.withValues(alpha: 0.2),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
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
//  ORDER ASSIGN FLOW SHEET (single modal: student list ↔ session preview)
// ═══════════════════════════════════════════════════════════════
class _OrderAssignFlowSheet extends StatefulWidget {
  const _OrderAssignFlowSheet({
    required this.order,
    required this.classified,
    required this.onAssignDirect,
    required this.onAssignConfirmed,
    this.useDialog = false,
  });

  final OrderModel order;
  final List<(StudentModel, _StudentAvail)> classified;
  final void Function(StudentModel student) onAssignDirect;
  final void Function(
    StudentModel student,
    List<SessionInstancePreview> sessions,
  )
  onAssignConfirmed;
  final bool useDialog;

  @override
  State<_OrderAssignFlowSheet> createState() => _OrderAssignFlowSheetState();
}

class _OrderAssignFlowSheetState extends State<_OrderAssignFlowSheet> {
  StudentModel? _selectedStudent;

  void _selectStudent(StudentModel student) {
    setState(() => _selectedStudent = student);
  }

  void _goBack() {
    setState(() => _selectedStudent = null);
  }

  @override
  Widget build(BuildContext context) {
    final content = _selectedStudent != null
        ? _OrderSessionPreview(
            key: ValueKey(_selectedStudent!.id),
            student: _selectedStudent!,
            order: widget.order,
            onBack: _goBack,
            onAssigned: (sessions) =>
                widget.onAssignConfirmed(_selectedStudent!, sessions),
            useDialog: widget.useDialog,
          )
        : _buildStudentList();

    if (widget.useDialog) {
      return Container(
        decoration: const BoxDecoration(
          color: HelpiTheme.scaffold,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: content,
      );
    }

    final height = _selectedStudent != null ? 0.9 : 0.65;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      height: MediaQuery.of(context).size.height * height,
      decoration: const BoxDecoration(
        color: HelpiTheme.scaffold,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: content,
    );
  }

  Widget _buildStudentList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.useDialog)
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: DragHandle(),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.people_outline, color: HelpiTheme.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.suggestedStudents,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${widget.classified.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HelpiTheme.accent,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: widget.classified.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.noStudentsFound,
                    style: const TextStyle(color: HelpiTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  itemCount: widget.classified.length,
                  itemBuilder: (_, i) {
                    final (student, avail) = widget.classified[i];
                    return _StudentAssignCard(
                      student: student,
                      avail: avail,
                      onAssign: avail == _StudentAvail.full
                          ? () => widget.onAssignDirect(student)
                          : () => _selectStudent(student),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ORDER SESSION PREVIEW (for partial-availability assign flow)
// ═══════════════════════════════════════════════════════════════
class _OrderSessionPreview extends StatefulWidget {
  const _OrderSessionPreview({
    super.key,
    required this.student,
    required this.order,
    required this.onBack,
    required this.onAssigned,
    this.useDialog = false,
  });

  final StudentModel student;
  final OrderModel order;
  final VoidCallback onBack;
  final void Function(List<SessionInstancePreview> sessions) onAssigned;
  final bool useDialog;

  @override
  State<_OrderSessionPreview> createState() => _OrderSessionPreviewState();
}

class _OrderSessionPreviewState extends State<_OrderSessionPreview> {
  late List<SessionInstancePreview> _sessions;
  int? _expandedIndex;
  String? _expandedType; // 'time' or 'substitute'

  @override
  void initState() {
    super.initState();
    _sessions = _generateSessions();
  }

  // ── Generate upcoming sessions with conflict detection ──────

  List<SessionInstancePreview> _generateSessions() {
    final order = widget.order;
    final student = widget.student;

    final studentOrders = MockData.orders
        .where(
          (o) =>
              o.student?.id == student.id &&
              o.status != OrderStatus.cancelled &&
              o.id != order.id,
        )
        .toList();

    final List<SessionInstancePreview> result = [];
    for (final session in order.sessions) {
      if (session.status != SessionStatus.upcoming) continue;
      final startMin = _toMin(session.startTime);
      final endMin = startMin + session.durationHours * 60;

      SessionConflictType conflictType = SessionConflictType.free;
      OrderModel? conflictingOrder;

      // 1) Check student availability window
      if (student.availability.isNotEmpty) {
        final dayAvail = student.availability.where(
          (a) => a.dayOfWeek == session.weekday,
        );
        if (dayAvail.isEmpty || !dayAvail.first.isEnabled) {
          conflictType = SessionConflictType.conflict;
        } else {
          final avail = dayAvail.first;
          final fromMin = _toMin(avail.from);
          final toMin = _toMin(avail.to);
          if (startMin < fromMin || startMin >= toMin) {
            conflictType = SessionConflictType.conflict;
          }
        }
      }

      // 2) Check scheduling conflicts with other orders
      if (conflictType == SessionConflictType.free) {
        conflictingOrder = _findConflict(
          date: session.date,
          weekday: session.weekday,
          startMin: startMin,
          endMin: endMin,
          studentOrders: studentOrders,
        );
        if (conflictingOrder != null) {
          conflictType = SessionConflictType.conflict;
        }
      }

      result.add(
        SessionInstancePreview(
          date: session.date,
          weekday: session.weekday,
          startTime: session.startTime,
          durationHours: session.durationHours,
          conflictType: conflictType,
          conflictingOrder: conflictingOrder,
        ),
      );
    }
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  OrderModel? _findConflict({
    required DateTime date,
    required int weekday,
    required int startMin,
    required int endMin,
    required List<OrderModel> studentOrders,
  }) {
    for (final existing in studentOrders) {
      if (existing.dayEntries.isNotEmpty) {
        for (final entry in existing.dayEntries) {
          if (entry.dayOfWeek == weekday) {
            final exStart = _toMin(entry.startTime);
            final exEnd = exStart + entry.durationHours * 60;
            if (_overlap(startMin, endMin, exStart, exEnd)) return existing;
          }
        }
      } else if (_sameDay(existing.scheduledDate, date)) {
        final exStart = _toMin(existing.scheduledStart);
        final exEnd = exStart + existing.durationHours * 60;
        if (_overlap(startMin, endMin, exStart, exEnd)) return existing;
      }
    }
    return null;
  }

  List<StudentModel> _findSubstitutes(SessionInstancePreview session) {
    return MockData.students.where((s) {
      if (s.id == widget.student.id) return false;
      if (!s.isActive || s.contractStatus != ContractStatus.active) {
        return false;
      }
      final avail = s.availability.where(
        (a) => a.dayOfWeek == session.weekday && a.isEnabled,
      );
      if (avail.isEmpty) return s.availability.isEmpty;
      final a = avail.first;
      final sStart = _toMin(session.startTime);
      final sEnd = sStart + session.durationHours * 60;
      if (_toMin(a.from) > sStart || _toMin(a.to) < sEnd) return false;
      final subOrders = MockData.orders.where(
        (o) => o.student?.id == s.id && o.status != OrderStatus.cancelled,
      );
      for (final o in subOrders) {
        if (o.dayEntries.isNotEmpty) {
          for (final entry in o.dayEntries) {
            if (entry.dayOfWeek == session.weekday) {
              final exS = _toMin(entry.startTime);
              if (_overlap(sStart, sEnd, exS, exS + entry.durationHours * 60)) {
                return false;
              }
            }
          }
        } else if (_sameDay(o.scheduledDate, session.date)) {
          final exS = _toMin(o.scheduledStart);
          if (_overlap(sStart, sEnd, exS, exS + o.durationHours * 60)) {
            return false;
          }
        }
      }
      return true;
    }).toList();
  }

  List<TimeOfDay> _findAltSlots(SessionInstancePreview session) {
    final avail = widget.student.availability.where(
      (a) => a.dayOfWeek == session.weekday && a.isEnabled,
    );
    if (avail.isEmpty) return [];
    final a = avail.first;
    final availFrom = _toMin(a.from);
    final availTo = _toMin(a.to);
    final dur = session.durationHours * 60;

    final busy = <({int start, int end})>[];
    for (final o in MockData.orders.where(
      (o) =>
          o.student?.id == widget.student.id &&
          o.status != OrderStatus.cancelled,
    )) {
      if (o.dayEntries.isNotEmpty) {
        for (final e in o.dayEntries) {
          if (e.dayOfWeek == session.weekday) {
            final s = _toMin(e.startTime);
            busy.add((start: s, end: s + e.durationHours * 60));
          }
        }
      } else if (_sameDay(o.scheduledDate, session.date)) {
        final s = _toMin(o.scheduledStart);
        busy.add((start: s, end: s + o.durationHours * 60));
      }
    }
    busy.sort((a, b) => a.start.compareTo(b.start));

    final List<TimeOfDay> slots = [];
    int cursor = availFrom;
    for (final b in busy) {
      if (cursor + dur <= b.start) {
        slots.add(TimeOfDay(hour: cursor ~/ 60, minute: cursor % 60));
      }
      if (b.end > cursor) cursor = b.end;
    }
    if (cursor + dur <= availTo) {
      slots.add(TimeOfDay(hour: cursor ~/ 60, minute: cursor % 60));
    }
    slots.removeWhere(
      (t) =>
          t.hour == session.startTime.hour &&
          t.minute == session.startTime.minute,
    );
    return slots;
  }

  // ── Helpers ─────────────────────────────────────────────────

  static int _toMin(TimeOfDay t) => t.hour * 60 + t.minute;
  static bool _overlap(int s1, int e1, int s2, int e2) => s1 < e2 && s2 < e1;
  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int get _freeCount =>
      _sessions.where((s) => s.conflictType == SessionConflictType.free).length;
  int get _conflictCount => _sessions
      .where((s) => s.conflictType == SessionConflictType.conflict)
      .length;
  int get _unresolvedCount =>
      _sessions.where((s) => s.hasUnresolvedConflict).length;

  static const _dayLabelsShort = [
    'Pon',
    'Uto',
    'Sri',
    'Čet',
    'Pet',
    'Sub',
    'Ned',
  ];

  // ── Actions ─────────────────────────────────────────────────

  void _skipSession(int i) => setState(() => _sessions[i].isSkipped = true);
  void _undoSkip(int i) => setState(() => _sessions[i].isSkipped = false);

  void _toggleTimePicker(int index) {
    final session = _sessions[index];
    final slots = _findAltSlots(session);
    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.noSubstitutesAvailable),
          backgroundColor: HelpiTheme.error,
        ),
      );
      return;
    }
    setState(() {
      if (_expandedIndex == index && _expandedType == 'time') {
        _expandedIndex = null;
        _expandedType = null;
      } else {
        _expandedIndex = index;
        _expandedType = 'time';
      }
    });
  }

  void _toggleSubstitutePicker(int index) {
    final session = _sessions[index];
    final subs = _findSubstitutes(session);
    if (subs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.noSubstitutesAvailable),
          backgroundColor: HelpiTheme.error,
        ),
      );
      return;
    }
    setState(() {
      if (_expandedIndex == index && _expandedType == 'substitute') {
        _expandedIndex = null;
        _expandedType = null;
      } else {
        _expandedIndex = index;
        _expandedType = 'substitute';
      }
    });
  }

  void _confirmAssign() {
    if (_unresolvedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.unresolvedConflicts),
          backgroundColor: HelpiTheme.error,
        ),
      );
      return;
    }
    widget.onAssigned(_sessions);
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.useDialog)
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: DragHandle(),
          ),
        // Header with back button
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: widget.onBack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              const Icon(Icons.calendar_month, color: HelpiTheme.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.sessionPreviewTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Sub-header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${widget.order.orderNumber} '
                '${widget.order.senior.fullName}  →  '
                '${widget.student.fullName}',
                style: const TextStyle(
                  fontSize: 13,
                  color: HelpiTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatsBar(),
            ],
          ),
        ),
        const Divider(height: 1),
        // Session list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _sessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _buildSessionTile(i),
          ),
        ),
        // Bottom bar
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Row(
      children: [
        _statChip(
          Icons.check_box_outlined,
          '$_freeCount',
          HelpiTheme.statusActiveBg,
          HelpiTheme.statusActiveText,
        ),
        const SizedBox(width: 8),
        if (_conflictCount > 0) ...[
          _statChip(
            Icons.warning_amber_rounded,
            '$_conflictCount',
            HelpiTheme.statusCancelledBg,
            HelpiTheme.statusCancelledText,
          ),
          const SizedBox(width: 8),
        ],
        _statChip(
          Icons.event_note,
          AppStrings.sessionCountChip(_sessions.length),
          HelpiTheme.chipBg,
          HelpiTheme.textSecondary,
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg.withAlpha(50)),
        borderRadius: BorderRadius.circular(HelpiTheme.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(int index) {
    final s = _sessions[index];
    final isFree = s.conflictType == SessionConflictType.free;
    final isResolved =
        s.isSkipped ||
        s.rescheduledStart != null ||
        s.substituteStudent != null;

    Color borderColor;
    Color bgColor;
    if (s.isSkipped) {
      borderColor = HelpiTheme.border;
      bgColor = HelpiTheme.chipBg;
    } else if (isFree || isResolved) {
      borderColor = HelpiTheme.statusActiveText.withAlpha(80);
      bgColor = Colors.white;
    } else {
      borderColor = HelpiTheme.statusCancelledText.withAlpha(120);
      bgColor = Colors.white;
    }

    final displayStart = s.rescheduledStart ?? s.startTime;
    final endMin = _toMin(displayStart) + s.durationHours * 60;
    final endTime = TimeOfDay(hour: endMin ~/ 60, minute: endMin % 60);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Date + Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (!isFree && !isResolved && !s.isSkipped)
                      ? HelpiTheme.statusCancelledText.withAlpha(20)
                      : HelpiTheme.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _dayLabelsShort[s.weekday - 1],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: (!isFree && !isResolved && !s.isSkipped)
                        ? HelpiTheme.statusCancelledText
                        : HelpiTheme.accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatDate(s.date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: s.isSkipped ? TextDecoration.lineThrough : null,
                  color: s.isSkipped ? HelpiTheme.textSecondary : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${formatTimeOfDay(displayStart)} – ${formatTimeOfDay(endTime)}',
                style: TextStyle(
                  fontSize: 13,
                  color: s.isSkipped ? HelpiTheme.textSecondary : null,
                  decoration: s.isSkipped ? TextDecoration.lineThrough : null,
                ),
              ),
              const Spacer(),
              _buildBadge(s),
            ],
          ),

          // Conflict info / resolution
          if (!isFree && !s.isSkipped) ...[
            const SizedBox(height: 8),
            if (s.rescheduledStart != null)
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: HelpiTheme.statusProcessingText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatTimeOfDay(s.rescheduledStart!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: HelpiTheme.statusProcessingText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    Icons.undo,
                    AppStrings.undoSkip,
                    HelpiTheme.accent,
                    () => setState(() {
                      _sessions[index].rescheduledStart = null;
                    }),
                  ),
                ],
              )
            else if (s.substituteStudent != null)
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: HelpiTheme.accent,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      s.substituteStudent!.fullName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: HelpiTheme.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    Icons.undo,
                    AppStrings.undoSkip,
                    HelpiTheme.accent,
                    () => setState(() {
                      _sessions[index].substituteStudent = null;
                    }),
                  ),
                ],
              )
            else ...[
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: HelpiTheme.statusCancelledText,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      s.conflictingOrder != null
                          ? '${AppStrings.conflictWith} '
                                '#${s.conflictingOrder!.orderNumber} '
                                '${s.conflictingOrder!.senior.fullName}'
                          : AppStrings.timeMismatch,
                      style: const TextStyle(
                        fontSize: 12,
                        color: HelpiTheme.statusCancelledText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _actionBtn(
                    Icons.skip_next,
                    AppStrings.skipSession,
                    HelpiTheme.textSecondary,
                    () => _skipSession(index),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    Icons.schedule,
                    AppStrings.changeTime,
                    _expandedIndex == index && _expandedType == 'time'
                        ? HelpiTheme.accent
                        : HelpiTheme.statusProcessingText,
                    () => _toggleTimePicker(index),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    Icons.person_add_alt_1,
                    AppStrings.findSubstitute,
                    _expandedIndex == index && _expandedType == 'substitute'
                        ? HelpiTheme.statusProcessingText
                        : HelpiTheme.accent,
                    () => _toggleSubstitutePicker(index),
                  ),
                ],
              ),
              // ── Inline time picker ──
              if (_expandedIndex == index && _expandedType == 'time')
                _buildInlineTimePicker(index),
              // ── Inline substitute picker ──
              if (_expandedIndex == index && _expandedType == 'substitute')
                _buildInlineSubstitutePicker(index),
            ],
          ],

          if (s.isSkipped) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.skip_next,
                  size: 14,
                  color: HelpiTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  AppStrings.sessionSkipped,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                _actionBtn(
                  Icons.undo,
                  AppStrings.undoSkip,
                  HelpiTheme.accent,
                  () => _undoSkip(index),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(SessionInstancePreview s) {
    String label;
    Color bg;
    Color fg;
    if (s.isSkipped) {
      label = AppStrings.sessionSkipped;
      bg = HelpiTheme.chipBg;
      fg = HelpiTheme.textSecondary;
    } else if (s.rescheduledStart != null) {
      label = AppStrings.sessionRescheduled;
      bg = HelpiTheme.statusProcessingBg;
      fg = HelpiTheme.statusProcessingText;
    } else if (s.substituteStudent != null) {
      label = AppStrings.sessionSubstitute;
      bg = HelpiTheme.pastelTeal;
      fg = HelpiTheme.accent;
    } else if (s.conflictType == SessionConflictType.free) {
      label = AppStrings.sessionFree;
      bg = HelpiTheme.statusActiveBg;
      fg = HelpiTheme.statusActiveText;
    } else {
      label = AppStrings.sessionConflict;
      bg = HelpiTheme.statusCancelledBg;
      fg = HelpiTheme.statusCancelledText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg.withAlpha(50)),
        borderRadius: BorderRadius.circular(HelpiTheme.pillRadius),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  // ── Inline pickers ──────────────────────────────────────────

  Widget _buildInlineTimePicker(int index) {
    final session = _sessions[index];
    final slots = _findAltSlots(session);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.selectNewTime,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: HelpiTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: slots.map((slot) {
              final endMin = _toMin(slot) + session.durationHours * 60;
              final end = TimeOfDay(hour: endMin ~/ 60, minute: endMin % 60);
              return Material(
                color: HelpiTheme.statusProcessingBg,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  hoverColor: HelpiTheme.statusProcessingText.withAlpha(20),
                  splashColor: HelpiTheme.statusProcessingText.withAlpha(30),
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    setState(() {
                      _sessions[index].rescheduledStart = slot;
                      _expandedIndex = null;
                      _expandedType = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: HelpiTheme.statusProcessingText.withAlpha(60),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 13,
                          color: HelpiTheme.statusProcessingText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${formatTimeOfDay(slot)} – ${formatTimeOfDay(end)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: HelpiTheme.statusProcessingText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineSubstitutePicker(int index) {
    final session = _sessions[index];
    final subs = _findSubstitutes(session);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.selectSubstitute,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: HelpiTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          ...subs.map(
            (sub) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(HelpiTheme.pillRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(HelpiTheme.pillRadius),
                  hoverColor: HelpiTheme.accent.withAlpha(15),
                  splashColor: HelpiTheme.accent.withAlpha(25),
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    setState(() {
                      _sessions[index].substituteStudent = sub;
                      _expandedIndex = null;
                      _expandedType = null;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        HelpiTheme.pillRadius,
                      ),
                      border: Border.all(
                        color: HelpiTheme.accent.withAlpha(60),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: HelpiTheme.accent.withAlpha(30),
                          radius: 14,
                          child: Text(
                            '${sub.firstName[0]}${sub.lastName[0]}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: HelpiTheme.accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sub.fullName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${sub.avgRating}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        hoverColor: color.withAlpha(25),
        splashColor: color.withAlpha(35),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final hasUnresolved = _unresolvedCount > 0;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: HelpiTheme.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasUnresolved) ...[
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: HelpiTheme.statusCancelledText,
                ),
                const SizedBox(width: 6),
                Text(
                  '${AppStrings.unresolvedConflicts} ($_unresolvedCount)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: HelpiTheme.statusCancelledText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: ActionChipButton(
              icon: Icons.check_circle,
              label: AppStrings.confirmAssign,
              color: hasUnresolved
                  ? HelpiTheme.textSecondary
                  : HelpiTheme.accent,
              onTap: _confirmAssign,
            ),
          ),
        ],
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
