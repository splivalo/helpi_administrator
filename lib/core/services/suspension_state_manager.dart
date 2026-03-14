import 'package:flutter/foundation.dart';

/// In-memory singleton that tracks which users are currently suspended.
/// When connected to the real API, this will be replaced by backend state.
class SuspensionStateManager extends ChangeNotifier {
  SuspensionStateManager._();
  static final instance = SuspensionStateManager._();

  final _suspendedUserIds = <String>{};

  bool isSuspended(String userId) => _suspendedUserIds.contains(userId);

  void suspend(String userId) {
    _suspendedUserIds.add(userId);
    notifyListeners();
  }

  void activate(String userId) {
    _suspendedUserIds.remove(userId);
    notifyListeners();
  }
}
