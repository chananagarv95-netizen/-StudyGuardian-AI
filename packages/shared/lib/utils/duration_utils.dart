/// Utility class for formatting and converting duration values.
///
/// All methods accept minutes as the base unit and provide various
/// human-readable formatting options for screen time display.
class DurationUtils {
  DurationUtils._();

  /// Formats [minutes] into a compact duration string.
  ///
  /// Examples:
  /// - `formatDuration(155)` → `'2h 35m'`
  /// - `formatDuration(45)` → `'45m'`
  /// - `formatDuration(0)` → `'0m'`
  /// - `formatDuration(120)` → `'2h 0m'`
  static String formatDuration(int minutes) {
    if (minutes <= 0) return '0m';

    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;

    if (hours == 0) return '${mins}m';
    return '${hours}h ${mins}m';
  }

  /// Formats [minutes] into a verbose, spelled-out duration string.
  ///
  /// Examples:
  /// - `formatMinutes(252)` → `'4 hours 12 minutes'`
  /// - `formatMinutes(45)` → `'45 minutes'`
  /// - `formatMinutes(60)` → `'1 hour 0 minutes'`
  /// - `formatMinutes(0)` → `'0 minutes'`
  /// - `formatMinutes(1)` → `'1 minute'`
  /// - `formatMinutes(61)` → `'1 hour 1 minute'`
  static String formatMinutes(int minutes) {
    if (minutes <= 0) return '0 minutes';

    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;

    if (hours == 0) {
      return '$mins ${mins == 1 ? 'minute' : 'minutes'}';
    }

    final String hourPart = '$hours ${hours == 1 ? 'hour' : 'hours'}';
    final String minutePart = '$mins ${mins == 1 ? 'minute' : 'minutes'}';
    return '$hourPart $minutePart';
  }

  /// Converts [minutes] to hours, rounded to 1 decimal place.
  ///
  /// Example:
  /// - `minutesToHours(150)` → `2.5`
  /// - `minutesToHours(0)` → `0.0`
  static double minutesToHours(int minutes) {
    return double.parse((minutes / 60.0).toStringAsFixed(1));
  }

  /// Formats [minutes] into a screen-time display string.
  ///
  /// Similar to [formatDuration] but handles edge cases for screen time:
  /// - Returns `'< 1 min'` for 0 minutes.
  /// - Includes days for very large values (1440+ minutes).
  ///
  /// Examples:
  /// - `formatScreenTime(0)` → `'< 1 min'`
  /// - `formatScreenTime(45)` → `'45m'`
  /// - `formatScreenTime(155)` → `'2h 35m'`
  /// - `formatScreenTime(1500)` → `'1d 1h 0m'`
  /// - `formatScreenTime(2880)` → `'2d 0h 0m'`
  static String formatScreenTime(int minutes) {
    if (minutes <= 0) return '< 1 min';

    final int days = minutes ~/ 1440;
    final int remainingAfterDays = minutes % 1440;
    final int hours = remainingAfterDays ~/ 60;
    final int mins = remainingAfterDays % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${mins}m';
    }

    if (hours == 0) return '${mins}m';
    return '${hours}h ${mins}m';
  }
}
