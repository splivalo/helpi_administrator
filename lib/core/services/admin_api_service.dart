import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Unified API result wrapper.
class ApiResult<T> {
  final bool success;
  final T? data;
  final String? error;

  const ApiResult._({required this.success, this.data, this.error});

  factory ApiResult.ok(T data) => ApiResult._(success: true, data: data);
  factory ApiResult.fail(String msg) =>
      ApiResult._(success: false, error: msg);
}

/// Central service for all admin API calls.
/// Converts backend DTOs ↔ frontend models.
class AdminApiService {
  final ApiClient _api;

  AdminApiService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  // ─────────────────────────────────────────────
  //  STUDENTS
  // ─────────────────────────────────────────────

  Future<ApiResult<List<StudentModel>>> getStudents({
    String? searchText,
    int? facultyId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (searchText != null && searchText.isNotEmpty) {
        params['searchText'] = searchText;
      }
      if (facultyId != null) params['facultyId'] = facultyId;

      final response = await _api.get(
        ApiEndpoints.students,
        queryParameters: params.isEmpty ? null : params,
      );
      final list = (response.data as List<dynamic>)
          .map((e) => _mapStudent(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<StudentModel>> getStudent(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.studentById(id));
      return ApiResult.ok(
          _mapStudent(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  SENIORS (backend: Customers → Seniors)
  // ─────────────────────────────────────────────

  Future<ApiResult<List<SeniorModel>>> getSeniors({
    String? searchText,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (searchText != null && searchText.isNotEmpty) {
        params['searchText'] = searchText;
      }
      final response = await _api.get(
        ApiEndpoints.seniors,
        queryParameters: params.isEmpty ? null : params,
      );
      final list = (response.data as List<dynamic>)
          .map((e) => _mapSenior(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<SeniorModel>> getSenior(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.seniorById(id));
      return ApiResult.ok(
          _mapSenior(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  ORDERS
  // ─────────────────────────────────────────────

  Future<ApiResult<List<OrderModel>>> getOrders({
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;

      final response = await _api.get(
        ApiEndpoints.orders,
        queryParameters: params.isEmpty ? null : params,
      );
      final list = (response.data as List<dynamic>)
          .map((e) => _mapOrder(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<OrderModel>> getOrder(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.orderById(id));
      return ApiResult.ok(
          _mapOrder(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<OrderModel>>> getOrdersBySenior(int seniorId) async {
    try {
      final response =
          await _api.get('${ApiEndpoints.orders}/senior/$seniorId');
      final list = (response.data as List<dynamic>)
          .map((e) => _mapOrder(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<OrderModel>> createOrder(
      Map<String, dynamic> orderData) async {
    try {
      final response =
          await _api.post(ApiEndpoints.orders, data: orderData);
      return ApiResult.ok(
          _mapOrder(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<OrderModel>> updateOrder(
      int id, Map<String, dynamic> data) async {
    try {
      final response =
          await _api.put(ApiEndpoints.orderById(id), data: data);
      return ApiResult.ok(
          _mapOrder(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<void>> cancelOrder(int id, String reason) async {
    try {
      await _api.post(
        ApiEndpoints.cancelOrder(id),
        data: {'cancellationReason': reason},
      );
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  SESSIONS
  // ─────────────────────────────────────────────

  Future<ApiResult<List<SessionModel>>> getSessions() async {
    try {
      final response = await _api.get(ApiEndpoints.sessions);
      final list = (response.data as List<dynamic>)
          .map((e) => _mapSession(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<SessionModel>>> getSessionsByStudent(
      int studentId) async {
    try {
      final response =
          await _api.get('${ApiEndpoints.sessions}/student/$studentId');
      final list = (response.data as List<dynamic>)
          .map((e) => _mapSession(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<SessionModel>>> getSessionsBySenior(
      int seniorId) async {
    try {
      final response = await _api
          .get('${ApiEndpoints.sessions}/completed/senior/$seniorId');
      final list = (response.data as List<dynamic>)
          .map((e) => _mapSession(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  REVIEWS
  // ─────────────────────────────────────────────

  Future<ApiResult<List<ReviewModel>>> getReviewsByStudent(
      int studentId) async {
    try {
      final response =
          await _api.get(ApiEndpoints.reviewsByStudent(studentId));
      final list = (response.data as List<dynamic>)
          .map((e) => _mapReview(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<ReviewModel>>> getReviewsBySenior(
      int seniorId) async {
    try {
      final response =
          await _api.get(ApiEndpoints.reviewsBySenior(seniorId));
      final list = (response.data as List<dynamic>)
          .map((e) => _mapReview(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  DASHBOARD
  // ─────────────────────────────────────────────

  Future<ApiResult<List<Map<String, dynamic>>>> getDashboardAdmin() async {
    try {
      final response = await _api.get(ApiEndpoints.dashboardAdmin);
      final list = (response.data as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  SUSPENSIONS
  // ─────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> getSuspensionStatus(
      int userId) async {
    try {
      final response =
          await _api.get(ApiEndpoints.suspensionStatus(userId));
      return ApiResult.ok(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<void>> suspendUser(int userId, String reason) async {
    try {
      await _api.post(
        ApiEndpoints.suspendUser(userId),
        data: {'reason': reason},
      );
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<void>> activateUser(int userId) async {
    try {
      await _api.post(ApiEndpoints.activateUser(userId));
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  SCHEDULE ASSIGNMENTS
  // ─────────────────────────────────────────────

  Future<ApiResult<void>> adminAssign(
      int orderScheduleId, int studentId) async {
    try {
      await _api.post(
        ApiEndpoints.adminAssign,
        data: {
          'orderScheduleId': orderScheduleId,
          'studentId': studentId,
        },
      );
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<StudentModel>>> getAvailableStudents({
    required String date,
    required String startTime,
    required String endTime,
    int? orderId,
  }) async {
    try {
      final params = <String, dynamic>{
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
      };
      if (orderId != null) params['orderId'] = orderId;

      final response = await _api.get(
        '${ApiEndpoints.students}/available-students',
        queryParameters: params,
      );
      final list = (response.data as List<dynamic>)
          .map((e) => _mapStudent(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  PROMO CODES
  // ─────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> validatePromoCode(
      String code) async {
    try {
      final response = await _api.post(
        ApiEndpoints.promoCodeValidate,
        data: {'code': code},
      );
      return ApiResult.ok(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  NOTIFICATIONS
  // ─────────────────────────────────────────────

  Future<ApiResult<List<ReviewModel>>> getReviews() async {
    try {
      final response = await _api.get(ApiEndpoints.reviews);
      final list = (response.data as List<dynamic>)
          .map((e) => _mapReview(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<NotificationModel>>> getNotifications() async {
    try {
      final response = await _api.get(ApiEndpoints.notifications);
      final list = (response.data as List<dynamic>)
          .map((e) => _mapNotification(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ═════════════════════════════════════════════
  //  MAPPERS — Backend JSON → Frontend Models
  // ═════════════════════════════════════════════

  StudentModel _mapStudent(Map<String, dynamic> json) {
    final contact = json['contact'] as Map<String, dynamic>?;
    final fullName = contact?['fullName'] as String? ?? '';
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final statusStr = json['status'] as String? ?? 'Active';

    return StudentModel(
      id: '${json['userId']}',
      firstName: firstName,
      lastName: lastName,
      email: contact?['email'] as String? ?? '',
      phone: contact?['phone'] as String? ?? '',
      address: contact?['fullAddress'] as String? ?? '',
      faculty: _extractFacultyName(json['faculty']),
      studentIdNumber: json['studentNumber'] as String? ?? '',
      dateOfBirth: _parseDate(contact?['dateOfBirth']),
      gender: _mapGender(contact?['gender']),
      avgRating: _toDouble(json['averageRating']),
      totalReviews: json['totalReviews'] as int? ?? 0,
      completedJobs: 0, // calculated from sessions if needed
      cancelledJobs: 0,
      isVerified: statusStr == 'Active',
      isActive: statusStr != 'AccountDeactivated' &&
          statusStr != 'PendingPermanentDeletion' &&
          statusStr != 'Deleted',
      isArchived:
          statusStr == 'PendingPermanentDeletion' || statusStr == 'Deleted',
      createdAt: _parseDateTime(json['dateRegistered']),
      contractStatus: _mapContractStatus(statusStr, json['daysToContractExpire']),
      contractStartDate: null, // from contract endpoint if needed
      contractExpiryDate: _parseNullableDate(
          json['daysToContractExpire'] != null
              ? null // calculated from days if needed
              : null),
      hourlyRate: 7.40,
      sundayHourlyRate: 11.10,
    );
  }

  SeniorModel _mapSenior(Map<String, dynamic> json) {
    final contact = json['contact'] as Map<String, dynamic>?;
    final fullName = contact?['fullName'] as String? ?? '';
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return SeniorModel(
      id: '${json['id']}',
      firstName: firstName,
      lastName: lastName,
      email: contact?['email'] as String? ?? '',
      phone: contact?['phone'] as String? ?? '',
      address: contact?['fullAddress'] as String? ?? '',
      gender: _mapGender(contact?['gender']),
      dateOfBirth: _parseDate(contact?['dateOfBirth']),
      createdAt: _parseDateTime(contact?['createdAt']),
      isActive: json['deletedAt'] == null,
      isArchived: json['deletedAt'] != null,
      creditCards: const [],
    );
  }

  OrderModel _mapOrder(Map<String, dynamic> json) {
    final schedules = (json['schedules'] as List<dynamic>? ?? [])
        .map((s) => s as Map<String, dynamic>)
        .toList();
    final services = (json['services'] as List<dynamic>? ?? [])
        .map((s) => _mapServiceType(s as Map<String, dynamic>))
        .toList();

    // Build day entries from schedules
    final dayEntries = schedules
        .map((s) => DayEntry(
              dayOfWeek: s['dayOfWeek'] as int? ?? 1,
              startTime: _parseTimeOfDay(s['startTime']),
              durationHours: _calcHours(s['startTime'], s['endTime']),
            ))
        .toList();

    // Determine first schedule for scheduledStart
    final firstSchedule =
        schedules.isNotEmpty ? schedules.first : <String, dynamic>{};

    return OrderModel(
      id: '${json['id']}',
      orderNumber: 'ORD-${json['id'].toString().padLeft(4, '0')}',
      senior: _mapOrderSenior(json),
      student: null, // populated from schedule assignment if needed
      status: _mapOrderStatus(json['status'] as String? ?? 'Pending'),
      frequency: (json['isRecurring'] == true)
          ? FrequencyType.recurring
          : FrequencyType.oneTime,
      services: services,
      createdAt: DateTime.now(), // not in OrderDto
      scheduledDate: _parseDate(json['startDate']),
      scheduledStart: _parseTimeOfDay(firstSchedule['startTime']),
      durationHours:
          _calcHours(firstSchedule['startTime'], firstSchedule['endTime']),
      notes: json['notes'] as String?,
      address: '', // from senior contact
      endDate: _parseNullableDate(json['endDate']),
      dayEntries: dayEntries,
      sessions: const [], // loaded separately
    );
  }

  SeniorModel _mapOrderSenior(Map<String, dynamic> orderJson) {
    final senior = orderJson['senior'] as Map<String, dynamic>?;
    if (senior != null) return _mapSenior(senior);

    // Minimal fallback
    return SeniorModel(
      id: '${orderJson['seniorId']}',
      firstName: orderJson['seniorName'] as String? ?? '',
      lastName: '',
      email: '',
      phone: '',
      address: '',
      gender: Gender.female,
      dateOfBirth: DateTime(1950),
      createdAt: DateTime.now(),
    );
  }

  SessionModel _mapSession(Map<String, dynamic> json) {
    final assignment = json['scheduleAssignment'] as Map<String, dynamic>?;
    final studentContact =
        assignment?['student']?['contact'] as Map<String, dynamic>?;

    return SessionModel(
      id: '${json['id']}',
      orderId: '${json['orderId']}',
      date: _parseDate(json['scheduledDate']),
      weekday: _parseDate(json['scheduledDate']).weekday,
      startTime: _parseTimeOfDay(json['startTime']),
      durationHours:
          _calcHours(json['startTime'], json['endTime']),
      studentName: studentContact?['fullName'] as String?,
      status: _mapSessionStatus(json['status'] as String? ?? 'Upcoming'),
      isModified: json['isRescheduleVariant'] == true,
    );
  }

  ReviewModel _mapReview(Map<String, dynamic> json) {
    return ReviewModel(
      id: '${json['id']}',
      sessionId: json['jobInstanceId'] != null
          ? '${json['jobInstanceId']}'
          : null,
      studentId:
          json['studentId'] != null ? '${json['studentId']}' : null,
      seniorId:
          json['seniorId'] != null ? '${json['seniorId']}' : null,
      seniorName: json['seniorFullName'] as String? ?? '',
      studentName: json['studentFullName'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  NotificationModel _mapNotification(Map<String, dynamic> json) {
    return NotificationModel(
      id: '${json['id']}',
      type: NotificationType.info,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  // ═════════════════════════════════════════════
  //  ENUM MAPPERS
  // ═════════════════════════════════════════════

  OrderStatus _mapOrderStatus(String s) => switch (s) {
        'InActive' || 'Pending' => OrderStatus.processing,
        'FullAssigned' => OrderStatus.active,
        'Completed' => OrderStatus.completed,
        'Cancelled' => OrderStatus.cancelled,
        _ => OrderStatus.processing,
      };

  SessionStatus _mapSessionStatus(String s) => switch (s) {
        'Upcoming' || 'InProgress' => SessionStatus.scheduled,
        'Completed' => SessionStatus.completed,
        'Cancelled' || 'Rescheduled' => SessionStatus.cancelled,
        _ => SessionStatus.scheduled,
      };

  Gender _mapGender(dynamic g) {
    if (g is String) {
      return g == 'Male' ? Gender.male : Gender.female;
    }
    if (g is int) {
      return g == 0 ? Gender.male : Gender.female;
    }
    return Gender.female;
  }

  ContractStatus _mapContractStatus(String studentStatus, dynamic daysToExpire) {
    if (studentStatus == 'Active' || studentStatus == 'ContractAboutToExpire') {
      return ContractStatus.active;
    }
    if (studentStatus == 'Expired') return ContractStatus.expired;
    return ContractStatus.none;
  }

  ServiceType _mapServiceType(Map<String, dynamic> serviceJson) {
    // Backend services have translations map
    final translations =
        serviceJson['translations'] as Map<String, dynamic>? ?? {};
    final en = translations['en'] as Map<String, dynamic>?;
    final name = (en?['name'] as String? ?? '').toLowerCase();
    return ServiceType.fromCode(name);
  }

  // ═════════════════════════════════════════════
  //  PARSE HELPERS
  // ═════════════════════════════════════════════

  DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  DateTime? _parseNullableDate(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  DateTime _parseDateTime(dynamic v) => _parseDate(v);

  TimeOfDay _parseTimeOfDay(dynamic v) {
    if (v == null) return const TimeOfDay(hour: 8, minute: 0);
    if (v is String) {
      final parts = v.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

  int _calcHours(dynamic startStr, dynamic endStr) {
    final start = _parseTimeOfDay(startStr);
    final end = _parseTimeOfDay(endStr);
    final diff = (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
    return diff > 0 ? (diff / 60).ceil() : 1;
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  String _extractFacultyName(dynamic faculty) {
    if (faculty == null) return '';
    if (faculty is Map<String, dynamic>) {
      final translations =
          faculty['translations'] as Map<String, dynamic>? ?? {};
      final hr = translations['hr'] as Map<String, dynamic>?;
      return hr?['name'] as String? ?? '';
    }
    return '';
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final body = e.response!.data as Map<String, dynamic>;
      return body['message'] as String? ??
          body['title'] as String? ??
          'Greška na serveru';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Server ne odgovara. Provjerite je li backend pokrenut.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Nije moguće spojiti se na server (localhost:5142).';
    }
    return 'Greška: ${e.message ?? "nepoznata"}';
  }
}
