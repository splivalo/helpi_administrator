import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/network/token_storage.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';

// TODO: Add chatRooms loading once chat backend is implemented

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

    // Fire all requests in parallel
    final results = await Future.wait([
      api.getStudents(), // 0
      api.getSeniors(), // 1
      api.getOrders(), // 2
      api.getReviews(), // 3
      api.getNotifications(userId), // 4
      api.getSessions(), // 5
    ]);

    final studentsResult = results[0] as ApiResult<List<StudentModel>>;
    final seniorsResult = results[1] as ApiResult<List<SeniorModel>>;
    final ordersResult = results[2] as ApiResult<List<OrderModel>>;
    final reviewsResult = results[3] as ApiResult<List<ReviewModel>>;
    final notifResult = results[4] as ApiResult<List<NotificationModel>>;
    final sessionsResult = results[5] as ApiResult<List<SessionModel>>;

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
      AppData.notifications
        ..clear()
        ..addAll(notifResult.data!);
    } else {
      debugPrint('[DataLoader] notifications failed: ${notifResult.error}');
      allOk = false;
    }

    // Merge sessions into orders
    if (sessionsResult.success && sessionsResult.data != null) {
      final sessionsByOrder = <String, List<SessionModel>>{};
      for (final s in sessionsResult.data!) {
        final oid = s.orderId;
        if (oid != null) {
          sessionsByOrder.putIfAbsent(oid, () => []).add(s);
        }
      }
      for (var i = 0; i < AppData.orders.length; i++) {
        final order = AppData.orders[i];
        final orderSessions = sessionsByOrder[order.id];
        if (orderSessions != null && orderSessions.isNotEmpty) {
          AppData.orders[i] = order.copyWith(sessions: orderSessions);
        }
      }
      debugPrint(
        '[DataLoader] sessions merged: ${sessionsResult.data!.length} total, '
        '${sessionsByOrder.length} orders with sessions',
      );
    } else {
      debugPrint('[DataLoader] sessions failed: ${sessionsResult.error}');
      allOk = false;
    }

    // TODO: Chat backend not implemented - using demo data for development
    // In production, chatRooms should be loaded from API like notifications
    _seedDemoDataIfEmpty();

    // Sync Riverpod providers for reactive UI updates
    if (ref != null) {
      ref.read(studentsProvider.notifier).setAll(AppData.students);
      ref.read(seniorsProvider.notifier).setAll(AppData.seniors);
      ref.read(ordersProvider.notifier).setAll(AppData.orders);
      ref.read(reviewsProvider.notifier).setAll(AppData.reviews);
      ref.read(notificationsProvider.notifier).setAll(AppData.notifications);
      ref.read(chatRoomsProvider.notifier).setAll(AppData.chatRooms);
    }

    _loaded = allOk;
    debugPrint(
      '[DataLoader] loadAll completed — '
      'students=${AppData.students.length}, '
      'seniors=${AppData.seniors.length}, '
      'orders=${AppData.orders.length}, '
      'reviews=${AppData.reviews.length}, '
      'notifications=${AppData.notifications.length}, '
      'chatRooms=${AppData.chatRooms.length}, '
      'allOk=$allOk',
    );
    return allOk;
  }

  /// Seeds demo data for development when API returns empty results.
  /// TODO: Remove this method before production - all data should come from backend
  static void _seedDemoDataIfEmpty() {
    // Demo notifications if none from API
    if (AppData.notifications.isEmpty) {
      AppData.notifications.addAll([
        NotificationModel(
          id: 'demo-notif-1',
          type: NotificationType.orderCancelled,
          title: 'Nova narudžba',
          body: 'Senior Marija Horvat je kreirao novu narudžbu #ORD-001',
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          isRead: false,
        ),
        NotificationModel(
          id: 'demo-notif-2',
          type: NotificationType.general,
          title: 'Student dodijeljen',
          body: 'Ana Kovač je dodijeljena narudžbi #ORD-001',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
        ),
        NotificationModel(
          id: 'demo-notif-3',
          type: NotificationType.paymentSuccess,
          title: 'Plaćanje uspješno',
          body: 'Stripe naplata 45.00€ za narudžbu #ORD-002 je uspješna',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true,
        ),
        NotificationModel(
          id: 'demo-notif-4',
          type: NotificationType.contractExpired,
          title: 'Ugovor istječe',
          body: 'Ugovor studenta Ivan Babić istječe za 5 dana',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        NotificationModel(
          id: 'demo-notif-5',
          type: NotificationType.newSeniorAdded,
          title: 'Novi korisnik',
          body: 'Senior Petar Novak se registrirao u sustav',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
      ]);
    }

    // Demo chat rooms if none exist - use real IDs from loaded data
    if (AppData.chatRooms.isEmpty && AppData.seniors.isNotEmpty) {
      final senior1 = AppData.seniors.isNotEmpty ? AppData.seniors[0] : null;
      final senior2 = AppData.seniors.length > 1 ? AppData.seniors[1] : null;
      final student1 = AppData.students.isNotEmpty ? AppData.students[0] : null;

      if (senior1 != null) {
        AppData.chatRooms.add(
          ChatRoom(
            id: 'demo-chat-1',
            participantId: senior1.id,
            participantName: senior1.fullName,
            participantRole: 'senior',
            lastMessage: 'Hvala na brzom odgovoru!',
            lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
            unreadCount: 2,
            orderId: 'ORD-001',
            messages: [
              ChatMessage(
                id: 'msg-1',
                senderId: senior1.id,
                senderName: senior1.fullName,
                senderRole: 'senior',
                content: 'Dobar dan, imam pitanje o narudžbi',
                sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
              ),
              ChatMessage(
                id: 'msg-2',
                senderId: 'admin-1',
                senderName: 'Admin',
                senderRole: 'admin',
                content: 'Dobar dan! Kako Vam mogu pomoći?',
                sentAt: DateTime.now().subtract(const Duration(minutes: 25)),
              ),
              ChatMessage(
                id: 'msg-3',
                senderId: senior1.id,
                senderName: senior1.fullName,
                senderRole: 'senior',
                content: 'Mogu li promijeniti vrijeme dolaska studenta?',
                sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
              ),
              ChatMessage(
                id: 'msg-4',
                senderId: 'admin-1',
                senderName: 'Admin',
                senderRole: 'admin',
                content: 'Da, naravno. Koje vrijeme Vam odgovara?',
                sentAt: DateTime.now().subtract(const Duration(minutes: 8)),
              ),
              ChatMessage(
                id: 'msg-5',
                senderId: senior1.id,
                senderName: senior1.fullName,
                senderRole: 'senior',
                content: 'Hvala na brzom odgovoru!',
                sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
              ),
            ],
          ),
        );
      }

      if (student1 != null) {
        AppData.chatRooms.add(
          ChatRoom(
            id: 'demo-chat-2',
            participantId: student1.id,
            participantName: student1.fullName,
            participantRole: 'student',
            lastMessage: 'Razumijem, hvala!',
            lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
            unreadCount: 0,
            messages: [
              ChatMessage(
                id: 'msg-6',
                senderId: student1.id,
                senderName: student1.fullName,
                senderRole: 'student',
                content: 'Bok, kada mi istječe ugovor?',
                sentAt: DateTime.now().subtract(const Duration(hours: 3)),
              ),
              ChatMessage(
                id: 'msg-7',
                senderId: 'admin-1',
                senderName: 'Admin',
                senderRole: 'admin',
                content: 'Vaš ugovor vrijedi do 15.06.2026.',
                sentAt: DateTime.now().subtract(
                  const Duration(hours: 2, minutes: 30),
                ),
              ),
              ChatMessage(
                id: 'msg-8',
                senderId: student1.id,
                senderName: student1.fullName,
                senderRole: 'student',
                content: 'Razumijem, hvala!',
                sentAt: DateTime.now().subtract(const Duration(hours: 2)),
              ),
            ],
          ),
        );
      }

      if (senior2 != null) {
        AppData.chatRooms.add(
          ChatRoom(
            id: 'demo-chat-3',
            participantId: senior2.id,
            participantName: senior2.fullName,
            participantRole: 'senior',
            lastMessage: 'Studentica je bila izvrsna!',
            lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
            unreadCount: 1,
            messages: [
              ChatMessage(
                id: 'msg-9',
                senderId: senior2.id,
                senderName: senior2.fullName,
                senderRole: 'senior',
                content: 'Studentica je bila izvrsna!',
                sentAt: DateTime.now().subtract(const Duration(days: 1)),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Reset loaded flag (e.g. on logout).
  static void reset() {
    _loaded = false;
  }
}
