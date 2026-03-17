// ═══════════════════════════════════════════════════════════════
//  ARCHIVE CHECK — API response models for archive/delete
// ═══════════════════════════════════════════════════════════════

/// Result of checking if an entity can be archived.
class ArchiveCheckResult {
  final bool canArchiveDirectly;
  final bool hasBlockingItems;
  final int activeAssignmentsCount;
  final int upcomingSessionsCount;
  final int activeOrdersCount;
  final String? message;

  const ArchiveCheckResult({
    required this.canArchiveDirectly,
    required this.hasBlockingItems,
    this.activeAssignmentsCount = 0,
    this.upcomingSessionsCount = 0,
    this.activeOrdersCount = 0,
    this.message,
  });

  factory ArchiveCheckResult.fromJson(Map<String, dynamic> json) {
    return ArchiveCheckResult(
      canArchiveDirectly: json['canArchiveDirectly'] as bool? ?? false,
      hasBlockingItems: json['hasBlockingItems'] as bool? ?? false,
      activeAssignmentsCount: json['activeAssignmentsCount'] as int? ?? 0,
      upcomingSessionsCount: json['upcomingSessionsCount'] as int? ?? 0,
      activeOrdersCount: json['activeOrdersCount'] as int? ?? 0,
      message: json['message'] as String?,
    );
  }

  /// Total number of items that will be affected by force archive.
  int get totalBlockingItems =>
      activeAssignmentsCount + upcomingSessionsCount + activeOrdersCount;
}

/// Result of archive operation.
class ArchiveResult {
  final bool success;
  final String? message;
  final int terminatedAssignmentsCount;
  final int cancelledSessionsCount;
  final int cancelledOrdersCount;

  const ArchiveResult({
    required this.success,
    this.message,
    this.terminatedAssignmentsCount = 0,
    this.cancelledSessionsCount = 0,
    this.cancelledOrdersCount = 0,
  });

  factory ArchiveResult.fromJson(Map<String, dynamic> json) {
    return ArchiveResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      terminatedAssignmentsCount:
          json['terminatedAssignmentsCount'] as int? ?? 0,
      cancelledSessionsCount: json['cancelledSessionsCount'] as int? ?? 0,
      cancelledOrdersCount: json['cancelledOrdersCount'] as int? ?? 0,
    );
  }
}
