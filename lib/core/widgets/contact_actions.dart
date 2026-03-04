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
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse('tel:$phone')),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(Icons.phone, size: 16, color: HelpiTheme.accent),
      ),
    );
  }
}

/// Grey copy icon button for e-mail (20×20 hit-target).
class EmailCopyButton extends StatelessWidget {
  const EmailCopyButton({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: email));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.emailCopied),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(Icons.copy, size: 16, color: HelpiTheme.textSecondary),
      ),
    );
  }
}
