import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extensions on [BuildContext] for convenient access to theme data.
extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
}

/// Extensions on [DateTime] for formatting.
extension DateTimeExtensions on DateTime {
  /// Returns 'Today', 'Yesterday', or formatted date.
  String get friendlyDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(year, month, day);

    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(this);
  }

  /// Returns time as 'h:mm a' format.
  String get friendlyTime => DateFormat('h:mm a').format(this);

  /// Returns full date-time string.
  String get fullDateTime => DateFormat('MMM d, yyyy h:mm a').format(this);

  /// Returns date key in yyyy-MM-dd format.
  String get dateKey => DateFormat('yyyy-MM-dd').format(this);

  /// Returns human-readable time ago string.
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(this);
  }
}

/// Extensions on [String] for common transformations.
extension StringExtensions on String {
  /// Capitalizes the first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts package name to readable app name.
  String get packageToReadable {
    final parts = split('.');
    if (parts.length <= 1) return this;
    return parts.last.capitalize;
  }
}

/// Extensions on [num] for formatting.
extension NumExtensions on num {
  /// Formats number in compact form (e.g., 1.2K, 3.5M).
  String get compact {
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toStringAsFixed(0);
  }

  /// Formats bytes as human-readable storage string.
  String get formatBytes {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = toDouble();
    var i = 0;
    while (value >= 1024 && i < suffixes.length - 1) {
      value /= 1024;
      i++;
    }
    return '${value.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Formats percentage with one decimal.
  String get formatPercent => '${toStringAsFixed(1)}%';
}
