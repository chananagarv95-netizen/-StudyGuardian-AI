import 'package:logger/logger.dart';

/// Application-wide logger providing tagged, leveled logging.
///
/// Wraps the `logger` package with a consistent API and pretty-printed output.
/// All methods are static for convenient access throughout the codebase.
///
/// Usage:
/// ```dart
/// AppLogger.d('MyClass', 'Debug message');
/// AppLogger.i('MyClass', 'Info message');
/// AppLogger.w('MyClass', 'Warning message');
/// AppLogger.e('MyClass', 'Error occurred', error, stackTrace);
/// ```
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Logs a debug-level message with the given [tag] and [message].
  ///
  /// Use for granular information useful during development and debugging.
  static void d(String tag, String message) {
    _logger.d('[$tag] $message');
  }

  /// Logs an info-level message with the given [tag] and [message].
  ///
  /// Use for general operational information (e.g., lifecycle events).
  static void i(String tag, String message) {
    _logger.i('[$tag] $message');
  }

  /// Logs a warning-level message with the given [tag] and [message].
  ///
  /// Use for potentially harmful situations that don't prevent execution.
  static void w(String tag, String message) {
    _logger.w('[$tag] $message');
  }

  /// Logs an error-level message with the given [tag], [message],
  /// optional [error] object, and optional [stackTrace].
  ///
  /// Use for error events that might still allow the app to continue running.
  static void e(
    String tag,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _logger.e('[$tag] $message', error: error, stackTrace: stackTrace);
  }
}
