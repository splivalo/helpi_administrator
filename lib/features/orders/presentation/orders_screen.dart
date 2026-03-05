import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/services/preferences_service.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/features/orders/presentation/order_detail_screen.dart';
import 'package:helpi_admin/features/orders/presentation/create_order_screen.dart';

enum OrderSort { newest, oldest, az, za }

/// Admin Orders Screen — sve narudžbe s tabovima i filterima.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  static const _screenKey = 'orders';
  final _prefs = PreferencesService.instance;

  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = false;
  OrderSort _sort = OrderSort.newest;

  static const _tabs = [
    null, // All
    OrderStatus.processing,
    OrderStatus.active,
    OrderStatus.completed,
    OrderStatus.cancelled,
    OrderStatus.archived,
  ];

  @override
  void initState() {
    super.initState();

    // Restore saved preferences
    _isGridView = _prefs.getGridView(_screenKey);
    final savedSort = _prefs.getSort(_screenKey);
    if (savedSort != null) {
      _sort = OrderSort.values.firstWhere(
        (e) => e.name == savedSort,
        orElse: () => OrderSort.newest,
      );
    }
    final savedTab = _prefs.getTab(_screenKey);

    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: savedTab.clamp(0, _tabs.length - 1),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
        _prefs.setTab(_screenKey, _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<OrderModel> _filteredOrders(OrderStatus? statusFilter) {
    var orders = MockData.orders.toList();

    if (statusFilter != null) {
      orders = orders.where((o) => o.status == statusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      orders = orders.where((o) {
        return o.orderNumber.toLowerCase().contains(q) ||
            o.senior.fullName.toLowerCase().contains(q) ||
            (o.student?.fullName.toLowerCase().contains(q) ?? false) ||
            o.address.toLowerCase().contains(q);
      }).toList();
    }

    // Sorting
    switch (_sort) {
      case OrderSort.az:
        orders.sort((a, b) => a.senior.fullName.compareTo(b.senior.fullName));
      case OrderSort.za:
        orders.sort((a, b) => b.senior.fullName.compareTo(a.senior.fullName));
      case OrderSort.newest:
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case OrderSort.oldest:
        orders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.ordersTitle),
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
          // ── Search ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: AppStrings.searchOrders,
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
          // ── Tabs ──
          TabBar(
            controller: _tabController,
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
            tabs: [
              Tab(text: AppStrings.allOrders),
              Tab(text: AppStrings.ordersProcessing),
              Tab(text: AppStrings.ordersActive),
              Tab(text: AppStrings.ordersCompleted),
              Tab(text: AppStrings.ordersCancelled),
              Tab(text: AppStrings.ordersArchived),
            ],
          ),

          const SizedBox(height: 8),

          // ── Result count + sort ──
          Builder(
            builder: (context) {
              final count = _filteredOrders(_tabs[_tabController.index]).length;
              return ResultCountRow(
                text: AppStrings.orderResultCount(count),
                trailing: PopupMenuButton<OrderSort>(
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
                    _sortMenuItem(OrderSort.newest, AppStrings.sortNewest),
                    _sortMenuItem(OrderSort.oldest, AppStrings.sortOldest),
                    _sortMenuItem(OrderSort.az, AppStrings.sortAZ),
                    _sortMenuItem(OrderSort.za, AppStrings.sortZA),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          // ── Order list ──
          Expanded(
            child: Builder(
              builder: (context) {
                final orders = _filteredOrders(_tabs[_tabController.index]);
                if (orders.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long,
                    message: AppStrings.noOrdersFound,
                  );
                }
                final screenWidth = MediaQuery.sizeOf(context).width;
                final gridCols = screenWidth >= 1200
                    ? 3
                    : (screenWidth >= 900 ? 2 : 1);
                if (_isGridView && gridCols > 1) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: (orders.length / gridCols).ceil(),
                    itemBuilder: (ctx, rowIdx) {
                      final start = rowIdx * gridCols;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: start + gridCols < orders.length ? 0 : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var j = 0; j < gridCols; j++) ...[
                              if (j > 0) const SizedBox(width: 10),
                              Expanded(
                                child: start + j < orders.length
                                    ? _OrderListCard(
                                        order: orders[start + j],
                                        onTap: () =>
                                            _openOrderDetail(orders[start + j]),
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) => _OrderListCard(
                    order: orders[i],
                    onTap: () => _openOrderDetail(orders[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'orders_fab',
        backgroundColor: HelpiTheme.accent,
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
          );
          if (!mounted) return;
          if (result == true) setState(() {});
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _openOrderDetail(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
    );
  }

  PopupMenuItem<OrderSort> _sortMenuItem(OrderSort value, String label) {
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
//  ORDER LIST CARD
// ═══════════════════════════════════════════════════════════════
class _OrderListCard extends StatelessWidget {
  const _OrderListCard({required this.order, required this.onTap});
  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = formatDate(order.scheduledDate);
    final timeStr = formatTimeOfDay(order.scheduledStart);

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
            // ── Header: order number + status ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.orderNumber(order.orderNumber),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                StatusBadge.order(order.status),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Details + Arrow ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Senior ──
                      Row(
                        children: [
                          const Icon(
                            Icons.elderly,
                            size: 18,
                            color: HelpiTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.senior.fullName,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // ── Student ──
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 18,
                            color: order.student != null
                                ? HelpiTheme.textSecondary
                                : HelpiTheme.statusCancelledText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.student?.fullName ??
                                AppStrings.noStudentAssigned,
                            style: TextStyle(
                              fontSize: 14,
                              color: order.student != null
                                  ? HelpiTheme.textPrimary
                                  : HelpiTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // ── Date + Time ──
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: HelpiTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$dateStr  $timeStr  ·  ${order.durationHours}h',
                            style: const TextStyle(
                              fontSize: 14,
                              color: HelpiTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ── Service chips ──
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: order.services
                            .map((s) => ServiceChip(type: s))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                // ── Arrow ──
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
