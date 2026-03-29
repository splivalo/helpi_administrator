import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/preferences_service.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/utils/session_preview_helper.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/features/orders/presentation/create_order_screen.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
import 'package:helpi_admin/core/services/data_loader.dart';

/// Order Detail Screen — detalji narudžbe + dodjela studenta.
class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.order});
  final OrderModel order;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final _prefs = PreferencesService.instance;
  static const _screenKey = 'orderDetail';
  static const _sectionCount = 6;

  late OrderModel _order;
  bool _sessionsLoading = true;
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
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final orderId = int.tryParse(_order.id);
    if (orderId == null) return;
    final result = await AdminApiService().getSessionsByOrder(orderId);
    if (!mounted) return;
    setState(() {
      _sessionsLoading = false;
      if (result.success && result.data != null) {
        _order = _order.copyWith(sessions: result.data);
      }
    });
  }

  /// Reload order data from backend + sessions.
  Future<void> _refreshOrder() async {
    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;
    final refreshed = ref
        .read(ordersProvider)
        .where((o) => o.id == _order.id)
        .firstOrNull;
    if (refreshed != null) {
      setState(() => _order = refreshed);
    }
    await _loadSessions();
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
            StatusBadge.order(_order.status),
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

  // ---------------------------------------------------------
  //  SECTION REORDER HELPERS
  // ---------------------------------------------------------

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
    final hasSessionsOrSchedule =
        _order.sessions.isNotEmpty || _order.dayEntries.isNotEmpty;
    return [
      _buildOrdererSection(),
      _buildServiceUserSection(),
      _buildStudentSection(),
      _buildOrderDetailsSection(),
      if (_sessionsLoading)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        )
      else if (hasSessionsOrSchedule)
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.reorder, color: HelpiTheme.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.sectionLayoutTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppStrings.sectionLayoutHint,
              style: TextStyle(fontSize: 13, color: HelpiTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: _sectionCount * 56.0,
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 4),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionChipButton(
                  icon: Icons.restart_alt,
                  label: AppStrings.resetDefault,
                  color: HelpiTheme.accent,
                  outlined: true,
                  size: ActionChipButtonSize.medium,
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
                  size: ActionChipButtonSize.medium,
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
                  return buildContent(ctx, setSheetState);
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

  // ---------------------------------------------------------
  //  EDIT ORDER MODAL (dialog on desktop / bottom sheet on mobile)
  // ---------------------------------------------------------
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

  // ---------------------------------------------------------
  //  ORDERER SECTION
  // ---------------------------------------------------------
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

  // ---------------------------------------------------------
  //  SERVICE USER SECTION
  // ---------------------------------------------------------
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

  // ---------------------------------------------------------
  //  STUDENT SECTION
  // ---------------------------------------------------------
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
                    '${_order.student!.avgRating.toStringAsFixed(1)}/5 (${_order.student!.totalReviews})',
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

  // -------------------------------------------------------------
  //  ORDER DETAILS SECTION
  // -------------------------------------------------------------
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
            InfoField(
              label: AppStrings.orderServices,
              value: _order.services.map((s) => serviceLabel(s)).join(', '),
            ),
            if (_order.notes != null && _order.notes!.isNotEmpty)
              InfoField(label: AppStrings.orderNotes, value: _order.notes!),
            if (_order.promoCode != null && _order.promoCode!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.promoCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: HelpiTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: HelpiTheme.textSecondary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: HelpiTheme.textSecondary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(
                          HelpiTheme.statusBadgeRadius,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _order.promoCode!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: HelpiTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () async {
                              final orderId = int.tryParse(_order.id);
                              if (orderId == null) return;
                              final api = AdminApiService();
                              final result = await api.updateOrderPromoCode(
                                orderId,
                                null,
                              );
                              if (!mounted) return;
                              if (!result.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result.error ?? 'Error'),
                                  ),
                                );
                                return;
                              }
                              await _refreshOrder();
                            },
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: HelpiTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  //  TERMINI (SESSIONS) SECTION
  // ---------------------------------------------------------------
  Widget _buildSessionsSection() {
    final hasRealSessions = _order.sessions.isNotEmpty;
    final isProjected = !hasRealSessions && _order.dayEntries.isNotEmpty;
    final projectedSessions = isProjected
        ? _generateProjectedSessions()
        : <SessionModel>[];
    final displaySessions = hasRealSessions
        ? _order.sessions
        : projectedSessions;

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
              Icon(
                Icons.calendar_month,
                size: 20,
                color: isProjected
                    ? HelpiTheme.textSecondary
                    : HelpiTheme.accent,
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
              if (isProjected) ...[
                const SizedBox(width: 8),
                StatusBadge(
                  textColor: HelpiTheme.statusProcessingText,
                  bgColor: HelpiTheme.statusProcessingBg,
                  label: AppStrings.sessionStatusPlanned,
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isProjected
                ? AppStrings.sessionsPlannedSubtitle
                : _order.frequency != FrequencyType.oneTime
                ? AppStrings.sessionsMonthlySubtitle
                : '',
            style: const TextStyle(
              fontSize: 12,
              color: HelpiTheme.textSecondary,
            ),
          ),
          if (displaySessions.isNotEmpty) ...[
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: displaySessions.length > 5 ? 380 : double.infinity,
              ),
              child: displaySessions.length > 5
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: displaySessions.length,
                      itemBuilder: (_, i) {
                        final session = displaySessions[i];
                        final isLast = i == displaySessions.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                          child: isProjected
                              ? _buildProjectedSessionCard(session)
                              : _buildSessionCard(session),
                        );
                      },
                    )
                  : Column(
                      children: displaySessions.asMap().entries.map((mapEntry) {
                        final isLast =
                            mapEntry.key == displaySessions.length - 1;
                        final session = mapEntry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                          child: isProjected
                              ? _buildProjectedSessionCard(session)
                              : _buildSessionCard(session),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  /// Generate projected session dates from OrderSchedule data (dayEntries).
  List<SessionModel> _generateProjectedSessions() {
    final sessions = <SessionModel>[];
    final startDate = _order.scheduledDate;
    final now = DateTime.now();
    final effectiveStart = startDate.isAfter(now) ? startDate : now;
    final isRecurring = _order.frequency != FrequencyType.oneTime;
    final horizonDate =
        _order.endDate ?? DateTime(now.year, now.month + 3, now.day);

    for (final entry in _order.dayEntries) {
      // Find first matching weekday on/after effectiveStart
      var current = effectiveStart;
      final daysToAdd = (entry.dayOfWeek - current.weekday + 7) % 7;
      current = current.add(Duration(days: daysToAdd));
      // If aligned to today but startDate is in the past, ensure we don't go before startDate
      if (current.isBefore(startDate)) {
        current = current.add(const Duration(days: 7));
      }

      if (!isRecurring) {
        // One-time: just the first matching date
        if (!current.isAfter(horizonDate)) {
          sessions.add(
            SessionModel(
              id: 'projected_${entry.dayOfWeek}_${sessions.length}',
              date: current,
              weekday: entry.dayOfWeek,
              startTime: entry.startTime,
              durationHours: entry.durationHours,
            ),
          );
        }
      } else {
        // Recurring: weekly until horizon
        while (!current.isAfter(horizonDate)) {
          sessions.add(
            SessionModel(
              id: 'projected_${entry.dayOfWeek}_${sessions.length}',
              date: current,
              weekday: entry.dayOfWeek,
              startTime: entry.startTime,
              durationHours: entry.durationHours,
            ),
          );
          current = current.add(const Duration(days: 7));
        }
      }
    }

    sessions.sort((a, b) => a.date.compareTo(b.date));
    return sessions;
  }

  /// Lighter card for projected (planned) sessions — no action buttons.
  Widget _buildProjectedSessionCard(SessionModel session) {
    final useShort = MediaQuery.sizeOf(context).width < 600;
    final dateStr =
        '${_dayName(session.weekday, short: useShort)}, ${formatDateDot(session.date)}';
    final timeStr = formatTimeOfDay(session.startTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HelpiTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_note,
                size: 18,
                color: HelpiTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: HelpiTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$timeStr  ·  ${session.durationHours}h',
                  style: const TextStyle(
                    fontSize: 13,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    final isCompleted = session.status == SessionStatus.completed;
    final isCancelled = session.status == SessionStatus.cancelled;

    final useShort = MediaQuery.sizeOf(context).width < 600;
    final dateStr =
        '${_dayName(session.weekday, short: useShort)}, ${formatDateDot(session.date)}';

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
                    ? Icons.event_available
                    : isCancelled
                    ? Icons.event_busy
                    : Icons.event,
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
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: HelpiTheme.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  '$timeStr  ·  ${session.durationHours}h',
                  style: const TextStyle(
                    fontSize: 13,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
              ],
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
          if (session.status == SessionStatus.scheduled) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Builder(
                builder: (context) {
                  final narrow = MediaQuery.sizeOf(context).width < 600;
                  return Row(
                    children: [
                      _SessionActionButton(
                        icon: Icons.edit_calendar,
                        label: narrow
                            ? AppStrings.sessionRescheduleShort
                            : AppStrings.sessionReschedule,
                        color: HelpiTheme.accent,
                        onTap: () => _showRescheduleSheet(session),
                      ),
                      const SizedBox(width: 12),
                      _SessionActionButton(
                        icon: Icons.cancel_outlined,
                        label: narrow
                            ? AppStrings.sessionCancelShort
                            : AppStrings.sessionCancel,
                        color: HelpiTheme.primary,
                        onTap: () => _confirmCancelSession(session),
                      ),
                    ],
                  );
                },
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

  Widget _sessionStatusBadge(SessionStatus status) =>
      StatusBadge.session(status);

  // ---------------------------------------------------------------
  //  ADMIN ACTIONS SECTION
  // ---------------------------------------------------------------

  Widget _buildAdminActionsSection() {
    final isCancelled = _order.status == OrderStatus.cancelled;
    final isCompleted = _order.status == OrderStatus.completed;
    final canCancel = !isCancelled && !isCompleted;

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
            if (!isCancelled)
              ActionChipButton(
                icon: Icons.discount_outlined,
                label: AppStrings.promoCodeApply,
                color: HelpiTheme.accent,
                onTap: _showPromoCodeDialog,
              ),
          ],
        ),
      ],
    );
  }

  void _showPromoCodeDialog() {
    final controller = TextEditingController(text: _order.promoCode ?? '');
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.promoCodeApply),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: AppStrings.promoCodeHint,
              labelText: AppStrings.promoCode,
              prefixIcon: const Icon(Icons.discount_outlined),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    ).then((code) async {
      if (code == null || !mounted) return;
      final orderId = int.tryParse(_order.id);
      if (orderId == null) return;
      final api = AdminApiService();
      final promoValue = code.isEmpty ? null : code;
      final result = await api.updateOrderPromoCode(orderId, promoValue);
      if (!mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error ?? 'Error')));
        return;
      }
      await _refreshOrder();
    });
  }

  void _confirmCancelOrder() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.cancelOrderConfirmTitle),
        content: SizedBox(
          width: 400,
          child: Text(AppStrings.cancelOrderConfirmMsg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.cancelOrderBtn),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true || !mounted) return;
      final orderId = int.tryParse(_order.id);
      if (orderId == null) return;
      final api = AdminApiService();
      final result = await api.cancelOrder(orderId, 'Cancelled by admin');
      if (!mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Error'),
            backgroundColor: HelpiTheme.primary,
          ),
        );
        return;
      }
      await _refreshOrder();
    });
  }

  // ---------------------------------------------------------------
  //  SESSION ACTIONS — CANCEL & RESCHEDULE
  // ---------------------------------------------------------------

  void _confirmCancelSession(SessionModel session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.sessionCancel),
        content: SizedBox(
          width: 400,
          child: Text(AppStrings.sessionCancelConfirm),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final sessionId = int.tryParse(session.id);
              if (sessionId == null) return;
              final api = AdminApiService();
              final result = await api.cancelSession(sessionId);
              if (!mounted) return;
              if (!result.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.error ?? 'Error')),
                );
                return;
              }
              await _refreshOrder();
            },
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
      // Student not available ? open reschedule sheet directly
      _showRescheduleSheet(session.copyWith(status: SessionStatus.scheduled));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.sessionReactivate),
        content: SizedBox(
          width: 400,
          child: Text(AppStrings.sessionReactivateConfirm),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final sessionId = int.tryParse(session.id);
              if (sessionId == null) return;
              final api = AdminApiService();
              final result = await api.reactivateSession(sessionId);
              if (!mounted) return;
              if (!result.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.error ?? 'Error')),
                );
                return;
              }
              await _refreshOrder();
            },
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

    final allActiveStudents = ref
        .read(studentsProvider)
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
        ...filteredStudents.where((s) => s.fullName != session.studentName).map(
          (student) {
            final senLat = _order.senior.latitude;
            final senLng = _order.senior.longitude;
            final stuLat = student.latitude;
            final stuLng = student.longitude;
            final distKm =
                (senLat != null &&
                    senLng != null &&
                    stuLat != null &&
                    stuLng != null)
                ? haversineKm(senLat, senLng, stuLat, stuLng)
                : null;
            final distLabel = distKm != null
                ? '${distKm.toStringAsFixed(1)} km'
                : '';
            final sep = distLabel.isNotEmpty ? '  ·  ' : '';
            return _StudentRadioTile(
              name: student.fullName,
              subtitle:
                  '⭐ ${student.avgRating.toStringAsFixed(1)}$sep$distLabel',
              isSelected: selectedStudentName == student.fullName,
              onTap: () {
                setSheetState(() {
                  selectedStudentName = student.fullName;
                });
              },
            );
          },
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.event, color: HelpiTheme.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.sessionRescheduleTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // -- Date picker row --
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
                  confirmText: AppStrings.ok,
                  cancelText: AppStrings.cancel,
                );
                if (picked != null) {
                  setSheetState(() => selectedDate = picked);
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // -- Time picker row (15-min intervals) --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _RescheduleRow(
              icon: Icons.access_time,
              label: AppStrings.sessionNewTime,
              value: timeLabel,
              onTap: () async {
                final picked = await show15MinTimePicker(
                  ctx,
                  initial: selectedTime,
                );
                if (!ctx.mounted) return;
                if (picked != null) {
                  setSheetState(() => selectedTime = picked);
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // -- Student selector label --
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

          // -- Student list (responsive) --
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

          // -- Confirm button --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: ActionChipButton(
                icon: Icons.check,
                label: AppStrings.confirm,
                color: HelpiTheme.primary,
                size: ActionChipButtonSize.medium,
                onTap: () async {
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  final sessionId = int.tryParse(session.id);
                  if (sessionId == null) return;
                  final api = AdminApiService();
                  // Find student ID from name
                  int? studentId;
                  if (selectedStudentName != null) {
                    final student = ref
                        .read(studentsProvider)
                        .where((s) => s.fullName == selectedStudentName)
                        .firstOrNull;
                    if (student != null) {
                      studentId = int.tryParse(student.id);
                    }
                  }
                  final result = await api.manageSession(
                    sessionId,
                    newDate: selectedDate,
                    newStartTime: selectedTime,
                    preferredStudentId: studentId,
                  );
                  if (!mounted) return;
                  if (!result.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.error ?? 'Error')),
                    );
                    return;
                  }
                  await _refreshOrder();
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

  // ---------------------------------------------------------------
  //  AVAILABILITY HELPERS
  // ---------------------------------------------------------------

  /// Returns the order's schedule slots as (dayOfWeek, startTime) pairs.
  // ---------------------------------------------------------------
  //  ASSIGN STUDENT (single-modal flow with back navigation)
  // ---------------------------------------------------------------
  Future<void> _showAssignSheet() async {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    Future<void> onConfirmed(
      StudentModel student,
      List<SessionInstancePreview> previewSessions,
    ) async {
      if (!context.mounted) return;

      // -- Backend assign per schedule --
      final assignApi = AdminApiService();
      final studentId = int.tryParse(student.id) ?? 0;
      final sIds = _order.scheduleIds;
      final entries = _order.dayEntries;

      // Build weekday ? scheduleId map (parallel arrays)
      final weekdayToSchedule = <int, int>{};
      for (var i = 0; i < sIds.length && i < entries.length; i++) {
        weekdayToSchedule[entries[i].dayOfWeek] = sIds[i];
      }

      // Determine which weekdays are fully skipped
      final skippedWeekdays = <int>{};
      final seenWeekdays = <int>{};
      for (final p in previewSessions) {
        seenWeekdays.add(p.weekday);
        if (!p.isSkipped) {
          // At least one session for this weekday is NOT skipped
          skippedWeekdays.remove(p.weekday);
        } else if (!skippedWeekdays.contains(p.weekday) &&
            !previewSessions.any(
              (o) => o.weekday == p.weekday && !o.isSkipped,
            )) {
          skippedWeekdays.add(p.weekday);
        }
      }

      // Assign each non-skipped schedule to backend
      for (final entry in weekdayToSchedule.entries) {
        final weekday = entry.key;
        final scheduleId = entry.value;
        if (skippedWeekdays.contains(weekday)) continue;

        final result = await assignApi.adminAssign(scheduleId, studentId);
        if (!mounted) return;
        if (!result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error'),
              backgroundColor: HelpiTheme.error,
            ),
          );
          return;
        }
      }

      if (!mounted) return;

      setState(() {
        final updatedSessions = _order.sessions.map((s) {
          if (s.status != SessionStatus.scheduled) return s;

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
          promoCode: _order.promoCode,
          scheduleIds: _order.scheduleIds,
        );
      });

      // Sync updated order back to provider for reactive UI
      ref.read(ordersProvider.notifier).updateItem(_order);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.assignSuccess),
          backgroundColor: HelpiTheme.accent,
        ),
      );
    }

    // Fetch available students per schedule and classify by coverage
    final api = AdminApiService();
    final scheduleIds = _order.scheduleIds;

    final Map<String, StudentModel> allStudents = {};
    final Map<String, int> studentScheduleHits = {};

    if (scheduleIds.isNotEmpty) {
      for (final sid in scheduleIds) {
        final result = await api.getAvailableStudentsForSchedule(sid);
        if (!mounted) return;
        if (!result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error'),
              backgroundColor: HelpiTheme.error,
            ),
          );
          return;
        }
        for (final s in result.data ?? <StudentModel>[]) {
          allStudents[s.id] = s;
          studentScheduleHits[s.id] = (studentScheduleHits[s.id] ?? 0) + 1;
        }
      }
    } else {
      // Fallback: single-date query for orders without scheduleIds
      final dateStr =
          '${_order.scheduledDate.year}-${_order.scheduledDate.month.toString().padLeft(2, '0')}-${_order.scheduledDate.day.toString().padLeft(2, '0')}';
      final startStr =
          '${_order.scheduledStart.hour.toString().padLeft(2, '0')}:${_order.scheduledStart.minute.toString().padLeft(2, '0')}';
      final endHour = _order.scheduledStart.hour + _order.durationHours;
      final endStr =
          '${endHour.toString().padLeft(2, '0')}:${_order.scheduledStart.minute.toString().padLeft(2, '0')}';

      final result = await api.getAvailableStudents(
        date: dateStr,
        startTime: startStr,
        endTime: endStr,
        orderId: int.tryParse(_order.id),
      );
      if (!mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Error'),
            backgroundColor: HelpiTheme.error,
          ),
        );
        return;
      }
      for (final s in result.data ?? <StudentModel>[]) {
        allStudents[s.id] = s;
        studentScheduleHits[s.id] = 1;
      }
    }

    final totalSchedules = scheduleIds.isNotEmpty ? scheduleIds.length : 1;
    final classified = <(StudentModel, _StudentAvail)>[];
    for (final entry in allStudents.entries) {
      if (entry.value.id == _order.student?.id) continue;
      final hits = studentScheduleHits[entry.key] ?? 0;
      final avail = hits >= totalSchedules
          ? _StudentAvail.full
          : _StudentAvail.differentTimes;
      classified.add((entry.value, avail));
    }
    final senLat = _order.senior.latitude;
    final senLng = _order.senior.longitude;
    classified.sort((a, b) {
      final aIdx = a.$2.index;
      final bIdx = b.$2.index;
      if (aIdx != bIdx) return aIdx.compareTo(bIdx);
      // Within same availability group, sort by distance (closest first)
      if (senLat != null && senLng != null) {
        final aLat = a.$1.latitude;
        final aLng = a.$1.longitude;
        final bLat = b.$1.latitude;
        final bLng = b.$1.longitude;
        final aDist = (aLat != null && aLng != null)
            ? haversineKm(senLat, senLng, aLat, aLng)
            : double.infinity;
        final bDist = (bLat != null && bLng != null)
            ? haversineKm(senLat, senLng, bLat, bLng)
            : double.infinity;
        if (aDist != bDist) return aDist.compareTo(bDist);
      }
      return b.$1.avgRating.compareTo(a.$1.avgRating);
    });

    if (!mounted) return;

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
        title: Text(AppStrings.confirm),
        content: SizedBox(
          width: 400,
          child: Text(AppStrings.assignConfirm(student.fullName)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(sheetContext);

              final api = AdminApiService();
              final studentId = int.tryParse(student.id) ?? 0;

              // Assign student to each schedule of this order
              for (final scheduleId in _order.scheduleIds) {
                final result = await api.adminAssign(scheduleId, studentId);
                if (!result.success) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.error ?? 'Error'),
                      backgroundColor: HelpiTheme.error,
                    ),
                  );
                  return;
                }
              }

              if (!mounted) return;

              setState(() {
                // Propagate student to all upcoming sessions
                final updatedSessions = _order.sessions.map((s) {
                  if (s.status == SessionStatus.scheduled) {
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
                  promoCode: _order.promoCode,
                  scheduleIds: _order.scheduleIds,
                );
              });

              // Sync updated order back to provider for reactive UI
              ref.read(ordersProvider.notifier).updateItem(_order);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.assignSuccess),
                  backgroundColor: HelpiTheme.accent,
                ),
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

  // ---------------------------------------------------------------
  //  HELPERS
  // ---------------------------------------------------------------

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

  String _dayName(int dayOfWeek, {bool short = false}) {
    switch (dayOfWeek) {
      case 1:
        return short ? AppStrings.dayMon : AppStrings.dayMonFull;
      case 2:
        return short ? AppStrings.dayTue : AppStrings.dayTueFull;
      case 3:
        return short ? AppStrings.dayWed : AppStrings.dayWedFull;
      case 4:
        return short ? AppStrings.dayThu : AppStrings.dayThuFull;
      case 5:
        return short ? AppStrings.dayFri : AppStrings.dayFriFull;
      case 6:
        return short ? AppStrings.daySat : AppStrings.daySatFull;
      case 7:
        return short ? AppStrings.daySun : AppStrings.daySunFull;
      default:
        return '';
    }
  }
}

