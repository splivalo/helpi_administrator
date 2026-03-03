import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:helpi_admin/app/responsive_shell.dart';
import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/l10n/locale_notifier.dart';
import 'package:helpi_admin/features/auth/presentation/login_screen.dart';

/// Root widget za Helpi Admin app.
class HelpiAdminApp extends StatefulWidget {
  const HelpiAdminApp({super.key});

  @override
  State<HelpiAdminApp> createState() => _HelpiAdminAppState();
}

class _HelpiAdminAppState extends State<HelpiAdminApp> {
  final _localeNotifier = LocaleNotifier();
  bool _isLoggedIn = false;

  void _handleLogin() {
    setState(() => _isLoggedIn = true);
  }

  void _handleLogout() {
    setState(() => _isLoggedIn = false);
  }

  @override
  void dispose() {
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
          home: _isLoggedIn
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
