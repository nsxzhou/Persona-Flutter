import 'package:flutter/material.dart';

ThemeData buildPersonaTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2758D9),
    brightness: brightness,
    primary: const Color(0xFF2758D9),
    surface: isDark ? const Color(0xFF15171D) : const Color(0xFFFAFBFD),
    surfaceContainerHighest: isDark
        ? const Color(0xFF252933)
        : const Color(0xFFE8ECF3),
  );

  final textColor = isDark ? const Color(0xFFE9EDF5) : const Color(0xFF171A21);
  final mutedTextColor = isDark
      ? const Color(0xFF9AA4B5)
      : const Color(0xFF596273);
  final borderColor = isDark
      ? const Color(0xFF303644)
      : const Color(0xFFD7DDE8);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF101217)
        : const Color(0xFFF4F6FA),
    visualDensity: VisualDensity.standard,
    dividerTheme: DividerThemeData(color: borderColor, thickness: 1),
    textTheme: _buildTextTheme(textColor, mutedTextColor),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      selectedColor: scheme.primary.withValues(alpha: 0.12),
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: TextStyle(color: mutedTextColor, fontWeight: FontWeight.w600),
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
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        side: BorderSide(color: borderColor),
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      subtitleTextStyle: TextStyle(color: mutedTextColor, fontSize: 12),
    ),
  );
}

TextTheme _buildTextTheme(Color textColor, Color mutedTextColor) {
  const fontFamily = 'Avenir Next';

  return TextTheme(
    headlineLarge: TextStyle(
      color: textColor,
      fontFamily: fontFamily,
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 1.05,
    ),
    headlineMedium: TextStyle(
      color: textColor,
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 1.12,
    ),
    titleLarge: TextStyle(
      color: textColor,
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w800,
    ),
    titleMedium: TextStyle(
      color: textColor,
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: TextStyle(
      color: textColor,
      fontFamily: fontFamily,
      fontSize: 15,
      height: 1.45,
    ),
    bodyMedium: TextStyle(
      color: mutedTextColor,
      fontFamily: fontFamily,
      fontSize: 13,
      height: 1.45,
    ),
    labelLarge: TextStyle(
      color: textColor,
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w800,
    ),
    labelMedium: TextStyle(
      color: mutedTextColor,
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w800,
    ),
  );
}