// ---------------------------------------------------------------
//  STUDENT ASSIGN CARD (bottom sheet)
// ---------------------------------------------------------------
//  STUDENT AVAILABILITY CATEGORY
// ---------------------------------------------------------------
enum _StudentAvail { full, differentTimes }

// ---------------------------------------------------------------
//  STUDENT ASSIGN CARD (bottom sheet)
// ---------------------------------------------------------------
class _StudentAssignCard extends StatelessWidget {
  const _StudentAssignCard({
    required this.student,
    required this.avail,
    required this.onAssign,
    this.distanceKm,
  });
  final StudentModel student;
  final _StudentAvail avail;
  final VoidCallback onAssign;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final String availLabel;
    final Color availColor;
    final IconData availIcon;
    final String buttonLabel;
    final IconData buttonIcon;

    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    if (avail == _StudentAvail.full) {
      availLabel = AppStrings.availableAllDays;
      availColor = HelpiTheme.accent;
      availIcon = Icons.check_circle_outline;
      buttonLabel = isNarrow
          ? AppStrings.assignShort
          : AppStrings.assignStudent;
      buttonIcon = Icons.person_add;
    } else {
      availLabel = isNarrow
          ? AppStrings.availableDifferentTimesShort
          : AppStrings.availableDifferentTimes;
      availColor = const Color(0xFFE65100);
      availIcon = Icons.schedule;
      buttonLabel = isNarrow
          ? AppStrings.reviewShort
          : AppStrings.reviewSessions;
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
          // -- Avatar --
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

          // -- Info --
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
                      student.avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        color: HelpiTheme.textSecondary,
                      ),
                    ),
                    if (distanceKm != null) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: HelpiTheme.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 13,
                          color: HelpiTheme.textSecondary,
                        ),
                      ),
                    ],
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

          // -- Action button --
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

