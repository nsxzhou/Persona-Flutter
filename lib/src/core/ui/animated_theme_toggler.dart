import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/theme_mode_provider.dart';

class AnimatedThemeToggler extends ConsumerWidget {
  const AnimatedThemeToggler({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final tooltip = isDark ? '切换亮色模式' : '切换暗色模式';

    return Semantics(
      button: true,
      toggled: isDark,
      label: tooltip,
      child: _ThemeToggleButton(isDark: isDark, onPressed: onPressed),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.isDark, required this.onPressed});

  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isDark ? colorScheme.onSurface : colorScheme.primary;

    return IconButton(
      tooltip: isDark ? '切换亮色模式' : '切换暗色模式',
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.82, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: Icon(
          isDark ? Icons.dark_mode_outlined : Icons.wb_sunny_outlined,
          key: ValueKey<bool>(isDark),
          color: iconColor,
          size: 19,
        ),
      ),
    );
  }
}
