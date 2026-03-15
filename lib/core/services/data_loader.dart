import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';

/// Loads data from the backend API into [MockData] static lists.
///
/// Call [loadAll] after successful login. If the backend is unreachable
/// the existing mock data is kept as a fallback so the UI remains usable
/// during development.
class DataLoader {
  DataLoader._();

  static bool _loaded = false;
  static bool get isLoaded => _loaded;

  /// Fetch students, seniors, orders, reviews and notifications
  /// from the API **in parallel** and replace [MockData] contents.
  ///
  /// The entire operation is capped at [_timeout] so the UI never
  /// hangs when the backend is unreachable — mock data stays as fallback.
  static const _timeout = Duration(seconds: 8);

  static Future<bool> loadAll() async {
    try {
      return await _doLoad().timeout(_timeout);
    } on TimeoutException {
      debugPrint('[DataLoader] loadAll TIMEOUT — using mock data');
      return false;
    } catch (e) {
      debugPrint('[DataLoader] loadAll ERROR: $e — using mock data');
      return false;
    }
  }

  static Future<bool> _doLoad() async {
    final api = AdminApiService();
    var allOk = true;

    // Fire all requests in parallel
    final results = await Future.wait([
      api.getStudents(),   // 0
      api.getSeniors(),    // 1
      api.getOrders(),     // 2
      api.getReviews(),    // 3
      api.getNotifications(), // 4
    ]);

    final studentsResult = results[0] as ApiResult<List<StudentModel>>;
    final seniorsResult = results[1] as ApiResult<List<SeniorModel>>;
    final ordersResult = results[2] as ApiResult<List<OrderModel>>;
    final reviewsResult = results[3] as ApiResult<List<ReviewModel>>;
    final notifResult = results[4] as ApiResult<List<NotificationModel>>;

    if (studentsResult.success && studentsResult.data != null) {
      MockData.students
        ..clear()
        ..addAll(studentsResult.data!);
    } else {
      debugPrint('[DataLoader] students failed: ${studentsResult.error}');
      allOk = false;
    }

    if (seniorsResult.success && seniorsResult.data != null) {
      MockData.seniors
        ..clear()
        ..addAll(seniorsResult.data!);
    } else {
      debugPrint('[DataLoader] seniors failed: ${seniorsResult.error}');
      allOk = false;
    }

    if (ordersResult.success && ordersResult.data != null) {
      MockData.orders
        ..clear()
        ..addAll(ordersResult.data!);
    } else {
      debugPrint('[DataLoader] orders failed: ${ordersResult.error}');
      allOk = false;
    }

    if (reviewsResult.success && reviewsResult.data != null) {
      MockData.reviews
        ..clear()
        ..addAll(reviewsResult.data!);
    } else {
      debugPrint('[DataLoader] reviews failed: ${reviewsResult.error}');
      allOk = false;
    }

    if (notifResult.success && notifResult.data != null) {
      MockData.notifications
        ..clear()
        ..addAll(notifResult.data!);
    } else {
      debugPrint('[DataLoader] notifications failed: ${notifResult.error}');
      allOk = false;
    }

    _loaded = allOk;
    debugPrint(
      '[DataLoader] loadAll completed — '
      'students=${MockData.students.length}, '
      'seniors=${MockData.seniors.length}, '
      'orders=${MockData.orders.length}, '
      'reviews=${MockData.reviews.length}, '
      'notifications=${MockData.notifications.length}, '
      'allOk=$allOk',
    );
    return allOk;
  }

  /// Reset loaded flag (e.g. on logout).
  static void reset() {
    _loaded = false;
  }
}
