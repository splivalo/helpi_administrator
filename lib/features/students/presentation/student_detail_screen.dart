import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/services/preferences_service.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
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
              value: _student.faculty,
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
          content: Text(AppStrings.archiveBlockedMsg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
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
              return InfoField(
                label: dayLabels[i],
                valueWidget: day.isEnabled
                    ? Text(
                        '${formatTimeOfDay(day.from)} – ${formatTimeOfDay(day.to)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: HelpiTheme.textPrimary,
                        ),
                      )
                    : Text(
                        AppStrings.studentNotAvailableGendered(_student.gender),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: HelpiTheme.textSecondary,
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: HelpiTheme.accent,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: HelpiTheme.accent,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
                              child: Text(
                                '${AppStrings.workFrom}: ${formatDate(_summaryStart)}',
                                style: const TextStyle(fontSize: 13),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '→',
                      style: TextStyle(color: HelpiTheme.textSecondary),
                    ),
                  ),
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
                              child: Text(
                                '${AppStrings.workTo}: ${formatDate(_summaryEnd)}',
                                style: const TextStyle(fontSize: 13),
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
              );
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
    if (reviews.isEmpty) {
      return SectionCard(
        title: AppStrings.studentReviews,
        icon: Icons.star,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.star_border,
                    size: 36,
                    color: HelpiTheme.border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.seniorNoReviews,
                    style: const TextStyle(color: HelpiTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return SectionCard(
      title: AppStrings.studentReviews,
      icon: Icons.star,
      children: [
        // ── Rating summary ──
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HelpiTheme.starYellow.withValues(alpha: 0.15),
                border: Border.all(
                  color: HelpiTheme.starYellow.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(
                  HelpiTheme.statusBadgeRadius,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    size: 18,
                    color: HelpiTheme.starYellow,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_student.avgRating}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${AppStrings.studentTotalRatings}: ${reviews.length}',
              style: const TextStyle(
                color: HelpiTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        if (reviews.isNotEmpty) ...[
          const Divider(height: 20),
          ...reviews.map(
            (r) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HelpiTheme.scaffold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < r.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: HelpiTheme.starYellow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        r.seniorName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: HelpiTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (r.comment != null && r.comment!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      r.comment!,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
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
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 80,
              vertical: 40,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 560,
                  maxHeight: 700,
                ),
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
        ? _SessionPreviewContent(
            key: ValueKey(_selectedOrder!.id),
            student: widget.student,
            order: _selectedOrder!,
            onBack: _goBack,
            onAssigned: () => widget.onAssigned(_selectedOrder!),
            useDialog: widget.useDialog,
          )
        : _buildMatchingList();

    if (widget.useDialog) {
      return Container(
        decoration: const BoxDecoration(
          color: HelpiTheme.scaffold,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: content,
      );
    }

    final height = _selectedOrder != null ? 0.9 : 0.65;
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.assignment_ind, color: HelpiTheme.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.matchingOrders,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${widget.matchingOrders.length}',
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
class _SessionPreviewContent extends StatefulWidget {
  const _SessionPreviewContent({
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
  final VoidCallback onAssigned;
  final bool useDialog;

  @override
  State<_SessionPreviewContent> createState() => _SessionPreviewContentState();
}

class _SessionPreviewContentState extends State<_SessionPreviewContent> {
  late List<SessionInstancePreview> _sessions;
  int? _expandedIndex;
  // 'time' or 'substitute'
  String? _expandedType;

  @override
  void initState() {
    super.initState();
    _sessions = _generateSessions();
  }

  // ── Generate sessions ───────────────────────────────────────

  List<SessionInstancePreview> _generateSessions() {
    final order = widget.order;
    final student = widget.student;
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
      final conflict = _findConflict(
        date: order.scheduledDate,
        weekday: order.scheduledDate.weekday,
        startMin: _toMin(order.scheduledStart),
        endMin: _toMin(order.scheduledStart) + order.durationHours * 60,
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
        final startMin = _toMin(entry.startTime);
        final endMin = startMin + entry.durationHours * 60;
        final conflict = _findConflict(
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
      final avail = s.availability.where(
        (a) => a.dayOfWeek == session.weekday && a.isEnabled,
      );
      if (avail.isEmpty) return false;
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
    widget.onAssigned();
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
                      '${AppStrings.conflictWith} '
                      '#${s.conflictingOrder?.orderNumber ?? "?"} '
                      '${s.conflictingOrder?.senior.fullName ?? ""}',
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
                label: AppStrings.assignToOrder,
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
