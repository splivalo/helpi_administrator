import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/models/suspension_models.dart';
import 'package:helpi_admin/core/network/api_client.dart';
import 'package:helpi_admin/core/network/api_endpoints.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
import 'package:helpi_admin/core/services/data_loader.dart';
import 'package:helpi_admin/core/services/excel_export_service.dart';
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

class SeniorsScreen extends ConsumerStatefulWidget {
  const SeniorsScreen({super.key});

  @override
  ConsumerState<SeniorsScreen> createState() => _SeniorsScreenState();
}

class _SeniorsScreenState extends ConsumerState<SeniorsScreen>
    with SingleTickerProviderStateMixin {
  static const _screenKey = 'seniors';
  final _prefs = PreferencesService.instance;
  final _cityApi = ApiClient();

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  SeniorSort _sort = SeniorSort.az;
  late final TabController _tabCtrl;
  bool _isGridView = false;
  String? _cityFilter;
  List<String> _cityOptions = const [];
  List<Map<String, dynamic>> _pendingAssignments = [];

  static const _tabFilters = _SeniorStatusFilter.values;

  @override
  void initState() {
    super.initState();
    SuspensionStateManager.instance.addListener(_onSuspensionChanged);
    _loadCityOptions();
    _loadPendingAssignments();

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

    // Refresh pending banner when accept/decline notifications arrive
    ref.listenManual(notificationsProvider, (prev, next) {
      if (next.isEmpty) return;
      final latest = next.first;
      if (latest.type == NotificationType.assignmentAccepted ||
          latest.type == NotificationType.assignmentDeclined) {
        _loadPendingAssignments();
      }
    });

    // Refresh pending banner when DataLoader updates pending IDs
    // (triggered by EntityChanged → DataLoader.loadAll or optimistic update)
    ref.listenManual(pendingAcceptanceOrderIdsProvider, (prev, next) {
      _loadPendingAssignments();
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

  Future<void> _loadCityOptions() async {
    try {
      final response = await _cityApi.get(ApiEndpoints.cities);
      final options =
          (response.data as List<dynamic>)
              .map((entry) => (entry as Map<String, dynamic>)['name'])
              .map((name) => name?.toString().trim() ?? '')
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      if (!mounted) return;
      setState(() {
        _cityOptions = options;
        if (_cityFilter != null && !_cityOptions.contains(_cityFilter)) {
          _cityFilter = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cityOptions = const [];
      });
    }
  }

  Future<void> _loadPendingAssignments() async {
    try {
      final response = await _cityApi.get(ApiEndpoints.adminPending);
      final list = (response.data as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      if (!mounted) return;
      setState(() => _pendingAssignments = list);
      ref.read(pendingAcceptanceOrderIdsProvider.notifier).state = list
          .map((e) => (e['orderId'] as num).toInt())
          .toSet();
      // Build per-order map: first entry wins (all have same student)
      final dataMap = <int, Map<String, dynamic>>{};
      for (final e in list) {
        final oid = (e['orderId'] as num).toInt();
        dataMap.putIfAbsent(oid, () => e);
      }
      ref.read(pendingAcceptanceDataProvider.notifier).state = dataMap;
    } catch (_) {
      // silent
    }
  }

  String _formatPendingTime(int minutes) {
    if (minutes < 60) return AppStrings.pendingAcceptanceMinutes(minutes);
    final hours = minutes ~/ 60;
    if (hours < 24) {
      return AppStrings.pendingAcceptanceHours(hours, minutes % 60);
    }
    return AppStrings.pendingAcceptanceDays(hours ~/ 24, hours % 24);
  }

  void _openPendingSheet() {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    if (isWide) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 600),
            child: _buildPendingContent(isDialog: true, ctx: ctx),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: HelpiColors.of(context).surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: _buildPendingContent(scrollController: scrollCtrl, ctx: ctx),
          ),
        ),
      );
    }
  }

  Widget _buildPendingContent({
    bool isDialog = false,
    ScrollController? scrollController,
    required BuildContext ctx,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isDialog)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: HelpiColors.of(context).border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
          child: Row(
            children: [
              const Icon(
                Icons.hourglass_top,
                color: HelpiTheme.statusProcessingText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.pendingAcceptanceTitle,
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
        if (_pendingAssignments.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              AppStrings.pendingAcceptanceEmpty,
              style: TextStyle(color: HelpiColors.of(context).textSecondary),
            ),
          )
        else
          Flexible(
            child: Builder(
              builder: (_) {
                // Group by orderId — collect ALL students per order
                final grouped = <int, Map<String, dynamic>>{};
                for (final a in _pendingAssignments) {
                  final oid = (a['orderId'] as num?)?.toInt() ?? 0;
                  if (!grouped.containsKey(oid)) {
                    grouped[oid] = Map<String, dynamic>.from(a);
                    grouped[oid]!['_allStudents'] = <String>[
                      a['studentName'] as String? ?? '—',
                    ];
                  } else {
                    final name = a['studentName'] as String? ?? '—';
                    final existing =
                        grouped[oid]!['_allStudents'] as List<String>;
                    if (!existing.contains(name)) {
                      existing.add(name);
                    }
                  }
                }
                final items = grouped.values.toList();
                return ListView.separated(
                  controller: scrollController,
                  shrinkWrap: isDialog,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final a = items[i];
                    final minutes = (a['minutesPending'] as num?)?.toInt() ?? 0;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: dark
                            ? HelpiTheme.statusProcessingText.withValues(
                                alpha: 0.15,
                              )
                            : HelpiTheme.statusProcessingBg,
                        child: const Icon(
                          Icons.hourglass_bottom,
                          color: HelpiTheme.statusProcessingText,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        a['seniorName'] as String? ?? '—',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${AppStrings.pendingAcceptanceStudent}: '
                        '${(a['_allStudents'] as List<String>?)?.join(', ') ?? a['studentName'] ?? '—'}',
                      ),
                      trailing: Text(
                        _formatPendingTime(minutes),
                        style: TextStyle(
                          color: minutes > 120
                              ? HelpiTheme.primary
                              : HelpiTheme.statusProcessingText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _navigateToOrder(a['orderId'] as int?);
                      },
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _navigateToOrder(int? orderId) async {
    if (orderId == null) {
      debugPrint('[Pending] orderId is null — aborting navigation');
      return;
    }
    debugPrint('[Pending] navigating to order $orderId');
    var orders = ref.read(ordersProvider);
    var order = orders.where((o) => int.tryParse(o.id) == orderId).firstOrNull;
    if (order == null) {
      debugPrint('[Pending] order $orderId not in provider — reloading');
      await DataLoader.loadAll(ref: ref);
      if (!mounted) return;
      orders = ref.read(ordersProvider);
      order = orders.where((o) => int.tryParse(o.id) == orderId).firstOrNull;
    }
    if (order == null) {
      debugPrint('[Pending] order $orderId still not found after reload');
      return;
    }
    if (!mounted) return;
    debugPrint('[Pending] pushing OrderDetailScreen for order $orderId');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order!)),
    );
  }

  List<SeniorModel> _filteredSeniors(_SeniorStatusFilter filter) {
    var seniors = ref.watch(seniorsProvider).toList();

    final allOrders = ref.watch(ordersProvider);

    // Samo aktivne narudžbe (processing/active) — isključi otkazane/završene
    final liveOrders = allOrders
        .where(
          (o) =>
              o.status == OrderStatus.processing ||
              o.status == OrderStatus.active,
        )
        .toList();

    // Seniori koji imaju barem jednu narudžbu u obradi (Processing)
    final processingIds = liveOrders
        .where((o) => o.status == OrderStatus.processing)
        .map((o) => o.senior.id)
        .toSet();

    // Seniori koji imaju barem jednu aktivnu narudžbu (Active/FullAssigned)
    final activeIds = liveOrders
        .where((o) => o.status == OrderStatus.active)
        .map((o) => o.senior.id)
        .toSet();

    // Seniori koji imaju bilo kakvu živu narudžbu
    final hasOrderIds = liveOrders.map((o) => o.senior.id).toSet();

    // Status filter
    switch (filter) {
      case _SeniorStatusFilter.all:
        break;
      case _SeniorStatusFilter.processing:
        // U obradi = ima barem jednu narudžbu sa statusom Processing
        seniors = seniors
            .where(
              (s) =>
                  s.isActive &&
                  !s.isArchived &&
                  !s.isSuspended &&
                  processingIds.contains(s.id),
            )
            .toList();
      case _SeniorStatusFilter.active:
        // Aktivan = ima aktivnu narudžbu, ALI nijednu u obradi
        seniors = seniors
            .where(
              (s) =>
                  s.isActive &&
                  !s.isArchived &&
                  !s.isSuspended &&
                  activeIds.contains(s.id) &&
                  !processingIds.contains(s.id),
            )
            .toList();
      case _SeniorStatusFilter.inactive:
        // Neaktivan = nema narudžbi ILI deletedAt != null
        seniors = seniors
            .where(
              (s) =>
                  !s.isArchived &&
                  !s.isSuspended &&
                  ((!s.isActive) ||
                      (s.isActive && !hasOrderIds.contains(s.id))),
            )
            .toList();
      case _SeniorStatusFilter.suspended:
        seniors = seniors.where((s) => s.isSuspended).toList();
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

    // City filter
    if (_cityFilter != null) {
      seniors = seniors.where((s) => s.city == _cityFilter).toList();
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
      appBar: HelpiAppBar(
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
          // ── Search bar + City filter ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cities = _cityOptions.isNotEmpty
                    ? _cityOptions
                    : (ref
                          .read(seniorsProvider)
                          .map((s) => s.city)
                          .where((c) => c.isNotEmpty)
                          .toSet()
                          .toList()
                        ..sort());
                final searchField = TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: AppStrings.searchSeniors,
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: HelpiTheme.accent,
                    ),
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
                );
                final cityDropdown = SizedBox(
                  height: HelpiTheme.inputFieldHeight,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _cityFilter,
                    isExpanded: true,
                    isDense: true,
                    style: TextStyle(
                      fontSize: 14,
                      color: HelpiColors.of(context).textPrimary,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      hintStyle: const TextStyle(fontSize: 14),
                      hintText: AppStrings.filterByCity,
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: HelpiTheme.accent,
                        size: 20,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(AppStrings.anyCity),
                      ),
                      ...cities.map(
                        (c) =>
                            DropdownMenuItem<String?>(value: c, child: Text(c)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _cityFilter = v),
                  ),
                );
                if (constraints.maxWidth >= 600) {
                  return Row(
                    children: [
                      Expanded(flex: 2, child: searchField),
                      const SizedBox(width: 12),
                      Expanded(child: cityDropdown),
                    ],
                  );
                }
                return Column(
                  children: [
                    searchField,
                    const SizedBox(height: 8),
                    cityDropdown,
                  ],
                );
              },
            ),
          ),
          // ── Pending acceptance banner ──
          if (_pendingAssignments.isNotEmpty)
            Builder(
              builder: (context) {
                final dark = Theme.of(context).brightness == Brightness.dark;
                final bg = dark
                    ? HelpiTheme.statusProcessingText.withValues(alpha: 0.15)
                    : HelpiTheme.statusProcessingBg;
                final borderC = HelpiTheme.statusProcessingText.withValues(
                  alpha: 0.3,
                );
                return GestureDetector(
                  onTap: _openPendingSheet,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderC),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.hourglass_top,
                          size: 20,
                          color: HelpiTheme.statusProcessingText,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.pendingAcceptanceBanner(
                              _pendingAssignments
                                  .map(
                                    (e) => (e['orderId'] as num?)?.toInt() ?? 0,
                                  )
                                  .toSet()
                                  .length,
                            ),
                            style: const TextStyle(
                              color: HelpiTheme.statusProcessingText,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: HelpiTheme.statusProcessingText,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          // ── Status filter tabs ──
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: HelpiTheme.accent,
            unselectedLabelColor: HelpiColors.of(context).textSecondary,
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
            dividerColor: HelpiColors.of(context).border,
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

          // ── Result count + sort ──
          Builder(
            builder: (context) {
              final currentFilter = _tabFilters[_tabCtrl.index];
              final seniors = _filteredSeniors(currentFilter);
              return ResultCountRow(
                text: AppStrings.seniorResultCount(seniors.length),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.download_outlined,
                        size: 20,
                        color: HelpiColors.of(context).textSecondary,
                      ),
                      onPressed: () async {
                        final saved = await ExcelExportService.exportSeniors(
                          seniors,
                          currentFilter.name,
                        );
                        if (!context.mounted) return;
                        if (saved) {
                          showSuccessSnack(context, AppStrings.exportSuccess);
                        }
                      },
                      tooltip: AppStrings.exportToExcel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<SeniorSort>(
                      icon: Icon(
                        Icons.sort,
                        size: 20,
                        color: HelpiColors.of(context).textSecondary,
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
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
    final seniorOrders = ref
        .read(ordersProvider)
        .where((o) => o.senior.id == senior.id)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SeniorDetailScreen(senior: senior, orders: seniorOrders),
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {});
    });
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
      height: 36,
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
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? HelpiTheme.accent
                  : HelpiColors.of(context).textPrimary,
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
class _SeniorCard extends ConsumerWidget {
  const _SeniorCard({required this.senior, required this.onTap});
  final SeniorModel senior;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveOrders = ref
        .watch(ordersProvider)
        .where(
          (o) =>
              o.senior.id == senior.id &&
              (o.status == OrderStatus.processing ||
                  o.status == OrderStatus.active),
        )
        .toList();

    return HoverCard(
      onTap: onTap,
      bgColor: HelpiColors.of(context).surface,
      borderColor: HelpiColors.of(context).border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Avatar + Name + Status chip ──
          Row(
            children: [
              ProfileAvatar(
                initials: senior.firstName[0] + senior.lastName[0],
                profileImageUrl: senior.profileImageUrl,
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
              StatusBadge.senior(senior, liveOrders: liveOrders),
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
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: HelpiColors.of(context).textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            senior.contactPhone,
                            style: TextStyle(
                              fontSize: 14,
                              color: HelpiColors.of(context).textSecondary,
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
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: HelpiColors.of(context).textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            senior.contactEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: HelpiColors.of(context).textSecondary,
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
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: HelpiColors.of(context).textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            senior.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: HelpiColors.of(context).textSecondary,
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
              Icon(
                Icons.chevron_right,
                color: HelpiColors.of(context).textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SENIOR DETAIL (inline same file)
// ═══════════════════════════════════════════════════════════════
class SeniorDetailScreen extends ConsumerStatefulWidget {
  const SeniorDetailScreen({
    super.key,
    required this.senior,
    required this.orders,
  });
  final SeniorModel senior;
  final List<OrderModel> orders;

  @override
  ConsumerState<SeniorDetailScreen> createState() => SeniorDetailScreenState();
}

class SeniorDetailScreenState extends ConsumerState<SeniorDetailScreen> {
  late SeniorModel _senior;
  late List<OrderModel> _orders;
  final _prefs = PreferencesService.instance;
  static const _screenKey = 'seniorDetail';
  static const _sectionCount = 8;

  final _api = ApiClient();
  UserSuspensionStatus? _suspensionStatus;

  late List<int> _sectionOrder;

  @override
  void initState() {
    super.initState();
    _senior = widget.senior;
    _orders = widget.orders
      ..sort((a, b) {
        final aNum = int.tryParse(a.orderNumber) ?? 0;
        final bNum = int.tryParse(b.orderNumber) ?? 0;
        return bNum.compareTo(aNum);
      });
    final saved = _prefs.getSectionOrder(_screenKey);
    if (saved != null && saved.length == _sectionCount) {
      _sectionOrder = saved;
    } else {
      _sectionOrder = List.generate(_sectionCount, (i) => i);
    }
    _loadSuspensionStatus();

    // Auto-refresh orders when SignalR updates ordersProvider.
    ref.listenManual(ordersProvider, (prev, next) {
      final fresh = next.where((o) => o.senior.id == _senior.id).toList()
        ..sort((a, b) {
          final aNum = int.tryParse(a.orderNumber) ?? 0;
          final bNum = int.tryParse(b.orderNumber) ?? 0;
          return bNum.compareTo(aNum);
        });
      if (mounted) setState(() => _orders = fresh);
    });
  }

  Future<void> _loadSuspensionStatus() async {
    final userId = _senior.userId;
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

  Future<void> _confirmArchive() async {
    final api = AdminApiService();
    final seniorId = int.tryParse(_senior.id) ?? 0;

    final checkResult = await api.getSeniorArchiveCheck(seniorId);
    if (!mounted) return;

    if (!checkResult.success) {
      showSuccessSnack(context, checkResult.error ?? 'Error');
      return;
    }

    final check = checkResult.data!;

    if (check.hasBlockingItems) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.archiveBlockedTitle),
          content: SizedBox(
            width: 400,
            child: Text(
              AppStrings.archiveWarningOrders(check.activeOrdersCount),
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

      final archiveResult = await api.archiveSenior(
        seniorId,
        force: true,
        reason: 'Admin forced archive',
      );
      if (!mounted) return;
      if (archiveResult.success) {
        await DataLoader.loadAll(ref: ref);
        if (!mounted) return;
        final refreshed = ref
            .read(seniorsProvider)
            .where((s) => s.id == _senior.id)
            .firstOrNull;
        if (refreshed != null) {
          setState(() => _senior = refreshed);
        }
        showSuccessSnack(context, AppStrings.archiveSuccess);
      } else {
        showSuccessSnack(context, archiveResult.error ?? 'Error');
      }
      return;
    }

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

    final archiveResult = await api.archiveSenior(seniorId);
    if (!mounted) return;
    if (archiveResult.success) {
      await DataLoader.loadAll(ref: ref);
      if (!mounted) return;
      final refreshed = ref
          .read(seniorsProvider)
          .where((s) => s.id == _senior.id)
          .firstOrNull;
      if (refreshed != null) {
        setState(() => _senior = refreshed);
      }
      showSuccessSnack(context, AppStrings.archiveSuccess);
    } else {
      showSuccessSnack(context, archiveResult.error ?? 'Error');
    }
  }

  Future<void> _confirmUnarchive() async {
    final confirmed = await showDialog<bool>(
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
    );
    if (!mounted || confirmed != true) return;

    final seniorId = int.tryParse(_senior.id) ?? 0;
    final api = AdminApiService();
    final result = await api.unarchiveSenior(seniorId);
    if (!mounted) return;

    if (!result.success) {
      showSuccessSnack(context, result.error ?? 'Error');
      return;
    }

    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;

    final refreshed = ref
        .read(seniorsProvider)
        .where((s) => s.id == _senior.id)
        .firstOrNull;
    if (refreshed != null) {
      setState(() => _senior = refreshed);
    }

    showSuccessSnack(context, AppStrings.unarchiveSuccess);
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
      appBar: HelpiAppBar(
        titleSpacing: HelpiAppBar.innerTitleSpacing,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(_senior.fullName, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            StatusBadge.senior(
              _senior,
              liveOrders: _orders
                  .where(
                    (o) =>
                        o.status == OrderStatus.processing ||
                        o.status == OrderStatus.active,
                  )
                  .toList(),
            ),
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

  // ─────────────────────────────────────────────────────────
  //  SECTION REORDER HELPERS
  // ─────────────────────────────────────────────────────────

  static List<String> get _sectionLabels => [
    AppStrings.seniorOrdererTitle,
    AppStrings.seniorServiceUser,
    AppStrings.seniorCreditCards,
    AppStrings.seniorOrders,
    AppStrings.seniorReviews,
    AppStrings.adminNotes,
    AppStrings.suspensionHistory,
    AppStrings.adminActions,
  ];

  static const _sectionIcons = [
    Icons.people,
    Icons.elderly,
    Icons.credit_card,
    Icons.receipt_long,
    Icons.star,
    Icons.sticky_note_2,
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
          Flexible(
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
              SectionEmptyState(
                icon: Icons.credit_card_off,
                message: AppStrings.seniorNoCards,
              ),
            ]
          : _senior.creditCards
                .map((card) => _buildCreditCardRow(card))
                .toList(),
    );
  }

  Widget _buildOrdersSection() {
    final hasMore = _orders.length > 5;
    return SectionCard(
      title: AppStrings.seniorOrders,
      icon: Icons.receipt_long,
      children: [
        if (_orders.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: hasMore ? 320 : double.infinity,
            ),
            child: hasMore
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: _orders.length,
                    itemBuilder: (_, i) => _buildOrderRow(_orders[i]),
                  )
                : Column(
                    children: _orders.map((o) => _buildOrderRow(o)).toList(),
                  ),
          ),
        if (_orders.isEmpty)
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
    // Refresh orders from API so the active-order check is up to date
    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;

    // Warn if user has active orders (will be auto-cancelled)
    final hasActiveOrders = ref
        .read(ordersProvider)
        .any(
          (o) =>
              o.senior.id == _senior.id &&
              (o.status == OrderStatus.active ||
                  o.status == OrderStatus.processing),
        );

    if (hasActiveOrders) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.suspendWarningTitle),
          content: SizedBox(
            width: 400,
            child: Text(AppStrings.suspendWarningMsg),
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

    final reason = await showSuspendDialog(context, _senior.fullName);
    if (!mounted || reason == null) return;

    final userId = _senior.userId;
    if (userId != null) {
      final error = await suspendUserApi(_api, userId, reason);
      if (!mounted) return;
      if (error != null) {
        showErrorSnack(context, '${AppStrings.suspensionFailed}: $error');
        return;
      }
    }

    // Backend auto-cancels all orders when suspending a customer.
    // Refresh data from backend to get updated order statuses.
    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;

    // Pick up fresh senior data from the refreshed AppData
    final fresh = ref
        .read(seniorsProvider)
        .firstWhere((s) => s.id == _senior.id, orElse: () => _senior);
    final freshOrders =
        ref
            .read(ordersProvider)
            .where((o) => o.senior.id == _senior.id)
            .toList()
          ..sort((a, b) {
            final aNum = int.tryParse(a.orderNumber) ?? 0;
            final bNum = int.tryParse(b.orderNumber) ?? 0;
            return bNum.compareTo(aNum);
          });
    setState(() {
      _senior = fresh;
      _orders = freshOrders;
    });
    showSuccessSnack(context, AppStrings.suspensionSuccess);
    SuspensionStateManager.instance.suspend(_senior.id);
    _loadSuspensionStatus();
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

    final userId = _senior.userId;
    if (userId != null) {
      final error = await activateUserApi(_api, userId);
      if (!mounted) return;
      if (error != null) {
        showErrorSnack(context, '${AppStrings.activationFailed}: $error');
        return;
      }
    }

    // Refresh data from backend
    await DataLoader.loadAll(ref: ref);
    if (!mounted) return;

    // Pick up fresh senior data from the refreshed AppData
    final fresh = ref
        .read(seniorsProvider)
        .firstWhere((s) => s.id == _senior.id, orElse: () => _senior);
    final freshOrders =
        ref
            .read(ordersProvider)
            .where((o) => o.senior.id == _senior.id)
            .toList()
          ..sort((a, b) {
            final aNum = int.tryParse(a.orderNumber) ?? 0;
            final bNum = int.tryParse(b.orderNumber) ?? 0;
            return bNum.compareTo(aNum);
          });
    setState(() {
      _senior = fresh;
      _orders = freshOrders;
    });
    showSuccessSnack(context, AppStrings.activationSuccess);
    SuspensionStateManager.instance.activate(_senior.id);
    _loadSuspensionStatus();
  }

  Widget _buildNotesSection() {
    final seniorId = int.tryParse(_senior.id) ?? 0;
    return NotesSection(entityType: 'Senior', entityId: seniorId);
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
              : HelpiColors.of(context).textSecondary,
          onTap: () =>
              _senior.isArchived ? _confirmUnarchive() : _confirmArchive(),
        ),
      ],
    );
  }

  List<ReviewModel> get _seniorReviews => ref
      .read(reviewsProvider)
      .where((r) => r.seniorName == _senior.fullName && r.reviewType == 1)
      .toList();

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
        color: expired
            ? HelpiTheme.statusCancelledBg
            : HelpiColors.of(context).scaffold,
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
                        : HelpiColors.of(context).textPrimary,
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
                        : HelpiColors.of(context).textSecondary,
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
    return HoverCard(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
        );
        if (!context.mounted) return;
        // Refresh local orders from provider after returning
        final freshOrders = ref.read(ordersProvider);
        final seniorOrders =
            freshOrders.where((o) => o.senior.id == _senior.id).toList()
              ..sort((a, b) {
                final aNum = int.tryParse(a.orderNumber) ?? 0;
                final bNum = int.tryParse(b.orderNumber) ?? 0;
                return bNum.compareTo(aNum);
              });
        setState(() => _orders = seniorOrders);
      },
      bgColor: HelpiColors.of(context).scaffold,
      borderColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      radius: 8,
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
                  style: TextStyle(
                    fontSize: 13,
                    color: HelpiColors.of(context).textSecondary,
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
    );
  }
}
