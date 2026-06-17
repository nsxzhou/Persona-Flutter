import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Named spacing widgets backed by [AppSpacing] tokens.
///
/// Default direction is **vertical** (SizedBox with height).
/// Use the `h`-prefixed constructors for horizontal gaps.
///
/// ```dart
/// AppGap.sm()        // 8 px vertical
/// AppGap.hLg()       // 16 px horizontal
/// AppGap.section()   // 40 px vertical
/// ```
class AppGap extends SizedBox {
  // ---- Vertical (default) ----
  const AppGap.xs({super.key}) : super(height: AppSpacing.xs);
  const AppGap.sm({super.key}) : super(height: AppSpacing.sm);
  const AppGap.md({super.key}) : super(height: AppSpacing.md);
  const AppGap.lg({super.key}) : super(height: AppSpacing.lg);
  const AppGap.xl({super.key}) : super(height: AppSpacing.xl);
  const AppGap.xxl({super.key}) : super(height: AppSpacing.xxl);
  const AppGap.section({super.key}) : super(height: AppSpacing.section);

  // ---- Horizontal ----
  const AppGap.hXs({super.key}) : super(width: AppSpacing.xs);
  const AppGap.hSm({super.key}) : super(width: AppSpacing.sm);
  const AppGap.hMd({super.key}) : super(width: AppSpacing.md);
  const AppGap.hLg({super.key}) : super(width: AppSpacing.lg);
  const AppGap.hXl({super.key}) : super(width: AppSpacing.xl);
  const AppGap.hXxl({super.key}) : super(width: AppSpacing.xxl);
}
