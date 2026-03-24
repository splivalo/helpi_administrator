import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/signalr_client.dart';

import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/network/api_endpoints.dart';
import 'package:helpi_admin/core/network/token_storage.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/services/data_loader.dart';

/// SignalR service for real-time admin notifications.
///
/// Backend sends:
///   - ReceiveNotification  (HNotificationDto JSON)
///   - UnreadCountUpdate    (int)
class SignalRNotificationService {
  SignalRNotificationService(this._tokenStorage);

  final TokenStorage _tokenStorage;
  HubConnection? _connection;
  bool _stoppedManually = false;
  int _reconnectAttempt = 0;
  WidgetRef? _ref;

  bool get isConnected =>
      _connection != null && _connection!.state == HubConnectionState.Connected;

  String get _hubUrl => '${ApiEndpoints.baseUrl}/hubs/notifications';

  Future<void> start({WidgetRef? ref}) async {
    _stoppedManually = false;
    _ref = ref;
    _reconnectAttempt = 0;

    // Tear down stale connection so we always get a fresh one
    if (_connection != null) {
      try {
        _connection!.off('ReceiveNotification');
        await _connection!.stop();
      } catch (_) {}
      _connection = null;
    }

    _connection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              return await _tokenStorage.getToken() ?? '';
            },
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.onclose(({Exception? error}) {
      debugPrint('[SignalR] closed: $error');
      if (!_stoppedManually) {
        _scheduleReconnect();
      }
    });

    _connection!.onreconnected(({String? connectionId}) {
      debugPrint('[SignalR] reconnected: $connectionId');
      _reconnectAttempt = 0;
    });

    _connection!.on('ReceiveNotification', _onReceiveNotification);

    await _startWithRetry();
  }

  Future<void> stop() async {
    _stoppedManually = true;
    _reconnectAttempt = 0;
    _ref = null;
    try {
      await _connection?.stop();
    } catch (e) {
      debugPrint('[SignalR] stop error: $e');
    }
    _connection = null;
  }

  void _onReceiveNotification(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final raw = args[0];
      final Map<String, dynamic> json;
      if (raw is String) {
        json = jsonDecode(raw) as Map<String, dynamic>;
      } else if (raw is Map) {
        json = Map<String, dynamic>.from(raw);
      } else {
        debugPrint(
          '[SignalR] unexpected notification format: ${raw.runtimeType}',
        );
        return;
      }

      final notification = _parseNotification(json);

      // Prepend to AppData
      AppData.notifications.insert(0, notification);

      // Update Riverpod provider
      if (_ref != null) {
        final notifier = _ref!.read(notificationsProvider.notifier);
        notifier.setAll(AppData.notifications);

        // Refresh all data for notification types that change entities
        if (_isDataChangingType(notification.type)) {
          DataLoader.loadAll(ref: _ref!);
        }
      }

      debugPrint('[SignalR] notification received: ${notification.title}');
    } catch (e) {
      debugPrint('[SignalR] parse notification error: $e');
    }
  }

  static const _dataChangingTypes = {
    NotificationType.newOrderAdded,
    NotificationType.orderCancelled,
    NotificationType.newStudentAdded,
    NotificationType.newSeniorAdded,
    NotificationType.studentDeleted,
    NotificationType.seniorDeleted,
    NotificationType.customerDeleted,
    NotificationType.contractAdded,
    NotificationType.contractUpdated,
    NotificationType.contractDeleted,
    NotificationType.jobCompleted,
    NotificationType.jobCancelled,
    NotificationType.reassignmentCompleted,
  };

  bool _isDataChangingType(NotificationType type) =>
      _dataChangingTypes.contains(type);

  NotificationModel _parseNotification(Map<String, dynamic> json) {
    final typeValue = json['type'];
    NotificationType type = NotificationType.general;
    if (typeValue is int &&
        typeValue >= 0 &&
        typeValue < NotificationType.values.length) {
      type = NotificationType.values[typeValue];
    }

    return NotificationModel(
      id: '${json['id']}',
      type: type,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      studentId: json['studentId'] as int?,
      seniorId: json['seniorId'] as int?,
      orderId: json['orderId'] as int?,
      jobInstanceId: json['jobInstanceId'] as int?,
    );
  }

  Future<void> _startWithRetry() async {
    const maxAttempts = 5;
    while (!_stoppedManually &&
        _connection!.state == HubConnectionState.Disconnected &&
        _reconnectAttempt < maxAttempts) {
      try {
        _reconnectAttempt++;
        debugPrint('[SignalR] connect attempt #$_reconnectAttempt');
        await _connection!.start();
        debugPrint('[SignalR] connected');
        _reconnectAttempt = 0;
        return;
      } catch (e) {
        debugPrint('[SignalR] connect failed: $e');
        final delay = Duration(seconds: _reconnectAttempt * 2);
        await Future.delayed(delay);
      }
    }
  }

  void _scheduleReconnect() {
    if (_stoppedManually) return;
    _reconnectAttempt = 0; // reset so _startWithRetry has full budget
    Future.delayed(const Duration(seconds: 3), () {
      if (_stoppedManually) return;
      _startWithRetry();
    });
  }
}
