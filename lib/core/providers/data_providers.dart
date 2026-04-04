import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/core/models/admin_models.dart';

// ═══════════════════════════════════════════════════════════════
//  STUDENTS
// ═══════════════════════════════════════════════════════════════

class StudentsNotifier extends StateNotifier<List<StudentModel>> {
  StudentsNotifier() : super([]);

  void setAll(List<StudentModel> items) => state = [...items];

  void addItem(StudentModel item) => state = [...state, item];

  void updateItem(StudentModel item) {
    state = [for (final s in state) s.id == item.id ? item : s];
  }

  void removeItem(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final studentsProvider =
    StateNotifierProvider<StudentsNotifier, List<StudentModel>>(
      (ref) => StudentsNotifier(),
    );

// ═══════════════════════════════════════════════════════════════
//  SENIORS
// ═══════════════════════════════════════════════════════════════

class SeniorsNotifier extends StateNotifier<List<SeniorModel>> {
  SeniorsNotifier() : super([]);

  void setAll(List<SeniorModel> items) => state = [...items];

  void addItem(SeniorModel item) => state = [...state, item];

  void updateItem(SeniorModel item) {
    state = [for (final s in state) s.id == item.id ? item : s];
  }

  void removeItem(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final seniorsProvider =
    StateNotifierProvider<SeniorsNotifier, List<SeniorModel>>(
      (ref) => SeniorsNotifier(),
    );

// ═══════════════════════════════════════════════════════════════
//  ORDERS
// ═══════════════════════════════════════════════════════════════

class OrdersNotifier extends StateNotifier<List<OrderModel>> {
  OrdersNotifier() : super([]);

  void setAll(List<OrderModel> items) => state = [...items];

  void addItem(OrderModel item) => state = [...state, item];

  void updateItem(OrderModel item) {
    state = [for (final o in state) o.id == item.id ? item : o];
  }

  void removeItem(String id) {
    state = state.where((o) => o.id != id).toList();
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderModel>>(
  (ref) => OrdersNotifier(),
);

// ═══════════════════════════════════════════════════════════════
//  REVIEWS
// ═══════════════════════════════════════════════════════════════

class ReviewsNotifier extends StateNotifier<List<ReviewModel>> {
  ReviewsNotifier() : super([]);

  void setAll(List<ReviewModel> items) => state = [...items];

  void addItem(ReviewModel item) => state = [...state, item];
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, List<ReviewModel>>(
      (ref) => ReviewsNotifier(),
    );

// ═══════════════════════════════════════════════════════════════
//  NOTIFICATIONS
// ═══════════════════════════════════════════════════════════════

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super([]);

  void setAll(List<NotificationModel> items) => state = [...items];

  void markRead(String id) {
    for (final n in state) {
      if (n.id == id) n.isRead = true;
    }
    state = [...state];
  }

  void markAllRead() {
    for (final n in state) {
      n.isRead = true;
    }
    state = [...state];
  }

  void removeRead() {
    state = state.where((n) => !n.isRead).toList();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
      (ref) => NotificationsNotifier(),
    );

// ═══════════════════════════════════════════════════════════════
//  CHAT ROOMS
// ═══════════════════════════════════════════════════════════════

class ChatRoomsNotifier extends StateNotifier<List<ChatRoom>> {
  ChatRoomsNotifier() : super([]);

  void setAll(List<ChatRoom> items) => state = [...items];

  void addRoom(ChatRoom room) => state = [...state, room];

  void updateRoom(ChatRoom room) {
    state = [for (final r in state) r.id == room.id ? room : r];
  }
}

final chatRoomsProvider =
    StateNotifierProvider<ChatRoomsNotifier, List<ChatRoom>>(
      (ref) => ChatRoomsNotifier(),
    );

// ═══════════════════════════════════════════════════════════════
//  UNREAD MESSAGES COUNT
// ═══════════════════════════════════════════════════════════════

class UnreadMessagesNotifier extends StateNotifier<Map<String, int>> {
  UnreadMessagesNotifier()
    : super({
        'demo-chat-1': 2, // TODO: revert to empty {} after testing
        'demo-chat-3': 1, // TODO: revert to empty {} after testing
      });

  void incrementRoom(String roomId) {
    final current = state[roomId] ?? 0;
    state = {...state, roomId: current + 1};
  }

  void markRoomRead(String roomId) {
    final updated = {...state};
    updated.remove(roomId);
    state = updated;
  }

  int get totalUnread => state.values.fold(0, (sum, c) => sum + c);
}

final unreadMessagesProvider =
    StateNotifierProvider<UnreadMessagesNotifier, Map<String, int>>(
      (ref) => UnreadMessagesNotifier(),
    );

// ═══════════════════════════════════════════════════════════════
//  PRICING VERSION (incremented on SettingsChanged)
// ═══════════════════════════════════════════════════════════════

final pricingVersionProvider = StateProvider<int>((ref) => 0);
