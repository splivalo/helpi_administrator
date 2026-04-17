import 'package:flutter/material.dart';
import 'package:helpi_admin/app/theme.dart';

class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.onTap,
    required this.bgColor,
    required this.borderColor,
    required this.child,
    this.margin = const EdgeInsets.only(bottom: 10),
    this.padding = const EdgeInsets.all(16),
    this.radius,
  });

  final VoidCallback onTap;
  final Color bgColor;
  final Color borderColor;
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double? radius;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hovered ? widget.bgColor.withAlpha(180) : widget.bgColor,
            borderRadius: BorderRadius.circular(
              widget.radius ?? HelpiTheme.cardRadius,
            ),
            border: Border.all(
              color: _hovered
                  ? HelpiTheme.accent.withAlpha(100)
                  : widget.borderColor,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
