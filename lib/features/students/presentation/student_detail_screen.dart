import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/models/faculty.dart';
import 'package:helpi_admin/core/models/suspension_models.dart';
import 'package:helpi_admin/core/network/api_client.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/preferences_service.dart';
import 'package:helpi_admin/core/services/suspension_state_manager.dart';
import 'package:helpi_admin/core/utils/croatian_holidays.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/suspension_widgets.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
import 'package:helpi_admin/core/services/data_loader.dart';
import 'package:flutter/services.dart';
import 'package:helpi_admin/features/orders/presentation/order_detail_screen.dart';
import 'package:helpi_admin/features/students/presentation/edit_student_screen.dart';

/// Student Detail Screen — profil studenta, ugovor, dostupnost, recenzije.
class StudentDetailScreen extends ConsumerStatefulWidget {
  const StudentDetailScreen({super.key, required this.student});
  final StudentModel student;

  @override
  ConsumerState<StudentDetailScreen> createState() =>
      _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  late StudentModel _student;
  final _prefs = PreferencesService.instance;
  static const _screenKey = 'studentDetail';
  static const _sectionCount = 9;

  /// Suspension status loaded from API.
  final _api = ApiClient();
  UserSuspensionStatus? _suspensionStatus;

  /// Active contract data from backend.
  Map<String, dynamic>? _activeContract;

  /// Whether a contract operation is in progress.
  bool _isContractLoading = false;

  /// Whether we are deleting (true) vs uploading (false) — for spinner text.
  bool _isContractDeleting = false;

  /// Availability loaded from backend.
  List<DayAvailability> _availability = [];

  /// Date range for work summary payout calculation.
  late DateTime _summaryStart;
  late DateTime _summaryEnd;
  bool _isCustomRange = false;

