import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_usage_model.dart';

/// Represents the aggregated usage data for a single device on a single day.
///
/// Includes total screen time, unlock count, per-app usage breakdown, and
/// an hourly usage breakdown for detailed time-of-day analysis.
class DailyUsageModel {
  /// The ID of the device this usage data belongs to.
  final String deviceId;

  /// The date of this usage record in `yyyy-MM-dd` format.
  final String date;

  /// Total screen-on time for the day, in minutes.
  final int totalScreenTime;

  /// Number of times the device was unlocked during the day.
  final int unlockCount;

  /// Total time the screen was on, in minutes.
  final int screenOnTime;

  /// Total time the screen was off, in minutes.
  final int screenOffTime;

  /// Per-application usage breakdown for the day.
  final List<AppUsageModel> apps;

  /// Hour-by-hour usage breakdown, keyed by hour (0–23).
  final Map<int, HourlyUsage> hourlyBreakdown;

  const DailyUsageModel({
    required this.deviceId,
    required this.date,
    required this.totalScreenTime,
    required this.unlockCount,
    required this.screenOnTime,
    required this.screenOffTime,
    this.apps = const [],
    this.hourlyBreakdown = const {},
  });

  /// Total screen time formatted as hours and minutes (e.g., "3h 25m").
  String get formattedScreenTime {
    final hours = totalScreenTime ~/ 60;
    final minutes = totalScreenTime % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  /// Returns apps sorted by foreground time in descending order.
  List<AppUsageModel> get topApps {
    final sorted = List<AppUsageModel>.from(apps);
    sorted.sort((a, b) => b.foregroundTime.compareTo(a.foregroundTime));
    return sorted;
  }

  /// Creates a [DailyUsageModel] from a Firestore [DocumentSnapshot].
  factory DailyUsageModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DailyUsageModel(
      deviceId: data['deviceId'] as String? ?? '',
      date: data['date'] as String? ?? '',
      totalScreenTime: (data['totalScreenTime'] as num?)?.toInt() ?? 0,
      unlockCount: (data['unlockCount'] as num?)?.toInt() ?? 0,
      screenOnTime: (data['screenOnTime'] as num?)?.toInt() ?? 0,
      screenOffTime: (data['screenOffTime'] as num?)?.toInt() ?? 0,
      apps: (data['apps'] as List<dynamic>?)
              ?.map((e) =>
                  AppUsageModel.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      hourlyBreakdown: _parseHourlyBreakdown(
          data['hourlyBreakdown'] as Map<String, dynamic>?),
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'deviceId': deviceId,
      'date': date,
      'totalScreenTime': totalScreenTime,
      'unlockCount': unlockCount,
      'screenOnTime': screenOnTime,
      'screenOffTime': screenOffTime,
      'apps': apps.map((app) => app.toMap()).toList(),
      'hourlyBreakdown': hourlyBreakdown.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
    };
  }

  /// Creates a [DailyUsageModel] from a plain JSON map.
  factory DailyUsageModel.fromJson(Map<String, dynamic> json) {
    return DailyUsageModel(
      deviceId: json['deviceId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      totalScreenTime: (json['totalScreenTime'] as num?)?.toInt() ?? 0,
      unlockCount: (json['unlockCount'] as num?)?.toInt() ?? 0,
      screenOnTime: (json['screenOnTime'] as num?)?.toInt() ?? 0,
      screenOffTime: (json['screenOffTime'] as num?)?.toInt() ?? 0,
      apps: (json['apps'] as List<dynamic>?)
              ?.map((e) =>
                  AppUsageModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      hourlyBreakdown: _parseHourlyBreakdown(
          json['hourlyBreakdown'] as Map<String, dynamic>?),
    );
  }

  /// Converts this model to a plain JSON map.
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'date': date,
      'totalScreenTime': totalScreenTime,
      'unlockCount': unlockCount,
      'screenOnTime': screenOnTime,
      'screenOffTime': screenOffTime,
      'apps': apps.map((app) => app.toJson()).toList(),
      'hourlyBreakdown': hourlyBreakdown.map(
        (key, value) => MapEntry(key.toString(), value.toJson()),
      ),
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  DailyUsageModel copyWith({
    String? deviceId,
    String? date,
    int? totalScreenTime,
    int? unlockCount,
    int? screenOnTime,
    int? screenOffTime,
    List<AppUsageModel>? apps,
    Map<int, HourlyUsage>? hourlyBreakdown,
  }) {
    return DailyUsageModel(
      deviceId: deviceId ?? this.deviceId,
      date: date ?? this.date,
      totalScreenTime: totalScreenTime ?? this.totalScreenTime,
      unlockCount: unlockCount ?? this.unlockCount,
      screenOnTime: screenOnTime ?? this.screenOnTime,
      screenOffTime: screenOffTime ?? this.screenOffTime,
      apps: apps ?? this.apps,
      hourlyBreakdown: hourlyBreakdown ?? this.hourlyBreakdown,
    );
  }

  /// Parses the hourly breakdown map from Firestore/JSON data.
  static Map<int, HourlyUsage> _parseHourlyBreakdown(
      Map<String, dynamic>? data) {
    if (data == null) return {};
    return data.map(
      (key, value) => MapEntry(
        int.tryParse(key) ?? 0,
        HourlyUsage.fromMap(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyUsageModel &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId &&
          date == other.date;

  @override
  int get hashCode => Object.hash(deviceId, date);

  @override
  String toString() =>
      'DailyUsageModel(deviceId: $deviceId, date: $date, '
      'totalScreenTime: ${formattedScreenTime}, unlockCount: $unlockCount, '
      'apps: ${apps.length})';
}

/// Represents usage data for a single hour within a day.
///
/// Used within [DailyUsageModel.hourlyBreakdown] to provide granular
/// time-of-day analysis of device usage patterns.
class HourlyUsage {
  /// Screen time during this hour, in minutes (0–60).
  final int screenTime;

  /// The most-used app during this hour (package name or display name).
  final String topApp;

  const HourlyUsage({
    required this.screenTime,
    required this.topApp,
  });

  /// Creates a [HourlyUsage] from a [Map].
  factory HourlyUsage.fromMap(Map<String, dynamic> map) {
    return HourlyUsage(
      screenTime: (map['screenTime'] as num?)?.toInt() ?? 0,
      topApp: map['topApp'] as String? ?? '',
    );
  }

  /// Converts this model to a [Map].
  Map<String, dynamic> toMap() {
    return {
      'screenTime': screenTime,
      'topApp': topApp,
    };
  }

  /// Creates a [HourlyUsage] from a plain JSON map.
  factory HourlyUsage.fromJson(Map<String, dynamic> json) {
    return HourlyUsage.fromMap(json);
  }

  /// Converts this model to a plain JSON map.
  Map<String, dynamic> toJson() => toMap();

  /// Creates a copy of this model with the given fields replaced.
  HourlyUsage copyWith({
    int? screenTime,
    String? topApp,
  }) {
    return HourlyUsage(
      screenTime: screenTime ?? this.screenTime,
      topApp: topApp ?? this.topApp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourlyUsage &&
          runtimeType == other.runtimeType &&
          screenTime == other.screenTime &&
          topApp == other.topApp;

  @override
  int get hashCode => Object.hash(screenTime, topApp);

  @override
  String toString() =>
      'HourlyUsage(screenTime: ${screenTime}m, topApp: $topApp)';
}
