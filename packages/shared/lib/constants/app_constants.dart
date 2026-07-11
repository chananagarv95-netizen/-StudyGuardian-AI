/// Application-wide constants for StudyGuardian AI.
///
/// Contains static configuration values used across the entire application,
/// including sync intervals, battery thresholds, device limits, and defaults.
library;

/// Centralized constants for the StudyGuardian AI application.
///
/// All values are compile-time constants and should not be modified at runtime.
/// For user-configurable settings, use a dedicated settings/preferences service.
class AppConstants {
  // Prevent instantiation.
  AppConstants._();

  /// The display name of the application.
  static const String appName = 'StudyGuardian AI';

  /// The current semantic version of the application.
  static const String appVersion = '1.0.0';

  /// The interval (in minutes) between automatic data sync operations.
  ///
  /// Controls how frequently the app synchronizes local data with Firebase.
  static const int syncIntervalMinutes = 15;

  /// Battery percentage threshold considered "low".
  ///
  /// When a child's device battery drops below this level, a notification
  /// is sent to the parent.
  static const int batteryLowThreshold = 20;

  /// Battery percentage value representing a fully charged device.
  static const int batteryFullThreshold = 100;

  /// Maximum number of child devices a single family can monitor.
  static const int maxDevicesPerFamily = 10;

  /// Length of the alphanumeric pairing code used to link a child device
  /// to a parent account.
  static const int pairingCodeLength = 6;

  /// Default daily study goal in minutes for a newly added child device.
  ///
  /// Can be overridden per-device in the parent dashboard settings.
  static const int defaultStudyGoalMinutes = 120;
}
