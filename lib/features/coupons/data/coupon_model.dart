import 'package:helpi_admin/core/l10n/app_strings.dart';

enum CouponType {
  monthlyHours,
  weeklyHours,
  oneTimeHours;

  String get label => switch (this) {
    monthlyHours => AppStrings.couponTypeMonthlyHours,
    weeklyHours => AppStrings.couponTypeWeeklyHours,
    oneTimeHours => AppStrings.couponTypeOneTimeHours,
  };

  static CouponType fromIndex(int index) => CouponType.values[index];
}

class CouponModel {
  final int id;
  final String code;
  final String name;
  final String? description;
  final CouponType type;
  final double value;
  final bool isCombainable;
  final int? cityId;
  final String? cityName;
  final String validFrom;
  final String validUntil;
  final bool isActive;
  final int assignmentCount;
  final DateTime createdAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.type,
    required this.value,
    required this.isCombainable,
    this.cityId,
    this.cityName,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    this.assignmentCount = 0,
    required this.createdAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: CouponType.fromIndex(json['type'] as int),
      value: (json['value'] as num).toDouble(),
      isCombainable: json['isCombainable'] as bool,
      cityId: json['cityId'] as int?,
      cityName: json['cityName'] as String?,
      validFrom: json['validFrom'] as String,
      validUntil: json['validUntil'] as String,
      isActive: json['isActive'] as bool,
      assignmentCount: json['assignmentCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class CouponAssignmentModel {
  final int id;
  final int couponId;
  final String couponCode;
  final String couponName;
  final CouponType couponType;
  final double couponValue;
  final bool isCombainable;
  final int seniorId;
  final String? seniorName;
  final int? assignedByAdminId;
  final double? remainingValue;
  final bool isActive;
  final DateTime assignedAt;

  CouponAssignmentModel({
    required this.id,
    required this.couponId,
    required this.couponCode,
    required this.couponName,
    required this.couponType,
    required this.couponValue,
    required this.isCombainable,
    required this.seniorId,
    this.seniorName,
    this.assignedByAdminId,
    this.remainingValue,
    required this.isActive,
    required this.assignedAt,
  });

  factory CouponAssignmentModel.fromJson(Map<String, dynamic> json) {
    return CouponAssignmentModel(
      id: json['id'] as int,
      couponId: json['couponId'] as int,
      couponCode: json['couponCode'] as String,
      couponName: json['couponName'] as String,
      couponType: CouponType.fromIndex(json['couponType'] as int),
      couponValue: (json['couponValue'] as num).toDouble(),
      isCombainable: json['isCombainable'] as bool,
      seniorId: json['seniorId'] as int,
      seniorName: json['seniorName'] as String?,
      assignedByAdminId: json['assignedByAdminId'] as int?,
      remainingValue: (json['remainingValue'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
    );
  }
}
