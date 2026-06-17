import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// A page scaffold variant designed for **literary / creative** contexts
/// (reader, chapter editor, story review).
///
/// Differences from [PersonaPage]:
/// - Paper-like background ([AppColors.literaryLightBg] / [AppColors.literaryDarkBg])
///   instead of the standard scaffold colour.
/// - Default body text uses the literary serif font family
///   ([AppFonts.literaryFamilyZh] for CJK, [AppFonts.literaryFamilyEn] for Latin).
///
/// Use this as a drop-in wrapper for content areas inside the novel workshop
/// reader or editor where a "writing studio" atmosphere is desired.
class LiteraryPage extends StatelessWidget {
  const LiteraryPage({
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.xxl,
    ),
    this.maxWidth = 960,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.literaryDarkBg
        : AppColors.literaryLightBg;

    return ColoredBox(
      color: bgColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: padding,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontFamily: AppFonts.literaryFamilyEn,
                fontSize: 18,
                height: 1.8,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Applies the literary serif font to its child text.
///
/// Useful for individual text widgets or blocks that need the serif
/// treatment without wrapping in a full [LiteraryPage].
class LiteraryText extends StatelessWidget {
  const LiteraryText(
    this.data, {
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: (style ?? const TextStyle()).merge(
        TextStyle(
          fontFamily: AppFonts.literaryFamilyEn,
          fontSize: style?.fontSize ?? 18,
          height: style?.height ?? 1.8,
        ),
      ),
    );
  }
}
