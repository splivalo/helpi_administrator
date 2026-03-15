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
//  STATUS BADGE WIDGET
// ═══════════════════════════════════════════════════════════════

/// Renders a small rounded status badge (chip) with colored text/bg/border.
///
/// [size] controls the visual density:
/// - `StatusBadgeSize.small` → padding (10,3), fontSize 11, statusBadgeRadius
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

  final Color textColor;
  final Color bgColor;
  final String label;
  final StatusBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final isSmall = size == StatusBadgeSize.small;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 10 : 14,
        vertical: isSmall ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(
          isSmall ? HelpiTheme.statusBadgeRadius : HelpiTheme.chipRadius,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSmall ? 11 : 13,
          fontWeight: FontWeight.w600,
          color: textColor,
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
