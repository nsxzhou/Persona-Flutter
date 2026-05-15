import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kPanelRadius = 12.0;
const kButtonRadius = 10.0;
const kInputRadius = 10.0;

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kButtonRadius),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kButtonRadius),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      selectedColor: scheme.primary.withValues(alpha: 0.12),
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kButtonRadius),
      ),
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
        borderRadius: const BorderRadius.all(Radius.circular(kPanelRadius)),
        side: BorderSide(color: borderColor),
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kPanelRadius),
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
      fillColor: isDark
          ? const Color(0xFF1A1D25)
          : const Color(0xFFF0F2F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kInputRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kInputRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kInputRadius),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle: TextStyle(color: mutedTextColor, fontSize: 13),
      hintStyle: TextStyle(
        color: mutedTextColor.withValues(alpha: 0.6),
        fontSize: 13,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: isDark
          ? const Color(0xFF1A1D25).withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.92),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kPanelRadius),
        side: BorderSide(color: borderColor),
      ),
    ),
  );
}

TextTheme _buildTextTheme(Color textColor, Color mutedTextColor) {
  final fontFamily = GoogleFonts.inter().fontFamily;

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
