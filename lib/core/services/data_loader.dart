import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/network/api_client.dart';
import 'package:helpi_admin/core/network/api_endpoints.dart';
import 'package:helpi_admin/core/network/token_storage.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';

/// Loads data from the backend API into Riverpod providers (and [AppData]
/// for backward compatibility).
///
/// Call [loadAll] after successful login. If the backend is unreachable
/// the existing mock data is kept as a fallback so the UI remains usable
/// during development.
class DataLoader {
  DataLoader._();

  static bool _loaded = false;
  static bool get isLoaded => _loaded;

  /// Fetch students, seniors, orders, reviews and notifications
  /// from the API **in parallel** and replace provider + [AppData] contents.
  ///
  /// The entire operation is capped at [_timeout] so the UI never
  /// hangs when the backend is unreachable — mock data stays as fallback.
  static const _timeout = Duration(seconds: 8);

  /// Pass [ref] to populate Riverpod providers reactively.
  /// Without ref, only [AppData] static lists are populated (legacy path).
  static Future<bool> loadAll({WidgetRef? ref}) async {
    try {
      return await _doLoad(ref: ref).timeout(_timeout);
    } on TimeoutException {
      debugPrint('[DataLoader] loadAll TIMEOUT — using mock data');
      return false;
    } catch (e) {
      debugPrint('[DataLoader] loadAll ERROR: $e — using mock data');
      return false;
    }
  }

  static Future<bool> _doLoad({WidgetRef? ref}) async {
    final api = AdminApiService();
    final userId = await TokenStorage().getUserId() ?? 0;
    var allOk = true;

    // Fire all requests in parallel.
    // Sessions (JobInstances) are NOT loaded here — order_detail_screen fetches
    // them on-demand with a month filter, preventing "all sessions" from loading.
    final results = await Future.wait([
      api.getStudents(), // 0
      api.getSeniors(), // 1
      api.getOrders(), // 2
      api.getReviews(), // 3
      api.getNotifications(userId), // 4
    ]);

    final studentsResult = results[0] as ApiResult<List<StudentModel>>;
    final seniorsResult = results[1] as ApiResult<List<SeniorModel>>;
    final ordersResult = results[2] as ApiResult<List<OrderModel>>;
    final reviewsResult = results[3] as ApiResult<List<ReviewModel>>;
    final notifResult = results[4] as ApiResult<List<NotificationModel>>;

    if (studentsResult.success && studentsResult.data != null) {
      AppData.students
        ..clear()
        ..addAll(studentsResult.data!);
    } else {
      debugPrint('[DataLoader] students failed: ${studentsResult.error}');
      allOk = false;
    }

    if (seniorsResult.success && seniorsResult.data != null) {
      AppData.seniors
        ..clear()
        ..addAll(seniorsResult.data!);
    } else {
      debugPrint('[DataLoader] seniors failed: ${seniorsResult.error}');
      allOk = false;
    }

    if (ordersResult.success && ordersResult.data != null) {
      AppData.orders
        ..clear()
        ..addAll(ordersResult.data!);
    } else {
      debugPrint('[DataLoader] orders failed: ${ordersResult.error}');
      allOk = false;
    }

    if (reviewsResult.success && reviewsResult.data != null) {
      AppData.reviews
        ..clear()
        ..addAll(reviewsResult.data!);
    } else {
      debugPrint('[DataLoader] reviews failed: ${reviewsResult.error}');
      allOk = false;
    }

    if (notifResult.success && notifResult.data != null) {
      // Merge: keep any SignalR-prepended notifications that the backend
      // hasn't returned yet (race condition on quick successive calls).
      final freshIds = notifResult.data!.map((n) => n.id).toSet();
      final signalROnly = AppData.notifications
          .where((n) => !freshIds.contains(n.id))
          .toList();
      // Filter out locally-deleted IDs so rapid deletes don't get restored
      // when the backend fetch races ahead of the DELETE API call.
      final deleted = AppData.deletedNotificationIds;
      AppData.notifications
        ..clear()
        ..addAll(signalROnly.where((n) => !deleted.contains(n.id)))
        ..addAll(notifResult.data!.where((n) => !deleted.contains(n.id)));
      // Sort newest first
      AppData.notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      debugPrint('[DataLoader] notifications failed: ${notifResult.error}');
      allOk = false;
    }

    // Load pending acceptance assignments
    List<Map<String, dynamic>> pendingList = [];
    try {
      final pendingResp = await ApiClient().get(ApiEndpoints.adminPending);
      pendingList = (pendingResp.data as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      debugPrint(
        '[DataLoader] pending assignments loaded: ${pendingList.length}',
      );
    } catch (e) {
      debugPrint('[DataLoader] pending assignments failed: $e');
    }

    // Sync Riverpod providers for reactive UI updates
    // Only update each provider if the corresponding API call succeeded —
    // prevents overwriting fresh in-memory data with stale AppData on partial failures.
    if (ref != null) {
      try {
        if (studentsResult.success && studentsResult.data != null) {
          ref.read(studentsProvider.notifier).setAll(AppData.students);
        }
        if (seniorsResult.success && seniorsResult.data != null) {
          ref.read(seniorsProvider.notifier).setAll(AppData.seniors);
        }
        if (ordersResult.success && ordersResult.data != null) {
          ref.read(ordersProvider.notifier).setAll(AppData.orders);
        }
        if (reviewsResult.success && reviewsResult.data != null) {
          ref.read(reviewsProvider.notifier).setAll(AppData.reviews);
        }
        if (notifResult.success && notifResult.data != null) {
          ref
              .read(notificationsProvider.notifier)
              .setAll(AppData.notifications);
        }

        // Pending acceptance providers
        ref.read(pendingAcceptanceOrderIdsProvider.notifier).state = pendingList
            .map((e) => (e['orderId'] as num).toInt())
            .toSet();
        final dataMap = <int, Map<String, dynamic>>{};
        for (final e in pendingList) {
          final oid = (e['orderId'] as num).toInt();
          dataMap.putIfAbsent(oid, () => e);
        }
        ref.read(pendingAcceptanceDataProvider.notifier).state = dataMap;

        // Chat rooms loaded from API
        await ref.read(adminChatRoomsProvider.notifier).loadRooms();
        await ref.read(unreadMessagesProvider.notifier).refresh();
      } catch (e) {
        debugPrint('[DataLoader] ref.read failed (widget disposed?): $e');
      }
    }

    _loaded = allOk;
    debugPrint(
      '[DataLoader] loadAll completed — '
      'students=${AppData.students.length}, '
      'seniors=${AppData.seniors.length}, '
      'orders=${AppData.orders.length}, '
      'reviews=${AppData.reviews.length}, '
      'notifications=${AppData.notifications.length}, '
      'allOk=$allOk',
    );
    return allOk;
  }

  /// Reset loaded flag (e.g. on logout).
  static void reset() {
    _loaded = false;
  }

  /// Quick check: can we reach the backend at all?
  /// Returns true if any HTTP response comes back (even 401/404).
  static Future<bool> isServerReachable() async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      await dio.get('${ApiEndpoints.baseUrl}/api/students');
      return true;
    } on DioException catch (e) {
      // Any HTTP response (401, 404, 500) = server IS reachable.
      return e.response != null;
    } catch (_) {
      return false;
    }
  }
}
