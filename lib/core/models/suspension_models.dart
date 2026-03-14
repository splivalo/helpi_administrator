/// Represents a single suspension/activation log entry.
class SuspensionLogModel {
  final int id;
  final int userId;
  final SuspensionAction action;
  final String? reason;
  final int adminId;
  final DateTime createdAt;

  const SuspensionLogModel({
    required this.id,
    required this.userId,
    required this.action,
    this.reason,
    required this.adminId,
    required this.createdAt,
  });

  factory SuspensionLogModel.fromJson(Map<String, dynamic> json) {
    return SuspensionLogModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      action: SuspensionAction.values[json['action'] as int],
      reason: json['reason'] as String?,
      adminId: json['adminId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Full suspension status for a user.
class UserSuspensionStatus {
  final bool isSuspended;
  final String? suspensionReason;
  final DateTime? suspendedAt;
  final int? suspendedByAdminId;
  final List<SuspensionLogModel> suspensionHistory;

  const UserSuspensionStatus({
    required this.isSuspended,
    this.suspensionReason,
    this.suspendedAt,
    this.suspendedByAdminId,
    this.suspensionHistory = const [],
  });

  factory UserSuspensionStatus.fromJson(Map<String, dynamic> json) {
    return UserSuspensionStatus(
      isSuspended: json['isSuspended'] as bool,
      suspensionReason: json['suspensionReason'] as String?,
      suspendedAt: json['suspendedAt'] != null
          ? DateTime.parse(json['suspendedAt'] as String)
          : null,
      suspendedByAdminId: json['suspendedByAdminId'] as int?,
      suspensionHistory: (json['suspensionHistory'] as List<dynamic>?)
              ?.map(
                (e) =>
                    SuspensionLogModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

enum SuspensionAction { suspended, activated }
