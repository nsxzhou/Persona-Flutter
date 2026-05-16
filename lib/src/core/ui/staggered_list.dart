import 'package:flutter/material.dart';

class StaggeredList extends StatefulWidget {
  const StaggeredList({
    required this.children,
    this.animate = false,
    this.itemDuration = const Duration(milliseconds: 350),
    this.verticalOffset = 16.0,
    super.key,
  });

  final List<Widget> children;
  final bool animate;
  final Duration itemDuration;
  final double verticalOffset;

  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    if (!widget.animate) {
      _animate = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.children.length; i++)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: _animate ? 1.0 : 0.0),
            duration: widget.animate ? widget.itemDuration : Duration.zero,
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final delayedValue = (value - (i * 0.08)).clamp(0.0, 1.0);
              return Opacity(
                opacity: delayedValue,
                child: Transform.translate(
                  offset: Offset(0, widget.verticalOffset * (1 - delayedValue)),
                  child: child,
                ),
              );
            },
            child: widget.children[i],
          ),
      ],
    );
  }
}
