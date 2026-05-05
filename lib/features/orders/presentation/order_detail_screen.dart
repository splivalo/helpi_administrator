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
import 'package:helpi_admin/features/students/presentation/student_detail_screen.dart';
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
  List<Map<String, dynamic>> _seniorCoupons = [];
  bool _couponsLoading = false;
  bool _isAssigning = false;

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
    _loadSeniorCoupons();

    // Auto-refresh when SignalR updates ordersProvider (EntityChanged).
    // Suppress during active assignment to avoid race conditions.
    ref.listenManual(ordersProvider, (prev, next) {
      if (_isAssigning) return;
      final updated = next.where((o) => o.id == _order.id).firstOrNull;
      if (updated == null) return;
      if (updated.status != _order.status ||
          updated.student?.id != _order.student?.id) {
        _refreshOrder();
      }
    });

    // Auto-refresh sessions when SignalR sends EntityChanged for Sessions/Orders
    ref.listenManual(sessionsVersionProvider, (prev, next) {
      if (prev != null && next != prev) {
        debugPrint(
          '[OrderDetailScreen] sessionsVersion changed $prev → $next, reloading sessions',
        );
        _loadSessions();
        _loadSeniorCoupons();
      }
    });
  }

  /// ISO date string for current month boundary queries.
  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Returns (from, to) capped to the relevant month.
  /// For orders starting in the future, uses that start month.
  /// For one-time orders this is unused — no filter is applied.
  ({String from, String to}) _monthRange() {
    final now = DateTime.now();
    final ref = _order.scheduledDate.isAfter(now) ? _order.scheduledDate : now;
    return (
      from: _isoDate(DateTime(ref.year, ref.month)),
      to: _isoDate(DateTime(ref.year, ref.month + 1, 0)),
    );
  }

  Future<void> _loadSessions() async {
    final orderId = int.tryParse(_order.id);
    if (orderId == null) return;
    // One-time orders have at most 1 session — skip date filter so it's
    // always returned regardless of which month it falls in.
    final isOneTime = _order.frequency == FrequencyType.oneTime;
    final range = isOneTime ? null : _monthRange();
    final result = await AdminApiService().getSessionsByOrder(
      orderId,
      from: range?.from,
      to: range?.to,
    );
    if (!mounted) return;
    setState(() {
      _sessionsLoading = false;
      if (result.success && result.data != null) {
        _order = _order.copyWith(sessions: result.data);
      }
    });
  }

  Future<void> _loadSeniorCoupons() async {
    final seniorId = int.tryParse(_order.senior.id);
    if (seniorId == null) return;
    setState(() => _couponsLoading = true);
    final result = await AdminApiService().getSeniorCoupons(seniorId);
    if (!mounted) return;
    setState(() {
      _couponsLoading = false;
      if (result.success && result.data != null) {
        _seniorCoupons = result.data!;
      }
    });
  }

  /// Lightweight reload: fetch only this order + its sessions.
  /// Falls back to full reload if the single-order fetch fails.
  Future<void> _refreshOrder() async {
    if (_isAssigning) return; // Suppress during multi-schedule assignment
    final orderId = int.tryParse(_order.id);
    if (orderId == null) return;

    final api = AdminApiService();
    final isOneTime = _order.frequency == FrequencyType.oneTime;
    final range = isOneTime ? null : _monthRange();
    final results = await Future.wait([
      api.getOrder(orderId),
      api.getSessionsByOrder(orderId, from: range?.from, to: range?.to),
    ]);
    if (!mounted) return;

    final orderResult = results[0] as ApiResult<OrderModel>;
    final sessionsResult = results[1] as ApiResult<List<SessionModel>>;

    if (orderResult.success && orderResult.data != null) {
      final refreshed = sessionsResult.success && sessionsResult.data != null
          ? orderResult.data!.copyWith(sessions: sessionsResult.data)
          : orderResult.data!;
      setState(() => _order = refreshed);

      // Keep the global provider in sync so other screens see the update.
      ref.read(ordersProvider.notifier).updateItem(refreshed);
    } else {
      // Fallback: full reload (e.g. order was deleted or network hiccup).
      await DataLoader.loadAll(ref: ref);
      if (!mounted) return;
      final fallback = ref
          .read(ordersProvider)
          .where((o) => o.id == _order.id)
          .firstOrNull;
      if (fallback != null) {
        setState(() => _order = fallback);
      }
      await _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpiAppBar(
        titleSpacing: HelpiAppBar.innerTitleSpacing,
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
          ]..removeWhere((w) => w is SizedBox && w.child == null);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < sections.length; i++) ...[
                  sections[i],
                  if (i < sections.length - 1) const SizedBox(height: 10),
                ],
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
              style: TextStyle(
                fontSize: 13,
                color: HelpiColors.of(context).textSecondary,
              ),
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
    final pendingIds = ref.watch(pendingAcceptanceOrderIdsProvider);
    final pendingData = ref.watch(pendingAcceptanceDataProvider);
    final orderId = int.tryParse(_order.id);
    final isPending = pendingIds.contains(orderId);
    final pendingInfo = orderId != null ? pendingData[orderId] : null;

    return SectionCard(
      title: AppStrings.orderStudent,
      icon: Icons.school,
      children: [
        if (_order.student != null && !isPending) ...[
          // ── Case A: Student assigned & accepted ──
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
        ] else if (isPending) ...[
          // ── Case B: Student assigned but awaiting acceptance ──
          _buildPendingBanner(),
          const SizedBox(height: 8),
          ResponsiveFieldGrid(
            children: [
              InfoField(
                label: AppStrings.studentFirstName,
                value:
                    _order.student?.firstName ??
                    (pendingInfo?['studentName'] as String?)
                        ?.split(' ')
                        .first ??
                    '—',
              ),
              InfoField(
                label: AppStrings.studentLastName,
                value:
                    _order.student?.lastName ??
                    (pendingInfo?['studentName'] as String?)
                        ?.split(' ')
                        .skip(1)
                        .join(' ') ??
                    '—',
              ),
              if (_order.student != null) ...[
                InfoField(
                  label: AppStrings.studentRating,
                  value:
                      '${_order.student!.avgRating.toStringAsFixed(1)}/5 (${_order.student!.totalReviews})',
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ActionChipButton(
            icon: Icons.swap_horiz,
            label: AppStrings.reassignStudent,
            color: HelpiTheme.accent,
            outlined: true,
            onTap: () => _showAssignSheet(),
          ),
        ] else ...[
          // ── Case C: No student at all ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 36,
                    color: HelpiColors.of(context).border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.noStudentAssigned,
                    style: TextStyle(
                      color: HelpiColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (_order.status == OrderStatus.processing ||
              _order.status == OrderStatus.active)
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

  Widget _buildPendingBanner() {
    // Collect unique students from scheduled sessions
    final studentDays = <String, List<String>>{};
    for (final s in _order.sessions) {
      if (s.studentName != null && s.status == SessionStatus.scheduled) {
        studentDays.putIfAbsent(s.studentName!, () => []);
        final day = _dayName(s.weekday, short: true);
        if (!studentDays[s.studentName!]!.contains(day)) {
          studentDays[s.studentName!]!.add(day);
        }
      }
    }

    final String bannerText;
    if (studentDays.length > 1) {
      final parts = studentDays.entries
          .map((e) => '${e.key} (${e.value.join(', ')})')
          .join(', ');
      bannerText = '${AppStrings.awaitingAcceptanceMulti}: $parts';
    } else {
      bannerText = AppStrings.studentAwaitingAcceptance;
    }

    return Builder(
      builder: (context) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        final bg = dark
            ? HelpiTheme.statusProcessingText.withValues(alpha: 0.15)
            : HelpiTheme.statusProcessingBg;
        final borderC = HelpiTheme.statusProcessingText.withValues(alpha: 0.3);
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderC),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.hourglass_top,
                size: 18,
                color: HelpiTheme.statusProcessingText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bannerText,
                  style: const TextStyle(
                    color: HelpiTheme.statusProcessingText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Refresh pending acceptance providers after admin assigns a student.
  Future<void> _refreshPendingData(String studentName) async {
    final orderId = int.tryParse(_order.id);
    if (orderId == null) return;

    // Optimistic update — add this order to pending immediately
    final currentIds = ref.read(pendingAcceptanceOrderIdsProvider);
    ref.read(pendingAcceptanceOrderIdsProvider.notifier).state = {
      ...currentIds,
      orderId,
    };

    final currentData = ref.read(pendingAcceptanceDataProvider);
    ref.read(pendingAcceptanceDataProvider.notifier).state = {
      ...currentData,
      orderId: <String, dynamic>{
        'orderId': orderId,
        'studentName': studentName,
        'seniorName': _order.senior.fullName,
        'minutesPending': 0,
      },
    };
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
            if (_couponsLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (_seniorCoupons.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.couponActiveCoupons,
                      style: TextStyle(
                        fontSize: 12,
                        color: HelpiColors.of(context).textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _seniorCoupons.map((c) {
                        final code = c['couponCode'] as String? ?? '';
                        final assignmentId = c['id'] as int? ?? 0;
                        final remaining = (c['remainingValue'] as num?)
                            ?.toDouble();
                        final couponType = c['couponType'] as int? ?? 0;
                        final couponValue =
                            (c['couponValue'] as num?)?.toDouble() ?? 0;
                        final couponName = c['couponName'] as String? ?? code;

                        // Build hover tooltip
                        String tooltip = couponName;
                        if (couponType <= 2 && remaining != null) {
                          // Hour-based: show remaining
                          tooltip =
                              '$couponName\n${remaining.toStringAsFixed(remaining == remaining.roundToDouble() ? 0 : 1)}h preostalo od ${couponValue.toStringAsFixed(couponValue == couponValue.roundToDouble() ? 0 : 1)}h';
                        } else if (couponType == 3) {
                          tooltip =
                              '$couponName\n${couponValue.toStringAsFixed(0)}% po terminu';
                        } else if (couponType == 4) {
                          tooltip =
                              '$couponName\n€${couponValue.toStringAsFixed(2)} po terminu';
                        }

                        return Tooltip(
                          message: tooltip,
                          child: Chip(
                            avatar: const Icon(Icons.local_offer, size: 14),
                            label: Text(
                              code,
                              style: const TextStyle(fontSize: 11),
                            ),
                            side: BorderSide(
                              color: HelpiColors.of(context).border,
                              width: 0.5,
                            ),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            deleteButtonTooltipMessage: '',
                            onDeleted: () =>
                                _deactivateSeniorCoupon(assignmentId),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }).toList(),
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
    final isOrderCancelled = _order.status == OrderStatus.cancelled;
    final projectedSessions = isProjected
        ? _generateProjectedSessions()
        : <SessionModel>[];
    final displaySessions = hasRealSessions
        ? _order.sessions
        : projectedSessions;

    final hasStudent = _order.student != null;
    final isMuted = (isProjected && !hasStudent) || isOrderCancelled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HelpiColors.of(context).surface,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiColors.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 20,
                color: isMuted
                    ? HelpiColors.of(context).textSecondary
                    : HelpiTheme.accent,
              ),
              const SizedBox(width: 8),
              Text(
                _order.frequency == FrequencyType.oneTime
                    ? AppStrings.sessionsTitleSingular
                    : AppStrings.sessionsTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HelpiColors.of(context).textPrimary,
                ),
              ),
            ],
          ),
          if (_order.frequency != FrequencyType.oneTime &&
              !isOrderCancelled) ...[
            const SizedBox(height: 6),
            Text(
              () {
                final now = DateTime.now();
                final ref = _order.scheduledDate.isAfter(now)
                    ? _order.scheduledDate
                    : now;
                return AppStrings.sessionsMonthlySubtitle(
                  AppStrings.monthName(ref.month),
                  ref.year,
                );
              }(),
              style: TextStyle(
                fontSize: 12,
                color: HelpiColors.of(context).textSecondary,
              ),
            ),
          ],
          if (isOrderCancelled) ...[
            const SizedBox(height: 6),
            Text(
              AppStrings.sessionsCancelledSubtitle,
              style: TextStyle(
                fontSize: 12,
                color: HelpiColors.of(context).textSecondary,
              ),
            ),
          ],
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
                          child: isProjected && !hasStudent
                              ? _buildProjectedSessionCard(session)
                              : _buildSessionCard(
                                  session,
                                  orderCancelled: isOrderCancelled,
                                ),
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
                          child: isProjected && !hasStudent
                              ? _buildProjectedSessionCard(session)
                              : _buildSessionCard(
                                  session,
                                  orderCancelled: isOrderCancelled,
                                ),
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
    // Cap projected sessions to end of the month in which the order starts
    // (effectiveStart month). This handles both:
    //  - Orders starting this month → shows remainder of current month
    //  - Orders starting next month → shows their first full month
    // If order.endDate is earlier than that, use endDate instead.
    final endOfStartMonth = DateTime(
      effectiveStart.year,
      effectiveStart.month + 1,
      0,
    );
    final horizonDate =
        _order.endDate != null && _order.endDate!.isBefore(endOfStartMonth)
        ? _order.endDate!
        : endOfStartMonth;

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
              endTime: TimeOfDay(
                hour: (entry.startTime.hour + entry.durationHours) % 24,
                minute: entry.startTime.minute,
              ),
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
              endTime: TimeOfDay(
                hour: (entry.startTime.hour + entry.durationHours) % 24,
                minute: entry.startTime.minute,
              ),
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
        color: HelpiColors.of(context).scaffold,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_note,
                size: 18,
                color: HelpiColors.of(context).textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateStr,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: HelpiColors.of(context).textSecondary,
                  ),
                ),
              ),
              StatusBadge(
                textColor: HelpiTheme.statusProcessingText,
                bgColor: HelpiTheme.statusProcessingBg,
                label: AppStrings.sessionStatusPlanned,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: HelpiColors.of(context).textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$timeStr  ·  ${session.durationHours}h',
                  style: TextStyle(
                    fontSize: 13,
                    color: HelpiColors.of(context).textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSessionActive(SessionModel s) {
    if (s.status != SessionStatus.scheduled) return false;
    final now = DateTime.now();
    final start = DateTime(
      s.date.year,
      s.date.month,
      s.date.day,
      s.startTime.hour,
      s.startTime.minute,
    );
    final end = DateTime(
      s.date.year,
      s.date.month,
      s.date.day,
      s.endTime.hour,
      s.endTime.minute,
    );
    return now.isAfter(start) && now.isBefore(end);
  }

  bool _isSessionDone(SessionModel s) {
    if (s.status == SessionStatus.completed) return true;
    if (s.status != SessionStatus.scheduled) return false;
    final end = DateTime(
      s.date.year,
      s.date.month,
      s.date.day,
      s.endTime.hour,
      s.endTime.minute,
    );
    return DateTime.now().isAfter(end);
  }

  Widget _buildSessionCard(
    SessionModel session, {
    bool orderCancelled = false,
  }) {
    final isCancelled =
        session.status == SessionStatus.cancelled || orderCancelled;

    final useShort = MediaQuery.sizeOf(context).width < 600;
    final dateStr =
        '${_dayName(session.weekday, short: useShort)}, ${formatDateDot(session.date)}';

    final timeStr = formatTimeOfDay(session.startTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HelpiColors.of(context).surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HelpiColors.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: date + status badge
          Row(
            children: [
              Icon(
                _isSessionDone(session)
                    ? Icons.event_available
                    : isCancelled
                    ? Icons.event_busy
                    : _isSessionActive(session)
                    ? Icons.event_available
                    : Icons.event,
                size: 18,
                color: _isSessionDone(session)
                    ? HelpiTheme.accent
                    : isCancelled
                    ? HelpiTheme.statusCancelledText
                    : _isSessionActive(session)
                    ? HelpiTheme.statusActiveText
                    : HelpiTheme.statusScheduledText,
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
                              ? HelpiColors.of(context).textSecondary
                              : HelpiColors.of(context).textPrimary,
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (session.isModified && !orderCancelled) ...[
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
              if (orderCancelled)
                StatusBadge.session(SessionStatus.cancelled)
              else
                LiveSessionBadge(
                  status: session.status,
                  date: session.date,
                  startTime: session.startTime,
                  endTime: session.endTime,
                  onPhaseChanged: () {
                    if (mounted) setState(() {});
                  },
                ),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: HelpiColors.of(context).textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Row 3: student name (+ pending status as subtitle)
          if (session.studentName != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      session.assignmentPending
                          ? Icons.hourglass_top_rounded
                          : Icons.person_outline,
                      size: 14,
                      color: session.assignmentPending
                          ? HelpiTheme.statusProcessingText
                          : HelpiTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.studentName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: HelpiColors.of(context).textSecondary,
                        ),
                      ),
                      if (session.assignmentPending)
                        Text(
                          AppStrings.studentAwaitingAcceptance,
                          style: const TextStyle(
                            fontSize: 11,
                            color: HelpiTheme.statusProcessingText,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Row 4: action buttons (scheduled sessions, NOT on cancelled orders)
          if (session.status == SessionStatus.scheduled && !orderCancelled) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Builder(
                builder: (context) {
                  final narrow = MediaQuery.sizeOf(context).width < 600;
                  final now = DateTime.now();
                  final start = DateTime(
                    session.date.year,
                    session.date.month,
                    session.date.day,
                    session.startTime.hour,
                    session.startTime.minute,
                  );
                  final isActiveOrDone = now.isAfter(start);
                  return Row(
                    children: [
                      _SessionActionButton(
                        icon: Icons.edit_calendar,
                        label: narrow
                            ? AppStrings.sessionRescheduleShort
                            : AppStrings.sessionReschedule,
                        color: HelpiTheme.accent,
                        onTap: isActiveOrDone
                            ? null
                            : () => _showRescheduleSheet(session),
                      ),
                      const SizedBox(width: 12),
                      _SessionActionButton(
                        icon: Icons.cancel_outlined,
                        label: narrow
                            ? AppStrings.sessionCancelShort
                            : AppStrings.sessionCancel,
                        color: HelpiTheme.primary,
                        onTap: isActiveOrDone
                            ? null
                            : () => _confirmCancelSession(session),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],

          // Row 4b: reactivate button (only for cancelled sessions, NOT on cancelled orders)
          if (session.status == SessionStatus.cancelled && !orderCancelled) ...[
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

  // ---------------------------------------------------------------
  //  ADMIN ACTIONS SECTION
  // ---------------------------------------------------------------

  Widget _buildAdminActionsSection() {
    final isCancelled = _order.status == OrderStatus.cancelled;
    final isCompleted = _order.status == OrderStatus.completed;
    final canCancel = !isCancelled && !isCompleted;

    // No actions for cancelled orders — hide entire section
    if (isCancelled) return const SizedBox.shrink();

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
                icon: Icons.local_offer,
                label: AppStrings.couponAssignSenior,
                color: HelpiTheme.accent,
                onTap: _showCouponDialog,
              ),
          ],
        ),
      ],
    );
  }

  void _showCouponDialog() {
    final controller = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.couponRedeemTitle),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: AppStrings.couponRedeemHint,
              labelText: AppStrings.couponCode,
              prefixIcon: const Icon(Icons.local_offer),
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
      if (code == null || code.isEmpty || !mounted) return;
      final seniorId = int.tryParse(_order.senior.id);
      if (seniorId == null) return;
      final api = AdminApiService();
      final result = await api.redeemCouponForSenior(code, seniorId);
      if (!mounted) return;
      if (!result.success) {
        showErrorSnack(context, result.error ?? AppStrings.couponRedeemFailed);
        return;
      }
      final data = result.data;
      if (data != null && data['isValid'] == true) {
        showSuccessSnack(context, AppStrings.couponRedeemed);
        await _loadSeniorCoupons();
      } else {
        final errorCode = data?['errorCode'] as String? ?? '';
        showErrorSnack(context, _mapCouponErrorCode(errorCode));
      }
    });
  }

  Future<void> _deactivateSeniorCoupon(int assignmentId) async {
    final api = AdminApiService();
    final result = await api.deactivateMyAssignment(assignmentId);
    if (!mounted) return;
    if (result.success) {
      showSuccessSnack(context, AppStrings.couponDeactivated);
      await _loadSeniorCoupons();
    } else {
      showErrorSnack(
        context,
        result.error ?? AppStrings.couponDeactivateFailed,
      );
    }
  }

  String _mapCouponErrorCode(String code) {
    switch (code) {
      case 'coupon_not_found':
        return AppStrings.couponNotFound;
      case 'coupon_already_active':
        return AppStrings.couponAlreadyActive;
      case 'coupon_inactive':
        return AppStrings.couponInactive;
      case 'coupon_not_yet_valid':
        return AppStrings.couponNotYetValid;
      case 'coupon_expired':
        return AppStrings.couponExpired;
      case 'exclusive_coupon_conflict':
        return AppStrings.couponExclusiveConflict;
      default:
        return AppStrings.couponRedeemFailed;
    }
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
            style: TextButton.styleFrom(foregroundColor: HelpiTheme.error),
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
        showErrorSnack(context, result.error ?? 'Error');
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
            style: TextButton.styleFrom(foregroundColor: HelpiTheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final sessionId = int.tryParse(session.id);
              if (sessionId == null) return;
              final api = AdminApiService();
              final result = await api.cancelSession(sessionId);
              if (!mounted) return;
              if (!result.success) {
                showErrorSnack(context, result.error ?? 'Error');
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

  void _confirmReactivateSession(SessionModel session) {
    // Always show modal with student picker (like reschedule)
    _showRescheduleSheet(
      session.copyWith(status: SessionStatus.scheduled),
      isReactivation: true,
    );
  }

  void _showRescheduleSheet(
    SessionModel session, {
    bool isReactivation = false,
  }) {
    DateTime selectedDate = session.date;
    // Snap to nearest 15-min interval
    final originalSnappedTime = TimeOfDay(
      hour: session.startTime.hour,
      minute: (session.startTime.minute ~/ 15) * 15,
    );
    TimeOfDay selectedTime = originalSnappedTime;
    int? selectedStudentId = session.studentId;

    // Async state for backend-fetched available students
    List<StudentModel> availableStudents = [];
    bool isLoadingStudents = true;
    bool needsInitialLoad = true;

    // Calculate session duration in minutes from actual start/end
    final origStartMin = session.startTime.hour * 60 + session.startTime.minute;
    final origEndMin = session.endTime.hour * 60 + session.endTime.minute;
    final durationMinutes = origEndMin > origStartMin
        ? origEndMin - origStartMin
        : 60;

    // Fetch available students from backend for the selected date/time
    Future<void> fetchStudents(StateSetter setSheetState) async {
      setSheetState(() => isLoadingStudents = true);
      final orderId = int.tryParse(session.orderId ?? '');
      if (orderId == null) {
        setSheetState(() {
          availableStudents = [];
          isLoadingStudents = false;
        });
        return;
      }
      final sessionIdInt = int.tryParse(session.id);
      final selStartMin = selectedTime.hour * 60 + selectedTime.minute;
      final selEndMin = selStartMin + durationMinutes;
      final endTime = TimeOfDay(
        hour: (selEndMin ~/ 60) % 24,
        minute: selEndMin % 60,
      );

      final dateStr =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      final startStr =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';
      final endStr =
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

      final result = await AdminApiService().getAvailableStudents(
        date: dateStr,
        startTime: startStr,
        endTime: endStr,
        orderId: orderId,
        excludeJobInstanceIds: sessionIdInt != null ? [sessionIdInt] : null,
      );

      setSheetState(() {
        availableStudents = result.success ? (result.data ?? []) : [];
        isLoadingStudents = false;

        // For reactivation with no pre-selected student, auto-select first available.
        if (isReactivation &&
            selectedStudentId == null &&
            availableStudents.isNotEmpty) {
          selectedStudentId = int.tryParse(availableStudents.first.id);
          return;
        }

        // Only reset selection if the selected student is NOT the current
        // one AND is no longer in the available list.
        if (selectedStudentId != session.studentId &&
            !availableStudents.any(
              (s) => int.tryParse(s.id) == selectedStudentId,
            )) {
          if (availableStudents.isNotEmpty) {
            selectedStudentId = int.tryParse(availableStudents.first.id);
          } else if (session.studentId != null) {
            selectedStudentId = session.studentId;
          } else {
            selectedStudentId = null;
          }
        }
      });
    }

    final isWide = MediaQuery.sizeOf(context).width >= 600;

    Widget buildContent(
      BuildContext ctx,
      StateSetter setSheetState, [
      ScrollController? scrollCtrl,
    ]) {
      // Trigger initial load on first build
      if (needsInitialLoad) {
        needsInitialLoad = false;
        Future.microtask(() => fetchStudents(setSheetState));
      }

      final dateLabel = formatDate(selectedDate);
      final timeLabel = formatTimeOfDay(selectedTime);

      // Check if current student is in the available list
      final currentStillAvailable =
          session.studentId != null &&
          availableStudents.any((s) => int.tryParse(s.id) == session.studentId);

      // Build student list widgets
      final studentListChildren = <Widget>[
        if (isLoadingStudents)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.loading,
                    style: TextStyle(
                      color: HelpiColors.of(context).textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          // "Keep current" option — always show if session has a student.
          // Even if not in the backend available list (e.g. availability
          // slots changed), admin should be able to keep the assignment.
          if (session.studentName != null && session.studentId != null)
            _StudentRadioTile(
              name: session.studentName!,
              subtitle: currentStillAvailable
                  ? AppStrings.sessionKeepCurrentStudent
                  : '${AppStrings.sessionKeepCurrentStudent} ⚠️',
              isSelected: selectedStudentId == session.studentId,
              onTap: () {
                setSheetState(() {
                  selectedStudentId = session.studentId;
                });
              },
            ),
          // Available students from backend (exclude current)
          if (availableStudents
                  .where((s) => int.tryParse(s.id) != session.studentId)
                  .isEmpty &&
              session.studentId == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                AppStrings.noStudentsForSlot,
                style: TextStyle(
                  color: HelpiColors.of(context).textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ...availableStudents
              .where((s) => int.tryParse(s.id) != session.studentId)
              .map((student) {
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
                final stuId = int.tryParse(student.id);
                return _StudentRadioTile(
                  name: student.fullName,
                  subtitle:
                      '⭐ ${student.avgRating.toStringAsFixed(1)}$sep$distLabel',
                  isSelected: selectedStudentId == stuId,
                  onTap: () {
                    setSheetState(() {
                      selectedStudentId = stuId;
                    });
                  },
                );
              }),
        ],
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
                    isReactivation
                        ? AppStrings.sessionReactivate
                        : AppStrings.sessionRescheduleTitle,
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
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: selectedDate.isBefore(now) ? now : selectedDate,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                  confirmText: AppStrings.ok,
                  cancelText: AppStrings.cancel,
                );
                if (picked != null && picked != selectedDate) {
                  setSheetState(() => selectedDate = picked);
                  await fetchStudents(setSheetState);
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
                if (picked != null &&
                    (picked.hour != selectedTime.hour ||
                        picked.minute != selectedTime.minute)) {
                  setSheetState(() => selectedTime = picked);
                  await fetchStudents(setSheetState);
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: HelpiColors.of(context).textSecondary,
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
                  if (isLoadingStudents) return;
                  // For reactivation, require a student to be selected
                  if (isReactivation && selectedStudentId == null) {
                    showErrorSnack(
                      context,
                      AppStrings.sessionReactivateNoStudentError,
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  final sessionId = int.tryParse(session.id);
                  if (sessionId == null) return;
                  final api = AdminApiService();

                  // Detect what changed
                  final dateChanged =
                      selectedDate.year != session.date.year ||
                      selectedDate.month != session.date.month ||
                      selectedDate.day != session.date.day;
                  final timeChanged =
                      selectedTime.hour != originalSnappedTime.hour ||
                      selectedTime.minute != originalSnappedTime.minute;
                  final studentChanged = selectedStudentId != session.studentId;

                  // Calculate new end time when start changes
                  TimeOfDay? newEndTime;
                  if (timeChanged) {
                    final newStartMin =
                        selectedTime.hour * 60 + selectedTime.minute;
                    final newEndMin = newStartMin + durationMinutes;
                    newEndTime = TimeOfDay(
                      hour: (newEndMin ~/ 60) % 24,
                      minute: newEndMin % 60,
                    );
                  }

                  if (isReactivation) {
                    // Single atomic call: reactivate + optional date/time/student change
                    final result = await api.reactivateAndManageSession(
                      sessionId,
                      newDate: dateChanged ? selectedDate : null,
                      newStartTime: timeChanged ? selectedTime : null,
                      newEndTime: timeChanged ? newEndTime : null,
                      preferredStudentId: studentChanged
                          ? selectedStudentId
                          : null,
                    );
                    if (!mounted) return;
                    if (!result.success) {
                      showErrorSnack(context, _localizeError(result.error));
                      return;
                    }
                    // Force immediate session reload so the card reflects the
                    // new "Čeka potvrdu studenta" state without requiring navigation.
                    await _loadSessions();
                    if (!mounted) return;
                  } else {
                    // Reschedule: nothing changed → just close
                    if (!dateChanged && !timeChanged && !studentChanged) {
                      return;
                    }
                    final result = await api.manageSession(
                      sessionId,
                      newDate: dateChanged ? selectedDate : null,
                      newStartTime: timeChanged ? selectedTime : null,
                      newEndTime: newEndTime,
                      preferredStudentId: studentChanged
                          ? selectedStudentId
                          : null,
                    );
                    if (!mounted) return;
                    if (!result.success) {
                      showErrorSnack(context, _localizeError(result.error));
                      return;
                    }
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
  //  ERROR TRANSLATION HELPER
  // ---------------------------------------------------------------

  /// Translates known backend error messages to localized strings.
  String _localizeError(String? error) {
    if (error == null) return AppStrings.error;
    if (error.contains('Senior already has another session')) {
      final dateMatch = RegExp(r'on (\S+)').firstMatch(error);
      final timeMatch = RegExp(r'with (.+)\.$').firstMatch(error);
      final date = dateMatch?.group(1) ?? '';
      final time = timeMatch?.group(1) ?? '';
      return AppStrings.seniorSessionConflict(date, time);
    }
    return error;
  }

  // ---------------------------------------------------------------
  //  AVAILABILITY HELPERS
  // ---------------------------------------------------------------

  /// Returns the order's schedule slots as (dayOfWeek, startTime) pairs.
  // ---------------------------------------------------------------
  //  ASSIGN STUDENT (single-modal flow with back navigation)
  // ---------------------------------------------------------------
  Future<void> _showAssignSheet() async {
    // Block assignment on cancelled/completed/archived orders
    if (_order.status == OrderStatus.cancelled ||
        _order.status == OrderStatus.completed ||
        _order.status == OrderStatus.archived) {
      return;
    }
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    Future<void> onConfirmed(
      StudentModel student,
      List<SessionInstancePreview> previewSessions,
    ) async {
      if (!context.mounted) return;

      _isAssigning = true;

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

        // Check if a substitute student was chosen for this weekday
        final sub = previewSessions
            .where((p) => p.weekday == weekday && p.substituteStudent != null)
            .map((p) => p.substituteStudent!)
            .firstOrNull;
        final assignId = sub != null ? int.parse(sub.id) : studentId;

        final result = await assignApi.adminAssign(scheduleId, assignId);
        if (!mounted) return;
        if (!result.success) {
          _isAssigning = false;
          showErrorSnack(context, result.error ?? 'Error');
          return;
        }
      }

      // Terminate old assignments on skipped schedules
      for (final entry in weekdayToSchedule.entries) {
        final weekday = entry.key;
        final scheduleId = entry.value;
        if (!skippedWeekdays.contains(weekday)) continue;

        final result = await assignApi.adminTerminate(scheduleId);
        if (!mounted) return;
        if (!result.success) {
          _isAssigning = false;
          showErrorSnack(context, result.error ?? 'Error');
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
          student: student, // show newly assigned student immediately
          status: _order
              .status, // keep current — backend doesn't change until accept
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
          couponCode: _order.couponCode,
          scheduleIds: _order.scheduleIds,
        );
      });

      // Sync updated order back to provider for reactive UI
      ref.read(ordersProvider.notifier).updateItem(_order);

      // Refresh pending acceptance data for banner + this screen
      await _refreshPendingData(student.fullName);

      // All schedules assigned — allow refresh and fetch final state
      _isAssigning = false;
      await _refreshOrder();

      if (!mounted) return;
      showSuccessSnack(context, AppStrings.assignSuccess);
    }

    // Fetch available students per schedule and classify by coverage
    final api = AdminApiService();
    final allScheduleIds = _order.scheduleIds;

    // Determine which weekdays already have a student (pending/accepted)
    final coveredWeekdays = <int>{};
    for (final s in _order.sessions) {
      if (s.studentId != null && s.status == SessionStatus.scheduled) {
        coveredWeekdays.add(s.weekday);
      }
    }

    // Only fetch available students for UNCOVERED schedules
    var scheduleIds = <int>[];
    for (
      var i = 0;
      i < allScheduleIds.length && i < _order.dayEntries.length;
      i++
    ) {
      if (!coveredWeekdays.contains(_order.dayEntries[i].dayOfWeek)) {
        scheduleIds.add(allScheduleIds[i]);
      }
    }

    // If all schedules are covered, use ALL schedules (admin wants to replace)
    if (scheduleIds.isEmpty && coveredWeekdays.isNotEmpty) {
      scheduleIds = allScheduleIds.toList();
    }

    final Map<String, StudentModel> allStudents = {};
    final Map<String, int> studentScheduleHits = {};

    if (scheduleIds.isNotEmpty) {
      for (final sid in scheduleIds) {
        final result = await api.getAvailableStudentsForSchedule(sid);
        if (!mounted) return;
        if (!result.success) {
          showErrorSnack(context, result.error ?? 'Error');
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
        showErrorSnack(context, result.error ?? 'Error');
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
    // Block assignment on cancelled/completed/archived orders
    if (_order.status == OrderStatus.cancelled ||
        _order.status == OrderStatus.completed ||
        _order.status == OrderStatus.archived) {
      return;
    }
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

              // Skip schedules that already have a student assigned
              final coveredDays = <int>{};
              for (final s in _order.sessions) {
                if (s.studentId != null &&
                    s.status == SessionStatus.scheduled) {
                  coveredDays.add(s.weekday);
                }
              }

              // Assign student only to uncovered schedules
              for (
                var i = 0;
                i < _order.scheduleIds.length && i < _order.dayEntries.length;
                i++
              ) {
                if (coveredDays.contains(_order.dayEntries[i].dayOfWeek)) {
                  continue;
                }
                final scheduleId = _order.scheduleIds[i];
                final result = await api.adminAssign(scheduleId, studentId);
                if (!result.success) {
                  if (!mounted) return;
                  showErrorSnack(context, result.error ?? 'Error');
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
                  couponCode: _order.couponCode,
                  scheduleIds: _order.scheduleIds,
                );
              });

              // Sync updated order back to provider for reactive UI
              ref.read(ordersProvider.notifier).updateItem(_order);

              // Refresh from backend to get real session IDs (needed
              // for reschedule excludeJobInstanceIds to work correctly).
              await _refreshOrder();

              if (!mounted) return;

              showSuccessSnack(context, AppStrings.assignSuccess);
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
class _StudentAssignCard extends StatefulWidget {
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
  State<_StudentAssignCard> createState() => _StudentAssignCardState();
}

class _StudentAssignCardState extends State<_StudentAssignCard> {
  List<AdminNote>? _notes;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final studentId = int.tryParse(widget.student.id);
    if (studentId == null) return;
    final result = await AdminApiService().getAdminNotes('Student', studentId);
    if (!mounted) return;
    if (result.success && result.data != null) {
      setState(() {
        _notes = result.data!.map((j) => AdminNote.fromJson(j)).toList();
      });
    } else {
      setState(() => _notes = []);
    }
  }

  void _showNotesDialog() {
    final notes = _notes ?? [];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.comment_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.student.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: notes.isEmpty
              ? Text(
                  AppStrings.adminNoNotes,
                  style: TextStyle(color: HelpiColors.of(ctx).textSecondary),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < notes.length; i++) ...[
                      if (i > 0) const Divider(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notes[i].text,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatDate(notes[i].updatedAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: HelpiColors.of(ctx).textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.adminNoteCancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final avail = widget.avail;
    final distanceKm = widget.distanceKm;
    final String availLabel;
    final Color availColor;
    final IconData availIcon;
    final String buttonLabel;
    final IconData buttonIcon;

    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    if (avail == _StudentAvail.full) {
      availLabel = isNarrow
          ? AppStrings.availableAllDaysShort
          : AppStrings.availableAllDays;
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
        color: HelpiColors.of(context).surface,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiColors.of(context).border),
      ),
      child: Row(
        children: [
          // -- Avatar (klikabilan → profil studenta) --
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentDetailScreen(student: student),
                ),
              ),
              child: ProfileAvatar(
                initials: student.firstName[0] + student.lastName[0],
                profileImageUrl: student.profileImageUrl,
                radius: 22,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // -- Info --
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        student.fullName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (_notes != null && _notes!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: AppStrings.adminNotes,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _showNotesDialog,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.comment_outlined,
                              size: 15,
                              color: HelpiColors.of(context).textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
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
                      style: TextStyle(
                        fontSize: 13,
                        color: HelpiColors.of(context).textSecondary,
                      ),
                    ),
                    if (distanceKm != null) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.location_on,
                        size: 13,
                        color: HelpiColors.of(context).textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${distanceKm.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 13,
                          color: HelpiColors.of(context).textSecondary,
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
              onTap: widget.onAssign,
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  bool get _disabled => onTap == null;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _disabled ? Colors.grey : color;
    return Material(
      color: effectiveColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        hoverColor: _disabled ? null : effectiveColor.withValues(alpha: 0.15),
        splashColor: _disabled ? null : effectiveColor.withValues(alpha: 0.2),
        mouseCursor: _disabled
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: effectiveColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: effectiveColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
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
          border: Border.all(color: HelpiColors.of(context).border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: HelpiTheme.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: HelpiColors.of(context).textSecondary,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: HelpiColors.of(context).textSecondary,
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
          color: HelpiColors.of(context).scaffold,
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
        color: HelpiColors.of(context).scaffold,
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

    // Auto-select if only one faculty
    if (faculties.length == 1 && _selectedFaculty == null) {
      _selectedFaculty = faculties.first;
    }

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
            final dropdownWidget = faculties.isNotEmpty
                ? Flexible(
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: HelpiColors.of(context).border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: HelpiColors.of(context).chipBg,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                value: _selectedFaculty,
                                isDense: true,
                                isExpanded: true,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: HelpiColors.of(context).textSecondary,
                                ),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  size: 16,
                                  color: HelpiColors.of(context).textSecondary,
                                ),
                                hint: Text(
                                  AppStrings.anyFaculty,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: HelpiColors.of(
                                      context,
                                    ).textSecondary,
                                  ),
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
                    ),
                  )
                : null;

            final knownChip = FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: _onlyWorkedWithSenior
                        ? HelpiTheme.accent
                        : HelpiColors.of(context).textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.knownStudents,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _onlyWorkedWithSenior
                          ? HelpiTheme.accent
                          : HelpiColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
              selected: _onlyWorkedWithSenior,
              showCheckmark: false,
              color: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return HelpiColors.of(context).pastelTeal;
                }
                return HelpiColors.of(context).chipBg;
              }),
              side: BorderSide(
                color: _onlyWorkedWithSenior
                    ? HelpiTheme.accent
                    : HelpiColors.of(context).border,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              labelPadding: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onSelected: (v) => setState(() => _onlyWorkedWithSenior = v),
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  ?dropdownWidget,
                  if (dropdownWidget != null) const SizedBox(width: 8),
                  knownChip,
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
                    style: TextStyle(
                      color: HelpiColors.of(context).textSecondary,
                    ),
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
    if (!s.isActive || s.isSuspended) return false;
    if (s.contractStatus != ContractStatus.active) return false;
    return true;
  }

  @override
  bool onNoAvailability(StudentModel s) => s.availability.isEmpty;

  @override
  List<SessionInstancePreview> generateSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Sessions only up to end of current month (student contracts expire monthly)
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final studentOrders = allOrders
        .where(
          (o) =>
              o.student?.id == student.id &&
              o.status != OrderStatus.cancelled &&
              o.status != OrderStatus.completed &&
              o.id != order.id,
        )
        .toList();

    // One-time order → single session
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
          sessionCount: 1,
        ),
      ];
    }

    // Recurring order → ONE row per weekday (not per date)
    final List<SessionInstancePreview> result = [];
    final effectiveEnd =
        order.endDate != null && order.endDate!.isBefore(endOfMonth)
        ? order.endDate!
        : endOfMonth;

    for (final entry in order.dayEntries) {
      // Find first occurrence from today
      var nextDate = today;
      while (nextDate.weekday != entry.dayOfWeek) {
        nextDate = nextDate.add(const Duration(days: 1));
      }

      // Count sessions until end
      int count = 0;
      var d = nextDate;
      while (!d.isAfter(effectiveEnd)) {
        count++;
        d = d.add(const Duration(days: 7));
      }

      final startMin = toMinutes(entry.startTime);
      final endMin = startMin + entry.durationHours * 60;

      // Conflict detection at weekday level (same conflict every week)
      final availConflict = _checkAvailability(entry.dayOfWeek, startMin);
      final schedConflict = availConflict
          ? null
          : findConflict(
              date: nextDate,
              weekday: entry.dayOfWeek,
              startMin: startMin,
              endMin: endMin,
              studentOrders: studentOrders,
            );

      result.add(
        SessionInstancePreview(
          date: nextDate,
          weekday: entry.dayOfWeek,
          startTime: entry.startTime,
          durationHours: entry.durationHours,
          conflictType: (availConflict || schedConflict != null)
              ? SessionConflictType.conflict
              : SessionConflictType.free,
          conflictingOrder: schedConflict,
          sessionCount: count,
        ),
      );
    }
    result.sort((a, b) => a.weekday.compareTo(b.weekday));
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? HelpiColors.of(context).pastelTeal
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? HelpiTheme.accent
                  : HelpiColors.of(context).border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 20,
                color: isSelected
                    ? HelpiTheme.accent
                    : HelpiColors.of(context).textSecondary,
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
                      style: TextStyle(
                        fontSize: 12,
                        color: HelpiColors.of(context).textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
