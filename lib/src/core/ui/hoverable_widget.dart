import 'package:flutter/material.dart';

class HoverableWidget extends StatefulWidget {
  const HoverableWidget({
    required this.builder,
    this.child,
    this.scaleOnHover = 1.015,
    this.duration = const Duration(milliseconds: 160),
    super.key,
  });

  final Widget Function(BuildContext context, bool isHovered, Widget? child)
  builder;
  final Widget? child;
  final double scaleOnHover;
  final Duration duration;

  @override
  State<HoverableWidget> createState() => _HoverableWidgetState();
}

class _HoverableWidgetState extends State<HoverableWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? widget.scaleOnHover : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.builder(context, _isHovered, widget.child),
      ),
    );
  }
}
