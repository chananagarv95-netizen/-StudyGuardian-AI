/// Visual mappings (colors, icons, emojis) for app categories.
///
/// Used by the parent dashboard and child device UI to present app usage
/// data with consistent, recognisable visual cues.
library;

import 'package:flutter/material.dart';

import '../models/app_category.dart';

/// Provides colour, icon, and emoji mappings for every [AppCategory].
///
/// All maps are compile-time constants where possible.  The emoji helper
/// is a regular static method since `switch` expressions on enums are not
/// const-evaluable.
class CategoryMappings {
  // Prevent instantiation.
  CategoryMappings._();

  // ---------------------------------------------------------------------------
  // Colours
  // ---------------------------------------------------------------------------

  /// Distinct vibrant colours associated with each [AppCategory].
  static const Map<AppCategory, Color> categoryColors = {
    AppCategory.education: Color(0xFF4CAF50), // green
    AppCategory.games: Color(0xFFE91E63), // pink
    AppCategory.entertainment: Color(0xFF9C27B0), // purple
    AppCategory.socialMedia: Color(0xFF2196F3), // blue
    AppCategory.communication: Color(0xFF00BCD4), // cyan
    AppCategory.productivity: Color(0xFF607D8B), // blue-grey
    AppCategory.shopping: Color(0xFFFF9800), // orange
    AppCategory.finance: Color(0xFF795548), // brown
    AppCategory.ai: Color(0xFF6366F1), // indigo
    AppCategory.system: Color(0xFF9E9E9E), // grey
    AppCategory.utilities: Color(0xFF8BC34A), // light green
    AppCategory.others: Color(0xFFBDBDBD), // light grey
  };

  // ---------------------------------------------------------------------------
  // Icons
  // ---------------------------------------------------------------------------

  /// Material Design icons representing each [AppCategory].
  static const Map<AppCategory, IconData> categoryIcons = {
    AppCategory.education: Icons.school,
    AppCategory.games: Icons.sports_esports,
    AppCategory.entertainment: Icons.movie,
    AppCategory.socialMedia: Icons.people,
    AppCategory.communication: Icons.chat,
    AppCategory.productivity: Icons.work,
    AppCategory.shopping: Icons.shopping_cart,
    AppCategory.finance: Icons.account_balance,
    AppCategory.ai: Icons.auto_awesome,
    AppCategory.system: Icons.settings,
    AppCategory.utilities: Icons.build,
    AppCategory.others: Icons.apps,
  };

  // ---------------------------------------------------------------------------
  // Emojis
  // ---------------------------------------------------------------------------

  /// Returns a single emoji character that represents the given [category].
  ///
  /// Useful for quick textual representations in notifications and summaries.
  static String getCategoryEmoji(AppCategory category) {
    return switch (category) {
      AppCategory.education => '📚',
      AppCategory.games => '🎮',
      AppCategory.entertainment => '🎬',
      AppCategory.socialMedia => '👥',
      AppCategory.communication => '💬',
      AppCategory.productivity => '💼',
      AppCategory.shopping => '🛒',
      AppCategory.finance => '🏦',
      AppCategory.ai => '🤖',
      AppCategory.system => '⚙️',
      AppCategory.utilities => '🔧',
      AppCategory.others => '📱',
    };
  }
}
