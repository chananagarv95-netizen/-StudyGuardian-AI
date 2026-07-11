import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_category.dart';

/// Represents the usage statistics of a single application.
///
/// Tracks foreground/background time, open count, longest session duration,
/// and the application's category classification. Used as a component within
/// [DailyUsageModel] to provide per-app breakdowns.
class AppUsageModel {
  /// The unique package name of the application (e.g., "com.google.classroom").
  final String packageName;

  /// The user-facing display name of the application.
  final String appName;

  /// The category this application belongs to.
  final AppCategory category;

  /// Total time the app was in the foreground, in minutes.
  final int foregroundTime;

  /// Total time the app was running in the background, in minutes.
  final int backgroundTime;

  /// Number of times the app was opened during the period.
  final int openCount;

  /// Duration of the longest single session, in minutes.
  final int longestSession;

  /// Base64-encoded app icon, if available.
  final String? iconBase64;

  const AppUsageModel({
    required this.packageName,
    required this.appName,
    required this.category,
    required this.foregroundTime,
    required this.backgroundTime,
    required this.openCount,
    required this.longestSession,
    this.iconBase64,
  });

  /// Total usage time (foreground + background) in minutes.
  int get totalTime => foregroundTime + backgroundTime;

  /// Whether this app is in a productive category.
  bool get isProductive => category.isProductive;

  /// Whether this app is in a distracting category.
  bool get isDistracting => category.isDistracting;

  /// Creates an [AppUsageModel] from a Firestore [DocumentSnapshot].
  factory AppUsageModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUsageModel.fromMap(data);
  }

  /// Creates an [AppUsageModel] from a [Map].
  ///
  /// Useful for deserializing nested data within other Firestore documents.
  factory AppUsageModel.fromMap(Map<String, dynamic> map) {
    return AppUsageModel(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      category: AppCategory.fromString(map['category'] as String?),
      foregroundTime: (map['foregroundTime'] as num?)?.toInt() ?? 0,
      backgroundTime: (map['backgroundTime'] as num?)?.toInt() ?? 0,
      openCount: (map['openCount'] as num?)?.toInt() ?? 0,
      longestSession: (map['longestSession'] as num?)?.toInt() ?? 0,
      iconBase64: map['iconBase64'] as String?,
    );
  }

  /// Converts this model to a [Map] suitable for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'category': category.name,
      'foregroundTime': foregroundTime,
      'backgroundTime': backgroundTime,
      'openCount': openCount,
      'longestSession': longestSession,
      'iconBase64': iconBase64,
    };
  }

  /// Alias for [toMap] for Firestore serialization consistency.
  Map<String, dynamic> toFirestore() => toMap();

  /// Creates an [AppUsageModel] from a plain JSON map.
  factory AppUsageModel.fromJson(Map<String, dynamic> json) {
    return AppUsageModel.fromMap(json);
  }

  /// Converts this model to a plain JSON map.
  Map<String, dynamic> toJson() => toMap();

  /// Creates a copy of this model with the given fields replaced.
  AppUsageModel copyWith({
    String? packageName,
    String? appName,
    AppCategory? category,
    int? foregroundTime,
    int? backgroundTime,
    int? openCount,
    int? longestSession,
    String? iconBase64,
  }) {
    return AppUsageModel(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      category: category ?? this.category,
      foregroundTime: foregroundTime ?? this.foregroundTime,
      backgroundTime: backgroundTime ?? this.backgroundTime,
      openCount: openCount ?? this.openCount,
      longestSession: longestSession ?? this.longestSession,
      iconBase64: iconBase64 ?? this.iconBase64,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUsageModel &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;

  @override
  String toString() =>
      'AppUsageModel(packageName: $packageName, appName: $appName, '
      'category: ${category.displayName}, foregroundTime: ${foregroundTime}m)';
}
