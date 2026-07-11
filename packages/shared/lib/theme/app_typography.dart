/// Typography scale for StudyGuardian AI.
///
/// Follows the Material 3 type scale using Google Fonts [Outfit] for display
/// and headline styles, and [Inter] for body, title, and label styles.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provides a complete Material 3 type scale using premium Google Fonts.
///
/// Usage:
/// ```dart
/// Text('Hello', style: AppTypography.headlineMedium);
/// ```
///
/// All getters return new [TextStyle] instances so callers can safely use
/// `.copyWith(...)` without affecting other consumers.
class AppTypography {
  // Prevent instantiation.
  AppTypography._();

  // ---------------------------------------------------------------------------
  // Display
  // ---------------------------------------------------------------------------

  /// Display Large — 57 sp, Outfit, regular weight.
  static TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      );

  /// Display Medium — 45 sp, Outfit, regular weight.
  static TextStyle get displayMedium => GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      );

  /// Display Small — 36 sp, Outfit, regular weight.
  static TextStyle get displaySmall => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      );

  // ---------------------------------------------------------------------------
  // Headline
  // ---------------------------------------------------------------------------

  /// Headline Large — 32 sp, Outfit, semi-bold.
  static TextStyle get headlineLarge => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      );

  /// Headline Medium — 28 sp, Outfit, semi-bold.
  static TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );

  /// Headline Small — 24 sp, Outfit, semi-bold.
  static TextStyle get headlineSmall => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  // ---------------------------------------------------------------------------
  // Title
  // ---------------------------------------------------------------------------

  /// Title Large — 22 sp, Outfit, medium weight.
  static TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      );

  /// Title Medium — 16 sp, Inter, medium weight.
  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      );

  /// Title Small — 14 sp, Inter, medium weight.
  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  /// Body Large — 16 sp, Inter, regular weight.
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );

  /// Body Medium — 14 sp, Inter, regular weight.
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      );

  /// Body Small — 12 sp, Inter, regular weight.
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  // ---------------------------------------------------------------------------
  // Label
  // ---------------------------------------------------------------------------

  /// Label Large — 14 sp, Inter, medium weight.
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  /// Label Medium — 12 sp, Inter, medium weight.
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  /// Label Small — 11 sp, Inter, medium weight.
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );
}
