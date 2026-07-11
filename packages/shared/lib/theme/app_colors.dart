/// Application colour palette for StudyGuardian AI.
///
/// Defines all brand colours, semantic status colours, theme-specific surface
/// colours, category colour mappings, and reusable gradients.
library;

import 'package:flutter/material.dart';

import '../models/app_category.dart';

/// Centralised colour constants used by both the light and dark themes.
///
/// Colours follow a semantic naming convention so that UI code never hard-codes
/// hex values directly.
class AppColors {
  // Prevent instantiation.
  AppColors._();

  // ---------------------------------------------------------------------------
  // Primary
  // ---------------------------------------------------------------------------

  /// Deep indigo — the primary brand colour.
  static const Color primary = Color(0xFF6366F1);

  /// A lighter tint of [primary] for hover / focus states.
  static const Color primaryLight = Color(0xFF818CF8);

  /// A darker shade of [primary] for pressed states.
  static const Color primaryDark = Color(0xFF4F46E5);

  // ---------------------------------------------------------------------------
  // Secondary
  // ---------------------------------------------------------------------------

  /// Teal — used for complementary accents.
  static const Color secondary = Color(0xFF14B8A6);

  /// Lighter tint of [secondary].
  static const Color secondaryLight = Color(0xFF2DD4BF);

  /// Darker shade of [secondary].
  static const Color secondaryDark = Color(0xFF0D9488);

  // ---------------------------------------------------------------------------
  // Accent
  // ---------------------------------------------------------------------------

  /// Violet — used for highlights and decorative elements.
  static const Color accent = Color(0xFF8B5CF6);

  /// Lighter tint of [accent].
  static const Color accentLight = Color(0xFFA78BFA);

  /// Darker shade of [accent].
  static const Color accentDark = Color(0xFF7C3AED);

  // ---------------------------------------------------------------------------
  // Status / Semantic colours
  // ---------------------------------------------------------------------------

  /// Emerald — positive outcome / success indicator.
  static const Color success = Color(0xFF10B981);

  /// Amber — caution / warning indicator.
  static const Color warning = Color(0xFFF59E0B);

  /// Rose — error / destructive action indicator.
  static const Color error = Color(0xFFEF4444);

  /// Blue — informational indicator.
  static const Color info = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // Dark theme surfaces
  // ---------------------------------------------------------------------------

  /// Dark mode scaffold / page background.
  static const Color darkBackground = Color(0xFF0F172A);

  /// Dark mode elevated surface (e.g. app bar, bottom sheet).
  static const Color darkSurface = Color(0xFF1E293B);

  /// Dark mode card background.
  static const Color darkCard = Color(0xFF334155);

  /// Primary text colour on dark backgrounds.
  static const Color darkText = Color(0xFFF1F5F9);

  /// Secondary / muted text colour on dark backgrounds.
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------------
  // Light theme surfaces
  // ---------------------------------------------------------------------------

  /// Light mode scaffold / page background.
  static const Color lightBackground = Color(0xFFF8FAFC);

  /// Light mode elevated surface.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light mode card background.
  static const Color lightCard = Color(0xFFF1F5F9);

  /// Primary text colour on light backgrounds.
  static const Color lightText = Color(0xFF0F172A);

  /// Secondary / muted text colour on light backgrounds.
  static const Color lightTextSecondary = Color(0xFF64748B);

  // ---------------------------------------------------------------------------
  // Category colours
  // ---------------------------------------------------------------------------

  /// Colour assigned to each [AppCategory] for charts and badges.
  static const Map<AppCategory, Color> categoryColors = {
    AppCategory.education: Color(0xFF10B981),
    AppCategory.games: Color(0xFFEF4444),
    AppCategory.entertainment: Color(0xFF8B5CF6),
    AppCategory.socialMedia: Color(0xFF3B82F6),
    AppCategory.communication: Color(0xFF06B6D4),
    AppCategory.productivity: Color(0xFF6366F1),
    AppCategory.shopping: Color(0xFFF59E0B),
    AppCategory.finance: Color(0xFF14B8A6),
    AppCategory.ai: Color(0xFFA855F7),
    AppCategory.system: Color(0xFF64748B),
    AppCategory.utilities: Color(0xFF84CC16),
    AppCategory.others: Color(0xFF94A3B8),
  };

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------

  /// Primary brand gradient (indigo → violet).
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient (violet → light violet).
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient (emerald → teal).
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark-mode background gradient.
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
