import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedThemeToggler extends StatelessWidget {
  const AnimatedThemeToggler({
    required this.themeMode,
    required this.onPressed,
    super.key,
  });

  final ThemeMode themeMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == ThemeMode.dark;
    final tooltip = isDark ? '切换亮色模式' : '切换暗色模式';

    return Semantics(
      button: true,
      toggled: isDark,
      label: tooltip,
      child: _ThemeToggleButton(isDark: isDark, onPressed: onPressed),
    );
  }
}

class _ThemeToggleButton extends StatefulWidget {
  const _ThemeToggleButton({required this.isDark, required this.onPressed});

  final bool isDark;
  final VoidCallback onPressed;

  @override
  State<_ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<_ThemeToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = widget.isDark
        ? colorScheme.onSurface
        : colorScheme.primary;

    return IconButton(
      tooltip: widget.isDark ? '切换亮色模式' : '切换暗色模式',
      onPressed: widget.onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          final rotated = Tween<double>(
            begin: widget.isDark ? -0.08 : 0.08,
            end: 0,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.82, end: 1).animate(animation),
              child: AnimatedBuilder(
                animation: rotated,
                child: child,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: rotated.value * math.pi,
                    child: child,
                  );
                },
              ),
            ),
          );
        },
        child: Icon(
          widget.isDark ? Icons.dark_mode_outlined : Icons.wb_sunny_outlined,
          key: ValueKey<bool>(widget.isDark),
          color: iconColor,
          size: 19,
        ),
      ),
    );
  }
}
