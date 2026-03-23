import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  factory ApiResult.fail(String msg) => ApiResult._(success: false, error: msg);
}

/// Central service for all admin API calls.
/// Converts backend DTOs ↔ frontend models.
class AdminApiService {
  final ApiClient _api;

  AdminApiService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  // Cached pricing config
  static double _cachedHourlyRate = 7.40;
  static double _cachedSundayRate = 11.10;
  static bool _pricingLoaded = false;

  Future<void> _ensurePricingLoaded() async {
    if (_pricingLoaded) return;
    try {
      final response = await _api.get(ApiEndpoints.pricingConfigurations);
      final list = response.data as List<dynamic>;
      if (list.isNotEmpty) {
        final cfg = list.first as Map<String, dynamic>;
        _cachedHourlyRate = (cfg['jobHourlyRate'] as num?)?.toDouble() ?? 7.40;
        _cachedSundayRate =
            (cfg['sundayHourlyRate'] as num?)?.toDouble() ?? 11.10;
      }
      _pricingLoaded = true;
    } catch (_) {
      // keep defaults
    }
  }

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
      await _ensurePricingLoaded();
      final list = (response.data as List<dynamic>)
          .map((e) => _mapStudent(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    } catch (e) {
      return ApiResult.fail('getStudents mapper: $e');
    }
  }

