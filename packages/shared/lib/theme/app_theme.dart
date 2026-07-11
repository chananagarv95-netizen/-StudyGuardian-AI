/// Material 3 theme definitions for StudyGuardian AI.
///
/// Provides fully configured [ThemeData] for both light and dark modes,
/// wiring up [AppColors] and [AppTypography] into every relevant theme
/// component.
library;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Light and dark [ThemeData] for the application.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
/// );
/// ```
class AppTheme {
  // Prevent instantiation.
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  /// Fully configured Material 3 light theme.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,

      // -- Text --
      textTheme: TextTheme(
        displayLarge:
            AppTypography.displayLarge.copyWith(color: AppColors.lightText),
        displayMedium:
            AppTypography.displayMedium.copyWith(color: AppColors.lightText),
        displaySmall:
            AppTypography.displaySmall.copyWith(color: AppColors.lightText),
        headlineLarge:
            AppTypography.headlineLarge.copyWith(color: AppColors.lightText),
        headlineMedium:
            AppTypography.headlineMedium.copyWith(color: AppColors.lightText),
        headlineSmall:
            AppTypography.headlineSmall.copyWith(color: AppColors.lightText),
        titleLarge:
            AppTypography.titleLarge.copyWith(color: AppColors.lightText),
        titleMedium:
            AppTypography.titleMedium.copyWith(color: AppColors.lightText),
        titleSmall:
            AppTypography.titleSmall.copyWith(color: AppColors.lightText),
        bodyLarge:
            AppTypography.bodyLarge.copyWith(color: AppColors.lightText),
        bodyMedium:
            AppTypography.bodyMedium.copyWith(color: AppColors.lightText),
        bodySmall: AppTypography.bodySmall
            .copyWith(color: AppColors.lightTextSecondary),
        labelLarge:
            AppTypography.labelLarge.copyWith(color: AppColors.lightText),
        labelMedium: AppTypography.labelMedium
            .copyWith(color: AppColors.lightTextSecondary),
        labelSmall: AppTypography.labelSmall
            .copyWith(color: AppColors.lightTextSecondary),
      ),

      // -- App bar --
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.lightText,
        centerTitle: true,
        titleTextStyle:
            AppTypography.titleLarge.copyWith(color: AppColors.lightText),
      ),

      // -- Cards --
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // -- Elevated button --
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // -- Outlined button --
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // -- Input fields --
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // -- Bottom navigation --
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightTextSecondary,
      ),

      // -- FAB --
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),

      // -- Divider --
      dividerTheme: const DividerThemeData(
        color: AppColors.lightCard,
        thickness: 1,
      ),

      // -- Chip --
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightCard,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: AppTypography.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  /// Fully configured Material 3 dark theme.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,

      // -- Text --
      textTheme: TextTheme(
        displayLarge:
            AppTypography.displayLarge.copyWith(color: AppColors.darkText),
        displayMedium:
            AppTypography.displayMedium.copyWith(color: AppColors.darkText),
        displaySmall:
            AppTypography.displaySmall.copyWith(color: AppColors.darkText),
        headlineLarge:
            AppTypography.headlineLarge.copyWith(color: AppColors.darkText),
        headlineMedium:
            AppTypography.headlineMedium.copyWith(color: AppColors.darkText),
        headlineSmall:
            AppTypography.headlineSmall.copyWith(color: AppColors.darkText),
        titleLarge:
            AppTypography.titleLarge.copyWith(color: AppColors.darkText),
        titleMedium:
            AppTypography.titleMedium.copyWith(color: AppColors.darkText),
        titleSmall:
            AppTypography.titleSmall.copyWith(color: AppColors.darkText),
        bodyLarge:
            AppTypography.bodyLarge.copyWith(color: AppColors.darkText),
        bodyMedium:
            AppTypography.bodyMedium.copyWith(color: AppColors.darkText),
        bodySmall: AppTypography.bodySmall
            .copyWith(color: AppColors.darkTextSecondary),
        labelLarge:
            AppTypography.labelLarge.copyWith(color: AppColors.darkText),
        labelMedium: AppTypography.labelMedium
            .copyWith(color: AppColors.darkTextSecondary),
        labelSmall: AppTypography.labelSmall
            .copyWith(color: AppColors.darkTextSecondary),
      ),

      // -- App bar --
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.darkText,
        centerTitle: true,
        titleTextStyle:
            AppTypography.titleLarge.copyWith(color: AppColors.darkText),
      ),

      // -- Cards --
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // -- Elevated button --
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // -- Outlined button --
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // -- Input fields --
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // -- Bottom navigation --
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkTextSecondary,
      ),

      // -- FAB --
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),

      // -- Divider --
      dividerTheme: const DividerThemeData(
        color: AppColors.darkCard,
        thickness: 1,
      ),

      // -- Chip --
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: AppTypography.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
