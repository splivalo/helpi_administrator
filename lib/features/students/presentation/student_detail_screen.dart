import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/models/faculty.dart';
import 'package:helpi_admin/core/services/preferences_service.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/utils/session_preview_helper.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/features/orders/presentation/order_detail_screen.dart';

/// Student Detail Screen — profil studenta, ugovor, dostupnost, recenzije.
class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({super.key, required this.student});
  final StudentModel student;

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late StudentModel _student;
  final _prefs = PreferencesService.instance;
  static const _screenKey = 'studentDetail';
  static const _sectionCount = 7;

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
    final reviews = MockData.reviews
        .where((r) => r.studentName == _student.fullName)
        .toList();
    final orders = MockData.orders
        .where((o) => o.student?.id == _student.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(_student.fullName, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            StatusBadge.contract(_student.contractStatus),
            if (_student.isArchived) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: HelpiTheme.chipBg,
                  border: Border.all(
                    color: HelpiTheme.textSecondary.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(
                    HelpiTheme.statusBadgeRadius,
                  ),
                ),
                child: Text(
                  AppStrings.statusArchived,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
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
    AppStrings.adminActions,
  ];

  static const _sectionIcons = [
    Icons.person,
    Icons.description,
    Icons.work_history,
    Icons.schedule,
    Icons.receipt_long,
    Icons.star,
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
                          ? HelpiTheme.border
                          : HelpiTheme.textSecondary,
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
                          ? HelpiTheme.border
                          : HelpiTheme.textSecondary,
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
            InfoField(
              label: AppStrings.studentIdNumber,
              value: _student.studentIdNumber,
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  CONTRACT SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildContractSection() {
    if (_student.contractStatus == ContractStatus.none) {
      return SectionCard(
        title: AppStrings.studentContractTitle,
        icon: Icons.description,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 36,
                    color: HelpiTheme.border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.contractNone,
                    style: const TextStyle(color: HelpiTheme.textSecondary),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: HelpiTheme.textPrimary,
                ),
              ),
            ),
            if (_student.contractStartDate != null)
              InfoField(
                label: AppStrings.studentContractStart,
                value: formatDateDot(_student.contractStartDate!),
              ),
            if (_student.contractExpiryDate != null)
              InfoField(
                label: AppStrings.studentContractExpiry,
                value: formatDateDot(_student.contractExpiryDate!),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ActionChipButton(
          icon: Icons.upload_file,
          label: AppStrings.studentUploadContract,
          color: HelpiTheme.accent,
          onTap: _simulateContractUpload,
        ),
      ],
    );
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
              : HelpiTheme.textSecondary,
          onTap: () =>
              _student.isArchived ? _confirmUnarchive() : _confirmArchive(),
        ),
      ],
    );
  }

  // ── Archive / Unarchive logic ──

  void _confirmArchive() {
    // Check for active orders
    final hasActiveOrders = MockData.orders.any(
      (o) =>
          o.student?.id == _student.id &&
          (o.status == OrderStatus.active ||
              o.status == OrderStatus.processing),
    );

    if (hasActiveOrders) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.archiveBlockedTitle),
          content: SizedBox(
            width: 400,
            child: Text(AppStrings.archiveBlockedMsg),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.ok),
            ),
          ],
        ),
      );
      return;
    }

    showDialog<bool>(
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
            child: Text(AppStrings.studentArchive),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _student = _rebuildStudent(isArchived: true, isActive: false);
        });
      }
    });
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
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _student = _rebuildStudent(isArchived: false);
        });
      }
    });
  }

  StudentModel _rebuildStudent({
    bool? isActive,
    bool? isArchived,
    ContractStatus? contractStatus,
    DateTime? contractStartDate,
    DateTime? contractExpiryDate,
  }) {
    final updated = StudentModel(
      id: _student.id,
      firstName: _student.firstName,
      lastName: _student.lastName,
      email: _student.email,
      phone: _student.phone,
      address: _student.address,
      faculty: _student.faculty,
      studentIdNumber: _student.studentIdNumber,
      dateOfBirth: _student.dateOfBirth,
      gender: _student.gender,
      isActive: isActive ?? _student.isActive,
      isArchived: isArchived ?? _student.isArchived,
      isVerified: _student.isVerified,
      avgRating: _student.avgRating,
      totalReviews: _student.totalReviews,
      completedJobs: _student.completedJobs,
      cancelledJobs: _student.cancelledJobs,
      contractStatus: contractStatus ?? _student.contractStatus,
      contractStartDate: contractStartDate ?? _student.contractStartDate,
      contractExpiryDate: contractExpiryDate ?? _student.contractExpiryDate,
      createdAt: _student.createdAt,
      availability: _student.availability,
      hourlyRate: _student.hourlyRate,
      sundayHourlyRate: _student.sundayHourlyRate,
    );
    // Persist change to MockData so list screens reflect it
    final idx = MockData.students.indexWhere((s) => s.id == updated.id);
    if (idx != -1) MockData.students[idx] = updated;
    return updated;
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

    // Step 3: Update student
    setState(() {
      _student = _rebuildStudent(
        contractStatus: ContractStatus.active,
        contractStartDate: picked.start,
        contractExpiryDate: picked.end,
      );
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
        ResponsiveFieldGrid(
          children: [
            ...List.generate(_student.availability.length, (i) {
              final day = _student.availability[i];
              if (!day.isEnabled) return null;
              return InfoField(
                label: dayLabels[i],
                valueWidget: Text(
                  '${formatTimeOfDay(day.from)} – ${formatTimeOfDay(day.to)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: HelpiTheme.textPrimary,
                  ),
                ),
              );
            }).nonNulls,
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
    final studentOrders = MockData.orders.where(
      (o) => o.student?.id == _student.id,
    );

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

  /// Counts how many times [dayOfWeek] (1=Mon..7=Sun) falls in [start]..[end].
  int _dayOccurrencesInRange(DateTime start, DateTime end, int dayOfWeek) {
    int count = 0;
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      if (d.weekday == dayOfWeek) count++;
    }
    return count;
  }

  /// Calculates (regularHours, sundayHours) within [_summaryStart]..[_summaryEnd].
  (double, double) _rangeHours() {
    final studentOrders = MockData.orders.where(
      (o) =>
          o.student?.id == _student.id &&
          (o.status == OrderStatus.active || o.status == OrderStatus.completed),
    );

    double regular = 0;
    double sunday = 0;

    for (final order in studentOrders) {
      if (order.dayEntries.isNotEmpty) {
        // Recurring: count each day's occurrences in the selected range
        for (final entry in order.dayEntries) {
          final occurrences = _dayOccurrencesInRange(
            _summaryStart,
            _summaryEnd,
            entry.dayOfWeek,
          );
          final hours = entry.durationHours.toDouble() * occurrences;
          if (entry.dayOfWeek == DateTime.sunday) {
            sunday += hours;
          } else {
            regular += hours;
          }
        }
      } else {
        // One-time: only if scheduledDate falls within range
        if (!order.scheduledDate.isBefore(_summaryStart) &&
            !order.scheduledDate.isAfter(_summaryEnd)) {
          final hours = order.durationHours.toDouble();
          if (order.scheduledDate.weekday == DateTime.sunday) {
            sunday += hours;
          } else {
            regular += hours;
          }
        }
      }
    }
    return (regular, sunday);
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
    final (regularHrs, sundayHrs) = _rangeHours();
    final totalHrs = regularHrs + sundayHrs;
    final regularPay = regularHrs * _student.hourlyRate;
    final sundayPay = sundayHrs * _student.sundayHourlyRate;
    final totalPay = regularPay + sundayPay;

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
            color: HelpiTheme.scaffold,
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
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: HelpiTheme.textPrimary,
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: HelpiTheme.border),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '→',
                        style: TextStyle(color: HelpiTheme.textSecondary),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: HelpiTheme.border),
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
                  const Icon(
                    Icons.work_off_outlined,
                    size: 36,
                    color: HelpiTheme.border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.workNoOrders,
                    style: const TextStyle(color: HelpiTheme.textSecondary),
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
                value: '${_student.hourlyRate.toStringAsFixed(2)} €',
              ),
              InfoField(
                label: AppStrings.workSundayRate,
                value: '${_student.sundayHourlyRate.toStringAsFixed(2)} €',
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
                value: '${sundayHrs.toStringAsFixed(0)} ${AppStrings.hours}',
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
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${regularHrs.toStringAsFixed(0)}h × ${_student.hourlyRate.toStringAsFixed(2)}€ = ${regularPay.toStringAsFixed(2)}€'
              '${sundayHrs > 0 ? '  +  ${sundayHrs.toStringAsFixed(0)}h × ${_student.sundayHourlyRate.toStringAsFixed(2)}€ = ${sundayPay.toStringAsFixed(2)}€' : ''}',
              style: const TextStyle(
                fontSize: 11,
                color: HelpiTheme.textSecondary,
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
                  const Icon(
                    Icons.inbox_outlined,
                    size: 36,
                    color: HelpiTheme.border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.noOrdersFound,
                    style: const TextStyle(color: HelpiTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ...orders.map((o) {
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
                color: HelpiTheme.scaffold,
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
                          style: const TextStyle(
                            fontSize: 13,
                            color: HelpiTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.order(o.status),
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
        }),
        const SizedBox(height: 8),
        ActionChipButton(
          icon: Icons.assignment_ind,
          label: AppStrings.assignToOrder,
          color: HelpiTheme.accent,
          onTap: _openAssignSheet,
        ),
      ],
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
  //  ASSIGN TO ORDER — matching logic
  // ─────────────────────────────────────────────────────────

  /// Returns unassigned orders whose schedule fits the student's availability.
  List<OrderModel> _findMatchingOrders() {
    final unassigned = MockData.orders.where(
      (o) => o.student == null && o.status == OrderStatus.processing,
    );

    return unassigned.where((order) {
      if (order.dayEntries.isNotEmpty) {
        // Recurring: student must have the day enabled for every dayEntry
        // (time mismatches are handled in the session preview)
        return order.dayEntries.every(
          (entry) => _dayIsEnabled(entry.dayOfWeek),
        );
      }
      // One-time: check scheduledDate's weekday is enabled
      return _dayIsEnabled(order.scheduledDate.weekday);
    }).toList();
  }

  /// Returns true if the student has that weekday enabled (or has no
  /// availability set at all, which means "always available").
  bool _dayIsEnabled(int dayOfWeek) {
    if (_student.availability.isEmpty) return true;
    return _student.availability.any(
      (a) => a.dayOfWeek == dayOfWeek && a.isEnabled,
    );
  }

  void _openAssignSheet() {
    final matching = _findMatchingOrders();
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (isWide) {
      showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
                child: _AssignFlowSheet(
                  student: _student,
                  matchingOrders: matching,
                  onAssigned: (order) {
                    Navigator.pop(ctx);
                    _simulateAssign(order);
                  },
                  useDialog: true,
                ),
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return _AssignFlowSheet(
            student: _student,
            matchingOrders: matching,
            onAssigned: (order) {
              Navigator.pop(ctx);
              _simulateAssign(order);
            },
          );
        },
      );
    }
  }

  void _simulateAssign(OrderModel order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppStrings.assignSuccess} #${order.orderNumber}'),
        backgroundColor: HelpiTheme.statusActiveText,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────
}

// ═══════════════════════════════════════════════════════════════
//  ASSIGN FLOW SHEET — matching list + session preview in one sheet
// ═══════════════════════════════════════════════════════════════
class _AssignFlowSheet extends StatefulWidget {
  const _AssignFlowSheet({
    required this.student,
    required this.matchingOrders,
    required this.onAssigned,
    this.useDialog = false,
  });

  final StudentModel student;
  final List<OrderModel> matchingOrders;
  final void Function(OrderModel order) onAssigned;
  final bool useDialog;

  @override
  State<_AssignFlowSheet> createState() => _AssignFlowSheetState();
}

class _AssignFlowSheetState extends State<_AssignFlowSheet> {
  OrderModel? _selectedOrder;

  void _selectOrder(OrderModel order) {
    setState(() => _selectedOrder = order);
  }

  void _goBack() {
    setState(() => _selectedOrder = null);
  }

  @override
  Widget build(BuildContext context) {
    final content = _selectedOrder != null
        ? Builder(
            builder: (_) {
              final helper = _StudentSessionPreviewHelper(
                student: widget.student,
                order: _selectedOrder!,
              );
              return SessionPreviewContent(
                key: ValueKey(_selectedOrder!.id),
                student: widget.student,
                order: _selectedOrder!,
                onBack: _goBack,
                onAssigned: (_) => widget.onAssigned(_selectedOrder!),
                generateSessions: helper.generateSessions,
                findSubstitutes: helper.findSubstitutes,

                buildConflictMessage: helper.buildConflictMessage,
                useDialog: widget.useDialog,
              );
            },
          )
        : _buildMatchingList();

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

    final height = _selectedOrder != null ? 0.9 : 0.65;
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

  Widget _buildMatchingList() {
    return Column(
      children: [
        if (!widget.useDialog)
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: DragHandle(),
          ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.assignment_ind, color: HelpiTheme.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${AppStrings.matchingOrders} (${widget.matchingOrders.length})',
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
        const Divider(height: 1),
        // List
        Expanded(
          child: widget.matchingOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_busy,
                        size: 56,
                        color: HelpiTheme.border,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.noMatchingOrders,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: HelpiTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.matchingOrders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final o = widget.matchingOrders[i];
                    return _MatchingOrderCard(
                      order: o,
                      onAssign: () => _selectOrder(o),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SESSION PREVIEW CONTENT — shows inside the assign flow sheet
// ═══════════════════════════════════════════════════════════════

/// Thin wrapper that supplies student-detail-specific logic to the
/// shared [SessionPreviewContent] widget.
class _StudentSessionPreviewHelper extends SessionPreviewHelperBase {
  _StudentSessionPreviewHelper({required super.student, required super.order});

  @override
  List<SessionInstancePreview> generateSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final studentOrders = MockData.orders
        .where(
          (o) =>
              o.student?.id == student.id &&
              o.status != OrderStatus.cancelled &&
              o.id != order.id,
        )
        .toList();

    if (order.frequency == FrequencyType.oneTime) {
      final conflict = findConflict(
        date: order.scheduledDate,
        weekday: order.scheduledDate.weekday,
        startMin: toMinutes(order.scheduledStart),
        endMin: toMinutes(order.scheduledStart) + order.durationHours * 60,
        studentOrders: studentOrders,
      );
      return [
        SessionInstancePreview(
          date: order.scheduledDate,
          weekday: order.scheduledDate.weekday,
          startTime: order.scheduledStart,
          durationHours: order.durationHours,
          conflictType: conflict != null
              ? SessionConflictType.conflict
              : SessionConflictType.free,
          conflictingOrder: conflict,
        ),
      ];
    }

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
        final conflict = findConflict(
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
            conflictType: conflict != null
                ? SessionConflictType.conflict
                : SessionConflictType.free,
            conflictingOrder: conflict,
          ),
        );
      }
    }
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  @override
  String buildConflictMessage(SessionInstancePreview s) {
    return '${AppStrings.conflictWith} '
        '#${s.conflictingOrder?.orderNumber ?? "?"} '
        '${s.conflictingOrder?.senior.fullName ?? ""}';
  }
}

// ═══════════════════════════════════════════════════════════════
//  MATCHING ORDER CARD  (inside assign bottom sheet)
// ═══════════════════════════════════════════════════════════════
class _MatchingOrderCard extends StatelessWidget {
  const _MatchingOrderCard({required this.order, required this.onAssign});

  final OrderModel order;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: order number + senior name ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.senior.fullName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: HelpiTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ActionChipButton(
                icon: Icons.check,
                label: MediaQuery.sizeOf(context).width < 600
                    ? AppStrings.assignShort
                    : AppStrings.assignToOrder,
                color: HelpiTheme.accent,
                onTap: onAssign,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Schedule info ──
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: HelpiTheme.accent,
              ),
              const SizedBox(width: 6),
              Text(
                formatDate(order.scheduledDate),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 14, color: HelpiTheme.accent),
              const SizedBox(width: 4),
              Text(
                formatTimeOfDay(order.scheduledStart),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 4),
              Text(
                '(${order.durationHours}${AppStrings.hours})',
                style: const TextStyle(
                  fontSize: 12,
                  color: HelpiTheme.textSecondary,
                ),
              ),
            ],
          ),

          // ── Services ──
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: order.services.map((s) => ServiceChip(type: s)).toList(),
          ),

          // ── Address ──
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: HelpiTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
