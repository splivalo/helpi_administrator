import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';

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
  });

  final String title;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
        border: Border.all(color: HelpiTheme.border),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HelpiTheme.textPrimary,
                ),
              ),
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
              style: const TextStyle(
                fontSize: 13,
                color: HelpiTheme.textSecondary,
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
          color: HelpiTheme.border,
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
          Icon(icon, size: 64, color: HelpiTheme.border),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: HelpiTheme.textSecondary,
            ),
          ),
        ],
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
            style: const TextStyle(
              fontSize: 13,
              color: HelpiTheme.textSecondary,
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
