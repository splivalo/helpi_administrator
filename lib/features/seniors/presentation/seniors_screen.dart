import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/models/suspension_models.dart';
import 'package:helpi_admin/core/network/api_client.dart';
import 'package:helpi_admin/core/services/preferences_service.dart';
import 'package:helpi_admin/core/services/suspension_state_manager.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/suspension_widgets.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/features/orders/presentation/create_order_screen.dart';
import 'package:helpi_admin/features/orders/presentation/order_detail_screen.dart';
import 'package:helpi_admin/features/seniors/presentation/add_senior_screen.dart';
import 'package:helpi_admin/features/seniors/presentation/edit_senior_screen.dart';

/// Seniors Screen — popis seniora s pretragom i detaljima.
enum SeniorSort { az, za, newest, oldest }

enum _SeniorStatusFilter {
  all,
  processing,
  active,
  inactive,
  suspended,
  archived,
}

class SeniorsScreen extends StatefulWidget {
  const SeniorsScreen({super.key});

  @override
  State<SeniorsScreen> createState() => _SeniorsScreenState();
}

class _SeniorsScreenState extends State<SeniorsScreen>
    with SingleTickerProviderStateMixin {
  static const _screenKey = 'seniors';
  final _prefs = PreferencesService.instance;

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  SeniorSort _sort = SeniorSort.az;
  late final TabController _tabCtrl;
  bool _isGridView = false;

  static const _tabFilters = _SeniorStatusFilter.values;

  @override
  void initState() {
    super.initState();

    // Restore saved preferences
    _isGridView = _prefs.getGridView(_screenKey);
    final savedSort = _prefs.getSort(_screenKey);
    if (savedSort != null) {
      _sort = SeniorSort.values.firstWhere(
        (e) => e.name == savedSort,
        orElse: () => SeniorSort.az,
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
    SuspensionStateManager.instance.removeListener(_onSuspensionChanged);
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSuspensionChanged() {
    if (mounted) setState(() {});
  }

  List<SeniorModel> _filteredSeniors(_SeniorStatusFilter filter) {
    var seniors = MockData.seniors.toList();

    // Senior is "active" only when they have at least one order
    // with an assigned student. Otherwise they are "processing".
    final activeIds = MockData.orders
        .where((o) => o.student != null)
        .map((o) => o.senior.id)
        .toSet();

    // Status filter
    switch (filter) {
      case _SeniorStatusFilter.all:
        break;
      case _SeniorStatusFilter.processing:
        seniors = seniors
            .where(
              (s) => s.isActive && !s.isArchived && !activeIds.contains(s.id),
            )
            .toList();
      case _SeniorStatusFilter.active:
        seniors = seniors
            .where(
              (s) => s.isActive && !s.isArchived && activeIds.contains(s.id),
            )
            .toList();
      case _SeniorStatusFilter.inactive:
        seniors = seniors.where((s) => !s.isActive && !s.isArchived).toList();
      case _SeniorStatusFilter.suspended:
        seniors = seniors
            .where((s) => SuspensionStateManager.instance.isSuspended(s.id))
            .toList();
      case _SeniorStatusFilter.archived:
        seniors = seniors.where((s) => s.isArchived).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      seniors = seniors.where((s) {
        return s.fullName.toLowerCase().contains(q) ||
            s.contactName.toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q) ||
            s.phone.contains(q) ||
            s.address.toLowerCase().contains(q);
      }).toList();
    }

    // Sorting
    switch (_sort) {
      case SeniorSort.az:
        seniors.sort(
          (a, b) =>
              a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );
      case SeniorSort.za:
        seniors.sort(
          (a, b) =>
              b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()),
        );
      case SeniorSort.newest:
        seniors.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SeniorSort.oldest:
        seniors.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return seniors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.seniorsTitle),
        actions: [
          if (MediaQuery.sizeOf(context).width >= 900)
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'seniors_fab',
        onPressed: _showAddSeniorModal,
        backgroundColor: HelpiTheme.accent,
        child: const Icon(Icons.person_add, color: Colors.white),
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
                hintText: AppStrings.searchSeniors,
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
                _SeniorStatusFilter.all => AppStrings.filterAll,
                _SeniorStatusFilter.processing => AppStrings.filterProcessing,
                _SeniorStatusFilter.active => AppStrings.seniorFilterActive,
                _SeniorStatusFilter.inactive => AppStrings.seniorFilterInactive,
                _SeniorStatusFilter.suspended => AppStrings.suspended,
                _SeniorStatusFilter.archived => AppStrings.filterArchived,
              };
              return Tab(text: label);
            }).toList(),
          ),

          const SizedBox(height: 8),

          // ── Result count + sort ──
          Builder(
            builder: (context) {
              final count = _filteredSeniors(
                _tabFilters[_tabCtrl.index],
              ).length;
              return ResultCountRow(
                text: AppStrings.seniorResultCount(count),
                trailing: PopupMenuButton<SeniorSort>(
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
                    _sortMenuItem(SeniorSort.az, AppStrings.sortAZ),
                    _sortMenuItem(SeniorSort.za, AppStrings.sortZA),
                    _sortMenuItem(SeniorSort.newest, AppStrings.sortNewest),
                    _sortMenuItem(SeniorSort.oldest, AppStrings.sortOldest),
                  ],
                ),
              );
            },
          ),
          // ── Senior list ──
          Expanded(
            child: Builder(
              builder: (context) {
                final seniors = _filteredSeniors(_tabFilters[_tabCtrl.index]);
                if (seniors.isEmpty) {
                  return EmptyState(
                    icon: Icons.elderly_outlined,
                    message: AppStrings.noSeniorsFound,
                  );
                }
                final screenWidth = MediaQuery.sizeOf(context).width;
                final gridCols = screenWidth >= 1200
                    ? 3
                    : (screenWidth >= 900 ? 2 : 1);
                if (_isGridView && gridCols > 1) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: (seniors.length / gridCols).ceil(),
                    itemBuilder: (ctx, rowIdx) {
                      final start = rowIdx * gridCols;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var j = 0; j < gridCols; j++) ...[
                            if (j > 0) const SizedBox(width: 10),
                            Expanded(
                              child: start + j < seniors.length
                                  ? _SeniorCard(
                                      senior: seniors[start + j],
                                      onTap: () =>
                                          _openSeniorDetail(seniors[start + j]),
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
                  itemCount: seniors.length,
                  itemBuilder: (ctx, i) => _SeniorCard(
                    senior: seniors[i],
                    onTap: () => _openSeniorDetail(seniors[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openSeniorDetail(SeniorModel senior) {
    final seniorOrders = MockData.orders
        .where((o) => o.senior.id == senior.id)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SeniorDetailScreen(senior: senior, orders: seniorOrders),
      ),
    );
  }

  void _showAddSeniorModal() {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    const formWidget = AddSeniorScreen(isModal: true);

    if (isWide) {
      showDialog<bool>(
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
        if (!mounted) return;
        if (result == true) setState(() {});
      });
    } else {
      showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(HelpiTheme.bottomSheetRadius),
          ),
        ),
        builder: (ctx) =>
            const FractionallySizedBox(heightFactor: 0.92, child: formWidget),
      ).then((result) {
        if (!mounted) return;
        if (result == true) setState(() {});
      });
    }
  }

  PopupMenuItem<SeniorSort> _sortMenuItem(SeniorSort value, String label) {
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
}

// ═══════════════════════════════════════════════════════════════
//  SENIOR CARD
// ═══════════════════════════════════════════════════════════════
class _SeniorCard extends StatelessWidget {
  const _SeniorCard({required this.senior, required this.onTap});
  final SeniorModel senior;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Determine status chip
    // Senior is "Active" only when they have at least one order
    // with an assigned student. Otherwise they are "Processing".
    final seniorOrders = MockData.orders.where((o) => o.senior.id == senior.id);
    final bool hasStudentAssigned = seniorOrders.any((o) => o.student != null);

    final (
      Color chipTextColor,
      Color chipBgColor,
      String chipLabel,
    ) = SuspensionStateManager.instance.isSuspended(senior.id)
        ? (HelpiTheme.error, HelpiTheme.statusCancelledBg, AppStrings.suspended)
        : senior.isArchived
        ? (
            HelpiTheme.textSecondary,
            HelpiTheme.chipBg,
            AppStrings.statusArchived,
          )
        : !senior.isActive
        ? (
            HelpiTheme.statusCancelledText,
            HelpiTheme.statusCancelledBg,
            AppStrings.seniorFilterInactive,
          )
        : hasStudentAssigned
        ? (
            HelpiTheme.statusActiveText,
            HelpiTheme.statusActiveBg,
            AppStrings.seniorFilterActive,
          )
        : (
            HelpiTheme.statusProcessingText,
            HelpiTheme.statusProcessingBg,
            AppStrings.filterProcessing,
          );

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
            // ── Header: Avatar + Name + Status chip ──
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
                      senior.firstName[0] + senior.lastName[0],
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
                    senior.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: chipBgColor,
                    border: Border.all(
                      color: chipTextColor.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(
                      HelpiTheme.statusBadgeRadius,
                    ),
                  ),
                  child: Text(
                    chipLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: chipTextColor,
                    ),
                  ),
                ),
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
                              senior.contactPhone,
                              style: const TextStyle(
                                fontSize: 14,
                                color: HelpiTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          PhoneCallButton(phone: senior.contactPhone),
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
                              senior.contactEmail,
                              style: const TextStyle(
                                fontSize: 14,
                                color: HelpiTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          EmailCopyButton(email: senior.contactEmail),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ── Address (always senior's — service location) ──
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
                              senior.address,
                              style: const TextStyle(
                                fontSize: 14,
                                color: HelpiTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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

// ═══════════════════════════════════════════════════════════════
//  SENIOR DETAIL (inline same file)
// ═══════════════════════════════════════════════════════════════
class SeniorDetailScreen extends StatefulWidget {
  const SeniorDetailScreen({super.key, required this.senior, required this.orders});
  final SeniorModel senior;
  final List<OrderModel> orders;

  @override
  State<SeniorDetailScreen> createState() => SeniorDetailScreenState();
}

class SeniorDetailScreenState extends State<SeniorDetailScreen> {
  late SeniorModel _senior;
  final _prefs = PreferencesService.instance;
  static const _screenKey = 'seniorDetail';
  static const _sectionCount = 7;

  final _api = ApiClient();
  UserSuspensionStatus? _suspensionStatus;

  late List<int> _sectionOrder;

  @override
  void initState() {
    super.initState();
    _senior = widget.senior;
    final saved = _prefs.getSectionOrder(_screenKey);
    if (saved != null && saved.length == _sectionCount) {
      _sectionOrder = saved;
    } else {
      _sectionOrder = List.generate(_sectionCount, (i) => i);
    }
    _loadSuspensionStatus();
  }

  Future<void> _loadSuspensionStatus() async {
    final userId = int.tryParse(_senior.id);
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

  SeniorModel _rebuildSenior({bool? isActive, bool? isArchived}) {
    final updated = SeniorModel(
      id: _senior.id,
      firstName: _senior.firstName,
      lastName: _senior.lastName,
      email: _senior.email,
      phone: _senior.phone,
      address: _senior.address,
      gender: _senior.gender,
      dateOfBirth: _senior.dateOfBirth,
      isActive: isActive ?? _senior.isActive,
      isArchived: isArchived ?? _senior.isArchived,
      createdAt: _senior.createdAt,
      ordererFirstName: _senior.ordererFirstName,
      ordererLastName: _senior.ordererLastName,
      ordererEmail: _senior.ordererEmail,
      ordererPhone: _senior.ordererPhone,
      ordererAddress: _senior.ordererAddress,
      ordererGender: _senior.ordererGender,
      ordererDateOfBirth: _senior.ordererDateOfBirth,
      creditCards: _senior.creditCards,
    );
    // Persist change to MockData so list screens reflect it
    final idx = MockData.seniors.indexWhere((s) => s.id == updated.id);
    if (idx != -1) MockData.seniors[idx] = updated;
    return updated;
  }

  void _confirmArchive() {
    final hasActiveOrders = MockData.orders.any(
      (o) =>
          o.senior.id == _senior.id &&
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
          _senior = _rebuildSenior(isArchived: true, isActive: false);
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
          _senior = _rebuildSenior(isArchived: false);
        });
      }
    });
  }

  void _openEditSenior() {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    final formWidget = EditSeniorScreen(senior: _senior, isModal: true);

    if (isWide) {
      showDialog<SeniorModel>(
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
        if (!mounted) return;
        if (result != null) setState(() => _senior = result);
      });
    } else {
      showModalBottomSheet<SeniorModel>(
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
        if (result != null) setState(() => _senior = result);
      });
    }
  }

  void _showAddOrderModal(SeniorModel senior) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    final formWidget = CreateOrderScreen(senior: senior, isModal: true);

    if (isWide) {
      showDialog<bool>(
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
        if (!mounted) return;
        if (result == true) setState(() {});
      });
    } else {
      showModalBottomSheet<bool>(
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
        if (result == true) setState(() {});
      });
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
              child: Text(_senior.fullName, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            if (_suspensionStatus?.isSuspended == true)
              const SuspendedBadge()
            else if (_senior.isActive && !_senior.isArchived)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: HelpiTheme.statusActiveBg,
                  border: Border.all(
                    color: HelpiTheme.statusActiveText.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(
                    HelpiTheme.statusBadgeRadius,
                  ),
                ),
                child: Text(
                  AppStrings.seniorFilterActive,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HelpiTheme.statusActiveText,
                  ),
                ),
              )
            else if (!_senior.isActive && !_senior.isArchived)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: HelpiTheme.statusCancelledBg,
                  border: Border.all(
                    color: HelpiTheme.statusCancelledText.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(
                    HelpiTheme.statusBadgeRadius,
                  ),
                ),
                child: Text(
                  AppStrings.seniorFilterInactive,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HelpiTheme.statusCancelledText,
                  ),
                ),
              ),
            if (_senior.isArchived) ...[
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
            icon: const Icon(Icons.edit, size: 22),
            tooltip: AppStrings.editSeniorTitle,
            onPressed: _openEditSenior,
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
    AppStrings.seniorCreditCards,
    AppStrings.seniorOrders,
    AppStrings.seniorReviews,
    AppStrings.suspensionHistory,
    AppStrings.adminActions,
  ];

  static const _sectionIcons = [
    Icons.people,
    Icons.elderly,
    Icons.credit_card,
    Icons.receipt_long,
    Icons.star,
    Icons.history,
    Icons.admin_panel_settings,
  ];

  List<Widget> _buildAllSections() {
    return [
      _buildOrdererSection(),
      _buildServiceUserSection(),
      _buildCreditCardsSection(),
      _buildOrdersSection(),
      _buildReviewsSection(_seniorReviews),
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

  // ─────────────────────────────────────────────────────────
  //  SECTION BUILDERS
  // ─────────────────────────────────────────────────────────

  Widget _buildOrdererSection() {
    if (!_senior.hasOrderer) return const SizedBox.shrink();
    return SectionCard(
      title: AppStrings.seniorOrdererTitle,
      icon: Icons.people,
      children: [
        ResponsiveFieldGrid(
          children: [
            InfoField(
              label: AppStrings.seniorOrdererFirstName,
              value: _senior.ordererFirstName!,
            ),
            InfoField(
              label: AppStrings.seniorOrdererLastName,
              value: _senior.ordererLastName ?? '',
            ),
            if (_senior.ordererEmail != null)
              InfoField(
                label: AppStrings.seniorOrdererEmail,
                value: _senior.ordererEmail!,
                trailing: EmailCopyButton(email: _senior.ordererEmail!),
              ),
            if (_senior.ordererPhone != null)
              InfoField(
                label: AppStrings.seniorOrdererPhone,
                value: _senior.ordererPhone!,
                trailing: PhoneCallButton(phone: _senior.ordererPhone!),
              ),
            if (_senior.ordererAddress != null)
              InfoField(
                label: AppStrings.seniorOrdererAddress,
                value: _senior.ordererAddress!,
              ),
            if (_senior.ordererGender != null)
              InfoField(
                label: AppStrings.seniorOrdererGender,
                value: _senior.ordererGender == Gender.male
                    ? AppStrings.genderMale
                    : AppStrings.genderFemale,
              ),
            if (_senior.ordererDateOfBirth != null)
              InfoField(
                label: AppStrings.seniorOrdererDob,
                value: formatDateDot(_senior.ordererDateOfBirth!),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceUserSection() {
    return SectionCard(
      title: AppStrings.seniorServiceUser,
      icon: Icons.elderly,
      children: [
        ResponsiveFieldGrid(
          children: [
            InfoField(
              label: AppStrings.seniorFirstName,
              value: _senior.firstName,
            ),
            InfoField(
              label: AppStrings.seniorLastName,
              value: _senior.lastName,
            ),
            if (!_senior.hasOrderer)
              InfoField(
                label: AppStrings.seniorEmail,
                value: _senior.email,
                trailing: EmailCopyButton(email: _senior.email),
              ),
            InfoField(
              label: AppStrings.seniorPhone,
              value: _senior.phone,
              trailing: PhoneCallButton(phone: _senior.phone),
            ),
            InfoField(label: AppStrings.seniorAddress, value: _senior.address),
            InfoField(
              label: AppStrings.seniorOrdererGender,
              value: _senior.gender == Gender.male
                  ? AppStrings.genderMale
                  : AppStrings.genderFemale,
            ),
            InfoField(
              label: AppStrings.seniorOrdererDob,
              value: formatDateDot(_senior.dateOfBirth),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreditCardsSection() {
    return SectionCard(
      title: AppStrings.seniorCreditCards,
      icon: Icons.credit_card,
      children: _senior.creditCards.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.credit_card_off,
                        size: 36,
                        color: HelpiTheme.border,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.seniorNoCards,
                        style: const TextStyle(color: HelpiTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          : _senior.creditCards
                .map((card) => _buildCreditCardRow(card))
                .toList(),
    );
  }

  Widget _buildOrdersSection() {
    return SectionCard(
      title: AppStrings.seniorOrders,
      icon: Icons.receipt_long,
      children: [
        if (widget.orders.isNotEmpty)
          ...widget.orders.map((o) => _buildOrderRow(o)),
        if (widget.orders.isEmpty)
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
        const SizedBox(height: 8),
        ActionChipButton(
          icon: Icons.add,
          label: AppStrings.addOrder,
          color: HelpiTheme.accent,
          onTap: () => _showAddOrderModal(widget.senior),
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

  Future<void> _confirmSuspend() async {
    final reason = await showSuspendDialog(context, _senior.fullName);
    if (!mounted || reason == null) return;

    final userId = int.tryParse(_senior.id);
    if (userId != null) {
      final success = await suspendUserApi(_api, userId, reason);
      if (!mounted) return;
      if (!success) return;
    }

    setState(() {
      _suspensionStatus = UserSuspensionStatus(
        isSuspended: true,
        suspensionReason: reason,
        suspendedAt: DateTime.now(),
        suspensionHistory: [
          SuspensionLogModel(
            id: 0,
            userId: userId ?? 0,
            action: SuspensionAction.suspended,
            reason: reason,
            adminId: 0,
            createdAt: DateTime.now(),
          ),
          ...(_suspensionStatus?.suspensionHistory ?? []),
        ],
      );
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppStrings.suspensionSuccess)));
    SuspensionStateManager.instance.suspend(_senior.id);
  }

  Future<void> _confirmActivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.activateConfirmTitle),
        content: SizedBox(
          width: 400,
          child: Text(AppStrings.activateConfirmMsg(_senior.fullName)),
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

    final userId = int.tryParse(_senior.id);
    if (userId != null) {
      final success = await activateUserApi(_api, userId);
      if (!mounted) return;
      if (!success) return;
    }

    setState(() {
      _suspensionStatus = UserSuspensionStatus(
        isSuspended: false,
        suspensionHistory: [
          SuspensionLogModel(
            id: 0,
            userId: userId ?? 0,
            action: SuspensionAction.activated,
            adminId: 0,
            createdAt: DateTime.now(),
          ),
          ...(_suspensionStatus?.suspensionHistory ?? []),
        ],
      );
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppStrings.activationSuccess)));
    SuspensionStateManager.instance.activate(_senior.id);
  }

  Widget _buildAdminActionsSection() {
    return SectionCard(
      title: AppStrings.adminActions,
      icon: Icons.admin_panel_settings,
      children: [
        ActionChipButton(
          icon: _senior.isArchived ? Icons.unarchive : Icons.archive,
          label: _senior.isArchived
              ? AppStrings.studentUnarchive
              : AppStrings.studentArchive,
          color: _senior.isArchived
              ? HelpiTheme.accent
              : HelpiTheme.textSecondary,
          onTap: () =>
              _senior.isArchived ? _confirmUnarchive() : _confirmArchive(),
        ),
      ],
    );
  }

  List<ReviewModel> get _seniorReviews =>
      MockData.reviews.where((r) => r.seniorName == _senior.fullName).toList();

  Widget _buildReviewsSection(List<ReviewModel> reviews) {
    final avgRating = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    return ReviewsSection(
      title: AppStrings.seniorReviews,
      avgRating: avgRating,
      reviews: reviews,
      reviewerName: (r) => r.studentName,
    );
  }

  Widget _buildCreditCardRow(CreditCard card) {
    final expired = card.isExpired;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: expired ? HelpiTheme.statusCancelledBg : HelpiTheme.scaffold,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${card.brandLabel}  \u2022\u2022\u2022\u2022 ${card.last4}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: expired
                        ? HelpiTheme.statusCancelledText
                        : HelpiTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expired
                      ? '${AppStrings.cardExpired} ${card.expiry}'
                      : '${AppStrings.cardExpiry} ${card.expiry}',
                  style: TextStyle(
                    fontSize: 12,
                    color: expired
                        ? HelpiTheme.statusCancelledText
                        : HelpiTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (expired)
            Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: HelpiTheme.statusCancelledText,
            ),
        ],
      ),
    );
  }

  Widget _buildOrderRow(OrderModel order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
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
                    '#${order.orderNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.services.map((s) => serviceLabel(s)).join(', '),
                    style: const TextStyle(
                      fontSize: 13,
                      color: HelpiTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            StatusBadge.order(order.status),
          ],
        ),
      ),
    );
  }
}
