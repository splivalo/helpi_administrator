import 'package:flutter/material.dart';

import 'package:helpi_admin/core/network/api_client.dart';
import 'package:helpi_admin/core/network/api_endpoints.dart';

// ── Models ──────────────────────────────────────────

class ApiChatRoom {
  ApiChatRoom({
    required this.id,
    required this.participant1UserId,
    required this.participant1Name,
    required this.participant1Role,
    required this.participant2UserId,
    required this.participant2Name,
    required this.participant2Role,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastMessageSenderUserId,
    this.unreadCount = 0,
    required this.createdAt,
  });

  factory ApiChatRoom.fromJson(Map<String, dynamic> json) {
    return ApiChatRoom(
      id: json['id'] as int,
      participant1UserId: json['participant1UserId'] as int,
      participant1Name: json['participant1Name'] as String,
      participant1Role: json['participant1Role'] as String,
      participant2UserId: json['participant2UserId'] as int,
      participant2Name: json['participant2Name'] as String,
      participant2Role: json['participant2Role'] as String,
      lastMessageText: json['lastMessageText'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      lastMessageSenderUserId: json['lastMessageSenderUserId'] as int?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final int id;
  final int participant1UserId;
  final String participant1Name;
  final String participant1Role;
  final int participant2UserId;
  final String participant2Name;
  final String participant2Role;
  String? lastMessageText;
  DateTime? lastMessageAt;
  int? lastMessageSenderUserId;
  int unreadCount;
  final DateTime createdAt;

  /// Get other participant name (admin is "self", other is the user).
  String otherName(int myUserId) {
    return participant1UserId == myUserId ? participant2Name : participant1Name;
  }

  String otherRole(int myUserId) {
    return participant1UserId == myUserId ? participant2Role : participant1Role;
  }

  int otherUserId(int myUserId) {
    return participant1UserId == myUserId
        ? participant2UserId
        : participant1UserId;
  }
}

class ApiChatMessage {
  ApiChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderUserId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.readAt,
  });

  factory ApiChatMessage.fromJson(Map<String, dynamic> json) {
    return ApiChatMessage(
      id: json['id'] as int,
      chatRoomId: json['chatRoomId'] as int,
      senderUserId: json['senderUserId'] as int,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }

  final int id;
  final int chatRoomId;
  final int senderUserId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final DateTime? readAt;

  bool isMine(int myUserId) => senderUserId == myUserId;

  String get timeFormatted {
    final local = sentAt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

// ── API Service ─────────────────────────────────────

class ChatApiService {
  final ApiClient _client = ApiClient();

  Future<List<ApiChatRoom>> getRooms() async {
    try {
      final response = await _client.get(ApiEndpoints.chatRooms);
      final list = response.data as List<dynamic>;
      return list
          .map((e) => ApiChatRoom.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[AdminChatApi] getRooms error: $e');
      return [];
    }
  }

  Future<List<ApiChatMessage>> getMessages(
    int roomId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.chatMessages(roomId),
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) => ApiChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[AdminChatApi] getMessages error: $e');
      return [];
    }
  }

  Future<ApiChatMessage?> sendMessage(int roomId, String content) async {
    try {
      final response = await _client.post(
        ApiEndpoints.chatMessages(roomId),
        data: {'content': content},
      );
      return ApiChatMessage.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[AdminChatApi] sendMessage error: $e');
      return null;
    }
  }

  Future<void> markAsRead(int roomId) async {
    try {
      await _client.put(ApiEndpoints.chatMarkRead(roomId));
    } catch (e) {
      debugPrint('[AdminChatApi] markAsRead error: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _client.get(ApiEndpoints.chatUnreadCount);
      final data = response.data as Map<String, dynamic>;
      return data['unreadCount'] as int? ?? 0;
    } catch (e) {
      debugPrint('[AdminChatApi] getUnreadCount error: $e');
      return 0;
    }
  }

  /// Creates or gets an existing room with [otherUserId].
  Future<ApiChatRoom?> getOrCreateRoom(int otherUserId) async {
    try {
      final response = await _client.post(
        ApiEndpoints.chatRooms,
        data: {'otherUserId': otherUserId},
      );
      return ApiChatRoom.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[AdminChatApi] getOrCreateRoom error: $e');
      return null;
    }
  }
}
