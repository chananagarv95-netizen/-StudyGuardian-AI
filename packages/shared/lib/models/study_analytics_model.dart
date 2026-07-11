import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents AI-generated study analytics for a single device on a single day.
///
/// The StudyGuardian AI engine computes study, focus, and distraction scores
/// along with time breakdowns by category. An AI-generated summary provides
/// human-readable insights for parents.
class StudyAnalyticsModel {
  /// The ID of the device this analytics data belongs to.
  final String deviceId;

  /// The date of this analytics record in `yyyy-MM-dd` format.
  final String date;

  /// Overall study score (0–100), computed by the AI engine.
  ///
  /// Higher values indicate better study habits.
  final int studyScore;

  /// Focus score (0–100), measuring sustained attention during study sessions.
  final int focusScore;

  /// Distraction score (0–100), measuring interruptions and app-switching.
  ///
  /// Lower values are better (less distraction).
  final int distractionScore;

  /// Percentage of total screen time spent on productive apps (0.0–100.0).
  final double productivityPercent;

  /// Total hours spent on education-related apps.
  final double studyHours;

  /// Total hours spent on entertainment-related apps.
  final double entertainmentHours;

  /// Duration of the longest uninterrupted study session, in minutes.
  final int longestStudySession;

  /// Package names or display names of the most distracting apps used.
  final List<String> mostDistractingApps;

  /// AI-generated natural language summary of the day's study patterns.
  final String aiSummary;

  /// Total screen time for the day, in minutes.
  final int totalScreenTime;

  /// Time spent on education apps, in minutes.
  final int educationTime;

  /// Time spent on gaming apps, in minutes.
  final int gameTime;

  /// Time spent on social media apps, in minutes.
  final int socialMediaTime;

  const StudyAnalyticsModel({
    required this.deviceId,
    required this.date,
    required this.studyScore,
    required this.focusScore,
    required this.distractionScore,
    required this.productivityPercent,
    required this.studyHours,
    required this.entertainmentHours,
    required this.longestStudySession,
    this.mostDistractingApps = const [],
    required this.aiSummary,
    required this.totalScreenTime,
    required this.educationTime,
    required this.gameTime,
    required this.socialMediaTime,
  });

  /// Whether the study score is considered good (>= 70).
  bool get isGoodStudyDay => studyScore >= 70;

  /// Whether the distraction score is considered high (>= 60).
  bool get isHighDistraction => distractionScore >= 60;