// ---------------------------------------------------------------
//  SESSION ACTION BUTTON (small tappable label)
// ---------------------------------------------------------------
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

// ---------------------------------------------------------------
//  RESCHEDULE ROW (date / time picker trigger)
// ---------------------------------------------------------------
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

// ---------------------------------------------------------------
//  ORDER ASSIGN FLOW SHEET (single modal: student list ? session preview)
// ---------------------------------------------------------------
class _OrderAssignFlowSheet extends ConsumerStatefulWidget {
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
  ConsumerState<_OrderAssignFlowSheet> createState() =>
      _OrderAssignFlowSheetState();
}

class _OrderAssignFlowSheetState extends ConsumerState<_OrderAssignFlowSheet> {
  StudentModel? _selectedStudent;
  bool _onlyWorkedWithSenior = false;
  String? _selectedFaculty;

  List<(StudentModel, _StudentAvail)> get _filteredClassified {
    var list = widget.classified;
    if (_onlyWorkedWithSenior) {
      list = list.where((e) => e.$1.previousJobsWithSenior > 0).toList();
    }
    if (_selectedFaculty != null) {
      list = list.where((e) => e.$1.faculty == _selectedFaculty).toList();
    }
    return list;
  }

  void _selectStudent(StudentModel student) {
    setState(() => _selectedStudent = student);
  }

