/// Glassmorphism design utilities for StudyGuardian AI.
///
/// Provides factory methods that produce frosted-glass style decorations,
/// gradients, and borders following the glassmorphism design trend.
library;

import 'package:flutter/material.dart';

/// Static helpers for creating glassmorphism-style [BoxDecoration]s,
/// [LinearGradient]s, and [Border]s.
///
/// Example — light glass card:
/// ```dart
/// Container(
///   decoration: Glassmorphism.decoration(opacity: 0.12),
///   child: …,
/// )
/// ```
///
/// Example — dark glass card:
/// ```dart
/// Container(
///   decoration: Glassmorphism.darkDecoration(),
///   child: …,
/// )
/// ```
class Glassmorphism {
  // Prevent instantiation.
  Glassmorphism._();

  /// Creates a light glassmorphism [BoxDecoration].
  ///
  /// - [color] — tint colour (defaults to [Colors.white]).
  /// - [borderRadius] — corner radius in logical pixels.
  /// - [blur] — shadow blur radius.
  /// - [opacity] — alpha applied to [color].
  static BoxDecoration decoration({
    Color? color,
    double borderRadius = 16.0,
    double blur = 10.0,
    double opacity = 0.1,
  }) {
    final baseColor = color ?? Colors.white;
    return BoxDecoration(
      color: baseColor.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: blur,
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Creates a [LinearGradient] from the given [colors].
  ///
  /// Runs from top-left to bottom-right by default.
  static LinearGradient gradient(List<Color> colors) {
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Creates a subtle frosted-glass [Border].
  ///
  /// [color] defaults to semi-transparent white.
  static Border border({Color? color}) {
    return Border.all(
      color: (color ?? Colors.white).withValues(alpha: 0.2),
      width: 1.5,
    );
  }

  /// Creates a dark glassmorphism [BoxDecoration].
  ///
  /// Suitable for cards and containers on dark-themed screens.
  ///
  /// - [borderRadius] — corner radius in logical pixels.
  /// - [opacity] — alpha applied to the dark base colour.
  static BoxDecoration darkDecoration({
    double borderRadius = 16.0,
    double opacity = 0.15,
  }) {
    return BoxDecoration(
      color: Colors.black.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
