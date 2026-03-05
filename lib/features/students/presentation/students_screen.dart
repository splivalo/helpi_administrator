import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/services/preferences_service.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/features/students/presentation/student_detail_screen.dart';

/// Students Screen — popis studenata s naprednim filterima i pretragom.
///
/// [ActivityPeriod] — Google Analytics-style period presets.
enum ActivityPeriod { thisMonth, lastMonth, last60Days, custom }

/// Sort options for the student list.
enum StudentSort { az, za, newest, oldest, ratingHigh, ratingLow }

enum _StudentFilter {
  all,
  active,
  expiring,
  expired,
  noContract,
  deactivated,
  archived,
}

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen>
    with SingleTickerProviderStateMixin {
  static const _screenKey = 'students';
  final _prefs = PreferencesService.instance;

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  StudentSort _sort = StudentSort.az;
  late final TabController _tabCtrl;
  bool _isGridView = false;

  // ── Advanced filter state ──
  ActivityPeriod? _activityPeriod; // null=any
  bool? _activityWorked; // null=any, true=worked, false=didn't
  DateTime? _customFrom;
  DateTime? _customTo;
  Gender? _genderFilter;
  double _minRating = 0.0;
  int? _minJobs;
  int? _maxJobs;
  Set<int> _selectedDays = {}; // 1=Mon..7=Sun
  TimeOfDay? _availableFrom;
  TimeOfDay? _availableTo;
  String? _seniorFilter;

  static const _tabFilters = _StudentFilter.values;

  @override
  void initState() {
    super.initState();

    // Restore saved preferences
    _isGridView = _prefs.getGridView(_screenKey);
    final savedSort = _prefs.getSort(_screenKey);
    if (savedSort != null) {
      _sort = StudentSort.values.firstWhere(
        (e) => e.name == savedSort,
        orElse: () => StudentSort.az,
      );
    }
    final savedTab = _prefs.getTab(_screenKey);

    _tabCtrl = TabController(
      length: _tabFilters.length,
      vsync: this,
      initialIndex: savedTab.clamp(0, _tabFilters.length - 1),
    );
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() {});
        _prefs.setTab(_screenKey, _tabCtrl.index);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Count active filters ──
  int get _activeFilterCount {
    int count = 0;
    if (_activityPeriod != null) count++;
    if (_genderFilter != null) count++;
    if (_minRating > 0) count++;
    if (_minJobs != null) count++;
    if (_maxJobs != null) count++;
    if (_selectedDays.isNotEmpty) count++;
    if (_availableFrom != null || _availableTo != null) count++;
    if (_seniorFilter != null) count++;
    return count;
  }

  // ── Date range from period ──
  (DateTime, DateTime) _dateRangeFor(ActivityPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case ActivityPeriod.thisMonth:
        return (DateTime(now.year, now.month), now);
      case ActivityPeriod.lastMonth:
        final first = DateTime(now.year, now.month - 1);
        final last = DateTime(now.year, now.month, 0);
        return (first, last);
      case ActivityPeriod.last60Days:
        return (now.subtract(const Duration(days: 60)), now);
      case ActivityPeriod.custom:
        return (
          _customFrom ?? now.subtract(const Duration(days: 30)),
          _customTo ?? now,
        );
    }
  }

  // ── Jobs in a date range ──
  int _jobsInRange(StudentModel student, DateTime from, DateTime to) {
    return MockData.orders
        .where(
          (o) =>
              o.student?.id == student.id &&
              o.status == OrderStatus.completed &&
              !o.scheduledDate.isBefore(from) &&
              !o.scheduledDate.isAfter(to),
        )
        .length;
  }

  Set<String> _seniorIdsForStudent(StudentModel student) {
    return MockData.orders
        .where((o) => o.student?.id == student.id)
        .map((o) => o.senior.id)
        .toSet();
  }

  // ── Check if availability slot covers time range ──
  bool _matchesTimeRange(DayAvailability a) {
    if (_availableFrom != null) {
      final fromMin = _availableFrom!.hour * 60 + _availableFrom!.minute;
      final slotFromMin = a.from.hour * 60 + a.from.minute;
      if (slotFromMin > fromMin) return false;
    }
    if (_availableTo != null) {
      final toMin = _availableTo!.hour * 60 + _availableTo!.minute;
      final slotToMin = a.to.hour * 60 + a.to.minute;
      if (slotToMin < toMin) return false;
    }
    return true;
  }

  // ── Apply all filters ──
  List<StudentModel> _filteredStudents(_StudentFilter filter) {
    var students = MockData.students.toList();

    // Combined status + contract filter
    switch (filter) {
      case _StudentFilter.all:
        break;
      case _StudentFilter.active:
        students = students
            .where(
              (s) => s.contractStatus == ContractStatus.active && !s.isArchived,
            )
            .toList();
      case _StudentFilter.expiring:
        students = students
            .where(
              (s) =>
                  s.contractStatus == ContractStatus.expiring && !s.isArchived,
            )
            .toList();
      case _StudentFilter.expired:
        students = students
            .where(
              (s) =>
                  s.contractStatus == ContractStatus.expired && !s.isArchived,
            )
            .toList();
      case _StudentFilter.noContract:
        students = students
            .where(
              (s) => s.contractStatus == ContractStatus.none && !s.isArchived,
            )
            .toList();
      case _StudentFilter.deactivated:
        students = students
            .where(
              (s) =>
                  s.contractStatus == ContractStatus.deactivated &&
                  !s.isArchived,
            )
            .toList();
      case _StudentFilter.archived:
        students = students.where((s) => s.isArchived).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      students = students.where((s) {
        return s.fullName.toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q) ||
            s.phone.contains(q) ||
            s.address.toLowerCase().contains(q);
      }).toList();
    }

    // Activity in period
    if (_activityPeriod != null) {
      final (from, to) = _dateRangeFor(_activityPeriod!);
      if (_activityWorked == true) {
        students = students
            .where((s) => _jobsInRange(s, from, to) > 0)
            .toList();
      } else if (_activityWorked == false) {
        students = students
            .where((s) => _jobsInRange(s, from, to) == 0)
            .toList();
      }
    }

    // Gender
    if (_genderFilter != null) {
      students = students.where((s) => s.gender == _genderFilter).toList();
    }

    // Min rating
    if (_minRating > 0) {
      students = students.where((s) => s.avgRating >= _minRating).toList();
    }

    // Min/max jobs
    if (_minJobs != null) {
      students = students.where((s) => s.completedJobs >= _minJobs!).toList();
    }
    if (_maxJobs != null) {
      students = students.where((s) => s.completedJobs <= _maxJobs!).toList();
    }

    // Availability — AND: dan + sati se kombiniraju
    if (_selectedDays.isNotEmpty) {
      final hasTime = _availableFrom != null || _availableTo != null;
      students = students.where((s) {
        return _selectedDays.every((day) {
          return s.availability.any(
            (a) =>
                a.dayOfWeek == day &&
                a.isEnabled &&
                (!hasTime || _matchesTimeRange(a)),
          );
        });
      }).toList();
    } else if (_availableFrom != null || _availableTo != null) {
      students = students.where((s) {
        return s.availability.any((a) => a.isEnabled && _matchesTimeRange(a));
      }).toList();
    }

    // Worked with specific senior
    if (_seniorFilter != null) {
      students = students.where((s) {
        return _seniorIdsForStudent(s).contains(_seniorFilter);
      }).toList();
    }

    // Sorting
    switch (_sort) {
      case StudentSort.az:
        students.sort(
          (a, b) =>
              a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );
      case StudentSort.za:
        students.sort(
          (a, b) =>
              b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()),
        );
      case StudentSort.newest:
        students.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case StudentSort.oldest:
        students.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case StudentSort.ratingHigh:
        students.sort((a, b) => b.avgRating.compareTo(a.avgRating));
      case StudentSort.ratingLow:
        students.sort((a, b) => a.avgRating.compareTo(b.avgRating));
    }

    return students;
  }

  void _resetFilters() {
    setState(() {
      _activityPeriod = null;
      _activityWorked = null;
      _customFrom = null;
      _customTo = null;
      _genderFilter = null;
      _minRating = 0.0;
      _minJobs = null;
      _maxJobs = null;
      _selectedDays = {};
      _availableFrom = null;
      _availableTo = null;
      _seniorFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = _tabFilters[_tabCtrl.index];
    final students = _filteredStudents(currentFilter);
    final filterCount = _activeFilterCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.studentsTitle),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
              _prefs.setGridView(_screenKey, isGrid: _isGridView);
            },
          ),
          const NotificationBell(),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: AppStrings.searchStudents,
                prefixIcon: const Icon(Icons.search, color: HelpiTheme.accent),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── Status filter tabs ──
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: HelpiTheme.accent,
            unselectedLabelColor: HelpiTheme.textSecondary,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            indicatorColor: HelpiTheme.accent,
            indicatorWeight: 2.5,
            dividerHeight: 0.5,
            dividerColor: HelpiTheme.border,
            padding: const EdgeInsets.only(left: 4),
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            tabs: _tabFilters.map((f) {
              final label = switch (f) {
                _StudentFilter.all => AppStrings.anyContract,
                _StudentFilter.active => AppStrings.contractActive,
                _StudentFilter.expiring => AppStrings.contractExpiring,
                _StudentFilter.expired => AppStrings.contractExpired,
                _StudentFilter.noContract => AppStrings.contractNone,
                _StudentFilter.deactivated => AppStrings.contractDeactivated,
                _StudentFilter.archived => AppStrings.filterArchived,
              };
              return Tab(text: label);
            }).toList(),
          ),

          // ── Active filter chips summary ──
          if (filterCount > 0) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: HelpiTheme.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.filterActiveCount(filterCount),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: HelpiTheme.accent,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Text(
                      AppStrings.filterReset,
                      style: const TextStyle(
                        fontSize: 13,
                        color: HelpiTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // ── Result count + sort/filter ──
          ResultCountRow(
            text: AppStrings.filterResultCount(students.length),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<StudentSort>(
                  icon: const Icon(
                    Icons.sort,
                    size: 20,
                    color: HelpiTheme.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  tooltip: AppStrings.sortBy,
                  onSelected: (v) {
                    setState(() => _sort = v);
                    _prefs.setSort(_screenKey, v.name);
                  },
                  itemBuilder: (_) => [
                    _sortMenuItem(StudentSort.az, AppStrings.sortAZ),
                    _sortMenuItem(StudentSort.za, AppStrings.sortZA),
                    _sortMenuItem(StudentSort.newest, AppStrings.sortNewest),
                    _sortMenuItem(StudentSort.oldest, AppStrings.sortOldest),
                    _sortMenuItem(
                      StudentSort.ratingHigh,
                      AppStrings.sortRatingHigh,
                    ),
                    _sortMenuItem(
                      StudentSort.ratingLow,
                      AppStrings.sortRatingLow,
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Badge(
                  isLabelVisible: filterCount > 0,
                  label: Text('$filterCount'),
                  backgroundColor: HelpiTheme.primary,
                  child: IconButton(
                    icon: Icon(
                      filterCount > 0
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                      size: 20,
                      color: filterCount > 0
                          ? HelpiTheme.accent
                          : HelpiTheme.textSecondary,
                    ),
                    onPressed: () => _openFilterSheet(context),
                    tooltip: AppStrings.advancedFilters,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Student list ──
          Expanded(
            child: students.isEmpty
                ? EmptyState(
                    icon: Icons.school_outlined,
                    message: AppStrings.noStudentsFound,
                  )
                : Builder(
                    builder: (context) {
                      final screenWidth = MediaQuery.sizeOf(context).width;
                      final gridCols = screenWidth >= 1200
                          ? 3
                          : (screenWidth >= 900 ? 2 : 1);
                      if (_isGridView && gridCols > 1) {
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: (students.length / gridCols).ceil(),
                          itemBuilder: (ctx, rowIdx) {
                            final start = rowIdx * gridCols;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var j = 0; j < gridCols; j++) ...[
                                  if (j > 0) const SizedBox(width: 10),
                                  Expanded(
                                    child: start + j < students.length
                                        ? _StudentCard(
                                            student: students[start + j],
                                            onTap: () => _openStudentDetail(
                                              students[start + j],
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ],
                            );
                          },
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: students.length,
                        itemBuilder: (ctx, i) {
                          final s = students[i];
                          return _StudentCard(
                            student: s,
                            onTap: () => _openStudentDetail(s),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openStudentDetail(StudentModel student) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudentDetailScreen(student: student)),
    );
  }

  PopupMenuItem<StudentSort> _sortMenuItem(StudentSort value, String label) {
    final selected = _sort == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (selected)
            const Icon(Icons.check, size: 16, color: HelpiTheme.accent)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? HelpiTheme.accent : HelpiTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  FILTER BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════
  void _openFilterSheet(BuildContext context) {
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
              child: _FilterPanel(
                isDialog: true,
                activityPeriod: _activityPeriod,
                activityWorked: _activityWorked,
                customFrom: _customFrom,
                customTo: _customTo,
                genderFilter: _genderFilter,
                minRating: _minRating,
                minJobs: _minJobs,
                maxJobs: _maxJobs,
                selectedDays: _selectedDays,
                availableFrom: _availableFrom,
                availableTo: _availableTo,
                seniorFilter: _seniorFilter,
                onApply:
                    ({
                      required ActivityPeriod? activityPeriod,
                      required bool? activityWorked,
                      required DateTime? customFrom,
                      required DateTime? customTo,
                      required Gender? genderFilter,
                      required double minRating,
                      required int? minJobs,
                      required int? maxJobs,
                      required Set<int> selectedDays,
                      required TimeOfDay? availableFrom,
                      required TimeOfDay? availableTo,
                      required String? seniorFilter,
                    }) {
                      setState(() {
                        _activityPeriod = activityPeriod;
                        _activityWorked = activityWorked;
                        _customFrom = customFrom;
                        _customTo = customTo;
                        _genderFilter = genderFilter;
                        _minRating = minRating;
                        _minJobs = minJobs;
                        _maxJobs = maxJobs;
                        _selectedDays = selectedDays;
                        _availableFrom = availableFrom;
                        _availableTo = availableTo;
                        _seniorFilter = seniorFilter;
                      });
                      Navigator.pop(ctx);
                    },
                onReset: () {
                  _resetFilters();
                  Navigator.pop(ctx);
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
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return _FilterPanel(
            activityPeriod: _activityPeriod,
            activityWorked: _activityWorked,
            customFrom: _customFrom,
            customTo: _customTo,
            genderFilter: _genderFilter,
            minRating: _minRating,
            minJobs: _minJobs,
            maxJobs: _maxJobs,
            selectedDays: _selectedDays,
            availableFrom: _availableFrom,
            availableTo: _availableTo,
            seniorFilter: _seniorFilter,
            onApply:
                ({
                  required ActivityPeriod? activityPeriod,
                  required bool? activityWorked,
                  required DateTime? customFrom,
                  required DateTime? customTo,
                  required Gender? genderFilter,
                  required double minRating,
                  required int? minJobs,
                  required int? maxJobs,
                  required Set<int> selectedDays,
                  required TimeOfDay? availableFrom,
                  required TimeOfDay? availableTo,
                  required String? seniorFilter,
                }) {
                  setState(() {
                    _activityPeriod = activityPeriod;
                    _activityWorked = activityWorked;
                    _customFrom = customFrom;
                    _customTo = customTo;
                    _genderFilter = genderFilter;
                    _minRating = minRating;
                    _minJobs = minJobs;
                    _maxJobs = maxJobs;
                    _selectedDays = selectedDays;
                    _availableFrom = availableFrom;
                    _availableTo = availableTo;
                    _seniorFilter = seniorFilter;
                  });
                  Navigator.pop(ctx);
                },
            onReset: () {
              _resetFilters();
              Navigator.pop(ctx);
            },
          );
        },
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  FILTER PANEL  (DraggableScrollableSheet)
// ═══════════════════════════════════════════════════════════════
class _FilterPanel extends StatefulWidget {
  const _FilterPanel({
    this.isDialog = false,
    required this.activityPeriod,
    required this.activityWorked,
    required this.customFrom,
    required this.customTo,
    required this.genderFilter,
    required this.minRating,
    required this.minJobs,
    required this.maxJobs,
    required this.selectedDays,
    required this.availableFrom,
    required this.availableTo,
    required this.seniorFilter,
    required this.onApply,
    required this.onReset,
  });

  final bool isDialog;
  final ActivityPeriod? activityPeriod;
  final bool? activityWorked;
  final DateTime? customFrom;
  final DateTime? customTo;
  final Gender? genderFilter;
  final double minRating;
  final int? minJobs;
  final int? maxJobs;
  final Set<int> selectedDays;
  final TimeOfDay? availableFrom;
  final TimeOfDay? availableTo;
  final String? seniorFilter;
  final void Function({
    required ActivityPeriod? activityPeriod,
    required bool? activityWorked,
    required DateTime? customFrom,
    required DateTime? customTo,
    required Gender? genderFilter,
    required double minRating,
    required int? minJobs,
    required int? maxJobs,
    required Set<int> selectedDays,
    required TimeOfDay? availableFrom,
    required TimeOfDay? availableTo,
    required String? seniorFilter,
  })
  onApply;
  final VoidCallback onReset;

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late ActivityPeriod? _activityPeriod;
  late bool? _activityWorked;
  late DateTime? _customFrom;
  late DateTime? _customTo;
  late Gender? _genderFilter;
  late double _minRating;
  late int? _minJobs;
  late int? _maxJobs;
  late Set<int> _selectedDays;
  late TimeOfDay? _availableFrom;
  late TimeOfDay? _availableTo;
  late String? _seniorFilter;

  final _minJobsCtrl = TextEditingController();
  final _maxJobsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activityPeriod = widget.activityPeriod;
    _activityWorked = widget.activityWorked;
    _customFrom = widget.customFrom;
    _customTo = widget.customTo;
    _genderFilter = widget.genderFilter;
    _minRating = widget.minRating;
    _minJobs = widget.minJobs;
    _maxJobs = widget.maxJobs;
    _selectedDays = Set<int>.from(widget.selectedDays);
    _availableFrom = widget.availableFrom;
    _availableTo = widget.availableTo;
    _seniorFilter = widget.seniorFilter;

    _minJobsCtrl.text = _minJobs?.toString() ?? '';
    _maxJobsCtrl.text = _maxJobs?.toString() ?? '';
  }

  @override
  void dispose() {
    _minJobsCtrl.dispose();
    _maxJobsCtrl.dispose();
    super.dispose();
  }

  String _dayLabel(int dayOfWeek) {
    final labels = [
      AppStrings.dayMon,
      AppStrings.dayTue,
      AppStrings.dayWed,
      AppStrings.dayThu,
      AppStrings.dayFri,
      AppStrings.daySat,
      AppStrings.daySun,
    ];
    return labels[dayOfWeek - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDialog) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        child: _buildFilterContent(null),
      );
    }
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: HelpiTheme.scaffold,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _buildFilterContent(scrollController),
        );
      },
    );
  }

  Widget _buildFilterContent(ScrollController? scrollController) {
    return Column(
      children: [
        if (!widget.isDialog)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: const DragHandle(),
          ),

        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.filter_alt, color: HelpiTheme.accent),
              const SizedBox(width: 8),
              Text(
                AppStrings.advancedFilters,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onReset,
                style: TextButton.styleFrom(
                  foregroundColor: HelpiTheme.primary,
                ),
                child: Text(AppStrings.filterReset),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ── Filter content ──
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // ──────────────────────────────────
              // 1. Activity period (GA-style)
              // ──────────────────────────────────
              _sectionTitle(AppStrings.filterByActivity),
              const SizedBox(height: 8),
              _buildChoiceRow<ActivityPeriod?>(
                [
                  (null, AppStrings.allStudents),
                  (ActivityPeriod.thisMonth, AppStrings.filterPeriodThisMonth),
                  (ActivityPeriod.lastMonth, AppStrings.filterPeriodLastMonth),
                  (
                    ActivityPeriod.last60Days,
                    AppStrings.filterPeriodLast60Days,
                  ),
                  (ActivityPeriod.custom, AppStrings.filterPeriodCustom),
                ],
                _activityPeriod,
                (v) {
                  setState(() {
                    _activityPeriod = v;
                    if (v == null) _activityWorked = null;
                  });
                },
              ),

              // Custom date range pickers
              if (_activityPeriod == ActivityPeriod.custom) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _datePickerBtn(
                        label: AppStrings.filterPeriodFrom,
                        value: _customFrom,
                        onPick: (d) => setState(() => _customFrom = d),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _datePickerBtn(
                        label: AppStrings.filterPeriodTo,
                        value: _customTo,
                        onPick: (d) => setState(() => _customTo = d),
                      ),
                    ),
                  ],
                ),
              ],

              // Worked / didn't work (only when period selected)
              if (_activityPeriod != null) ...[
                const SizedBox(height: 12),
                _buildChoiceRow<bool?>(
                  [
                    (null, AppStrings.allStudents),
                    (true, AppStrings.filterWorked),
                    (false, AppStrings.filterDidNotWork),
                  ],
                  _activityWorked,
                  (v) {
                    setState(() => _activityWorked = v);
                  },
                ),
              ],
              const SizedBox(height: 20),

              // ──────────────────────────────────
              // 2. Gender
              // ──────────────────────────────────
              _sectionTitle(AppStrings.filterByGender),
              const SizedBox(height: 8),
              _buildChoiceRow<Gender?>(
                [
                  (null, AppStrings.anyGender),
                  (Gender.male, AppStrings.genderMale),
                  (Gender.female, AppStrings.genderFemale),
                ],
                _genderFilter,
                (v) {
                  setState(() => _genderFilter = v);
                },
              ),
              const SizedBox(height: 20),

              // ──────────────────────────────────
              // 4. Min rating
              // ──────────────────────────────────
              _sectionTitle(
                '${AppStrings.filterByRating}: ${_minRating > 0 ? '≥ ${_minRating.toStringAsFixed(1)}' : '-'}',
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 18,
                    color: HelpiTheme.starYellow,
                  ),
                  Expanded(
                    child: Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      activeColor: HelpiTheme.accent,
                      label: _minRating.toStringAsFixed(1),
                      onChanged: (v) => setState(() => _minRating = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ──────────────────────────────────
              // 5. Min/max jobs
              // ──────────────────────────────────
              _sectionTitle(AppStrings.filterMinJobs),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minJobsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Min',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            HelpiTheme.cardRadius,
                          ),
                          borderSide: const BorderSide(
                            color: HelpiTheme.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            HelpiTheme.cardRadius,
                          ),
                          borderSide: const BorderSide(
                            color: HelpiTheme.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            HelpiTheme.cardRadius,
                          ),
                          borderSide: const BorderSide(
                            color: HelpiTheme.accent,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (v) {
                        _minJobs = int.tryParse(v);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxJobsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Max',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            HelpiTheme.cardRadius,
                          ),
                          borderSide: const BorderSide(
                            color: HelpiTheme.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            HelpiTheme.cardRadius,
                          ),
                          borderSide: const BorderSide(
                            color: HelpiTheme.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            HelpiTheme.cardRadius,
                          ),
                          borderSide: const BorderSide(
                            color: HelpiTheme.accent,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (v) {
                        _maxJobs = int.tryParse(v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ──────────────────────────────────
              // 6. Availability — days
              // ──────────────────────────────────
              _sectionTitle(AppStrings.filterByDay),
              const SizedBox(height: 8),
              Row(
                children: List.generate(7, (i) {
                  final day = i + 1;
                  final selected = _selectedDays.contains(day);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 6 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedDays.remove(day);
                            } else {
                              _selectedDays.add(day);
                            }
                          });
                        },
                        child: Container(
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? HelpiTheme.accent : Colors.white,
                            borderRadius: BorderRadius.circular(
                              HelpiTheme.cardRadius,
                            ),
                            border: Border.all(
                              color: selected
                                  ? HelpiTheme.accent
                                  : HelpiTheme.border,
                            ),
                          ),
                          child: Text(
                            _dayLabel(day),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : HelpiTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // ──────────────────────────────────
              // 7. Availability — time range
              // ──────────────────────────────────
              _sectionTitle(AppStrings.filterByAvailability),
              const SizedBox(height: 4),
              Text(
                AppStrings.filterAvailHint,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: HelpiTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _timePickerBtn(
                      label: AppStrings.filterByTimeFrom,
                      value: _availableFrom,
                      onPick: (t) => setState(() => _availableFrom = t),
                      onClear: () => setState(() => _availableFrom = null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timePickerBtn(
                      label: AppStrings.filterByTimeTo,
                      value: _availableTo,
                      onPick: (t) => setState(() => _availableTo = t),
                      onClear: () => setState(() => _availableTo = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ──────────────────────────────────
              // 8. Worked with senior
              // ──────────────────────────────────
              _sectionTitle(AppStrings.filterBySenior),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: _seniorFilter,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
                    borderSide: const BorderSide(color: HelpiTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
                    borderSide: const BorderSide(color: HelpiTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
                    borderSide: const BorderSide(
                      color: HelpiTheme.accent,
                      width: 2,
                    ),
                  ),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(AppStrings.anySenior),
                  ),
                  ...MockData.seniors.map(
                    (s) => DropdownMenuItem<String?>(
                      value: s.id,
                      child: Text(s.fullName),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _seniorFilter = v),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),

        // ── Apply button ──
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: ActionChipButton(
                icon: Icons.check,
                label: AppStrings.filterApply,
                color: HelpiTheme.accent,
                onTap: () {
                  widget.onApply(
                    activityPeriod: _activityPeriod,
                    activityWorked: _activityWorked,
                    customFrom: _customFrom,
                    customTo: _customTo,
                    genderFilter: _genderFilter,
                    minRating: _minRating,
                    minJobs: _minJobs,
                    maxJobs: _maxJobs,
                    selectedDays: _selectedDays,
                    availableFrom: _availableFrom,
                    availableTo: _availableTo,
                    seniorFilter: _seniorFilter,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: HelpiTheme.textPrimary,
      ),
    );
  }

  // ── Choice chips row ──
  Widget _buildChoiceRow<T>(
    List<(T, String)> options,
    T currentValue,
    ValueChanged<T> onChanged,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final (value, label) = option;
        final isSelected = value == currentValue;
        return GestureDetector(
          onTap: () => onChanged(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? HelpiTheme.pastelTeal : Colors.white,
              borderRadius: BorderRadius.circular(HelpiTheme.pillRadius),
              border: Border.all(
                color: isSelected ? HelpiTheme.accent : HelpiTheme.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? HelpiTheme.accent
                    : HelpiTheme.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Date picker button ──
  Widget _datePickerBtn({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPick,
  }) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (!mounted) return;
        if (picked != null) onPick(picked);
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        side: const BorderSide(color: HelpiTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: HelpiTheme.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value != null ? formatDate(value) : label,
              style: TextStyle(
                fontSize: 13,
                color: value != null
                    ? HelpiTheme.textPrimary
                    : HelpiTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Time picker button ──
  Widget _timePickerBtn({
    required String label,
    required TimeOfDay? value,
    required ValueChanged<TimeOfDay> onPick,
    required VoidCallback onClear,
  }) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? const TimeOfDay(hour: 8, minute: 0),
        );
        if (!mounted) return;
        if (picked != null) onPick(picked);
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        ),
        side: const BorderSide(color: HelpiTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 16, color: HelpiTheme.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value != null ? formatTimeOfDay(value) : label,
              style: TextStyle(
                fontSize: 13,
                color: value != null
                    ? HelpiTheme.textPrimary
                    : HelpiTheme.textSecondary,
              ),
            ),
          ),
          if (value != null)
            GestureDetector(
              onTap: onClear,
              child: const Icon(
                Icons.close,
                size: 16,
                color: HelpiTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STUDENT CARD
// ═══════════════════════════════════════════════════════════════
class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, required this.onTap});

  final StudentModel student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          border: Border.all(color: HelpiTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Avatar + Name + Status chips ──
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
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
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    student.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge.contract(student.contractStatus),
                if (student.isArchived) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
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
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: HelpiTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Details + Chevron ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Rating + Jobs ──
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
                              fontSize: 14,
                              color: HelpiTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ── Phone ──
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: HelpiTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              student.phone,
                              style: const TextStyle(
                                fontSize: 14,
                                color: HelpiTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          PhoneCallButton(phone: student.phone),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ── Email ──
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: HelpiTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              student.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: HelpiTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          EmailCopyButton(email: student.email),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Chevron ──
                const Icon(
                  Icons.chevron_right,
                  color: HelpiTheme.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
