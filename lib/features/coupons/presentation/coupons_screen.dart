import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
import 'package:helpi_admin/core/widgets/widgets.dart';
import 'package:helpi_admin/features/coupons/data/coupon_model.dart';
import 'package:helpi_admin/features/coupons/data/coupon_provider.dart';
import 'package:helpi_admin/features/coupons/presentation/coupon_form_dialog.dart';

class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  final _api = AdminApiService();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _api.getCoupons();
    if (!context.mounted) return;
    if (result.success) {
      final list = result.data!.map((j) => CouponModel.fromJson(j)).toList();
      ref.read(couponsProvider.notifier).setAll(list);
    } else {
      _error = result.error;
    }
    setState(() => _loading = false);
  }

  Future<void> _deleteCoupon(CouponModel coupon) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.couponDeleteConfirm),
        content: Text(coupon.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final result = await _api.deleteCoupon(coupon.id);
    if (!context.mounted) return;
    if (result.success) {
      ref.read(couponsProvider.notifier).removeItem(coupon.id);
      messenger.showSnackBar(SnackBar(content: Text(AppStrings.couponDeleted)));
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(AppStrings.couponDeleteFailed)),
      );
    }
  }

  Future<void> _openCreateDialog() async {
    final created = await showDialog<CouponModel>(
      context: context,
      builder: (_) => const CouponFormDialog(),
    );
    if (created != null) {
      ref.read(couponsProvider.notifier).addItem(created);
    }
  }

  Future<void> _openEditDialog(CouponModel coupon) async {
    final updated = await showDialog<CouponModel>(
      context: context,
      builder: (_) => CouponFormDialog(existing: coupon),
    );
    if (updated != null) {
      ref.read(couponsProvider.notifier).updateItem(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coupons = ref.watch(couponsProvider);

    return Scaffold(
      appBar: HelpiAppBar(title: Text(AppStrings.couponsTitle)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'coupons_fab',
        onPressed: _openCreateDialog,
        backgroundColor: HelpiTheme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : coupons.isEmpty
          ? EmptyState(
              icon: Icons.confirmation_number_outlined,
              message: AppStrings.couponNoCoupons,
            )
          : RefreshIndicator(
              onRefresh: _loadCoupons,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: coupons.length,
                itemBuilder: (_, i) => _CouponCard(
                  coupon: coupons[i],
                  onEdit: () => _openEditDialog(coupons[i]),
                  onDelete: () => _deleteCoupon(coupons[i]),
                ),
              ),
            ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.onEdit,
    required this.onDelete,
  });

  final CouponModel coupon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isExpired = DateFormat(
      'yyyy-MM-dd',
    ).parse(coupon.validUntil).isBefore(DateTime.now());
    final dateFmt = DateFormat('dd.MM.yyyy');

    // Status badge
    final StatusBadge badge;
    if (!coupon.isActive) {
      badge = StatusBadge(
        textColor: HelpiTheme.error,
        bgColor: HelpiTheme.statusCancelledBg,
        label: AppStrings.couponInactive,
      );
    } else if (isExpired) {
      badge = StatusBadge(
        textColor: HelpiTheme.error,
        bgColor: HelpiTheme.statusCancelledBg,
        label: AppStrings.couponExpired,
      );
    } else {
      badge = StatusBadge(
        textColor: HelpiTheme.statusActiveText,
        bgColor: HelpiTheme.statusActiveBg,
        label: AppStrings.couponActive,
      );
    }

    return HoverCard(
      onTap: onEdit,
      bgColor: HelpiColors.of(context).surface,
      borderColor: HelpiColors.of(context).border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Code in teal (left) → Badge + Delete (right) ──
          Row(
            children: [
              Text(
                coupon.code,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  color: HelpiTheme.accent,
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: AppStrings.couponCopyCode,
                waitDuration: const Duration(milliseconds: 400),
                preferBelow: false,
                verticalOffset: 14,
                decoration: BoxDecoration(
                  color: const Color(0xE6616161),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                textStyle: const TextStyle(fontSize: 13, color: Colors.white),
                child: IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: coupon.code));
                    showSuccessSnack(context, AppStrings.couponCodeCopied);
                  },
                  icon: const Icon(
                    Icons.copy,
                    size: 16,
                    color: HelpiTheme.accent,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  splashRadius: 14,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const Spacer(),
              badge,
              const SizedBox(width: 8),
              Tooltip(
                message: AppStrings.delete,
                waitDuration: const Duration(milliseconds: 400),
                preferBelow: false,
                verticalOffset: 14,
                decoration: BoxDecoration(
                  color: const Color(0xE6616161),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                textStyle: const TextStyle(fontSize: 13, color: Colors.white),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  color: HelpiColors.of(context).textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Row 2: Coupon name (left) → Type+Value (right) ──
          Row(
            children: [
              Expanded(
                child: Text(coupon.name, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTypeValue(coupon),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: HelpiColors.of(context).textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Row 3: Dates (left) → Combinable + City + Senior count (right) ──
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: HelpiColors.of(context).textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${dateFmt.format(DateFormat('yyyy-MM-dd').parse(coupon.validFrom))} – ${dateFmt.format(DateFormat('yyyy-MM-dd').parse(coupon.validUntil))}',
                style: TextStyle(
                  fontSize: 12,
                  color: HelpiColors.of(context).textSecondary,
                ),
              ),
              const Spacer(),
              if (coupon.isCombainable) ...[
                Icon(
                  Icons.merge_type,
                  size: 14,
                  color: HelpiColors.of(context).textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              if (coupon.cityName != null) ...[
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: HelpiColors.of(context).textSecondary,
                ),
                const SizedBox(width: 2),
                Text(
                  coupon.cityName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: HelpiColors.of(context).textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.people_outline,
                size: 14,
                color: HelpiColors.of(context).textSecondary,
              ),
              const SizedBox(width: 2),
              Text(
                '${coupon.assignmentCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: HelpiColors.of(context).textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTypeValue(CouponModel c) {
    final hours = _hoursLabel(c.value);
    switch (c.type) {
      case CouponType.monthlyHours:
        return '$hours / mj.';
      case CouponType.weeklyHours:
        return '$hours / tj.';
      case CouponType.oneTimeHours:
        return '$hours / ukupno';
      case CouponType.percentage:
        return '${c.value.toStringAsFixed(0)}% / termin';
      case CouponType.fixedPerSession:
        return '€${c.value.toStringAsFixed(c.value == c.value.roundToDouble() ? 0 : 2)} / termin';
    }
  }

  /// Croatian hour grammar: 1 sat, 2-4 sata, 5+ sati
  String _hoursLabel(double value) {
    final formatted = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    final intVal = value.round();
    final lastDigit = intVal % 10;
    final lastTwo = intVal % 100;
    String unit;
    if (lastTwo >= 11 && lastTwo <= 19) {
      unit = 'sati';
    } else if (lastDigit == 1) {
      unit = 'sat';
    } else if (lastDigit >= 2 && lastDigit <= 4) {
      unit = 'sata';
    } else {
      unit = 'sati';
    }
    return '$formatted $unit';
  }
}
