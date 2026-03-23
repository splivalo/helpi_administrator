import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/responsive_shell.dart';
import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/l10n/locale_notifier.dart';
import 'package:helpi_admin/core/services/auth_service.dart';
import 'package:helpi_admin/core/services/data_loader.dart';
import 'package:helpi_admin/core/services/signalr_notification_service.dart';
import 'package:helpi_admin/core/network/token_storage.dart';
import 'package:helpi_admin/features/auth/presentation/login_screen.dart';
import 'package:helpi_admin/features/auth/presentation/server_unavailable_screen.dart';

/// Root widget za Helpi Admin app.
class HelpiAdminApp extends ConsumerStatefulWidget {
  const HelpiAdminApp({super.key});

  @override
  ConsumerState<HelpiAdminApp> createState() => _HelpiAdminAppState();
}

class _HelpiAdminAppState extends ConsumerState<HelpiAdminApp> {
  final _localeNotifier = LocaleNotifier();
  final _authService = AuthService();
  final _signalR = SignalRNotificationService(TokenStorage());
  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;
  bool _isLoadingData = false;
  bool _serverUnavailable = false;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    bool loggedIn = false;
    bool dataOk = true;
    try {
      loggedIn = await _authService.isLoggedIn();
      if (!mounted) return;
      if (loggedIn) {
        dataOk = await DataLoader.loadAll(ref: ref);
        if (!mounted) return;
      }
    } catch (_) {
      // Never block startup — fall through with whatever state we have
    }
    if (!mounted) return;
    setState(() {
      _isLoggedIn = loggedIn;
      _isCheckingAuth = false;
      _serverUnavailable = loggedIn && !dataOk;
    });
    if (loggedIn && dataOk) {
      _signalR.start(ref: ref);
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoggedIn = true;
      _isLoadingData = true;
    });
    final dataOk = await DataLoader.loadAll(ref: ref);
    if (!mounted) return;
    setState(() {
      _isLoadingData = false;
      _serverUnavailable = !dataOk;
    });
    if (dataOk) {
      _signalR.start(ref: ref);
    }
  }

  Future<void> _handleServerBack() async {
    setState(() => _isLoadingData = true);
    final dataOk = await DataLoader.loadAll(ref: ref);
    if (!mounted) return;
    setState(() {
      _isLoadingData = false;
      _serverUnavailable = !dataOk;
    });
  }

  Future<void> _handleLogout() async {
    await _signalR.stop();
    await _authService.logout();
    DataLoader.reset();
    if (!mounted) return;
    setState(() => _isLoggedIn = false);
  }

  @override
  void dispose() {
    _signalR.stop();
    _localeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: _localeNotifier,
      builder: (context, locale, _) {
        // Sync AppStrings locale with notifier
        AppStrings.setLocale(locale.languageCode);

        return MaterialApp(
          title: 'Helpi Admin',
          debugShowCheckedModeBanner: false,
          theme: HelpiTheme.light,
          locale: locale,
          supportedLocales: const [Locale('hr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: _isCheckingAuth || _isLoadingData
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : _serverUnavailable
              ? ServerUnavailableScreen(onServerBack: _handleServerBack)
              : _isLoggedIn
              ? ResponsiveShell(
                  localeNotifier: _localeNotifier,
                  onLogout: _handleLogout,
                )
              : LoginScreen(
                  localeNotifier: _localeNotifier,
                  onLoginSuccess: _handleLogin,
                ),
        );
      },
    );
  }
}
