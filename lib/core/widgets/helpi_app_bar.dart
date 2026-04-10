import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';

/// Standard AppBar for all admin screens.
///
/// Automatically includes:
/// - Bottom divider (1px, aligned with sidebar)
/// - Right padding (8px) on the last action
class HelpiAppBar extends AppBar {
  HelpiAppBar({
    super.key,
    super.title,
    super.leading,
    super.automaticallyImplyLeading,
    List<Widget>? actions,
  }) : super(
         actions: _padActions(actions),
         bottom: const PreferredSize(
           preferredSize: Size.fromHeight(1),
           child: Divider(height: 1, thickness: 1, color: HelpiTheme.border),
         ),
       );

  static List<Widget>? _padActions(List<Widget>? actions) {
    if (actions == null || actions.isEmpty) return actions;
    return [
      ...actions.take(actions.length - 1),
      Padding(padding: const EdgeInsets.only(right: 8), child: actions.last),
    ];
  }
}
