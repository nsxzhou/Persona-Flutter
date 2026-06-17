import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// AppColors — centralised colour tokens
// ---------------------------------------------------------------------------

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2758D9);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Semantic status
  static const Color success = Color(0xFF16825D);
  static const Color warning = Color(0xFFC4850A);
  static const Color info = Color(0xFF2E7BD6);
  // error defers to colorScheme.error

  // Light palette
  static const Color lightSurface = Color(0xFFFAFBFD);
  static const Color lightSurfaceHigh = Color(0xFFE8ECF3);
  static const Color lightScaffold = Color(0xFFF4F6FA);
  static const Color lightText = Color(0xFF171A21);
  static const Color lightMuted = Color(0xFF596273);
  static const Color lightBorder = Color(0xFFD7DDE8);
  static const Color lightInputFill = Color(0xFFF0F2F7);
  static const Color lightTabHover = Color(0xFFF0F2F7);

  // Dark palette
  static const Color darkSurface = Color(0xFF15171D);
  static const Color darkSurfaceHigh = Color(0xFF252933);
  static const Color darkScaffold = Color(0xFF101217);
  static const Color darkText = Color(0xFFE9EDF5);
  static const Color darkMuted = Color(0xFF9AA4B5);
  static const Color darkBorder = Color(0xFF303644);
  static const Color darkInputFill = Color(0xFF1A1D25);
  static const Color darkTabHover = Color(0xFF1C2028);

  // Literary palette (paper-like backgrounds for reader/editor)
  static const Color literaryLightBg = Color(0xFFFAF8F5);
  static const Color literaryDarkBg = Color(0xFF181614);
}

// ---------------------------------------------------------------------------
// AppFonts — centralised font family tokens
// ---------------------------------------------------------------------------

class AppFonts {
  AppFonts._();

  /// UI font: Inter (via Google Fonts).
  static final String? uiFamily = GoogleFonts.inter().fontFamily;

  /// Editorial / display font: Cormorant Garamond (serif italic).
  static final String? displayFamily =
      GoogleFonts.cormorantGaramond().fontFamily;

  /// Monospace font: JetBrains Mono — section labels, code, technical metadata.
  static final String? monoFamily = GoogleFonts.jetBrainsMono().fontFamily;

  /// Literary font (Chinese): Songti SC — system-installed serif.
  static const String literaryFamilyZh = 'Songti SC';

  /// Literary font (English): Lora (via Google Fonts).
  static final String? literaryFamilyEn = GoogleFonts.lora().fontFamily;
}

// ---------------------------------------------------------------------------
// AppSpacing — 4 dp baseline grid
// ---------------------------------------------------------------------------

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double section = 40.0;

  // Semantic spacing
  static const double pageHPadding = 32.0;
  static const double pageVPadding = 28.0;
  static const double pageBottom = 40.0;
  static const double panelInner = 20.0;
  static const double listItemV = 12.0;
  static const double formFieldGap = 12.0;
}

// ---------------------------------------------------------------------------
// AppRadii — border-radius tokens
// ---------------------------------------------------------------------------

class AppRadii {
  AppRadii._();

  static const double panel = 12.0;
  static const double button = 10.0;
  static const double input = 10.0;
  static const double badge = 6.0;
  static const double pill = 999.0;
}

// ---------------------------------------------------------------------------
// AppShadows — elevation / box-shadow tokens
// ---------------------------------------------------------------------------

class AppShadows {
  AppShadows._();

  /// Panel at rest — soft, diffused shadow.
  static const List<BoxShadow> panelRest = [
    BoxShadow(
      color: Color(0x09000000), // black @ ~3.5 %
      offset: Offset(0, 10),
      blurRadius: 24,
    ),
  ];

  /// Panel on hover — deeper, more pronounced shadow.
  static const List<BoxShadow> panelHover = [
    BoxShadow(
      color: Color(0x14000000), // black @ ~8 %
      offset: Offset(0, 14),
      blurRadius: 32,
    ),
  ];
}

// ---------------------------------------------------------------------------
// Deprecated aliases — kept for gradual migration, will be removed.
// ---------------------------------------------------------------------------

@Deprecated('Use AppRadii.panel')
const double kPanelRadius = AppRadii.panel;

@Deprecated('Use AppRadii.button')
const double kButtonRadius = AppRadii.button;

@Deprecated('Use AppRadii.input')
const double kInputRadius = AppRadii.input;

@Deprecated('Use AppFonts.displayFamily')
final String? kDisplayFontFamily = AppFonts.displayFamily;

@Deprecated('Use AppFonts.monoFamily')
final String? kMonoFontFamily = AppFonts.monoFamily;
