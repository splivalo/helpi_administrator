import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
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

  /// Date range for work summary payout calculation.
  late DateTime _summaryStart;
  late DateTime _summaryEnd;
  bool _isCustomRange = false;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _initSummaryRange();
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
            _buildContractBadge(_student.contractStatus),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: AppStrings.studentPersonalData,
              icon: Icons.person,
              children: [
                _InfoRow(
                  label: AppStrings.studentFirstName,
                  value: _student.firstName,
                ),
                _InfoRow(
                  label: AppStrings.studentLastName,
                  value: _student.lastName,
                ),
                _InfoRow(label: AppStrings.studentEmail, value: _student.email),
                _InfoRow(label: AppStrings.studentPhone, value: _student.phone),
                _InfoRow(
                  label: AppStrings.studentAddress,
                  value: _student.address,
                ),
                _InfoRow(
                  label: AppStrings.studentDateOfBirth,
                  value:
                      '${_student.dateOfBirth.day}.${_student.dateOfBirth.month}.${_student.dateOfBirth.year}.',
                ),
                _InfoRow(
                  label: AppStrings.studentGender,
                  value: _student.gender == Gender.male
                      ? AppStrings.genderMale
                      : AppStrings.genderFemale,
                ),
                _InfoRow(
                  label: AppStrings.studentFaculty,
                  value: _student.faculty,
                ),
                _InfoRow(
                  label: AppStrings.studentIdNumber,
                  value: _student.studentIdNumber,
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildContractSection(),
            const SizedBox(height: 12),

            _buildWorkSummarySection(),
            const SizedBox(height: 12),

            _buildAvailabilitySection(),
            const SizedBox(height: 12),

            _buildOrdersSection(orders),
            const SizedBox(height: 12),

            _buildReviewsSection(reviews),
            const SizedBox(height: 12),

            // ── Admin actions ──
            _buildAdminActionsSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  CONTRACT SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildContractSection() {
    if (_student.contractStatus == ContractStatus.none) {
      return _SectionCard(
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
                    style: const TextStyle(
                      color: HelpiTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _simulateContractUpload,
              icon: const Icon(Icons.upload_file, size: 18),
              label: Text(AppStrings.studentUploadContract),
              style: OutlinedButton.styleFrom(
                foregroundColor: HelpiTheme.accent,
                side: const BorderSide(color: HelpiTheme.accent, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    }

    return _SectionCard(
      title: AppStrings.studentContractTitle,
      icon: Icons.description,
      children: [
        _InfoRow(
          label: AppStrings.studentContractStatus,
          valueWidget: Text(
            _contractLabel(_student.contractStatus),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _contractColor(_student.contractStatus),
            ),
          ),
        ),
        if (_student.contractStartDate != null)
          _InfoRow(
            label: AppStrings.studentContractStart,
            value:
                '${_student.contractStartDate!.day}.${_student.contractStartDate!.month}.${_student.contractStartDate!.year}.',
          ),
        if (_student.contractExpiryDate != null)
          _InfoRow(
            label: AppStrings.studentContractExpiry,
            value:
                '${_student.contractExpiryDate!.day}.${_student.contractExpiryDate!.month}.${_student.contractExpiryDate!.year}.',
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _simulateContractUpload,
            icon: const Icon(Icons.upload_file, size: 18),
            label: Text(AppStrings.studentUploadContract),
            style: OutlinedButton.styleFrom(
              foregroundColor: HelpiTheme.accent,
              side: const BorderSide(color: HelpiTheme.accent, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  ADMIN ACTIONS SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildAdminActionsSection() {
    return _SectionCard(
      title: AppStrings.adminActions,
      icon: Icons.admin_panel_settings,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                _student.isArchived ? _confirmUnarchive() : _confirmArchive(),
            icon: Icon(
              _student.isArchived ? Icons.unarchive : Icons.archive,
              size: 18,
            ),
            label: Text(
              _student.isArchived
                  ? AppStrings.studentUnarchive
                  : AppStrings.studentArchive,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _student.isArchived
                  ? HelpiTheme.accent
                  : HelpiTheme.primary,
              side: BorderSide(
                color: _student.isArchived
                    ? HelpiTheme.accent
                    : HelpiTheme.primary,
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
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
      lastDate: DateTime(now.year + 2),
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

    return _SectionCard(
      title: AppStrings.studentAvailability,
      icon: Icons.schedule,
      children: [
        ...List.generate(_student.availability.length, (i) {
          final day = _student.availability[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    dayLabels[i],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (day.isEnabled)
                  Expanded(
                    child: Text(
                      '${day.from.hour.toString().padLeft(2, '0')}:${day.from.minute.toString().padLeft(2, '0')}'
                      ' – '
                      '${day.to.hour.toString().padLeft(2, '0')}:${day.to.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: HelpiTheme.statusActiveText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      AppStrings.studentNotAvailable,
                      style: const TextStyle(
                        fontSize: 13,
                        color: HelpiTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
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

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      initialDateRange: DateTimeRange(start: _summaryStart, end: _summaryEnd),
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
        _summaryStart = picked.start;
        _summaryEnd = picked.end;
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

    return _SectionCard(
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
              GestureDetector(
                onTap: _pickDateRange,
                child: Container(
                  width: double.infinity,
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
                      Text(
                        '${AppStrings.workFrom}: ${_fmtDate(_summaryStart)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '→',
                        style: TextStyle(color: HelpiTheme.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${AppStrings.workTo}: ${_fmtDate(_summaryEnd)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.edit_calendar,
                        size: 16,
                        color: HelpiTheme.accent,
                      ),
                    ],
                  ),
                ),
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
                    style: const TextStyle(
                      color: HelpiTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          // Job counts
          _InfoRow(
            label: AppStrings.studentCompletedJobs,
            value: '$completedCount',
          ),
          _InfoRow(
            label: AppStrings.studentCancelledJobs,
            value: '$cancelledCount',
          ),
          const Divider(height: 20),
          // Hours breakdown
          _InfoRow(
            label: AppStrings.workRegularHours,
            value: '${regularHrs.toStringAsFixed(0)} ${AppStrings.hours}',
          ),
          _InfoRow(
            label: AppStrings.workSundayHours,
            value: '${sundayHrs.toStringAsFixed(0)} ${AppStrings.hours}',
          ),
          _InfoRow(
            label: AppStrings.workTotalHours,
            value: '${totalHrs.toStringAsFixed(0)} ${AppStrings.hours}',
          ),
          const Divider(height: 20),

          // Rates
          _InfoRow(
            label: AppStrings.workHourlyRate,
            value: '${_student.hourlyRate.toStringAsFixed(2)} €',
          ),
          _InfoRow(
            label: AppStrings.workSundayRate,
            value: '${_student.sundayHourlyRate.toStringAsFixed(2)} €',
          ),
          const Divider(height: 20),

          // Estimated payout
          _InfoRow(
            label: AppStrings.workEstimatedPayout,
            value: '${totalPay.toStringAsFixed(2)} €',
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
    return _SectionCard(
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
                    style: const TextStyle(
                      color: HelpiTheme.textSecondary,
                    ),
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
                  _buildStatusBadge(
                    _orderStatusLabel(o.status),
                    _orderStatusColor(o.status),
                    _orderStatusBg(o.status),
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
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _openAssignSheet,
            icon: const Icon(Icons.assignment_ind, size: 18),
            label: Text(AppStrings.assignToOrder),
            style: FilledButton.styleFrom(
              backgroundColor: HelpiTheme.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  REVIEWS SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildReviewsSection(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return _SectionCard(
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
                    style: const TextStyle(
                      color: HelpiTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _SectionCard(
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
        // Recurring: every dayEntry must fall within student's availability
        return order.dayEntries.every((entry) => _entryFitsAvailability(entry));
      }
      // One-time: check scheduledDate's weekday
      final dow = order.scheduledDate.weekday; // 1=Mon..7=Sun
      final endMin =
          order.scheduledStart.hour * 60 +
          order.scheduledStart.minute +
          order.durationHours * 60;
      return _student.availability.any(
        (a) =>
            a.dayOfWeek == dow &&
            a.isEnabled &&
            a.from.hour * 60 + a.from.minute <=
                order.scheduledStart.hour * 60 + order.scheduledStart.minute &&
            a.to.hour * 60 + a.to.minute >= endMin,
      );
    }).toList();
  }

  bool _entryFitsAvailability(DayEntry entry) {
    final endMin =
        entry.startTime.hour * 60 +
        entry.startTime.minute +
        entry.durationHours * 60;
    return _student.availability.any(
      (a) =>
          a.dayOfWeek == entry.dayOfWeek &&
          a.isEnabled &&
          a.from.hour * 60 + a.from.minute <=
              entry.startTime.hour * 60 + entry.startTime.minute &&
          a.to.hour * 60 + a.to.minute >= endMin,
    );
  }

  void _openAssignSheet() {
    final matching = _findMatchingOrders();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: HelpiTheme.scaffold,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: HelpiTheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.assignment_ind,
                          color: HelpiTheme.accent,
                        ),
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
                          '${matching.length}',
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
                    child: matching.isEmpty
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
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: matching.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final o = matching[i];
                              return _MatchingOrderCard(
                                order: o,
                                onAssign: () {
                                  Navigator.pop(ctx);
                                  _simulateAssign(o);
                                },
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
  Widget _buildStatusBadge(String label, Color textColor, Color bgColor) {
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

  String _contractLabel(ContractStatus status) => switch (status) {
    ContractStatus.active => AppStrings.contractActive,
    ContractStatus.expired => AppStrings.contractExpired,
    ContractStatus.expiring => AppStrings.contractExpiring,
    ContractStatus.none => AppStrings.contractNone,
    ContractStatus.deactivated => AppStrings.contractDeactivated,
  };

  Color _contractColor(ContractStatus status) => switch (status) {
    ContractStatus.active => HelpiTheme.statusActiveText,
    ContractStatus.expired => HelpiTheme.statusCancelledText,
    ContractStatus.expiring => HelpiTheme.statusProcessingText,
    ContractStatus.none => HelpiTheme.textSecondary,
    ContractStatus.deactivated => HelpiTheme.statusCancelledText,
  };

  Widget _buildContractBadge(ContractStatus status) {
    final (Color textColor, Color bgColor, String label) = switch (status) {
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

  String _orderStatusLabel(OrderStatus status) => switch (status) {
    OrderStatus.processing => AppStrings.statusProcessing,
    OrderStatus.active => AppStrings.statusActive,
    OrderStatus.completed => AppStrings.statusCompleted,
    OrderStatus.cancelled => AppStrings.statusCancelled,
  };

  Color _orderStatusColor(OrderStatus status) => switch (status) {
    OrderStatus.processing => HelpiTheme.statusProcessingText,
    OrderStatus.active => HelpiTheme.statusActiveText,
    OrderStatus.completed => HelpiTheme.statusActiveText,
    OrderStatus.cancelled => HelpiTheme.statusCancelledText,
  };

  Color _orderStatusBg(OrderStatus status) => switch (status) {
    OrderStatus.processing => HelpiTheme.statusProcessingBg,
    OrderStatus.active => HelpiTheme.statusActiveBg,
    OrderStatus.completed => HelpiTheme.statusActiveBg,
    OrderStatus.cancelled => HelpiTheme.statusCancelledBg,
  };
}

// ═══════════════════════════════════════════════════════════════
//  SECTION CARD
// ═══════════════════════════════════════════════════════════════
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children, this.icon});
  final String title;
  final IconData? icon;
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
              if (icon != null) ...[
                Icon(icon, size: 20, color: HelpiTheme.accent),
                const SizedBox(width: 8),
              ],
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
  const _InfoRow({required this.label, this.value, this.valueWidget});
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child:
                valueWidget ??
                Text(
                  value ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
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

  String _serviceLabel(ServiceType type) => switch (type) {
    ServiceType.shopping => AppStrings.serviceShopping,
    ServiceType.houseHelp => AppStrings.serviceHouseHelp,
    ServiceType.companionship => AppStrings.serviceCompanionship,
    ServiceType.walk => AppStrings.serviceWalk,
    ServiceType.escort => AppStrings.serviceEscort,
    ServiceType.other => AppStrings.serviceOther,
  };

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final dayLabels = [
      AppStrings.dayMon,
      AppStrings.dayTue,
      AppStrings.dayWed,
      AppStrings.dayThu,
      AppStrings.dayFri,
      AppStrings.daySat,
      AppStrings.daySun,
    ];

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
              FilledButton.icon(
                onPressed: onAssign,
                icon: const Icon(Icons.check, size: 16),
                label: Text(
                  AppStrings.assignToOrder,
                  style: const TextStyle(fontSize: 12),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: HelpiTheme.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
                _formatDate(order.scheduledDate),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 14, color: HelpiTheme.accent),
              const SizedBox(width: 4),
              Text(
                _formatTime(order.scheduledStart),
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

          // ── Day entries for recurring ──
          if (order.dayEntries.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: order.dayEntries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: HelpiTheme.pastelTeal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${dayLabels[e.dayOfWeek - 1]} ${_formatTime(e.startTime)} (${e.durationHours}${AppStrings.hours})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: HelpiTheme.accent,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // ── Services ──
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: order.services.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: HelpiTheme.chipBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _serviceLabel(s),
                  style: const TextStyle(
                    fontSize: 11,
                    color: HelpiTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
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
