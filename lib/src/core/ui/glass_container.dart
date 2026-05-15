import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    this.borderRadius = 12.0,
    this.blurSigma = 18.0,
    this.tint,
    this.border,
    this.padding,
    super.key,
  });

  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final Color? tint;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTint = isDark
        ? const Color(0xFF15171D).withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.72);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint ?? defaultTint,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
          ),
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );
  }
}

Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black38,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: GlassContainer(
            borderRadius: 12,
            blurSigma: 24,
            padding: const EdgeInsets.all(24),
            child: builder(context),
          ),
        ),
      );
    },
  );
}