  /// Formatted study hours string (e.g., "2h 30m").
  String get formattedStudyHours {
    final hours = studyHours.truncate();
    final minutes = ((studyHours - hours) * 60).round();
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  /// Creates a [StudyAnalyticsModel] from a Firestore [DocumentSnapshot].
  factory StudyAnalyticsModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return StudyAnalyticsModel(
      deviceId: data['deviceId'] as String? ?? '',
      date: data['date'] as String? ?? '',
      studyScore: (data['studyScore'] as num?)?.toInt() ?? 0,
      focusScore: (data['focusScore'] as num?)?.toInt() ?? 0,
      distractionScore: (data['distractionScore'] as num?)?.toInt() ?? 0,
      productivityPercent:
          (data['productivityPercent'] as num?)?.toDouble() ?? 0.0,
      studyHours: (data['studyHours'] as num?)?.toDouble() ?? 0.0,
      entertainmentHours:
          (data['entertainmentHours'] as num?)?.toDouble() ?? 0.0,
      longestStudySession:
          (data['longestStudySession'] as num?)?.toInt() ?? 0,
      mostDistractingApps:
          List<String>.from(data['mostDistractingApps'] as List? ?? []),
      aiSummary: data['aiSummary'] as String? ?? '',
      totalScreenTime: (data['totalScreenTime'] as num?)?.toInt() ?? 0,
      educationTime: (data['educationTime'] as num?)?.toInt() ?? 0,
      gameTime: (data['gameTime'] as num?)?.toInt() ?? 0,
      socialMediaTime: (data['socialMediaTime'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'deviceId': deviceId,
      'date': date,
      'studyScore': studyScore,
      'focusScore': focusScore,
      'distractionScore': distractionScore,
      'productivityPercent': productivityPercent,
      'studyHours': studyHours,
      'entertainmentHours': entertainmentHours,
      'longestStudySession': longestStudySession,
      'mostDistractingApps': mostDistractingApps,
      'aiSummary': aiSummary,
      'totalScreenTime': totalScreenTime,
      'educationTime': educationTime,
      'gameTime': gameTime,
      'socialMediaTime': socialMediaTime,
    };
  }

  /// Creates a [StudyAnalyticsModel] from a plain JSON map.
  factory StudyAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return StudyAnalyticsModel(
      deviceId: json['deviceId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      studyScore: (json['studyScore'] as num?)?.toInt() ?? 0,
      focusScore: (json['focusScore'] as num?)?.toInt() ?? 0,
      distractionScore: (json['distractionScore'] as num?)?.toInt() ?? 0,
      productivityPercent:
          (json['productivityPercent'] as num?)?.toDouble() ?? 0.0,
      studyHours: (json['studyHours'] as num?)?.toDouble() ?? 0.0,
      entertainmentHours:
          (json['entertainmentHours'] as num?)?.toDouble() ?? 0.0,
      longestStudySession:
          (json['longestStudySession'] as num?)?.toInt() ?? 0,
      mostDistractingApps:
          List<String>.from(json['mostDistractingApps'] as List? ?? []),
      aiSummary: json['aiSummary'] as String? ?? '',
      totalScreenTime: (json['totalScreenTime'] as num?)?.toInt() ?? 0,
      educationTime: (json['educationTime'] as num?)?.toInt() ?? 0,
      gameTime: (json['gameTime'] as num?)?.toInt() ?? 0,
      socialMediaTime: (json['socialMediaTime'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts this model to a plain JSON map.
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'date': date,
      'studyScore': studyScore,
      'focusScore': focusScore,
      'distractionScore': distractionScore,
      'productivityPercent': productivityPercent,
      'studyHours': studyHours,
      'entertainmentHours': entertainmentHours,
      'longestStudySession': longestStudySession,
      'mostDistractingApps': mostDistractingApps,
      'aiSummary': aiSummary,
      'totalScreenTime': totalScreenTime,
      'educationTime': educationTime,
      'gameTime': gameTime,
      'socialMediaTime': socialMediaTime,
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  StudyAnalyticsModel copyWith({
    String? deviceId,
    String? date,
    int? studyScore,
    int? focusScore,
    int? distractionScore,
    double? productivityPercent,
    double? studyHours,
    double? entertainmentHours,
    int? longestStudySession,
    List<String>? mostDistractingApps,
    String? aiSummary,
    int? totalScreenTime,
    int? educationTime,
    int? gameTime,
    int? socialMediaTime,
  }) {
    return StudyAnalyticsModel(
      deviceId: deviceId ?? this.deviceId,
      date: date ?? this.date,
      studyScore: studyScore ?? this.studyScore,
      focusScore: focusScore ?? this.focusScore,
      distractionScore: distractionScore ?? this.distractionScore,
      productivityPercent: productivityPercent ?? this.productivityPercent,
      studyHours: studyHours ?? this.studyHours,
      entertainmentHours: entertainmentHours ?? this.entertainmentHours,
      longestStudySession: longestStudySession ?? this.longestStudySession,
      mostDistractingApps: mostDistractingApps ?? this.mostDistractingApps,
      aiSummary: aiSummary ?? this.aiSummary,
      totalScreenTime: totalScreenTime ?? this.totalScreenTime,
      educationTime: educationTime ?? this.educationTime,
      gameTime: gameTime ?? this.gameTime,
      socialMediaTime: socialMediaTime ?? this.socialMediaTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyAnalyticsModel &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId &&
          date == other.date;

  @override
  int get hashCode => Object.hash(deviceId, date);

  @override
  String toString() =>
      'StudyAnalyticsModel(deviceId: $deviceId, date: $date, '
      'studyScore: $studyScore, focusScore: $focusScore, '
      'productivityPercent: ${productivityPercent.toStringAsFixed(1)}%)';
}
