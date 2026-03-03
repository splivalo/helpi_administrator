import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/l10n/locale_notifier.dart';

/// Admin login ekran — samo email + password (bez social logina).
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.localeNotifier,
  });

  final VoidCallback onLoginSuccess;
  final LocaleNotifier localeNotifier;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  late String _selectedLang = AppStrings.currentLocale.toUpperCase();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: HelpiTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // ── Logo ──
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 40),

                  // ── Email ──
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppStrings.email,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: HelpiTheme.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Password ──
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: HelpiTheme.accent,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: HelpiTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Forgot password ──
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        AppStrings.forgotPassword,
                        style: const TextStyle(
                          color: HelpiTheme.accent,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Login button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: widget.onLoginSuccess,
                      child: Text(AppStrings.loginButton),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Language picker ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.language,
                        color: HelpiTheme.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLang,
                          isDense: true,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 15,
                          ),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _selectedLang = v);
                              widget.localeNotifier.setLocale(v);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'HR',
                              child: Text('Hrvatski'),
                            ),
                            DropdownMenuItem(
                              value: 'EN',
                              child: Text('English'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
