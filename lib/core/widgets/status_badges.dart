import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';

// ═══════════════════════════════════════════════════════════════
//  SERVICE TYPE LABEL
// ═══════════════════════════════════════════════════════════════

/// Maps [ServiceType] → localized UI string.
String serviceLabel(ServiceType type) => switch (type) {
  ServiceType.shopping => AppStrings.serviceShopping,
  ServiceType.houseHelp => AppStrings.serviceHouseHelp,
  ServiceType.companionship => AppStrings.serviceCompanionship,
  ServiceType.walking => AppStrings.serviceWalking,
  ServiceType.escort => AppStrings.serviceEscort,
  ServiceType.other => AppStrings.serviceOther,
};

// ═══════════════════════════════════════════════════════════════
//  ORDER STATUS COLORS + LABEL
// ═══════════════════════════════════════════════════════════════

/// Returns (textColor, bgColor, label) for a given [OrderStatus].
(Color, Color, String) orderStatusStyle(OrderStatus status) => switch (status) {
  OrderStatus.processing => (
    HelpiTheme.statusProcessingText,
    HelpiTheme.statusProcessingBg,
    AppStrings.statusProcessing,
  ),
  OrderStatus.active => (
    HelpiTheme.statusActiveText,
    HelpiTheme.statusActiveBg,
    AppStrings.statusActive,
  ),
  OrderStatus.completed => (
    HelpiTheme.statusCompletedText,
    HelpiTheme.statusCompletedBg,
    AppStrings.statusCompleted,
  ),
  OrderStatus.cancelled => (
    HelpiTheme.statusCancelledText,
    HelpiTheme.statusCancelledBg,
    AppStrings.statusCancelled,
  ),
  OrderStatus.archived => (
    HelpiTheme.textSecondary,
    HelpiTheme.chipBg,
    AppStrings.statusArchived,
  ),
};

// ═══════════════════════════════════════════════════════════════
//  CONTRACT STATUS COLORS + LABEL
// ═══════════════════════════════════════════════════════════════

/// Returns (textColor, bgColor, label) for a given [ContractStatus].
(Color, Color, String) contractStatusStyle(ContractStatus status) =>
    switch (status) {
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
      ContractStatus.none => (
        HelpiTheme.textSecondary,
        HelpiTheme.chipBg,
        AppStrings.contractNone,
      ),
    };

// ═══════════════════════════════════════════════════════════════
//  SESSION STATUS COLORS + LABEL
// ═══════════════════════════════════════════════════════════════

/// Returns (textColor, bgColor, label) for a given [SessionStatus].
(Color, Color, String) sessionStatusStyle(SessionStatus status) =>
    switch (status) {
      SessionStatus.scheduled => (
        HelpiTheme.statusScheduledText,
        HelpiTheme.statusScheduledBg,
        AppStrings.sessionStatusScheduled,
      ),
      SessionStatus.completed => (
        HelpiTheme.statusActiveText,
        HelpiTheme.statusActiveBg,
        AppStrings.sessionStatusCompleted,
      ),
      SessionStatus.cancelled => (
        HelpiTheme.statusCancelledText,
        HelpiTheme.statusCancelledBg,
        AppStrings.sessionStatusCancelled,
      ),
    };

// ═══════════════════════════════════════════════════════════════
//  SENIOR STATUS COLORS + LABEL (centralized)
// ═══════════════════════════════════════════════════════════════

/// Returns (textColor, bgColor, label) for a senior based on flags + live
/// orders. [liveOrders] must already be filtered to processing/active orders
/// for this senior.
(Color, Color, String) seniorStatusStyle(
  SeniorModel senior,
  List<OrderModel> liveOrders,
) {
  if (senior.isSuspended) {
    return (
      HelpiTheme.error,
      HelpiTheme.statusCancelledBg,
      AppStrings.suspended,
    );
  }
  if (senior.isArchived) {
    return (
      HelpiTheme.textSecondary,
      HelpiTheme.chipBg,
      AppStrings.statusArchived,
    );
  }
  if (!senior.isActive || liveOrders.isEmpty) {
    return (
      HelpiTheme.statusCancelledText,
      HelpiTheme.statusCancelledBg,
      AppStrings.seniorFilterInactive,
    );
  }
  if (liveOrders.any((o) => o.status == OrderStatus.processing)) {
    return (
      HelpiTheme.statusProcessingText,
      HelpiTheme.statusProcessingBg,
      AppStrings.filterProcessing,
    );
  }
  return (
    HelpiTheme.statusActiveText,
    HelpiTheme.statusActiveBg,
    AppStrings.seniorFilterActive,
  );
}

