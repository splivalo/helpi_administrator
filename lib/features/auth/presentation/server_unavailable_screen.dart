import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/network/api_endpoints.dart';

/// Full-screen prikazuje se kad backend ne odgovara.
///
/// Auto-retry svakih 10 sekundi + ručni retry gumb.
/// Kad server odgovori, poziva [onServerBack].
class ServerUnavailableScreen extends StatefulWidget {
  final VoidCallback onServerBack;

  const ServerUnavailableScreen({super.key, required this.onServerBack});

  @override
  State<ServerUnavailableScreen> createState() =>
      _ServerUnavailableScreenState();
}

class _ServerUnavailableScreenState extends State<ServerUnavailableScreen> {
  Timer? _autoRetryTimer;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _startAutoRetry();
  }

  @override
  void dispose() {
    _autoRetryTimer?.cancel();
    super.dispose();
  }

  void _startAutoRetry() {
    _autoRetryTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkHealth(),
    );
  }

  Future<void> _checkHealth() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      final response = await dio.get('${ApiEndpoints.baseUrl}/health');
      if (!mounted) return;
      if (response.statusCode == 200) {
        _autoRetryTimer?.cancel();
        widget.onServerBack();
        return;
      }
    } catch (_) {
      // Still down
    }
    if (!mounted) return;
    setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.serverUnavailableTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.serverUnavailableMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (_isRetrying)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.serverUnavailableRetrying,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(height: 16),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isRetrying ? null : _checkHealth,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(AppStrings.serverUnavailableRetry),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
