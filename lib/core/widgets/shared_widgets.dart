import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';

// ═══════════════════════════════════════════════════════════════
//  SECTION CARD — white card with optional icon + title + children
// ═══════════════════════════════════════════════════════════════

/// Reusable section container: rounded white card, icon + title header, children.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HelpiColors.of(context).surface,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiColors.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: HelpiTheme.accent),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HelpiColors.of(context).textPrimary,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  INFO ROW — label (140px) + value/widget + optional trailing
// ═══════════════════════════════════════════════════════════════

/// Reusable label-value row. Supports:
/// - Plain text via [value]
/// - Custom widget via [valueWidget] (overrides [value])
/// - Trailing icon via [trailing]
///
/// When [trailing] is provided, cross-axis is centered; otherwise start-aligned.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.trailing,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final hasTrailing = trailing != null;
    final valueChild =
        valueWidget ??
        Text(
          value ?? '',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: hasTrailing
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: HelpiColors.of(context).textSecondary,
              ),
            ),
          ),
          if (hasTrailing) ...[
            Flexible(child: valueChild),
            const SizedBox(width: 4),
            trailing!,
          ] else
            Expanded(child: valueChild),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  INFO FIELD — stacked label (above) + value (below)
// ═══════════════════════════════════════════════════════════════

/// Stacked field: small grey label on top, value below.
/// Optional [trailing] widget (e.g. copy icon) shown right of value.
class InfoField extends StatelessWidget {
  const InfoField({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.trailing,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tooltipText = value ?? '';
    final valText =
        valueWidget ??
        Text(
          tooltipText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        );

    Widget val = Tooltip(
      message: tooltipText,
      waitDuration: const Duration(milliseconds: 400),
      preferBelow: false,
      verticalOffset: 14,
      decoration: BoxDecoration(
        color: const Color(0xE6616161),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: const TextStyle(fontSize: 13, color: Colors.white),
      child: valText,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: HelpiColors.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          if (trailing != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: val),
                const SizedBox(width: 4),
                trailing!,
              ],
            )
          else
            val,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  INFO FIELD ROW — two InfoFields side by side, equal width
// ═══════════════════════════════════════════════════════════════

/// Places children side-by-side with equal width (Expanded).
class InfoFieldRow extends StatelessWidget {
  const InfoFieldRow({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  RESPONSIVE FIELD GRID — 4-col desktop → 1-col mobile
// ═══════════════════════════════════════════════════════════════

/// Responsive grid that places [InfoField] children in up to [maxColumns]
/// columns.  On mobile (<600 px) it falls back to a single column.
/// Uses [Wrap] so fields flow naturally to the next row.
class ResponsiveFieldGrid extends StatelessWidget {
  const ResponsiveFieldGrid({
    super.key,
    required this.children,
    this.maxColumns = 4,
    this.spacing = 16,
    this.runSpacing = 4,
  });

  final List<Widget> children;
  final int maxColumns;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 800
            ? maxColumns
            : w >= 500
            ? 2
            : 1;
        final itemWidth = (w - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: cols == 1 ? w : itemWidth, child: child),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  RESPONSIVE BUTTON — normal width desktop, fullwidth mobile
// ═══════════════════════════════════════════════════════════════

/// Wraps a button: full-width on mobile (<600px), natural width on desktop.
class ResponsiveButton extends StatelessWidget {
  const ResponsiveButton({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return SizedBox(width: double.infinity, child: child);
        }
        return child;
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ACTION CHIP BUTTON — compact outlined button with icon
// ═══════════════════════════════════════════════════════════════

/// Visual density for [ActionChipButton].
///
/// - `small`  → icon 14, font 12, padding ~10×6  (inline card actions)
/// - `medium` → icon 18, font 14, padding ~14×8  (modal primary actions)
enum ActionChipButtonSize { small, medium }

/// Custom animated toggle switch matching analytics comparison toggle style.
class HelpiSwitch extends StatelessWidget {
  const HelpiSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 20,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: value ? HelpiTheme.accent : HelpiColors.of(context).border,
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact chip-style action button: tinted background, small icon + label.
class ActionChipButton extends StatelessWidget {
  const ActionChipButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.outlined = false,
    this.size = ActionChipButtonSize.small,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;
  final ActionChipButtonSize size;

  @override
  Widget build(BuildContext context) {
    final isMedium = size == ActionChipButtonSize.medium;
    final bgColor = outlined ? HelpiColors.of(context).surface : color;
    final fgColor = outlined ? color : Colors.white;
    final radius = isMedium ? 10.0 : 8.0;
    final iconSize = isMedium ? 18.0 : 14.0;
    final fontSize = isMedium ? 14.0 : 12.0;
    final hPad = outlined ? (isMedium ? 13.0 : 9.0) : (isMedium ? 14.0 : 10.0);
    final vPad = outlined ? (isMedium ? 7.0 : 5.0) : (isMedium ? 8.0 : 6.0);
    final gap = isMedium ? 6.0 : 4.0;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        hoverColor: outlined ? color.withAlpha(20) : Colors.white.withAlpha(25),
        splashColor: outlined
            ? color.withAlpha(35)
            : Colors.white.withAlpha(40),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: color),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: fgColor),
              SizedBox(width: gap),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DRAG HANDLE — bottom-sheet pill
// ═══════════════════════════════════════════════════════════════

/// Standard bottom-sheet drag indicator (40×4, rounded, centered).
class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: HelpiColors.of(context).border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  EMPTY STATE — centered icon + message
// ═══════════════════════════════════════════════════════════════

/// Full-screen empty-state placeholder: large icon + subtitle text.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: HelpiColors.of(context).border),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: HelpiColors.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SECTION EMPTY STATE — consistent empty indicator within SectionCard
// ═══════════════════════════════════════════════════════════════

/// Compact empty-state widget used inside [SectionCard] children.
///
/// Provides a uniform look: centred icon (36px) + message in
/// `textSecondary` colour with `vertical: 16` padding.
class SectionEmptyState extends StatelessWidget {
  const SectionEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 36, color: HelpiColors.of(context).border),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: HelpiColors.of(context).textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  RESULT COUNT ROW
// ═══════════════════════════════════════════════════════════════

/// Displays a result count label (e.g. "Prikazano: 12 rezultata") aligned left.
class ResultCountRow extends StatelessWidget {
  const ResultCountRow({super.key, required this.text, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: HelpiColors.of(context).textSecondary,
            ),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  15-MINUTE TIME PICKER — shared dialog with hour + minute
// ═══════════════════════════════════════════════════════════════

/// Shows a dialog to pick a time in 15-minute intervals (00, 15, 30, 45).
Future<TimeOfDay?> show15MinTimePicker(
  BuildContext context, {
  TimeOfDay? initial,
}) {
  int hour = (initial ?? const TimeOfDay(hour: 8, minute: 0)).hour;
  int minuteIndex =
      ((initial ?? const TimeOfDay(hour: 8, minute: 0)).minute ~/ 15).clamp(
        0,
        3,
      );
  const minutes = [0, 15, 30, 45];

  return showDialog<TimeOfDay>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(AppStrings.selectTime),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.timePickerHour,
                      style: TextStyle(
                        fontSize: 12,
                        color: HelpiColors.of(ctx).textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              HelpiTheme.cardRadius,
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: hour,
                            isDense: true,
                            items: List.generate(
                              24,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(i.toString().padLeft(2, '0')),
                              ),
                            ),
                            onChanged: (v) {
                              if (v != null) setDialogState(() => hour = v);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    ':',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.timePickerMinute,
                      style: TextStyle(
                        fontSize: 12,
                        color: HelpiColors.of(ctx).textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              HelpiTheme.cardRadius,
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: minuteIndex,
                            isDense: true,
                            items: List.generate(
                              4,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(
                                  minutes[i].toString().padLeft(2, '0'),
                                ),
                              ),
                            ),
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => minuteIndex = v);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(
                  ctx,
                  TimeOfDay(hour: hour, minute: minutes[minuteIndex]),
                ),
                child: Text(AppStrings.ok),
              ),
            ],
          );
        },
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════
//  SEARCH BAR
// ═══════════════════════════════════════════════════════════════

/// Unified search text field with search icon and clear button.
class HelpiSearchBar extends StatelessWidget {
  const HelpiSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
