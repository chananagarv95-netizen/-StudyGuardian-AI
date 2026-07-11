import 'package:flutter/material.dart';

/// Categorization of mobile applications for usage tracking and analytics.
///
/// Each category includes metadata for display (name, icon, color) and
/// classification helpers ([isProductive], [isDistracting]) used by the
/// StudyGuardian AI scoring engine.
enum AppCategory {
  education,
  games,
  entertainment,
  socialMedia,
  communication,
  productivity,
  shopping,
  finance,
  ai,
  system,
  utilities,
  others;

  /// Human-readable display name for this category.
  String get displayName {
    switch (this) {
      case AppCategory.education:
        return 'Education';
      case AppCategory.games:
        return 'Games';
      case AppCategory.entertainment:
        return 'Entertainment';
      case AppCategory.socialMedia:
        return 'Social Media';
      case AppCategory.communication:
        return 'Communication';
      case AppCategory.productivity:
        return 'Productivity';
      case AppCategory.shopping:
        return 'Shopping';
      case AppCategory.finance:
        return 'Finance';
      case AppCategory.ai:
        return 'AI';
      case AppCategory.system:
        return 'System';
      case AppCategory.utilities:
        return 'Utilities';
      case AppCategory.others:
        return 'Others';
    }
  }

  /// Material icon representing this category.
  IconData get icon {
    switch (this) {
      case AppCategory.education:
        return Icons.school_rounded;
      case AppCategory.games:
        return Icons.sports_esports_rounded;
      case AppCategory.entertainment:
        return Icons.movie_rounded;
      case AppCategory.socialMedia:
        return Icons.people_rounded;
      case AppCategory.communication:
        return Icons.chat_rounded;
      case AppCategory.productivity:
        return Icons.work_rounded;
      case AppCategory.shopping:
        return Icons.shopping_cart_rounded;
      case AppCategory.finance:
        return Icons.account_balance_rounded;
      case AppCategory.ai:
        return Icons.auto_awesome_rounded;
      case AppCategory.system:
        return Icons.settings_rounded;
      case AppCategory.utilities:
        return Icons.build_rounded;
      case AppCategory.others:
        return Icons.apps_rounded;
    }
  }

  /// Distinct vibrant color associated with this category for charts and UI.
  Color get color {
    switch (this) {
      case AppCategory.education:
        return const Color(0xFF4CAF50); // Green
      case AppCategory.games:
        return const Color(0xFFE91E63); // Pink
      case AppCategory.entertainment:
        return const Color(0xFFFF5722); // Deep Orange
      case AppCategory.socialMedia:
        return const Color(0xFF2196F3); // Blue
      case AppCategory.communication:
        return const Color(0xFF00BCD4); // Cyan
      case AppCategory.productivity:
        return const Color(0xFF673AB7); // Deep Purple
      case AppCategory.shopping:
        return const Color(0xFFFF9800); // Orange
      case AppCategory.finance:
        return const Color(0xFF009688); // Teal
      case AppCategory.ai:
        return const Color(0xFF9C27B0); // Purple
      case AppCategory.system:
        return const Color(0xFF607D8B); // Blue Grey
      case AppCategory.utilities:
        return const Color(0xFF795548); // Brown
      case AppCategory.others:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Whether this category is considered productive for study analytics.
  ///
  /// Productive categories positively influence the study score.
  bool get isProductive {
    switch (this) {
      case AppCategory.education:
      case AppCategory.productivity:
      case AppCategory.communication:
      case AppCategory.finance:
        return true;
      default:
        return false;
    }
  }

  /// Whether this category is considered distracting for study analytics.
  ///
  /// Distracting categories negatively influence the study score.
  bool get isDistracting {
    switch (this) {
      case AppCategory.games:
      case AppCategory.entertainment:
      case AppCategory.socialMedia:
        return true;
      default:
        return false;
    }
  }

  /// Parses a [String] value into an [AppCategory].
  ///
  /// Returns [AppCategory.others] if the value does not match any category.
  static AppCategory fromString(String? value) {
    if (value == null || value.isEmpty) return AppCategory.others;
    return AppCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => AppCategory.others,
    );
  }
}