  /// Section order — indices into the _buildSections() list.
  late List<int> _sectionOrder;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _initSummaryRange();
    final saved = _prefs.getSectionOrder(_screenKey);
    if (saved != null && saved.length == _sectionCount) {
      _sectionOrder = saved;
    } else {
      _sectionOrder = List.generate(_sectionCount, (i) => i);
    }
    _loadSuspensionStatus();
    _loadContracts();
    _loadAvailability();
  }

  Future<void> _loadContracts() async {
    final studentId = int.tryParse(_student.id);
    if (studentId == null) return;
    final api = AdminApiService();
    final result = await api.getStudentContracts(studentId);
    if (!mounted) return;
    if (result.success && result.data != null) {
      // Find active contract (not deleted, status=1=Active)
      final contracts = result.data!;
      Map<String, dynamic>? active;
      for (final c in contracts) {
        if (c['deletedOn'] == null && c['status'] == 1) {
          active = c;
          break;
        }
      }
      setState(() => _activeContract = active);
    }
  }

  Future<void> _loadAvailability() async {
    final studentId = int.tryParse(_student.id);
    if (studentId == null) return;
    final api = AdminApiService();
    final result = await api.getStudentAvailability(studentId);
    if (!mounted) return;
    if (result.success && result.data != null) {
      final slots = result.data!
        ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
      setState(() {
        _availability = slots;
        // Rebuild _student with real availability so matching/preview use it
        _student = StudentModel(
          id: _student.id,
          firstName: _student.firstName,
          lastName: _student.lastName,
          email: _student.email,
          phone: _student.phone,
          address: _student.address,
          city: _student.city,
          faculty: _student.faculty,
          dateOfBirth: _student.dateOfBirth,
          gender: _student.gender,
          avgRating: _student.avgRating,
          totalReviews: _student.totalReviews,
          completedJobs: _student.completedJobs,
          cancelledJobs: _student.cancelledJobs,
          isVerified: _student.isVerified,
          isActive: _student.isActive,
          isArchived: _student.isArchived,
          isSuspended: _student.isSuspended,
          suspensionReason: _student.suspensionReason,
          createdAt: _student.createdAt,
          contractStatus: _student.contractStatus,
          contractStartDate: _student.contractStartDate,
          contractExpiryDate: _student.contractExpiryDate,
          availability: slots,
          hourlyRate: _student.hourlyRate,
          sundayHourlyRate: _student.sundayHourlyRate,
        );
      });
    }
  }

  Future<void> _loadSuspensionStatus() async {
    final userId = int.tryParse(_student.id);
    if (userId == null) {
      setState(
        () =>
            _suspensionStatus = const UserSuspensionStatus(isSuspended: false),
      );
      return;
    }
    final status = await loadSuspensionStatus(_api, userId);
    if (!mounted) return;
    setState(
      () => _suspensionStatus =
          status ?? const UserSuspensionStatus(isSuspended: false),
    );
  }

  /// Default: contract period if available, otherwise current month.
  void _initSummaryRange() {
    if (_student.contractStartDate != null &&
        _student.contractExpiryDate != null) {
      _summaryStart = _student.contractStartDate!;
      _summaryEnd = _student.contractExpiryDate!;
    } else {
      final now = DateTime.now();
      _summaryStart = DateTime(now.year, now.month);
      _summaryEnd = DateTime(now.year, now.month + 1, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ref
        .watch(reviewsProvider)
        .where((r) => r.studentName == _student.fullName)
        .toList();
    final orders =
        ref
            .watch(ordersProvider)
            .where((o) => o.student?.id == _student.id)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: HelpiAppBar(
        titleSpacing: HelpiAppBar.innerTitleSpacing,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(_student.fullName, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            if (_student.isSuspended)
              StatusBadge.suspended()
            else
              StatusBadge.contract(_student.contractStatus),
            if (_student.isArchived) ...[
              const SizedBox(width: 6),
              StatusBadge(
                textColor: HelpiColors.of(context).textSecondary,
                bgColor: HelpiColors.of(context).chipBg,
                label: AppStrings.statusArchived,
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 22),
            tooltip: AppStrings.editStudentTitle,
            onPressed: _openEditStudent,
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
          final allSections = _buildAllSections(orders, reviews);
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
    AppStrings.studentPersonalData,
    AppStrings.studentContractTitle,
    AppStrings.workSummary,
    AppStrings.studentAvailability,
    AppStrings.studentAssignedOrders,
    AppStrings.studentReviews,
    AppStrings.adminNotes,
    AppStrings.suspensionHistory,
    AppStrings.adminActions,
  ];

  static const _sectionIcons = [
    Icons.person,
    Icons.description,
    Icons.work_history,
    Icons.schedule,
    Icons.receipt_long,
    Icons.star,
    Icons.sticky_note_2,
    Icons.history,
    Icons.admin_panel_settings,
  ];

  List<Widget> _buildAllSections(
    List<OrderModel> orders,
    List<ReviewModel> reviews,
  ) {
    return [
      _buildPersonalDataSection(),
      _buildContractSection(),
      _buildWorkSummarySection(),
      _buildAvailabilitySection(),
      _buildOrdersSection(orders),
      _buildReviewsSection(reviews),
      _buildNotesSection(),
      _buildSuspensionHistorySection(),
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
          ...List.generate(tempOrder.length, (i) {
            final sectionIdx = tempOrder[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 18),
                      color: i == 0
                          ? HelpiColors.of(context).border
                          : HelpiColors.of(context).textSecondary,
                      onPressed: i == 0
                          ? null
                          : () => setSheetState(() {
                              final item = tempOrder.removeAt(i);
                              tempOrder.insert(i - 1, item);
                            }),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 18),
                      color: i == tempOrder.length - 1
                          ? HelpiColors.of(context).border
                          : HelpiColors.of(context).textSecondary,
                      onPressed: i == tempOrder.length - 1
                          ? null
                          : () => setSheetState(() {
                              final item = tempOrder.removeAt(i);
                              tempOrder.insert(i + 1, item);
                            }),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _sectionIcons[sectionIdx],
                      color: HelpiTheme.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _sectionLabels[sectionIdx],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
  //  PERSONAL DATA SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildPersonalDataSection() {
    return SectionCard(
      title: AppStrings.studentPersonalData,
      icon: Icons.person,
      children: [
        ResponsiveFieldGrid(
          children: [
            InfoField(
              label: AppStrings.studentFirstName,
              value: _student.firstName,
            ),
            InfoField(
              label: AppStrings.studentLastName,
              value: _student.lastName,
            ),
            InfoField(
              label: AppStrings.studentEmail,
              value: _student.email,
              trailing: EmailCopyButton(email: _student.email),
            ),
            InfoField(
              label: AppStrings.studentPhone,
              value: _student.phone,
              trailing: PhoneCallButton(phone: _student.phone),
            ),
            InfoField(
              label: AppStrings.studentAddress,
              value: _student.address,
            ),
            InfoField(
              label: AppStrings.studentDateOfBirth,
              value: formatDateDot(_student.dateOfBirth),
            ),
            InfoField(
              label: AppStrings.studentGender,
              value: _student.gender == Gender.male
                  ? AppStrings.genderMale
                  : AppStrings.genderFemale,
            ),
            InfoField(
              label: AppStrings.studentFaculty,
              value:
                  Faculty.byAcronym(_student.faculty)?.fullName ??
                  _student.faculty,
            ),
          ],
        ),
      ],
    );
  }

  void _openEditStudent() {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    final formWidget = EditStudentScreen(
      student: _student,
      availability: _availability,
      isModal: true,
    );

    if (isWide) {
      showDialog<StudentModel>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 800),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
              child: formWidget,
            ),
          ),
        ),
      ).then((result) {
        if (!mounted) return;
        if (result != null) {
          setState(() => _student = result);
          _loadAvailability();
        }
      });
    } else {
      showModalBottomSheet<StudentModel>(
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
        if (!mounted) return;
        if (result != null) {
          setState(() => _student = result);
          _loadAvailability();
        }
      });
    }
  }

  // ─────────────────────────────────────────────────────────
  //  CONTRACT SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildContractSection() {
    if (_isContractLoading) {
      return SectionCard(
        title: AppStrings.studentContractTitle,
        icon: Icons.description,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isContractDeleting
                        ? AppStrings.contractDeleting
                        : AppStrings.contractLoading,
                    style: TextStyle(
                      color: HelpiColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final hasContract = _activeContract != null;

    if (!hasContract) {
      return SectionCard(
        title: AppStrings.studentContractTitle,
        icon: Icons.description,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 36,
                    color: HelpiColors.of(context).border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.contractNone,
                    style: TextStyle(
                      color: HelpiColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ActionChipButton(
            icon: Icons.upload_file,
            label: AppStrings.studentUploadContract,
            color: HelpiTheme.accent,
            onTap: _simulateContractUpload,
          ),
        ],
      );
    }

    final effectiveDate = _activeContract!['effectiveDate'] as String?;
    final expirationDate = _activeContract!['expirationDate'] as String?;
    final contractNumber = _activeContract!['contractNumber'] as String? ?? '';

    return SectionCard(
      title: AppStrings.studentContractTitle,
      icon: Icons.description,
      children: [
        ResponsiveFieldGrid(
          children: [
            InfoField(
              label: AppStrings.studentContractStatus,
              valueWidget: Text(
                contractStatusStyle(_student.contractStatus).$3,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: HelpiColors.of(context).textPrimary,
                ),
              ),
            ),
            if (contractNumber.isNotEmpty)
              InfoField(
                label: AppStrings.contractNumber,
                value: contractNumber,
              ),
            if (effectiveDate != null)
              InfoField(
                label: AppStrings.studentContractStart,
                value: formatDateDot(DateTime.parse(effectiveDate)),
              ),
            if (expirationDate != null)
              InfoField(
                label: AppStrings.studentContractExpiry,
                value: formatDateDot(DateTime.parse(expirationDate)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ActionChipButton(
              icon: Icons.upload_file,
              label: AppStrings.studentUploadContract,
              color: HelpiTheme.accent,
              onTap: _simulateContractUpload,
            ),
            const SizedBox(width: 8),
            ActionChipButton(
              icon: Icons.delete_outline,
              label: AppStrings.contractDelete,
              color: HelpiTheme.primary,
              onTap: _confirmDeleteContract,
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SUSPENSION HISTORY SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildSuspensionHistorySection() {
    if (_suspensionStatus == null) {
      return SectionCard(
        title: AppStrings.suspensionHistory,
        icon: Icons.history,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ],
      );
    }
    return SuspensionHistoryCard(
      status: _suspensionStatus!,
      onSuspend: _confirmSuspend,
      onActivate: _confirmActivate,
    );
  }

  // ─────────────────────────────────────────────────────────
  //  ADMIN NOTES SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildNotesSection() {
    final studentId = int.tryParse(_student.id) ?? 0;
    return NotesSection(entityType: 'Student', entityId: studentId);
  }

  // ─────────────────────────────────────────────────────────
  //  ADMIN ACTIONS SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildAdminActionsSection() {
    return SectionCard(
      title: AppStrings.adminActions,
      icon: Icons.admin_panel_settings,
      children: [
        ActionChipButton(
          icon: _student.isArchived ? Icons.unarchive : Icons.archive,
          label: _student.isArchived
              ? AppStrings.studentUnarchive
              : AppStrings.studentArchive,
          color: _student.isArchived
              ? HelpiTheme.accent
              : HelpiColors.of(context).textSecondary,
          onTap: () =>
              _student.isArchived ? _confirmUnarchive() : _confirmArchive(),
        ),
      ],
    );
  }

  // ── Suspend / Activate logic ──

  Future<void> _confirmSuspend() async {
    // Refresh orders from API so the active-order check is up to date
    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;

    // Warn if user has active orders (will be reassigned)
    final studentOrders = ref
        .read(ordersProvider)
        .where((o) => o.student?.id == _student.id)
        .toList();
    debugPrint(
      '[SUSPEND] student=${_student.id} orders=${studentOrders.length} '
      'statuses=${studentOrders.map((o) => '${o.id}:${o.status}').join(', ')}',
    );
    final hasActiveOrders = studentOrders.any(
      (o) =>
          o.status == OrderStatus.active || o.status == OrderStatus.processing,
    );

    if (hasActiveOrders) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.suspendWarningTitle),
          content: SizedBox(
            width: 400,
            child: Text(AppStrings.suspendWarningStudentMsg),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppStrings.suspend),
            ),
          ],
        ),
      );
      if (!mounted || proceed != true) return;
    }

    final reason = await showSuspendDialog(context, _student.fullName);
    if (!mounted || reason == null) return;

    final userId = int.tryParse(_student.id);
    if (userId != null) {
      final error = await suspendUserApi(_api, userId, reason);
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.suspensionFailed}: $error')),
        );
        return;
      }
    }

    // Refresh data from backend (orders auto-cancelled by backend)
    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;

    // Pick up fresh student data from the refreshed AppData
    final fresh = ref
        .read(studentsProvider)
        .firstWhere((s) => s.id == _student.id, orElse: () => _student);
    setState(() {
      _student = fresh;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppStrings.suspensionSuccess)));
    SuspensionStateManager.instance.suspend(_student.id);
    // Refresh suspension history for the panel
    _loadSuspensionStatus();
  }

  Future<void> _confirmActivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.activateConfirmTitle),
        content: SizedBox(
          width: 400,
          child: Text(AppStrings.activateConfirmMsg(_student.fullName)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.activate),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    final userId = int.tryParse(_student.id);
    if (userId != null) {
      final error = await activateUserApi(_api, userId);
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.activationFailed}: $error')),
        );
        return;
      }
    }

    // Refresh data from backend
    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;

    // Pick up fresh student data from the refreshed AppData
    final fresh = ref
        .read(studentsProvider)
        .firstWhere((s) => s.id == _student.id, orElse: () => _student);
    setState(() {
      _student = fresh;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppStrings.activationSuccess)));
    SuspensionStateManager.instance.activate(_student.id);
    // Refresh suspension history for the panel
    _loadSuspensionStatus();
  }

  // ── Archive / Unarchive logic ──

  Future<void> _confirmArchive() async {
    final api = AdminApiService();
    final studentId = int.tryParse(_student.id) ?? 0;

    // Check for blocking items via API
    final checkResult = await api.getStudentArchiveCheck(studentId);
    if (!mounted) return;

    if (!checkResult.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(checkResult.error ?? 'Error')));
      return;
    }

    final check = checkResult.data!;

    if (check.hasBlockingItems) {
      // Show warning dialog with force option
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.archiveBlockedTitle),
          content: SizedBox(
            width: 400,
            child: Text(
              AppStrings.archiveWarningAssignments(
                check.activeAssignmentsCount,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppStrings.studentArchive),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (confirmed != true) return;

      // Force archive
      final archiveResult = await api.archiveStudent(
        studentId,
        force: true,
        reason: 'Admin forced archive',
      );
      if (!mounted) return;
      if (archiveResult.success) {
        await DataLoader.loadAll(ref: ref);
        if (!mounted) return;
        final refreshed = ref
            .read(studentsProvider)
            .where((s) => s.id == _student.id)
            .firstOrNull;
        if (refreshed != null) {
          setState(() => _student = refreshed);
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppStrings.archiveSuccess)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(archiveResult.error ?? 'Error')));
      }
      return;
    }

    // Can archive directly - simple confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.archiveConfirmTitle),
        content: SizedBox(
          width: 400,
          child: Text(AppStrings.archiveConfirmMsg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: HelpiTheme.error),
            child: Text(AppStrings.studentArchive),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) return;

    final archiveResult = await api.archiveStudent(studentId);
    if (!mounted) return;
    if (archiveResult.success) {
      await DataLoader.loadAll(ref: ref);
      if (!mounted) return;
      final refreshed = ref
          .read(studentsProvider)
          .where((s) => s.id == _student.id)
          .firstOrNull;
      if (refreshed != null) {
        setState(() => _student = refreshed);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.archiveSuccess)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(archiveResult.error ?? 'Error')));
    }
  }

  void _confirmUnarchive() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.unarchiveConfirmTitle),
        content: SizedBox(
          width: 400,
          child: Text(AppStrings.unarchiveConfirmMsg),
        ),
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
    ).then((confirmed) async {
      if (confirmed != true || !mounted) return;
      final studentId = int.tryParse(_student.id);
      if (studentId == null) return;
      final api = AdminApiService();
      final result = await api.unarchiveStudent(studentId);
      if (!mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error ?? 'Error')));
        return;
      }
      await DataLoader.loadAll(ref: ref);
      if (!mounted) return;
      final refreshed = ref
          .read(studentsProvider)
          .where((s) => s.id == _student.id)
          .firstOrNull;
      if (refreshed != null) {
        setState(() => _student = refreshed);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.unarchiveSuccess)));
    });
  }

  Future<void> _confirmDeleteContract() async {
    if (_activeContract == null) return;
    final contractId = _activeContract!['id'] as int;
    final api = AdminApiService();

    // Check for blocking items via API
    final checkResult = await api.getContractDeleteCheck(contractId);
    if (!mounted) return;

    if (!checkResult.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(checkResult.error ?? 'Error')));
      return;
    }

    final check = checkResult.data!;

    if (check.hasBlockingItems) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.contractDeleteTitle),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.contractDeleteConfirm),
                const SizedBox(height: 8),
                Text(
                  AppStrings.archiveWarningAssignments(
                    check.activeAssignmentsCount,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppStrings.delete),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (confirmed != true) return;

      setState(() {
        _isContractLoading = true;
        _isContractDeleting = true;
      });

      final deleteResult = await api.deleteContractWithCheck(
        contractId,
        force: true,
        reason: 'Admin forced delete',
      );
      if (!mounted) return;
      if (!deleteResult.success) {
        setState(() => _isContractLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(deleteResult.error ?? 'Error'),
            backgroundColor: HelpiTheme.primary,
          ),
        );
        return;
      }

      await DataLoader.loadAll(ref: ref);
      if (!mounted) return;
      final refreshed = ref
          .read(studentsProvider)
          .where((s) => s.id == _student.id)
          .firstOrNull;
      setState(() {
        _isContractLoading = false;
        _isContractDeleting = false;
        _activeContract = null;
        if (refreshed != null) _student = refreshed;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.contractDeleteSuccess),
          backgroundColor: HelpiTheme.statusActiveText,
        ),
      );
      return;
    }

    // Can delete directly
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.contractDeleteTitle),
        content: SizedBox(
          width: 400,
          child: Text(AppStrings.contractDeleteConfirm),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: HelpiTheme.error),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() {
      _isContractLoading = true;
      _isContractDeleting = true;
    });

    final result = await api.deleteContract(contractId);
    if (!mounted) return;
    if (!result.success) {
      setState(() => _isContractLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Error'),
          backgroundColor: HelpiTheme.primary,
        ),
      );
      return;
    }

    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;
    final refreshed = ref
        .read(studentsProvider)
        .where((s) => s.id == _student.id)
        .firstOrNull;
    setState(() {
      _isContractLoading = false;
      _isContractDeleting = false;
      _activeContract = null;
      if (refreshed != null) _student = refreshed;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.contractDeleteSuccess),
        backgroundColor: HelpiTheme.statusActiveText,
      ),
    );
  }

  Future<void> _simulateContractUpload() async {
    // Step 1: Pick PDF file
    const pdfType = XTypeGroup(
      label: 'PDF',
      extensions: ['pdf'],
      mimeTypes: ['application/pdf'],
    );
    final file = await openFile(acceptedTypeGroups: [pdfType]);

    if (!mounted) return;
    if (file == null) return;

    final fileName = file.name;

    // Step 2: Pick contract date range
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(
        start: now,
        end: DateTime(now.year, now.month + 1, 0),
      ),
      helpText: AppStrings.contractSelectPeriod,
      saveText: AppStrings.save,
      cancelText: AppStrings.cancel,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: HelpiTheme.accent),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || picked == null) return;

    // Step 3: Read file bytes and upload to backend
    final fileBytes = await file.readAsBytes();
    if (!mounted) return;

    final studentId = int.tryParse(_student.id);
    if (studentId == null) return;

    setState(() => _isContractLoading = true);

    final api = AdminApiService();
    final result = await api.uploadContract(
      studentId: studentId,
      fileBytes: Uint8List.fromList(fileBytes),
      fileName: fileName,
      effectiveDate: picked.start.toIso8601String().split('T').first,
      expirationDate: picked.end.toIso8601String().split('T').first,
    );
    if (!mounted) return;
    if (!result.success) {
      setState(() => _isContractLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Error'),
          backgroundColor: HelpiTheme.primary,
        ),
      );
      return;
    }

    // Refresh data from backend
    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;
    await _loadContracts();
    if (!mounted) return;
    final refreshed = ref
        .read(studentsProvider)
        .where((s) => s.id == _student.id)
        .firstOrNull;
    setState(() {
      _isContractLoading = false;
      if (refreshed != null) _student = refreshed;
      if (!_isCustomRange) _initSummaryRange();
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppStrings.contractUploadSuccess} ($fileName)'),
        backgroundColor: HelpiTheme.statusActiveText,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  AVAILABILITY SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildAvailabilitySection() {
    final dayLabels = [
      AppStrings.dayMonFull,
      AppStrings.dayTueFull,
      AppStrings.dayWedFull,
      AppStrings.dayThuFull,
      AppStrings.dayFriFull,
      AppStrings.daySatFull,
      AppStrings.daySunFull,
    ];

    return SectionCard(
      title: AppStrings.studentAvailability,
      icon: Icons.schedule,
      children: [
        if (_availability.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                AppStrings.noAvailability,
                style: TextStyle(color: HelpiColors.of(context).textSecondary),
              ),
            ),
          ),
        if (_availability.isNotEmpty)
          ResponsiveFieldGrid(
            children: [
              ..._availability.map((day) {
                final idx = day.dayOfWeek - 1;
                final label = idx >= 0 && idx < dayLabels.length
                    ? dayLabels[idx]
                    : '?';
                return InfoField(
                  label: label,
                  valueWidget: Text(
                    '${formatTimeOfDay(day.from)} – ${formatTimeOfDay(day.to)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: HelpiColors.of(context).textPrimary,
                    ),
                  ),
                );
              }),
            ],
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  WORK SUMMARY (Obračun)
  // ─────────────────────────────────────────────────────────

  /// Counts (completed, cancelled) orders within [_summaryStart]..[_summaryEnd].
  (int, int) _rangeJobCounts() {
    final studentOrders = ref
        .read(ordersProvider)
        .where((o) => o.student?.id == _student.id);

    int completed = 0;
    int cancelled = 0;

    for (final order in studentOrders) {
      // One-time orders: check scheduledDate
      if (order.dayEntries.isEmpty) {
        if (!order.scheduledDate.isBefore(_summaryStart) &&
            !order.scheduledDate.isAfter(_summaryEnd)) {
          if (order.status == OrderStatus.completed) completed++;
          if (order.status == OrderStatus.cancelled) cancelled++;
        }
      } else {
        // Recurring: if order falls in range at all, count it once
        if (order.status == OrderStatus.completed) completed++;
        if (order.status == OrderStatus.cancelled) cancelled++;
      }
    }
    return (completed, cancelled);
  }

  List<SessionModel> _rangeSessions() {
    final studentOrders = ref
        .read(ordersProvider)
        .where((o) => o.student?.id == _student.id);

    return studentOrders.expand((order) => order.sessions).where((session) {
      if (session.status == SessionStatus.cancelled) {
        return false;
      }

      final sessionDate = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );

      return !sessionDate.isBefore(_summaryStart) &&
          !sessionDate.isAfter(_summaryEnd);
    }).toList();
  }

  double? _singleStudentRate(Iterable<SessionModel> sessions) {
    final rates = sessions
        .map((session) => session.studentHourlyRate)
        .where((rate) => rate > 0)
        .toSet();

    if (rates.length != 1) {
      return null;
    }

    return rates.first;
  }

  /// Calculates (regularHours, overtimeHours) within [_summaryStart]..[_summaryEnd].
  (double, double) _rangeHours() {
    final rangedSessions = _rangeSessions();

    double regular = 0;
    double overtime = 0;

    for (final session in rangedSessions) {
      final hours = session.durationHours.toDouble();
      if (CroatianHolidays.isOvertimeDay(session.date)) {
        overtime += hours;
      } else {
        regular += hours;
      }
    }
    return (regular, overtime);
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _summaryStart,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: _summaryEnd,
      confirmText: AppStrings.ok,
      cancelText: AppStrings.cancel,
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _summaryStart = picked;
        _isCustomRange = true;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _summaryEnd,
      firstDate: _summaryStart,
      lastDate: DateTime(now.year, 12, 31),
      confirmText: AppStrings.ok,
      cancelText: AppStrings.cancel,
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _summaryEnd = picked;
        _isCustomRange = true;
      });
    }
  }

  void _resetToContractRange() {
    setState(() {
      _isCustomRange = false;
      _initSummaryRange();
    });
  }

  Widget _buildWorkSummarySection() {
    final rangedSessions = _rangeSessions();
    final regularSessions = rangedSessions
        .where((session) => !CroatianHolidays.isOvertimeDay(session.date))
        .toList();
    final overtimeSessions = rangedSessions
        .where((session) => CroatianHolidays.isOvertimeDay(session.date))
        .toList();
    final (regularHrs, overtimeHrs) = _rangeHours();
    final totalHrs = regularHrs + overtimeHrs;
    final regularPay = regularSessions.fold<double>(
      0,
      (sum, session) => sum + session.durationHours * session.studentHourlyRate,
    );
    final overtimePay = overtimeSessions.fold<double>(
      0,
      (sum, session) => sum + session.durationHours * session.studentHourlyRate,
    );
    final totalPay = regularPay + overtimePay;
    final regularRate = _singleStudentRate(regularSessions);
    final overtimeRate = _singleStudentRate(overtimeSessions);

    final (completedCount, cancelledCount) = _rangeJobCounts();

    return SectionCard(
      title: AppStrings.workSummary,
      icon: Icons.work_history,
      children: [
        // ── Period selector ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: HelpiColors.of(context).scaffold,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.date_range,
                    size: 16,
                    color: HelpiTheme.accent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _isCustomRange
                          ? AppStrings.workCustomPeriod
                          : AppStrings.workContractPeriod,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: HelpiColors.of(context).textPrimary,
                      ),
                    ),
                  ),
                  if (_isCustomRange)
                    GestureDetector(
                      onTap: _resetToContractRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: HelpiTheme.statusProcessingBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.restart_alt,
                          size: 16,
                          color: HelpiTheme.statusProcessingText,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickStartDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: HelpiColors.of(context).surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: HelpiColors.of(context).border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final narrow =
                                      MediaQuery.sizeOf(context).width < 600;
                                  return Text(
                                    narrow
                                        ? formatDate(_summaryStart)
                                        : '${AppStrings.workFrom}: ${formatDate(_summaryStart)}',
                                    style: const TextStyle(fontSize: 13),
                                  );
                                },
                              ),
                            ),
                            const Icon(
                              Icons.edit_calendar,
                              size: 16,
                              color: HelpiTheme.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (MediaQuery.sizeOf(context).width >= 600)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '→',
                        style: TextStyle(
                          color: HelpiColors.of(context).textSecondary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickEndDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: HelpiColors.of(context).surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: HelpiColors.of(context).border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final narrow =
                                      MediaQuery.sizeOf(context).width < 600;
                                  return Text(
                                    narrow
                                        ? formatDate(_summaryEnd)
                                        : '${AppStrings.workTo}: ${formatDate(_summaryEnd)}',
                                    style: const TextStyle(fontSize: 13),
                                  );
                                },
                              ),
                            ),
                            const Icon(
                              Icons.edit_calendar,
                              size: 16,
                              color: HelpiTheme.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Job counts ──
        if (totalHrs == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.work_off_outlined,
                    size: 36,
                    color: HelpiColors.of(context).border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.workNoOrders,
                    style: TextStyle(
                      color: HelpiColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          // Row 1: counts + rates
          ResponsiveFieldGrid(
            children: [
              InfoField(
                label: AppStrings.studentCompletedJobs,
                value: '$completedCount',
              ),
              InfoField(
                label: AppStrings.studentCancelledJobs,
                value: '$cancelledCount',
              ),
              InfoField(
                label: AppStrings.workHourlyRate,
                value: regularRate != null
                    ? '${regularRate.toStringAsFixed(2)} €'
                    : '-',
              ),
              InfoField(
                label: AppStrings.workSundayRate,
                value: overtimeRate != null
                    ? '${overtimeRate.toStringAsFixed(2)} €'
                    : '-',
              ),
            ],
          ),
          // Row 2: hours + payout
          ResponsiveFieldGrid(
            children: [
              InfoField(
                label: AppStrings.workRegularHours,
                value: '${regularHrs.toStringAsFixed(0)} ${AppStrings.hours}',
              ),
              InfoField(
                label: AppStrings.workSundayHours,
                value: '${overtimeHrs.toStringAsFixed(0)} ${AppStrings.hours}',
              ),
              InfoField(
                label: AppStrings.workTotalHours,
                value: '${totalHrs.toStringAsFixed(0)} ${AppStrings.hours}',
              ),
              InfoField(
                label: AppStrings.workEstimatedPayout,
                value: '${totalPay.toStringAsFixed(2)} €',
              ),
            ],
          ),
          // Breakdown detail
          if (regularRate != null || (overtimeHrs > 0 && overtimeRate != null))
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${regularRate != null ? '${regularHrs.toStringAsFixed(0)}h × ${regularRate.toStringAsFixed(2)}€ = ${regularPay.toStringAsFixed(2)}€' : ''}'
                '${overtimeHrs > 0 && overtimeRate != null ? '  +  ${overtimeHrs.toStringAsFixed(0)}h × ${overtimeRate.toStringAsFixed(2)}€ = ${overtimePay.toStringAsFixed(2)}€' : ''}',
                style: TextStyle(
                  fontSize: 11,
                  color: HelpiColors.of(context).textSecondary,
                ),
              ),
            ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  ORDERS SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildOrdersSection(List<OrderModel> orders) {
    final visibleOrders = orders.take(5).toList();
    final hasMore = orders.length > 5;

    return SectionCard(
      title: AppStrings.studentAssignedOrders,
      icon: Icons.receipt_long,
      children: [
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 36,
                    color: HelpiColors.of(context).border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.noOrdersFound,
                    style: TextStyle(
                      color: HelpiColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (orders.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: hasMore ? 320 : double.infinity,
            ),
            child: hasMore
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: orders.length,
                    itemBuilder: (_, i) => _buildOrderTile(orders[i]),
                  )
                : Column(
                    children: visibleOrders
                        .map((o) => _buildOrderTile(o))
                        .toList(),
                  ),
          ),
      ],
    );
  }

  Widget _buildOrderTile(OrderModel o) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o)),
        ).then((_) {
          if (!mounted) return;
          setState(() {});
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: HelpiColors.of(context).scaffold,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${o.orderNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    o.senior.fullName,
                    style: TextStyle(
                      fontSize: 13,
                      color: HelpiColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge.order(o.status),
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

  // ─────────────────────────────────────────────────────────
  //  REVIEWS SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildReviewsSection(List<ReviewModel> reviews) {
    return ReviewsSection(
      title: AppStrings.studentReviews,
      avgRating: _student.avgRating,
      reviews: reviews,
      reviewerName: (r) => r.seniorName,
    );
  }

  // ─────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────
}
