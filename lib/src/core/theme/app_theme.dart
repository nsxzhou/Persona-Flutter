import 'package:flutter/material.dart';

import 'app_tokens.dart';
export 'app_tokens.dart'
    show kPanelRadius, kButtonRadius, kInputRadius, kDisplayFontFamily, kMonoFontFamily;

ThemeData buildPersonaTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: brightness,
    primary: AppColors.primary,
    surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    surfaceContainerHighest: isDark
        ? AppColors.darkSurfaceHigh
        : AppColors.lightSurfaceHigh,
  );

  final textColor = isDark ? AppColors.darkText : AppColors.lightText;
  final mutedTextColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
  final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: isDark
        ? AppColors.darkScaffold
        : AppColors.lightScaffold,
    visualDensity: VisualDensity.standard,
    dividerTheme: DividerThemeData(color: borderColor, thickness: 1),
    textTheme: _buildTextTheme(textColor, mutedTextColor),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      selectedColor: scheme.primary.withValues(alpha: 0.12),
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.button),
      ),
      labelStyle:
          TextStyle(color: mutedTextColor, fontWeight: FontWeight.w600),
    ),
    navigationRailTheme: NavigationRailThemeData(
      selectedIconTheme: IconThemeData(color: scheme.primary),
      selectedLabelTextStyle: TextStyle(
        color: scheme.primary,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius:
            const BorderRadius.all(Radius.circular(AppRadii.panel)),
        side: BorderSide(color: borderColor),
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.panel),
      ),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      subtitleTextStyle: TextStyle(color: mutedTextColor, fontSize: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle: TextStyle(color: mutedTextColor, fontSize: 13),
      hintStyle: TextStyle(
        color: mutedTextColor.withValues(alpha: 0.6),
        fontSize: 13,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: isDark
          ? AppColors.darkInputFill.withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.92),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.panel),
        side: BorderSide(color: borderColor),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: textColor,
      unselectedLabelColor: mutedTextColor,
      indicatorColor: scheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return isDark
              ? AppColors.darkTabHover
              : AppColors.lightTabHover;
        }
        return Colors.transparent;
      }),
      dividerColor: Colors.transparent,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: scheme.primary, width: 2),
        insets: const EdgeInsets.symmetric(horizontal: 16),
      ),
    ),
  );
}

final ThemeData personaLightTheme = buildPersonaTheme(Brightness.light);
final ThemeData personaDarkTheme = buildPersonaTheme(Brightness.dark);

TextTheme _buildTextTheme(Color textColor, Color mutedTextColor) {
  return TextTheme(
    headlineLarge: TextStyle(
      color: textColor,
      fontFamily: AppFonts.uiFamily,
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 1.05,
    ),
    headlineMedium: TextStyle(
      color: textColor,
      fontFamily: AppFonts.uiFamily,
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 1.12,
    ),
    titleLarge: TextStyle(
      color: textColor,
      fontFamily: AppFonts.uiFamily,
      fontSize: 18,
      fontWeight: FontWeight.w800,
    ),
    titleMedium: TextStyle(
      color: textColor,
      fontFamily: AppFonts.uiFamily,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: TextStyle(
      color: textColor,
      fontFamily: AppFonts.uiFamily,
      fontSize: 15,
      height: 1.45,
    ),
    bodyMedium: TextStyle(
      color: mutedTextColor,
      fontFamily: AppFonts.uiFamily,
      fontSize: 13,
      height: 1.45,
    ),
    labelLarge: TextStyle(
      color: textColor,
      fontFamily: AppFonts.uiFamily,
      fontSize: 13,
      fontWeight: FontWeight.w800,
    ),
    labelMedium: TextStyle(
      color: mutedTextColor,
      fontFamily: AppFonts.uiFamily,
      fontSize: 11,
      fontWeight: FontWeight.w800,
    ),
  );
}
