import 'package:intl/intl.dart';

/// Utility class for date and time operations.
///
/// Named [AppDateUtils] to avoid conflict with Flutter's built-in [DateUtils].
/// All methods are static and provide consistent date/time formatting
/// throughout the application.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');
  static final DateFormat _dateKeyFormat = DateFormat('yyyy-MM-dd');

  /// Formats a [DateTime] as a human-readable date string.
  ///
  /// Example: `'Jan 15, 2024'`
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formats a [DateTime] as a human-readable time string.
  ///
  /// Example: `'2:30 PM'`
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Formats a [DateTime] as a combined date and time string.
  ///
  /// Example: `'Jan 15, 2024 2:30 PM'`
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Returns the date as a sortable key string in `yyyy-MM-dd` format.
  ///
  /// Useful for map keys, database lookups, and comparisons.
  ///
  /// Example: `'2024-01-15'`
  static String getDateKey(DateTime date) {
    return _dateKeyFormat.format(date);
  }

  /// Returns the start (Monday) and end (Sunday) of the week containing [date].
  ///
  /// The week starts on Monday (ISO 8601 convention).
  /// Both returned dates are at midnight (00:00:00).
  static (DateTime, DateTime) getWeekRange(DateTime date) {
    // DateTime.weekday: Monday = 1, Sunday = 7
    final int daysFromMonday = date.weekday - DateTime.monday;
    final DateTime startOfWeek = DateTime(
      date.year,
      date.month,
      date.day - daysFromMonday,
    );
    final DateTime endOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day + 6,
    );
    return (startOfWeek, endOfWeek);
  }

  /// Returns the first and last day of the month containing [date].
  ///
  /// Both returned dates are at midnight (00:00:00).
  static (DateTime, DateTime) getMonthRange(DateTime date) {
    final DateTime firstDay = DateTime(date.year, date.month, 1);
    final DateTime lastDay = DateTime(date.year, date.month + 1, 0);
    return (firstDay, lastDay);
  }

  /// Returns a human-readable relative time string for [dateTime].
  ///
  /// Examples:
  /// - `'Just now'` (within the last 60 seconds)
  /// - `'5 minutes ago'`
  /// - `'2 hours ago'`
  /// - `'Yesterday'`
  /// - `'3 days ago'`
  /// - `'Jan 15, 2024'` (more than 7 days ago)
  static String timeAgo(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.isNegative) {
      return formatDate(dateTime);
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final int minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }

    if (difference.inHours < 24) {
      final int hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    if (isYesterday(dateTime)) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      final int days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }

    return formatDate(dateTime);
  }

  /// Returns `true` if [date] is today.
  static bool isToday(DateTime date) {
    final DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns `true` if [date] is yesterday.
  static bool isYesterday(DateTime date) {
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Returns `true` if [date] falls within the current ISO week
  /// (Monday through Sunday).
  static bool isThisWeek(DateTime date) {
    final DateTime now = DateTime.now();
    final (DateTime startOfWeek, DateTime endOfWeek) = getWeekRange(now);

    final DateTime dateOnly = DateTime(date.year, date.month, date.day);
    final DateTime endOfWeekEnd = DateTime(
      endOfWeek.year,
      endOfWeek.month,
      endOfWeek.day,
      23,
      59,
      59,
    );

    return !dateOnly.isBefore(startOfWeek) &&
        !dateOnly.isAfter(endOfWeekEnd);
  }
}
