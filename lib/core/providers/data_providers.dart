import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/features/chat/data/chat_api_service.dart';

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
    AppData.notifications.removeWhere((n) => n.isRead);
    state = state.where((n) => !n.isRead).toList();
  }

  void removeById(String id) {
    AppData.notifications.removeWhere((n) => n.id == id);
    state = state.where((n) => n.id != id).toList();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
      (ref) => NotificationsNotifier(),
    );

// ═══════════════════════════════════════════════════════════════
//  CHAT ROOMS (API-backed)
// ═══════════════════════════════════════════════════════════════

class AdminChatRoomsNotifier extends StateNotifier<List<ApiChatRoom>> {
  AdminChatRoomsNotifier() : super([]);

  final _api = ChatApiService();

  Future<void> loadRooms() async {
    final rooms = await _api.getRooms();
    // Sort: most recent message first
    rooms.sort((a, b) {
      final aTime = a.lastMessageAt ?? a.createdAt;
      final bTime = b.lastMessageAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    state = rooms;
  }

  void onNewMessage(ApiChatRoom updatedRoom) {
    final rooms = [...state];
    final idx = rooms.indexWhere((r) => r.id == updatedRoom.id);
    if (idx >= 0) {
      rooms.removeAt(idx);
    }
    rooms.insert(0, updatedRoom);
    state = rooms;
  }

  void clearUnread(int roomId) {
    state = [
      for (final r in state)
        if (r.id == roomId) ...[r..unreadCount = 0] else r,
    ];
  }

  void addRoom(ApiChatRoom room) {
    if (state.any((r) => r.id == room.id)) return;
    state = [room, ...state];
  }
}

final adminChatRoomsProvider =
    StateNotifierProvider<AdminChatRoomsNotifier, List<ApiChatRoom>>(
      (ref) => AdminChatRoomsNotifier(),
    );

// ═══════════════════════════════════════════════════════════════
//  CHAT MESSAGES (API-backed)
// ═══════════════════════════════════════════════════════════════

class AdminChatMessagesNotifier extends StateNotifier<List<ApiChatMessage>> {
  AdminChatMessagesNotifier() : super([]);

  final _api = ChatApiService();
  int? _currentRoomId;
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  bool _isInitialLoad = false;

  int? get currentRoomId => _currentRoomId;
  bool get isInitialLoad => _isInitialLoad;

  Future<void> loadMessages(int roomId) async {
    if (_currentRoomId == roomId && state.isNotEmpty) return;
    _currentRoomId = roomId;
    _page = 1;
    _hasMore = true;
    _isInitialLoad = true;
    state = [...state]; // trigger rebuild with isInitialLoad=true
    final msgs = await _api.getMessages(roomId, page: 1);
    _isInitialLoad = false;
    state = msgs;
    _hasMore = msgs.length >= 50;
  }

  Future<void> loadMore() async {
    if (_loading || !_hasMore || _currentRoomId == null) return;
    _loading = true;
    _page++;
    final msgs = await _api.getMessages(_currentRoomId!, page: _page);
    _hasMore = msgs.length >= 50;
    state = [...msgs, ...state];
    _loading = false;
  }

  Future<ApiChatMessage?> sendMessage(String content) async {
    if (_currentRoomId == null) return null;
    final msg = await _api.sendMessage(_currentRoomId!, content);
    if (msg != null) {
      state = [...state, msg];
    }
    return msg;
  }

  Future<void> markAsRead() async {
    if (_currentRoomId == null) return;
    await _api.markAsRead(_currentRoomId!);
  }

  void onReceiveMessage(ApiChatMessage msg) {
    if (msg.chatRoomId == _currentRoomId) {
      final exists = state.any((m) => m.id == msg.id);
      if (!exists) {
        state = [...state, msg];
      }
    }
  }

  void clear() {
    _currentRoomId = null;
    state = [];
  }
}

final adminChatMessagesProvider =
    StateNotifierProvider<AdminChatMessagesNotifier, List<ApiChatMessage>>(
      (ref) => AdminChatMessagesNotifier(),
    );

// ═══════════════════════════════════════════════════════════════
//  UNREAD MESSAGES COUNT (API-backed)
// ═══════════════════════════════════════════════════════════════

class UnreadMessagesNotifier extends StateNotifier<int> {
  UnreadMessagesNotifier() : super(0);

  final _api = ChatApiService();

  Future<void> refresh() async {
    state = await _api.getUnreadCount();
  }

  void set(int count) => state = count;
}

final unreadMessagesProvider =
    StateNotifierProvider<UnreadMessagesNotifier, int>(
      (ref) => UnreadMessagesNotifier(),
    );

// ═══════════════════════════════════════════════════════════════
//  PRICING VERSION (incremented on SettingsChanged)
// ═══════════════════════════════════════════════════════════════

final pricingVersionProvider = StateProvider<int>((ref) => 0);

// ═══════════════════════════════════════════════════════════════
//  PENDING ACCEPTANCE DATA (populated by SeniorsScreen)
//  Key = orderId, Value = {studentName, studentId, minutesPending}
// ═══════════════════════════════════════════════════════════════

final pendingAcceptanceOrderIdsProvider = StateProvider<Set<int>>((ref) => {});

final pendingAcceptanceDataProvider =
    StateProvider<Map<int, Map<String, dynamic>>>((ref) => {});

// ═══════════════════════════════════════════════════════════════
//  SESSIONS VERSION (incremented on EntityChanged for Sessions/Orders)
// ═══════════════════════════════════════════════════════════════

final sessionsVersionProvider = StateProvider<int>((ref) => 0);
