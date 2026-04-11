import 'package:flutter/material.dart';

/// Standard AppBar for all admin screens.
///
/// Automatically includes:
/// - Bottom divider (1px, uses theme divider color)
/// - Right padding (8px) on the last action
class HelpiAppBar extends AppBar {
  /// Spacing between back arrow and title on inner (pushed) screens.
  /// Change this single value to adjust all inner screens at once.
  static const double innerTitleSpacing = 4.5;

  HelpiAppBar({
    super.key,
    super.title,
    super.leading,
    super.automaticallyImplyLeading,
    super.titleSpacing,
    List<Widget>? actions,
  }) : super(
         actions: _padActions(actions),
         bottom: const PreferredSize(
           preferredSize: Size.fromHeight(1),
           child: Divider(height: 1, thickness: 1),
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
