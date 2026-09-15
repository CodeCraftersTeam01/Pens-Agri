import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stitch Bio-Digital Design Tokens for AgriPrecision Petani
class AppColors {
  // Brand & Vegetative Greens
  static const Color primary = Color(0xFF006B2C);
  static const Color primaryLight = Color(0xFF16A34A);
  static const Color primaryContainer = Color(0xFF00873A);
  static const Color onPrimaryContainer = Color(0xFFF7FFF2);
  static const Color primaryFixed = Color(0xFF7FFC97);
  static const Color primaryFixedDim = Color(0xFF62DF7D);
  static const Color onPrimaryFixed = Color(0xFF002109);
  static const Color onPrimary = Colors.white;

  // Earth / Humus Tones
  static const Color secondary = Color(0xFF8A5112);
  static const Color secondaryContainer = Color(0xFFFFB46E);
  static const Color secondaryFixed = Color(0xFFFFDCC0);
  static const Color secondaryFixedDim = Color(0xFFFFB877);
  static const Color onSecondary = Colors.white;

  // Warning & Amber Accents
  static const Color tertiary = Color(0xFF8D4B00);
  static const Color tertiaryAmber = Color(0xFFD97706);
  static const Color tertiaryContainer = Color(0xFFB15F00);
  static const Color tertiaryFixed = Color(0xFFFFDCC3);
  static const Color tertiaryFixedDim = Color(0xFFFFB77D);
  static const Color onTertiary = Colors.white;

  // Alert & Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorAlert = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Colors.white;

  // Neutral Surfaces & Canvas
  static const Color background = Color(0xFFF7F9FB);
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceDim = Color(0xFFD8DADC);
  static const Color surfaceBright = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);

  // Text & Lines
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF3E4A3D);
  static const Color outline = Color(0xFF6E7B6C);
  static const Color outlineVariant = Color(0xFFBDCABA);

  // Status Badges
  static const Color statusOptimalBg = Color(0xFFDCFCE7);
  static const Color statusOptimalText = Color(0xFF15803D);
  static const Color statusOptimalBorder = Color(0xFFBBF7D0);

  static const Color statusDeficitBg = Color(0xFFFEF3C7);
  static const Color statusDeficitText = Color(0xFFB45309);
  static const Color statusDeficitBorder = Color(0xFFFDE68A);

  static const Color statusExcessBg = Color(0xFFFEE2E2);
  static const Color statusExcessText = Color(0xFFB91C1C);
  static const Color statusExcessBorder = Color(0xFFFECACA);
}

/// Stitch Bio-Digital Typography Scales with Offline Fallback
class AppTypography {
  static const List<String> _fallback = ['Roboto', 'sans-serif'];

  static TextStyle display = GoogleFonts.plusJakartaSans(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.72,
    color: AppColors.onSurface,
  ).copyWith(fontFamilyFallback: _fallback);

  static TextStyle headlineLg = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.28,
    color: AppColors.onSurface,
  ).copyWith(fontFamilyFallback: _fallback);

  static TextStyle headlineMd = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  ).copyWith(fontFamilyFallback: _fallback);

  static TextStyle headlineSm = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  ).copyWith(fontFamilyFallback: _fallback);

  static TextStyle bodyLg = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  ).copyWith(fontFamilyFallback: _fallback);

  static TextStyle bodyMd = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  ).copyWith(fontFamilyFallback: _fallback);

  static TextStyle bodySm = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  ).copyWith(fontFamilyFallback: _fallback);

  static TextStyle labelMetric = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.72,
    color: AppColors.onSurface,
  ).copyWith(fontFamilyFallback: _fallback);

  static TextStyle labelMd = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.48,
    color: AppColors.onSurface,
  ).copyWith(fontFamilyFallback: _fallback);

  static TextStyle labelSm = GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.onSurface,
  ).copyWith(fontFamilyFallback: _fallback);
}