  void _goBack() {
    setState(() => _selectedStudent = null);
  }

  @override
  Widget build(BuildContext context) {
    final content = _selectedStudent != null
        ? Builder(
            builder: (_) {
              final helper = _OrderSessionPreviewHelper(
                student: _selectedStudent!,
                order: widget.order,
                allOrders: ref.read(ordersProvider),
                allStudents: ref.read(studentsProvider),
              );
              return SessionPreviewContent(
                key: ValueKey(_selectedStudent!.id),
                student: _selectedStudent!,
                order: widget.order,
                onBack: _goBack,
                onAssigned: (sessions) =>
                    widget.onAssignConfirmed(_selectedStudent!, sessions),
                useDialog: widget.useDialog,
                generateSessions: helper.generateSessions,
                findSubstitutes: helper.findSubstitutes,
                findAltSlots: helper.findAltSlots,
                buildConflictMessage: helper.buildConflictMessage,
              );
            },
          )
        : _buildStudentList();

    if (widget.useDialog) {
      return Container(
        decoration: BoxDecoration(
          color: HelpiTheme.scaffold,
          borderRadius: BorderRadius.all(
            Radius.circular(HelpiTheme.cardRadius),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(HelpiTheme.cardRadius),
          ),
          child: content,
        ),
      );
    }

    final height = _selectedStudent != null ? 0.9 : 0.65;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      height: MediaQuery.of(context).size.height * height,
      decoration: BoxDecoration(
        color: HelpiTheme.scaffold,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(HelpiTheme.cardRadius),
        ),
      ),
      child: content,
    );
  }

  Widget _buildStudentList() {
    final filtered = _filteredClassified;

    // Collect unique faculty names for dropdown
    final faculties =
        widget.classified
            .map((e) => e.$1.faculty)
            .where((f) => f.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.useDialog)
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: DragHandle(),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
          child: Row(
            children: [
              const Icon(Icons.people_outline, color: HelpiTheme.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${AppStrings.suggestedStudents} (${filtered.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        // ── Filter bar ──
        Builder(
          builder: (context) {
            final dropdownWidget = faculties.length > 1
                ? Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 20,
                          color: _selectedFaculty != null
                              ? HelpiTheme.accent
                              : HelpiTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedFaculty,
                              isDense: true,
                              isExpanded: true,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              hint: Text(
                                AppStrings.anyFaculty,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    AppStrings.anyFaculty,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                ...faculties.map(
                                  (f) => DropdownMenuItem<String?>(
                                    value: f,
                                    child: Text(
                                      f,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedFaculty = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null;

            final isNarrow = MediaQuery.sizeOf(context).width < 600;

            final historyIcon = Tooltip(
              message: AppStrings.filterBySenior,
              child: isNarrow
                  ? IconButton(
                      icon: Icon(
                        Icons.history,
                        size: 20,
                        color: _onlyWorkedWithSenior
                            ? HelpiTheme.accent
                            : HelpiTheme.textSecondary,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size.zero,
                        backgroundColor: _onlyWorkedWithSenior
                            ? HelpiTheme.pastelTeal
                            : null,
                      ),
                      onPressed: () => setState(
                        () => _onlyWorkedWithSenior = !_onlyWorkedWithSenior,
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.history,
                        size: 20,
                        color: _onlyWorkedWithSenior
                            ? HelpiTheme.accent
                            : HelpiTheme.textSecondary,
                      ),
                      style: _onlyWorkedWithSenior
                          ? IconButton.styleFrom(
                              backgroundColor: HelpiTheme.pastelTeal,
                            )
                          : null,
                      onPressed: () => setState(
                        () => _onlyWorkedWithSenior = !_onlyWorkedWithSenior,
                      ),
                    ),
            );

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 0, isNarrow ? 16 : 8, 4),
              child: Row(
                children: [
                  ?dropdownWidget,
                  if (dropdownWidget == null) const Spacer(),
                  historyIcon,
                ],
              ),
            );
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.noStudentsFound,
                    style: const TextStyle(color: HelpiTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final (student, avail) = filtered[i];
                    final senLat = widget.order.senior.latitude;
                    final senLng = widget.order.senior.longitude;
                    final stuLat = student.latitude;
                    final stuLng = student.longitude;
                    final distKm =
                        (senLat != null &&
                            senLng != null &&
                            stuLat != null &&
                            stuLng != null)
                        ? haversineKm(senLat, senLng, stuLat, stuLng)
                        : null;
                    return _StudentAssignCard(
                      student: student,
                      avail: avail,
                      distanceKm: distKm,
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

// ---------------------------------------------------------------
//  ORDER SESSION PREVIEW — helper with order-specific logic
// ---------------------------------------------------------------

/// Holds order-detail-specific session generation, substitute filtering,
/// and conflict messaging. Passed as callbacks to [SessionPreviewContent].
class _OrderSessionPreviewHelper extends SessionPreviewHelperBase {
  _OrderSessionPreviewHelper({
    required super.student,
    required super.order,
    required super.allOrders,
    required super.allStudents,
  });

  @override
  bool isSubstituteCandidate(StudentModel s) {
    if (s.id == student.id) return false;
    if (!s.isActive || s.contractStatus != ContractStatus.active) return false;
    return true;
  }

  @override
  bool onNoAvailability(StudentModel s) => s.availability.isEmpty;

  @override
  List<SessionInstancePreview> generateSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final studentOrders = allOrders
        .where(
          (o) =>
              o.student?.id == student.id &&
              o.status != OrderStatus.cancelled &&
              o.status != OrderStatus.completed &&
              o.id != order.id,
        )
        .toList();

    // One-time order ? single session
    if (order.frequency == FrequencyType.oneTime) {
      final startMin = toMinutes(order.scheduledStart);
      final endMin = startMin + order.durationHours * 60;
      final weekday = order.scheduledDate.weekday;

      final availConflict = _checkAvailability(weekday, startMin);
      final schedConflict = availConflict
          ? null
          : findConflict(
              date: order.scheduledDate,
              weekday: weekday,
              startMin: startMin,
              endMin: endMin,
              studentOrders: studentOrders,
            );

      return [
        SessionInstancePreview(
          date: order.scheduledDate,
          weekday: weekday,
          startTime: order.scheduledStart,
          durationHours: order.durationHours,
          conflictType: (availConflict || schedConflict != null)
              ? SessionConflictType.conflict
              : SessionConflictType.free,
          conflictingOrder: schedConflict,
        ),
      ];
    }

    // Recurring order ? generate from dayEntries for next 8 weeks
    final List<SessionInstancePreview> result = [];
    for (final entry in order.dayEntries) {
      var nextDate = today;
      while (nextDate.weekday != entry.dayOfWeek) {
        nextDate = nextDate.add(const Duration(days: 1));
      }
      for (int week = 0; week < 8; week++) {
        final sessionDate = nextDate.add(Duration(days: week * 7));
        if (order.endDate != null && sessionDate.isAfter(order.endDate!)) break;

        final startMin = toMinutes(entry.startTime);
        final endMin = startMin + entry.durationHours * 60;

        final availConflict = _checkAvailability(entry.dayOfWeek, startMin);
        final schedConflict = availConflict
            ? null
            : findConflict(
                date: sessionDate,
                weekday: entry.dayOfWeek,
                startMin: startMin,
                endMin: endMin,
                studentOrders: studentOrders,
              );

        result.add(
          SessionInstancePreview(
            date: sessionDate,
            weekday: entry.dayOfWeek,
            startTime: entry.startTime,
            durationHours: entry.durationHours,
            conflictType: (availConflict || schedConflict != null)
                ? SessionConflictType.conflict
                : SessionConflictType.free,
            conflictingOrder: schedConflict,
          ),
        );
      }
    }
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  /// Returns `true` if the student is NOT available on [weekday] at [startMin].
  bool _checkAvailability(int weekday, int startMin) {
    if (student.availability.isEmpty) return false;
    final dayAvail = student.availability.where((a) => a.dayOfWeek == weekday);
    if (dayAvail.isEmpty || !dayAvail.first.isEnabled) return true;
    final avail = dayAvail.first;
    final fromMin = toMinutes(avail.from);
    final toMin = toMinutes(avail.to);
    return startMin < fromMin || startMin >= toMin;
  }

  @override
  String buildConflictMessage(SessionInstancePreview s) {
    if (s.conflictingOrder != null) {
      return '${AppStrings.conflictWith} '
          '#${s.conflictingOrder!.orderNumber} '
          '${s.conflictingOrder!.senior.fullName}';
    }
    // Check if student has ANY availability slot for this weekday
    final hasDay = student.availability.any(
      (a) => a.dayOfWeek == s.weekday && a.isEnabled,
    );
    return hasDay ? AppStrings.timeMismatch : AppStrings.unavailableDay;
  }
}

// ---------------------------------------------------------------
//  STUDENT RADIO TILE (for reschedule student selector)
// ---------------------------------------------------------------
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