// ═══════════════════════════════════════════════════════════════
//  STATUS BADGE WIDGET
// ═══════════════════════════════════════════════════════════════

/// Renders a small rounded status badge (chip) with colored text/bg/border.
///
/// [size] controls the visual density:
/// - `StatusBadgeSize.small` → padding (10,4), fontSize 12, statusBadgeRadius
/// - `StatusBadgeSize.large` → padding (14,6), fontSize 13, chipRadius
enum StatusBadgeSize { small, large }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.textColor,
    required this.bgColor,
    required this.label,
    this.size = StatusBadgeSize.small,
  });

  /// Creates a badge from an [OrderStatus].
  factory StatusBadge.order(
    OrderStatus status, {
    StatusBadgeSize size = StatusBadgeSize.small,
  }) {
    final (textColor, bgColor, label) = orderStatusStyle(status);
    return StatusBadge(
      textColor: textColor,
      bgColor: bgColor,
      label: label,
      size: size,
    );
  }

  /// Creates a badge from a [ContractStatus].
  factory StatusBadge.contract(
    ContractStatus status, {
    StatusBadgeSize size = StatusBadgeSize.small,
  }) {
    final (textColor, bgColor, label) = contractStatusStyle(status);
    return StatusBadge(
      textColor: textColor,
      bgColor: bgColor,
      label: label,
      size: size,
    );
  }

  /// Creates a badge from a [SessionStatus].
  factory StatusBadge.session(
    SessionStatus status, {
    StatusBadgeSize size = StatusBadgeSize.small,
  }) {
    final (textColor, bgColor, label) = sessionStatusStyle(status);
    return StatusBadge(
      textColor: textColor,
      bgColor: bgColor,
      label: label,
      size: size,
    );
  }

  /// Suspended badge (red).
  factory StatusBadge.suspended({
    StatusBadgeSize size = StatusBadgeSize.small,
  }) {
    return StatusBadge(
      textColor: HelpiTheme.error,
      bgColor: HelpiTheme.statusCancelledBg,
      label: AppStrings.suspended,
      size: size,
    );
  }

  /// Computes the correct senior status badge from model + live orders.
  ///
  /// [liveOrders] must be pre-filtered to only processing/active orders
  /// belonging to this senior.
  factory StatusBadge.senior(
    SeniorModel senior, {
    required List<OrderModel> liveOrders,
    StatusBadgeSize size = StatusBadgeSize.small,
  }) {
    final (textColor, bgColor, label) = seniorStatusStyle(senior, liveOrders);
    return StatusBadge(
      textColor: textColor,
      bgColor: bgColor,
      label: label,
      size: size,
    );
  }

  final Color textColor;
  final Color bgColor;
  final String label;
  final StatusBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final isSmall = size == StatusBadgeSize.small;
    final double hPad = isSmall ? 10 : 14;
    final double vPad = isSmall ? 4 : 6;
    final double fs = isSmall ? 12 : 13;
    final double radius = isSmall
        ? HelpiTheme.statusBadgeRadius
        : HelpiTheme.chipRadius;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = isDark ? textColor.withValues(alpha: 0.15) : bgColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: effectiveBg,
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fs,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.1,
          leadingDistribution: TextLeadingDistribution.even,
          inherit: false,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SERVICE CHIP (pill in Wrap)
// ═══════════════════════════════════════════════════════════════

/// A single service-type chip used inside a [Wrap] of service pills.
class ServiceChip extends StatelessWidget {
  const ServiceChip({super.key, required this.type});
  final ServiceType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: HelpiTheme.textSecondary.withValues(alpha: 0.08),
        border: Border.all(
          color: HelpiTheme.textSecondary.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        serviceLabel(type),
        style: const TextStyle(fontSize: 12, color: HelpiTheme.textSecondary),
      ),
    );
  }
}
