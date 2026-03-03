import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';

/// Seniors Screen — popis seniora s pretragom i detaljima.
enum SeniorSort { az, za, newest, oldest }

class SeniorsScreen extends StatefulWidget {
  const SeniorsScreen({super.key});

  @override
  State<SeniorsScreen> createState() => _SeniorsScreenState();
}

class _SeniorsScreenState extends State<SeniorsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  SeniorSort _sort = SeniorSort.az;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SeniorModel> get _filteredSeniors {
    var seniors = MockData.seniors.toList();

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
          const SizedBox(height: 12),

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
                  Text(
                    AppStrings.seniorOrderCount(orderCount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: HelpiTheme.accent,
                    ),
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
//  SENIOR DETAIL (inline same file — simpler structure)
// ═══════════════════════════════════════════════════════════════
class _SeniorDetailScreen extends StatelessWidget {
  const _SeniorDetailScreen({required this.senior, required this.orders});
  final SeniorModel senior;
  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(senior.fullName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile header ──
            _buildHeader(),
            const SizedBox(height: 16),

            // ── Personal data ──
            _buildSection(AppStrings.seniorPersonalData, [
              _buildInfoRow(AppStrings.studentEmail, senior.email),
              _buildInfoRow(AppStrings.studentPhone, senior.phone),
              _buildInfoRow(AppStrings.studentAddress, senior.address),
            ]),
            const SizedBox(height: 12),

            // ── Orderer info ──
            if (senior.ordererFirstName != null) ...[
              _buildSection(AppStrings.seniorOrdererInfo, [
                _buildInfoRow(
                  AppStrings.seniorOrdererName,
                  '${senior.ordererFirstName} ${senior.ordererLastName}',
                ),
                if (senior.ordererPhone != null)
                  _buildInfoRow(
                    AppStrings.seniorOrdererPhone,
                    senior.ordererPhone!,
                  ),
              ]),
              const SizedBox(height: 12),
            ],

            // ── Orders ──
            if (orders.isNotEmpty) ...[
              _buildSection(
                AppStrings.seniorOrders,
                orders.map((o) => _buildOrderRow(o)).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // ── Empty state ──
            if (orders.isEmpty)
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
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
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senior.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  senior.phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
                if (senior.ordererFirstName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${AppStrings.seniorOrdererName}: ${senior.ordererFirstName} ${senior.ordererLastName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: HelpiTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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
            width: 130,
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

    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(HelpiTheme.statusBadgeRadius),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
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
