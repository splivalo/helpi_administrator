import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';

/// Teal phone-call icon button (20×20 hit-target).
class PhoneCallButton extends StatelessWidget {
  const PhoneCallButton({super.key, required this.phone});
  final String phone;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => launchUrl(Uri.parse('tel:$phone')),
      icon: const Icon(Icons.phone, size: 16, color: HelpiTheme.accent),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      splashRadius: 14,
      tooltip: AppStrings.callPhone,
    );
  }
}

/// Grey copy icon button for e-mail (20×20 hit-target).
class EmailCopyButton extends StatelessWidget {
  const EmailCopyButton({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: email));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.emailCopied),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      icon: const Icon(Icons.copy, size: 16, color: HelpiTheme.textSecondary),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      splashRadius: 14,
      tooltip: AppStrings.copyEmail,
    );
  }
}