  Future<ApiResult<StudentModel>> getStudent(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.studentById(id));
      return ApiResult.ok(_mapStudent(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  SENIORS (backend: Customers → Seniors)
  // ─────────────────────────────────────────────

  Future<ApiResult<List<SeniorModel>>> getSeniors({String? searchText}) async {
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
    } catch (e) {
      return ApiResult.fail('getSeniors mapper: $e');
    }
  }

  Future<ApiResult<SeniorModel>> getSenior(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.seniorById(id));
      return ApiResult.ok(_mapSenior(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  ORDERS
  // ─────────────────────────────────────────────

  Future<ApiResult<List<OrderModel>>> getOrders({String? status}) async {
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
    } catch (e) {
      return ApiResult.fail('getOrders mapper: $e');
    }
  }

  Future<ApiResult<OrderModel>> getOrder(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.orderById(id));
      return ApiResult.ok(_mapOrder(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<OrderModel>>> getOrdersBySenior(int seniorId) async {
    try {
      final response = await _api.get(
        '${ApiEndpoints.orders}/senior/$seniorId',
      );
      final list = (response.data as List<dynamic>)
          .map((e) => _mapOrder(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<OrderModel>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final response = await _api.post(ApiEndpoints.orders, data: orderData);
      return ApiResult.ok(_mapOrder(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<OrderModel>> updateOrder(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _api.put(ApiEndpoints.orderById(id), data: data);
      return ApiResult.ok(_mapOrder(response.data as Map<String, dynamic>));
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

  /// Update order promo code. Pass null to remove promo code.
  Future<ApiResult<void>> updateOrderPromoCode(
    int orderId,
    String? promoCode,
  ) async {
    try {
      // PromoCodeId: 0 = remove, positive = set/change, null = no change
      // Since we're using the general PUT endpoint, we pass promoCodeId
      // We need to look up the promo code ID from the code string
      // For removal (null), we send 0
      final int promoCodeId = promoCode == null || promoCode.isEmpty ? 0 : -1;
      // TODO: If setting a promo code, need to validate/look it up first
      // For now, this method only supports REMOVAL (promoCode = null)
      await _api.put(
        ApiEndpoints.orderById(orderId),
        data: {'promoCodeId': promoCodeId},
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
    int studentId,
  ) async {
    try {
      final response = await _api.get(
        '${ApiEndpoints.sessions}/student/$studentId',
      );
      final list = (response.data as List<dynamic>)
          .map((e) => _mapSession(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<SessionModel>>> getSessionsBySenior(
    int seniorId,
  ) async {
    try {
      final response = await _api.get(
        '${ApiEndpoints.sessions}/completed/senior/$seniorId',
      );
      final list = (response.data as List<dynamic>)
          .map((e) => _mapSession(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<SessionModel>>> getSessionsByOrder(int orderId) async {
    try {
      final response = await _api.get(ApiEndpoints.sessionsByOrder(orderId));
      final list = (response.data as List<dynamic>)
          .map((e) => _mapSession(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<void>> cancelSession(int sessionId) async {
    try {
      await _api.post(ApiEndpoints.cancelSession(sessionId));
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<void>> reactivateSession(int sessionId) async {
    try {
      await _api.post(ApiEndpoints.reactivateSession(sessionId));
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  /// Reschedule/manage a session (change date, time, or student).
  Future<ApiResult<void>> manageSession(
    int sessionId, {
    DateTime? newDate,
    TimeOfDay? newStartTime,
    TimeOfDay? newEndTime,
    int? preferredStudentId,
    String reason = 'Rescheduled by admin',
  }) async {
    try {
      final data = <String, dynamic>{
        'reason': reason,
        'reassignStudent': preferredStudentId != null,
        'requestedByUserId': 1, // Admin default
      };
      if (newDate != null) {
        data['newDate'] =
            '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}';
      }
      if (newStartTime != null) {
        data['newStartTime'] =
            '${newStartTime.hour.toString().padLeft(2, '0')}:${newStartTime.minute.toString().padLeft(2, '0')}:00';
      }
      if (newEndTime != null) {
        data['newEndTime'] =
            '${newEndTime.hour.toString().padLeft(2, '0')}:${newEndTime.minute.toString().padLeft(2, '0')}:00';
      }
      if (preferredStudentId != null) {
        data['preferredStudentId'] = preferredStudentId;
      }
      await _api.post(ApiEndpoints.manageSession(sessionId), data: data);
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  REVIEWS
  // ─────────────────────────────────────────────

  Future<ApiResult<List<ReviewModel>>> getReviewsByStudent(
    int studentId,
  ) async {
    try {
      final response = await _api.get(ApiEndpoints.reviewsByStudent(studentId));
      final list = (response.data as List<dynamic>)
          .map((e) => _mapReview(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<ReviewModel>>> getReviewsBySenior(int seniorId) async {
    try {
      final response = await _api.get(ApiEndpoints.reviewsBySenior(seniorId));
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
    int userId,
  ) async {
    try {
      final response = await _api.get(ApiEndpoints.suspensionStatus(userId));
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
  //  ARCHIVE CHECK & ARCHIVE
  // ─────────────────────────────────────────────

  Future<ApiResult<ArchiveCheckResult>> getStudentArchiveCheck(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.studentArchiveCheck(id));
      return ApiResult.ok(
        ArchiveCheckResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<ArchiveResult>> archiveStudent(
    int id, {
    bool force = false,
    String? reason,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.studentArchive(id),
        data: {'force': force, 'reason': reason},
      );
      return ApiResult.ok(
        ArchiveResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<ArchiveResult>> unarchiveStudent(int id) async {
    try {
      final response = await _api.post(ApiEndpoints.studentUnarchive(id));
      return ApiResult.ok(
        ArchiveResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<ArchiveCheckResult>> getSeniorArchiveCheck(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.seniorArchiveCheck(id));
      return ApiResult.ok(
        ArchiveCheckResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<ArchiveResult>> archiveSenior(
    int id, {
    bool force = false,
    String? reason,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.seniorArchive(id),
        data: {'force': force, 'reason': reason},
      );
      return ApiResult.ok(
        ArchiveResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<ArchiveResult>> unarchiveSenior(int id) async {
    try {
      final response = await _api.post('${ApiEndpoints.seniors}/$id/unarchive');
      return ApiResult.ok(
        ArchiveResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<ArchiveCheckResult>> getOrderArchiveCheck(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.orderArchiveCheck(id));
      return ApiResult.ok(
        ArchiveCheckResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<ArchiveResult>> archiveOrder(
    int id, {
    bool force = false,
    String? reason,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.orderArchive(id),
        data: {'force': force, 'reason': reason},
      );
      return ApiResult.ok(
        ArchiveResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<ArchiveResult>> unarchiveOrder(int id) async {
    try {
      final response = await _api.post('${ApiEndpoints.orders}/$id/unarchive');
      return ApiResult.ok(
        ArchiveResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<ArchiveCheckResult>> getContractDeleteCheck(int id) async {
    try {
      final response = await _api.get(ApiEndpoints.contractDeleteCheck(id));
      return ApiResult.ok(
        ArchiveCheckResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<ArchiveResult>> deleteContractWithCheck(
    int id, {
    bool force = false,
    String? reason,
  }) async {
    try {
      final response = await _api.delete(
        ApiEndpoints.contractDeleteWithCheck(id),
        data: {'force': force, 'reason': reason},
      );
      return ApiResult.ok(
        ArchiveResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  SCHEDULE ASSIGNMENTS
  // ─────────────────────────────────────────────

  Future<ApiResult<void>> adminAssign(
    int orderScheduleId,
    int studentId,
  ) async {
    try {
      await _api.post(
        ApiEndpoints.adminAssign,
        data: {'orderScheduleId': orderScheduleId, 'studentId': studentId},
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

  Future<ApiResult<List<StudentModel>>> getAvailableStudentsForSchedule(
    int scheduleId,
  ) async {
    try {
      final response = await _api.get(
        '${ApiEndpoints.students}/order-schedules/$scheduleId/available-students',
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

  Future<ApiResult<Map<String, dynamic>>> validatePromoCode(String code) async {
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
    } catch (e) {
      return ApiResult.fail('getReviews mapper: $e');
    }
  }

  Future<ApiResult<List<NotificationModel>>> getNotifications(
    int userId,
  ) async {
    try {
      final response = await _api.get(ApiEndpoints.notificationsByUser(userId));
      final list = (response.data as List<dynamic>)
          .map((e) => _mapNotification(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    } catch (e) {
      return ApiResult.fail('getNotifications mapper: $e');
    }
  }

  Future<ApiResult<void>> markNotificationRead(int notificationId) async {
    try {
      await _api.put(ApiEndpoints.notificationMarkRead(notificationId));
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<void>> markAllNotificationsRead(int userId) async {
    try {
      await _api.put(ApiEndpoints.notificationMarkAllRead(userId));
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  CONTACT INFO
  // ─────────────────────────────────────────────

  Future<ApiResult<int>> createContactInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String streetAddress,
    required int gender,
    required String dateOfBirth,
    int? cityId,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.contactInfos,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'streetAddress': streetAddress,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'cityId': ?cityId,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResult.ok(data['id'] as int);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<void>> updateContactInfo({
    required int contactId,
    required String fullName,
    required String email,
    required String phone,
    required String fullAddress,
    required int gender,
    required String dateOfBirth,
  }) async {
    try {
      await _api.put(
        '${ApiEndpoints.contactInfos}/$contactId',
        data: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'fullAddress': fullAddress,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'googlePlaceId': 'admin-manual-entry',
          'languageCode': 'hr',
          'country': 'Croatia',
          'cityId': 1, // Default city, backend should handle null
        },
      );
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  CUSTOMERS (orderers / naručitelji)
  // ─────────────────────────────────────────────

  Future<ApiResult<int>> createCustomer({required int contactId}) async {
    try {
      final response = await _api.post(
        ApiEndpoints.customers,
        data: {'contactId': contactId, 'preferredNotificationMethod': 0},
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResult.ok(data['userId'] as int? ?? data['id'] as int);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  SENIOR CREATE (backend entity)
  // ─────────────────────────────────────────────

  Future<ApiResult<int>> createSeniorBackend({
    required int customerId,
    required int contactId,
    required int relationship,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.seniors,
        data: {
          'customerId': customerId,
          'contactId': contactId,
          'relationship': relationship,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResult.ok(data['id'] as int);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  REGISTER CUSTOMER (creates User+Customer+Senior)
  // ─────────────────────────────────────────────

  Future<ApiResult<void>> registerCustomer({
    required String email,
    required String password,
    required int relationship,
    required Map<String, dynamic> contactInfo,
    Map<String, dynamic>? seniorContactInfo,
  }) async {
    try {
      final data = <String, dynamic>{
        'email': email,
        'password': password,
        'userType': 2, // Customer
        'relationship': relationship,
        'preferredNotificationMethod': 0,
        'contactInfo': contactInfo,
        'seniorContactInfo': ?seniorContactInfo,
      };
      await _api.post(ApiEndpoints.registerCustomer, data: data);
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  STUDENT CONTRACTS
  // ─────────────────────────────────────────────

  Future<ApiResult<void>> uploadContract({
    required int studentId,
    required Uint8List fileBytes,
    required String fileName,
    required String effectiveDate,
    required String expirationDate,
  }) async {
    try {
      final formData = FormData.fromMap({
        'StudentId': studentId,
        'EffectiveDate': effectiveDate,
        'ExpirationDate': expirationDate,
        'ContractFile': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });
      await _api.post(ApiEndpoints.studentContracts, data: formData);
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getStudentContracts(
    int studentId,
  ) async {
    try {
      final response = await _api.get(
        ApiEndpoints.contractsByStudent(studentId),
      );
      final list = (response.data as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<void>> deleteContract(int contractId) async {
    try {
      await _api.delete('${ApiEndpoints.studentContracts}/$contractId');
      return const ApiResult._(success: true);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  // ─────────────────────────────────────────────
  //  STUDENT AVAILABILITY
  // ─────────────────────────────────────────────

  Future<ApiResult<Set<int>>> getStudentServiceIds(int studentId) async {
    try {
      final response = await _api.get(
        ApiEndpoints.servicesByStudent(studentId),
      );
      final ids = (response.data as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>)['serviceId'] as int)
          .toSet();
      return ApiResult.ok(ids);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  Future<ApiResult<List<DayAvailability>>> getStudentAvailability(
    int studentId,
  ) async {
    try {
      final response = await _api.get(
        ApiEndpoints.availabilityByStudent(studentId),
      );
      final list = (response.data as List<dynamic>)
          .map((e) => _mapAvailabilitySlot(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  DayAvailability _mapAvailabilitySlot(Map<String, dynamic> json) {
    final dayOfWeek = json['dayOfWeek'] as int? ?? 1;
    final start = _parseTimeOnly(json['startTime']);
    final end = _parseTimeOnly(json['endTime']);
    return DayAvailability(
      dayOfWeek: dayOfWeek,
      isEnabled: true,
      from: start,
      to: end,
    );
  }

  TimeOfDay _parseTimeOnly(dynamic value) {
    if (value is String && value.isNotEmpty) {
      final parts = value.split(':');
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      );
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  // ─────────────────────────────────────────────
  //  BACKEND SERVICES (for serviceId lookup)
  // ─────────────────────────────────────────────

  static List<Map<String, dynamic>>? _cachedServices;

  Future<ApiResult<List<Map<String, dynamic>>>> getBackendServices() async {
    if (_cachedServices != null) return ApiResult.ok(_cachedServices!);
    try {
      final response = await _api.get(ApiEndpoints.services);
      final list = (response.data as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      _cachedServices = list;
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  /// Maps a frontend [ServiceType] to a backend service ID.
  /// Matches mobile app _serviceKeyToId mapping.
  static const _serviceTypeToId = <ServiceType, int>{
    ServiceType.companionship: 1,
    ServiceType.walking: 4,
    ServiceType.shopping: 11,
    ServiceType.houseHelp: 21,
    ServiceType.escort: 31,
    ServiceType.other: 41,
  };

  Future<int?> serviceTypeToId(ServiceType type) async {
    return _serviceTypeToId[type];
  }

  // ═════════════════════════════════════════════
  //  ADMIN NOTES
  // ═════════════════════════════════════════════

  /// Fetches admin notes for a specific entity (Senior, Student, Order).
  Future<ApiResult<List<Map<String, dynamic>>>> getAdminNotes(
    String entityType,
    int entityId,
  ) async {
    try {
      final response = await _api.get(
        ApiEndpoints.adminNotes(entityType, entityId),
      );
      final list = (response.data as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      return ApiResult.ok(list);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  /// Creates a new admin note for an entity.
  Future<ApiResult<Map<String, dynamic>>> createAdminNote({
    required String entityType,
    required int entityId,
    required String text,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.adminNotes(entityType, entityId),
        data: {'entityType': entityType, 'entityId': entityId, 'text': text},
      );
      return ApiResult.ok(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  /// Updates an existing admin note.
  Future<ApiResult<Map<String, dynamic>>> updateAdminNote({
    required int id,
    required String text,
  }) async {
    try {
      final response = await _api.put(
        ApiEndpoints.adminNoteById(id),
        data: {'text': text},
      );
      return ApiResult.ok(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResult.fail(_extractError(e));
    }
  }

  /// Deletes an admin note.
  Future<ApiResult<void>> deleteAdminNote(int id) async {
    try {
      await _api.delete(ApiEndpoints.adminNoteById(id));
      return ApiResult.ok(null);
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
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final statusStr = _studentStatusStr(json['status']);

    // Parse availability slots from backend
    final rawSlots = json['availabilitySlots'] as List<dynamic>? ?? [];
    final availability = rawSlots.map((slot) {
      final s = slot as Map<String, dynamic>;
      return DayAvailability(
        dayOfWeek: (s['dayOfWeek'] as num).toInt(),
        isEnabled: true,
        from: _parseTimeOfDay(s['startTime']),
        to: _parseTimeOfDay(s['endTime']),
      );
    }).toList();

    return StudentModel(
      id: '${json['userId']}',
      firstName: firstName,
      lastName: lastName,
      email: contact?['email'] as String? ?? '',
      phone: contact?['phone'] as String? ?? '',
      address: contact?['fullAddress'] as String? ?? '',
      city: contact?['cityName'] as String? ?? '',
      latitude: (contact?['latitude'] as num?)?.toDouble(),
      longitude: (contact?['longitude'] as num?)?.toDouble(),
      faculty: _extractFacultyName(json['faculty']),
      studentIdNumber: json['studentNumber'] as String? ?? '',
      dateOfBirth: _parseDate(contact?['dateOfBirth']),
      gender: _mapGender(contact?['gender']),
      avgRating: _toDouble(json['averageRating']),
      totalReviews: json['totalReviews'] as int? ?? 0,
      completedJobs: 0, // calculated from sessions if needed
      cancelledJobs: 0,
      isVerified: statusStr == 'Active',
      isActive:
          statusStr != 'AccountDeactivated' &&
          statusStr != 'PendingPermanentDeletion' &&
          statusStr != 'Deleted',
      isArchived:
          statusStr == 'PendingPermanentDeletion' || statusStr == 'Deleted',
      isSuspended: json['isSuspended'] as bool? ?? false,
      suspensionReason: json['suspensionReason'] as String?,
      createdAt: _parseDateTime(json['dateRegistered']),
      contractStatus: _mapContractStatus(
        statusStr,
        json['daysToContractExpire'],
      ),
      contractStartDate: null,
      contractExpiryDate: json['daysToContractExpire'] != null
          ? DateTime.now().add(
              Duration(days: (json['daysToContractExpire'] as num).toInt()),
            )
          : null,
      hourlyRate: _cachedHourlyRate,
      sundayHourlyRate: _cachedSundayRate,
      availability: availability,
    );
  }

  SeniorModel _mapSenior(Map<String, dynamic> json) {
    final contact = json['contact'] as Map<String, dynamic>?;
    final fullName = contact?['fullName'] as String? ?? '';
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // Parse orderer contact if present (when Relationship != Self)
    final ordererContact = json['ordererContact'] as Map<String, dynamic>?;
    String? ordererFirstName;
    String? ordererLastName;
    if (ordererContact != null) {
      final ordererFullName = ordererContact['fullName'] as String? ?? '';
      final ordererNameParts = ordererFullName.split(' ');
      ordererFirstName = ordererNameParts.isNotEmpty
          ? ordererNameParts.first
          : null;
      ordererLastName = ordererNameParts.length > 1
          ? ordererNameParts.sublist(1).join(' ')
          : null;
    }

    return SeniorModel(
      id: '${json['id']}',
      userId: json['customerId'] as int?,
      contactId: contact?['id'] as int?,
      ordererContactId: ordererContact?['id'] as int?,
      firstName: firstName,
      lastName: lastName,
      email: contact?['email'] as String? ?? '',
      phone: contact?['phone'] as String? ?? '',
      address: contact?['fullAddress'] as String? ?? '',
      city: contact?['cityName'] as String? ?? '',
      latitude: (contact?['latitude'] as num?)?.toDouble(),
      longitude: (contact?['longitude'] as num?)?.toDouble(),
      gender: _mapGender(contact?['gender']),
      dateOfBirth: _parseDate(contact?['dateOfBirth']),
      createdAt: _parseDateTime(contact?['createdAt']),
      isActive: json['deletedAt'] == null,
      isArchived: json['deletedAt'] != null,
      isSuspended: json['isSuspended'] as bool? ?? false,
      suspensionReason: json['suspensionReason'] as String?,
      creditCards: const [],
      // Orderer data from ordererContact
      ordererFirstName: ordererFirstName,
      ordererLastName: ordererLastName,
      ordererEmail: ordererContact?['email'] as String?,
      ordererPhone: ordererContact?['phone'] as String?,
      ordererAddress: ordererContact?['fullAddress'] as String?,
      ordererGender: ordererContact != null
          ? _mapGender(ordererContact['gender'])
          : null,
      ordererDateOfBirth: ordererContact != null
          ? _parseNullableDate(ordererContact['dateOfBirth'])
          : null,
    );
  }

  OrderModel _mapOrder(Map<String, dynamic> json) {
    final schedules = (json['schedules'] as List<dynamic>? ?? [])
        .map((s) => s as Map<String, dynamic>)
        .toList();
    final services = (json['services'] as List<dynamic>? ?? [])
        .map((s) => _mapServiceType(s as Map<String, dynamic>))
        .toList();

    // Extract schedule IDs for admin-assign
    final scheduleIds = schedules
        .map((s) => s['id'] as int? ?? 0)
        .where((id) => id > 0)
        .toList();

    // Build day entries from schedules
    final dayEntries = schedules
        .map(
          (s) => DayEntry(
            dayOfWeek: s['dayOfWeek'] as int? ?? 1,
            startTime: _parseTimeOfDay(s['startTime']),
            durationHours: _calcHours(s['startTime'], s['endTime']),
          ),
        )
        .toList();

    // Determine first schedule for scheduledStart
    final firstSchedule = schedules.isNotEmpty
        ? schedules.first
        : <String, dynamic>{};

    // Build assigned student (if any) from backend fields
    final assignedStudentName = json['assignedStudentName'] as String?;
    final assignedStudentId = json['assignedStudentId'] as int?;
    StudentModel? assignedStudent;
    if (assignedStudentName != null && assignedStudentId != null) {
      final nameParts = assignedStudentName.split(' ');
      final statusStr = _studentStatusStr(json['assignedStudentStatus']);
      assignedStudent = StudentModel(
        id: '$assignedStudentId',
        firstName: nameParts.isNotEmpty ? nameParts.first : '',
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        email: json['assignedStudentEmail'] as String? ?? '',
        phone: json['assignedStudentPhone'] as String? ?? '',
        address: json['assignedStudentAddress'] as String? ?? '',
        city: json['assignedStudentCity'] as String? ?? '',
        faculty: '',
        studentIdNumber: json['assignedStudentNumber'] as String? ?? '',
        dateOfBirth:
            _parseNullableDate(json['assignedStudentDateOfBirth']) ??
            DateTime(2000),
        gender: _mapGender(json['assignedStudentGender']),
        avgRating: _toDouble(json['assignedStudentAverageRating']),
        totalReviews: json['assignedStudentTotalReviews'] as int? ?? 0,
        isVerified: statusStr == 'Active',
        isActive:
            statusStr != 'AccountDeactivated' &&
            statusStr != 'PendingPermanentDeletion' &&
            statusStr != 'Deleted',
        isArchived:
            statusStr == 'PendingPermanentDeletion' || statusStr == 'Deleted',
        createdAt: DateTime.now(),
        contractStatus: _mapContractStatus(
          statusStr,
          json['assignedStudentDaysToContractExpire'],
        ),
        contractExpiryDate: json['assignedStudentDaysToContractExpire'] != null
            ? DateTime.now().add(
                Duration(
                  days: (json['assignedStudentDaysToContractExpire'] as num)
                      .toInt(),
                ),
              )
            : null,
        hourlyRate: _cachedHourlyRate,
        sundayHourlyRate: _cachedSundayRate,
      );
    }

    return OrderModel(
      id: '${json['id']}',
      orderNumber: json['id'].toString().padLeft(4, '0'),
      senior: _mapOrderSenior(json),
      student: assignedStudent,
      status: _mapOrderStatus(json['status']),
      frequency: (json['isRecurring'] == true)
          ? FrequencyType.recurring
          : FrequencyType.oneTime,
      services: services,
      createdAt: _parseDateTime(json['createdAt']),
      scheduledDate: _parseDate(json['startDate']),
      scheduledStart: _parseTimeOfDay(firstSchedule['startTime']),
      durationHours: _calcHours(
        firstSchedule['startTime'],
        firstSchedule['endTime'],
      ),
      notes: json['notes'] as String?,
      address: json['seniorAddress'] as String? ?? '',
      endDate: _parseNullableDate(json['endDate']),
      dayEntries: dayEntries,
      sessions: const [],
      scheduleIds: scheduleIds,
    );
  }

  SeniorModel _mapOrderSenior(Map<String, dynamic> orderJson) {
    final senior = orderJson['senior'] as Map<String, dynamic>?;
    if (senior != null) return _mapSenior(senior);

    // Fallback using flattened fields from OrderDto
    final fullName = orderJson['seniorName'] as String? ?? '';
    final nameParts = fullName.split(' ');
    return SeniorModel(
      id: '${orderJson['seniorId']}',
      firstName: nameParts.isNotEmpty ? nameParts.first : '',
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      email: orderJson['seniorEmail'] as String? ?? '',
      phone: orderJson['seniorPhone'] as String? ?? '',
      address: orderJson['seniorAddress'] as String? ?? '',
      latitude: (orderJson['seniorLatitude'] as num?)?.toDouble(),
      longitude: (orderJson['seniorLongitude'] as num?)?.toDouble(),
      gender: Gender.male,
      dateOfBirth: DateTime(1900),
      createdAt: _parseDateTime(orderJson['createdAt']),
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
      durationHours: _calcHours(json['startTime'], json['endTime']),
      studentName: studentContact?['fullName'] as String?,
      status: _mapSessionStatus(json['status']),
      isModified: json['isRescheduleVariant'] == true,
    );
  }

  ReviewModel _mapReview(Map<String, dynamic> json) {
    return ReviewModel(
      id: '${json['id']}',
      sessionId: json['jobInstanceId'] != null
          ? '${json['jobInstanceId']}'
          : null,
      studentId: json['studentId'] != null ? '${json['studentId']}' : null,
      seniorId: json['seniorId'] != null ? '${json['seniorId']}' : null,
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
      type: _mapNotificationType(json['type']),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  NotificationType _mapNotificationType(dynamic value) {
    if (value is int && value >= 0 && value < NotificationType.values.length) {
      return NotificationType.values[value];
    }
    return NotificationType.general;
  }

  // ═════════════════════════════════════════════
  //  ENUM MAPPERS
  // ═════════════════════════════════════════════

  OrderStatus _mapOrderStatus(dynamic s) {
    if (s is int) {
      return switch (s) {
        0 => OrderStatus.processing, // InActive
        1 => OrderStatus.processing, // Pending
        2 => OrderStatus.active, // FullAssigned
        3 => OrderStatus.completed,
        4 => OrderStatus.cancelled,
        _ => OrderStatus.processing,
      };
    }
    return switch ('$s') {
      'InActive' || 'Pending' => OrderStatus.processing,
      'FullAssigned' => OrderStatus.active,
      'Completed' => OrderStatus.completed,
      'Cancelled' => OrderStatus.cancelled,
      _ => OrderStatus.processing,
    };
  }

  SessionStatus _mapSessionStatus(dynamic s) {
    if (s is int) {
      return switch (s) {
        0 => SessionStatus.scheduled, // Upcoming
        1 => SessionStatus.scheduled, // InProgress
        2 => SessionStatus.completed,
        3 || 4 => SessionStatus.cancelled,
        _ => SessionStatus.scheduled,
      };
    }
    return switch ('$s') {
      'Upcoming' || 'InProgress' => SessionStatus.scheduled,
      'Completed' => SessionStatus.completed,
      'Cancelled' || 'Rescheduled' => SessionStatus.cancelled,
      _ => SessionStatus.scheduled,
    };
  }

  /// Convert backend StudentStatus (int or string) to string label.
  String _studentStatusStr(dynamic s) {
    if (s is int) {
      return const [
            'InActive',
            'Active',
            'ContractAboutToExpire',
            'Expired',
            'AccountDeactivated',
            'PendingPermanentDeletion',
            'Deleted',
          ].elementAtOrNull(s) ??
          'Active';
    }
    return '$s';
  }

  Gender _mapGender(dynamic g) {
    if (g is String) {
      return g == 'Male' ? Gender.male : Gender.female;
    }
    if (g is int) {
      return g == 0 ? Gender.male : Gender.female;
    }
    return Gender.female;
  }

  ContractStatus _mapContractStatus(
    String studentStatus,
    dynamic daysToExpire,
  ) {
    if (studentStatus == 'Active' || studentStatus == 'ContractAboutToExpire') {
      return ContractStatus.active;
    }
    if (studentStatus == 'Expired') return ContractStatus.expired;
    return ContractStatus.none;
  }

  // Backend ServiceId → frontend ServiceType
  // Matches mobile app _serviceKeyToId mapping
  static const _serviceIdToType = <int, ServiceType>{
    1: ServiceType.companionship,
    4: ServiceType.walking,
    11: ServiceType.shopping,
    21: ServiceType.houseHelp,
    31: ServiceType.escort,
    41: ServiceType.other,
  };

  ServiceType _mapServiceType(Map<String, dynamic> serviceJson) {
    final id = serviceJson['id'] as int? ?? 0;
    return _serviceIdToType[id] ?? ServiceType.other;
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
    final diff =
        (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
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
