import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/features/orders/presentation/order_detail_screen.dart';

/// Seniors Screen — popis seniora s pretragom i detaljima.
enum SeniorSort { az, za, newest, oldest }

enum _SeniorStatusFilter { all, processing, active, inactive, archived }

class SeniorsScreen extends StatefulWidget {
  const SeniorsScreen({super.key});

  @override
  State<SeniorsScreen> createState() => _SeniorsScreenState();
}

class _SeniorsScreenState extends State<SeniorsScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  SeniorSort _sort = SeniorSort.az;
  _SeniorStatusFilter _statusFilter = _SeniorStatusFilter.active;
  late final TabController _tabCtrl;

  static const _tabFilters = _SeniorStatusFilter.values;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: _tabFilters.length,
      vsync: this,
      initialIndex: _tabFilters.indexOf(_SeniorStatusFilter.active),
    );
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _statusFilter = _tabFilters[_tabCtrl.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SeniorModel> get _filteredSeniors {
    var seniors = MockData.seniors.toList();

    // Precompute senior IDs that have unassigned orders
    final processingIds = MockData.orders
        .where(
          (o) =>
              o.student == null &&
              (o.status == OrderStatus.active ||
                  o.status == OrderStatus.processing),
        )
        .map((o) => o.senior.id)
        .toSet();

    // Status filter
    switch (_statusFilter) {
      case _SeniorStatusFilter.all:
        break;
      case _SeniorStatusFilter.processing:
        seniors = seniors
            .where((s) => processingIds.contains(s.id) && !s.isArchived)
            .toList();
      case _SeniorStatusFilter.active:
        seniors = seniors
            .where(
              (s) =>
                  s.isActive && !s.isArchived && !processingIds.contains(s.id),
            )
            .toList();
      case _SeniorStatusFilter.inactive:
        seniors = seniors.where((s) => !s.isActive && !s.isArchived).toList();
      case _SeniorStatusFilter.archived:
        seniors = seniors.where((s) => s.isArchived).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      seniors = seniors.where((s) {
        return s.fullName.toLowerCase().contains(q) ||
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
    final seniors = _filteredSeniors;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.seniorsTitle),
        actions: [
          PopupMenuButton<SeniorSort>(
            icon: const Icon(Icons.sort, color: HelpiTheme.textSecondary),
            tooltip: AppStrings.sortBy,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => [
              _sortMenuItem(SeniorSort.az, AppStrings.sortAZ),
              _sortMenuItem(SeniorSort.za, AppStrings.sortZA),
              _sortMenuItem(SeniorSort.newest, AppStrings.sortNewest),
              _sortMenuItem(SeniorSort.oldest, AppStrings.sortOldest),
            ],
          ),
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
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 14),
            tabs: _tabFilters.map((f) {
              final label = switch (f) {
                _SeniorStatusFilter.all => AppStrings.filterAll,
                _SeniorStatusFilter.processing => AppStrings.filterProcessing,
                _SeniorStatusFilter.active => AppStrings.filterActive,
                _SeniorStatusFilter.inactive => AppStrings.filterInactive,
                _SeniorStatusFilter.archived => AppStrings.filterArchived,
              };
              return Tab(text: label);
            }).toList(),
          ),
          const SizedBox(height: 8),

          // ── Senior list ──
          Expanded(
            child: seniors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.elderly_outlined,
                          size: 64,
                          color: HelpiTheme.border,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.noSeniorsFound,
                          style: const TextStyle(
                            color: HelpiTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: seniors.length,
                    itemBuilder: (ctx, i) => _SeniorCard(
                      senior: seniors[i],
                      onTap: () => _openSeniorDetail(seniors[i]),
                    ),
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
            _SeniorDetailScreen(senior: senior, orders: seniorOrders),
      ),
    );
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
    final orderCount = MockData.orders
        .where((o) => o.senior.id == senior.id)
        .length;

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
        child: Row(
          children: [
            // ── Avatar ──
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: HelpiTheme.pastelCoral,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  senior.firstName[0] + senior.lastName[0],
                  style: const TextStyle(
                    color: HelpiTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senior.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: HelpiTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        senior.phone,
                        style: const TextStyle(
                          fontSize: 13,
                          color: HelpiTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
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
                            fontSize: 13,
                            color: HelpiTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        AppStrings.seniorOrderCount(orderCount),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: HelpiTheme.accent,
                        ),
                      ),
                      if (senior.isArchived) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: HelpiTheme.chipBg,
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
                      ] else if (!senior.isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: HelpiTheme.statusCancelledBg,
                            borderRadius: BorderRadius.circular(
                              HelpiTheme.statusBadgeRadius,
                            ),
                          ),
                          child: Text(
                            AppStrings.filterInactive,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: HelpiTheme.statusCancelledText,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Arrow ──
            const Icon(Icons.chevron_right, color: HelpiTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SENIOR DETAIL (inline same file)
// ═══════════════════════════════════════════════════════════════
class _SeniorDetailScreen extends StatefulWidget {
  const _SeniorDetailScreen({required this.senior, required this.orders});
  final SeniorModel senior;
  final List<OrderModel> orders;

  @override
  State<_SeniorDetailScreen> createState() => _SeniorDetailScreenState();
}

class _SeniorDetailScreenState extends State<_SeniorDetailScreen> {
  late SeniorModel _senior;

  @override
  void initState() {
    super.initState();
    _senior = widget.senior;
  }

  SeniorModel _rebuildSenior({bool? isActive, bool? isArchived}) {
    final updated = SeniorModel(
      id: _senior.id,
      firstName: _senior.firstName,
      lastName: _senior.lastName,
      email: _senior.email,
      phone: _senior.phone,
      address: _senior.address,
      isActive: isActive ?? _senior.isActive,
      isArchived: isArchived ?? _senior.isArchived,
      createdAt: _senior.createdAt,
      ordererFirstName: _senior.ordererFirstName,
      ordererLastName: _senior.ordererLastName,
      ordererPhone: _senior.ordererPhone,
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
          _senior = _rebuildSenior(isArchived: false);
        });
      }
    });
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
            if (_senior.isActive && !_senior.isArchived)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: HelpiTheme.statusActiveBg,
                  borderRadius: BorderRadius.circular(
                    HelpiTheme.statusBadgeRadius,
                  ),
                ),
                child: Text(
                  AppStrings.filterActive,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HelpiTheme.statusActiveText,
                  ),
                ),
              ),
            if (!_senior.isActive && !_senior.isArchived)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: HelpiTheme.statusCancelledBg,
                  borderRadius: BorderRadius.circular(
                    HelpiTheme.statusBadgeRadius,
                  ),
                ),
                child: Text(
                  AppStrings.filterInactive,
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
            // ── Personal data ──
            _buildSection(AppStrings.seniorPersonalData, [
              _buildInfoRow(AppStrings.seniorFirstName, _senior.firstName),
              _buildInfoRow(AppStrings.seniorLastName, _senior.lastName),
              _buildInfoRow(AppStrings.seniorEmail, _senior.email),
              _buildInfoRow(AppStrings.seniorPhone, _senior.phone),
              _buildInfoRow(AppStrings.seniorAddress, _senior.address),
            ]),
            const SizedBox(height: 12),

            // ── Orderer info ──
            if (_senior.ordererFirstName != null) ...[
              _buildSection(AppStrings.seniorOrdererInfo, [
                _buildInfoRow(
                  AppStrings.seniorOrdererName,
                  '${_senior.ordererFirstName} ${_senior.ordererLastName}',
                ),
                if (_senior.ordererPhone != null)
                  _buildInfoRow(
                    AppStrings.seniorOrdererPhone,
                    _senior.ordererPhone!,
                  ),
              ]),
              const SizedBox(height: 12),
            ],

            // ── Orders ──
            if (widget.orders.isNotEmpty) ...[
              _buildSection(
                AppStrings.seniorOrders,
                widget.orders.map((o) => _buildOrderRow(o)).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // ── Empty state ──
            if (widget.orders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 48,
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

            // ── Reviews ──
            if (_seniorReviews.isNotEmpty) ...[
              _buildReviewsSection(_seniorReviews),
              const SizedBox(height: 12),
            ],

            // ── Admin actions ──
            const SizedBox(height: 12),
            _buildSection(AppStrings.adminActions, [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (_senior.isActive) {
                            _senior = _rebuildSenior(isActive: false);
                          } else {
                            _senior = _rebuildSenior(isActive: true);
                          }
                        });
                      },
                      icon: Icon(
                        _senior.isActive
                            ? Icons.block
                            : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(
                        _senior.isActive
                            ? AppStrings.studentDeactivate
                            : AppStrings.studentActivate,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _senior.isActive
                            ? HelpiTheme.primary
                            : HelpiTheme.statusActiveText,
                        side: BorderSide(
                          color: _senior.isActive
                              ? HelpiTheme.primary
                              : HelpiTheme.statusActiveText,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              if (!_senior.isActive || _senior.isArchived) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _senior.isArchived
                        ? _confirmUnarchive()
                        : _confirmArchive(),
                    icon: Icon(
                      _senior.isArchived ? Icons.unarchive : Icons.archive,
                      size: 18,
                    ),
                    label: Text(
                      _senior.isArchived
                          ? AppStrings.studentUnarchive
                          : AppStrings.studentArchive,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _senior.isArchived
                          ? HelpiTheme.accent
                          : HelpiTheme.textSecondary,
                      side: BorderSide(
                        color: _senior.isArchived
                            ? HelpiTheme.accent
                            : HelpiTheme.textSecondary,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ]),
          ],
        ),
      ),
    );
  }

  List<ReviewModel> get _seniorReviews =>
      MockData.reviews.where((r) => r.seniorName == _senior.fullName).toList();

  Widget _buildReviewsSection(List<ReviewModel> reviews) {
    final avgRating = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return _buildSection(AppStrings.seniorReviews, [
      // ── Rating summary ──
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: HelpiTheme.starYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(HelpiTheme.statusBadgeRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 18, color: HelpiTheme.starYellow),
                const SizedBox(width: 4),
                Text(
                  avgRating.toStringAsFixed(1),
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
                      r.studentName,
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
    ]);
  }

  Widget _buildSection(String title, List<Widget> children) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: HelpiTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow(OrderModel order) {
    Color statusColor;
    Color statusBg;
    String statusLabel;

    switch (order.status) {
      case OrderStatus.processing:
        statusColor = HelpiTheme.statusProcessingText;
        statusBg = HelpiTheme.statusProcessingBg;
        statusLabel = AppStrings.statusProcessing;
      case OrderStatus.active:
        statusColor = HelpiTheme.statusActiveText;
        statusBg = HelpiTheme.statusActiveBg;
        statusLabel = AppStrings.statusActive;
      case OrderStatus.completed:
        statusColor = HelpiTheme.statusActiveText;
        statusBg = HelpiTheme.statusActiveBg;
        statusLabel = AppStrings.statusCompleted;
      case OrderStatus.cancelled:
        statusColor = HelpiTheme.statusCancelledText;
        statusBg = HelpiTheme.statusCancelledBg;
        statusLabel = AppStrings.statusCancelled;
    }

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
                    order.services.map((s) => _serviceLabel(s)).join(', '),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(
                  HelpiTheme.statusBadgeRadius,
                ),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _serviceLabel(ServiceType type) {
    switch (type) {
      case ServiceType.shopping:
        return AppStrings.serviceShopping;
      case ServiceType.houseHelp:
        return AppStrings.serviceHouseHelp;
      case ServiceType.walk:
        return AppStrings.serviceWalk;
      case ServiceType.companionship:
        return AppStrings.serviceCompanionship;
      case ServiceType.escort:
        return AppStrings.serviceEscort;
      case ServiceType.other:
        return AppStrings.serviceOther;
    }
  }
}
