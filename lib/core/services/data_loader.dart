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

  /// Fetch students, seniors, orders, sessions, reviews and notifications
  /// from the API and replace [MockData] contents.
  ///
  /// Returns `true` when **all** critical lists loaded successfully.
  /// If any individual list fails the error is logged and the
  /// corresponding [MockData] list is left unchanged.
  static Future<bool> loadAll() async {
    final api = AdminApiService();
    var allOk = true;

    // ── Students ──
    final studentsResult = await api.getStudents();
    if (studentsResult.success && studentsResult.data != null) {
      MockData.students
        ..clear()
        ..addAll(studentsResult.data!);
    } else {
      debugPrint('[DataLoader] students failed: ${studentsResult.error}');
      allOk = false;
    }

    // ── Seniors ──
    final seniorsResult = await api.getSeniors();
    if (seniorsResult.success && seniorsResult.data != null) {
      MockData.seniors
        ..clear()
        ..addAll(seniorsResult.data!);
    } else {
      debugPrint('[DataLoader] seniors failed: ${seniorsResult.error}');
      allOk = false;
    }

    // ── Orders ──
    final ordersResult = await api.getOrders();
    if (ordersResult.success && ordersResult.data != null) {
      MockData.orders
        ..clear()
        ..addAll(ordersResult.data!);
    } else {
      debugPrint('[DataLoader] orders failed: ${ordersResult.error}');
      allOk = false;
    }

    // ── Reviews ──
    final reviewsResult = await api.getReviews();
    if (reviewsResult.success && reviewsResult.data != null) {
      MockData.reviews
        ..clear()
        ..addAll(reviewsResult.data!);
    } else {
      debugPrint('[DataLoader] reviews failed: ${reviewsResult.error}');
      allOk = false;
    }

    // ── Notifications ──
    final notifResult = await api.getNotifications();
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
