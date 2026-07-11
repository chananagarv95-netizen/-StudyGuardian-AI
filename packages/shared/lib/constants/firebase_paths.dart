/// Firestore collection and document path constants for StudyGuardian AI.
///
/// Provides a single source of truth for all Firestore paths used throughout
/// the application, ensuring consistency and preventing typos.
library;

/// Static constants and helper methods for constructing Firestore document
/// and collection paths.
///
/// Usage:
/// ```dart
/// final ref = FirebaseFirestore.instance.doc(FirebasePaths.userDoc(uid));
/// ```
class FirebasePaths {
  // Prevent instantiation.
  FirebasePaths._();

  // ---------------------------------------------------------------------------
  // Collection names
  // ---------------------------------------------------------------------------

  /// Top-level collection for user profiles.
  static const String users = 'users';

  /// Top-level collection for family groups.
  static const String families = 'families';

  /// Top-level collection for registered child devices.
  static const String devices = 'devices';

  /// Top-level collection for real-time device status snapshots.
  static const String deviceStatus = 'device_status';

  /// Top-level collection for aggregated daily usage documents.
  static const String dailyUsage = 'daily_usage';

  /// Top-level collection for per-device, per-day study analytics.
  static const String studyAnalytics = 'study_analytics';

  /// Top-level collection for generated reports (daily / weekly).
  static const String reports = 'reports';

  /// Top-level collection for in-app notifications.
  static const String notifications = 'notifications';

  /// Top-level collection for queued push-notification payloads awaiting
  /// delivery via Cloud Functions.
  static const String notificationQueue = 'notification_queue';

  /// Top-level collection for granular per-app usage records.
  static const String appUsage = 'app_usage';

  // ---------------------------------------------------------------------------
  // Document path helpers
  // ---------------------------------------------------------------------------

  /// Returns the Firestore path for a specific user document.
  static String userDoc(String userId) => '$users/$userId';

  /// Returns the Firestore path for a specific family document.
  static String familyDoc(String familyId) => '$families/$familyId';

  /// Returns the Firestore path for a specific device document.
  static String deviceDoc(String deviceId) => '$devices/$deviceId';

  /// Returns the Firestore path for a specific device status document.
  static String deviceStatusDoc(String deviceId) =>
      '$deviceStatus/$deviceId';

  /// Returns the Firestore path for a daily usage document.
  ///
  /// The [date] parameter should be in `yyyy-MM-dd` format.
  static String dailyUsageDoc(String deviceId, String date) =>
      '$dailyUsage/${deviceId}_$date';

  /// Returns the Firestore path for a study analytics document.
  ///
  /// The [date] parameter should be in `yyyy-MM-dd` format.
  static String studyAnalyticsDoc(String deviceId, String date) =>
      '$studyAnalytics/${deviceId}_$date';

  /// Returns the Firestore path for a specific report document.
  static String reportDoc(String reportId) => '$reports/$reportId';

  /// Returns the Firestore path for a specific notification document.
  static String notificationDoc(String notificationId) =>
      '$notifications/$notificationId';
}
