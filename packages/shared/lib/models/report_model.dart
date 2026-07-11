import 'package:cloud_firestore/cloud_firestore.dart';

/// The type of report period.
enum ReportType {
  daily,
  weekly,
  monthly;

  /// Human-readable display name for this report type.
  String get displayName {
    switch (this) {
      case ReportType.daily:
        return 'Daily Report';
      case ReportType.weekly:
        return 'Weekly Report';
      case ReportType.monthly:
        return 'Monthly Report';
    }
  }

  /// Parses a [String] value into a [ReportType].
  ///
  /// Returns [ReportType.daily] if the value does not match any type.
  static ReportType fromString(String? value) {
    if (value == null || value.isEmpty) return ReportType.daily;
    return ReportType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ReportType.daily,
    );
  }
}

/// Represents a generated analytics report for a device over a time period.
///
/// Reports aggregate [DailyUsageModel] and [StudyAnalyticsModel] data into
/// daily, weekly, or monthly summaries. The raw aggregated data is stored
/// in the [data] map for flexible rendering.
class ReportModel {
  /// Unique identifier for this report.
  final String id;

  /// The ID of the device this report covers.
  final String deviceId;

  /// The type of this report (daily, weekly, or monthly).
  final ReportType type;

  /// Start date of the report period (inclusive).
  final DateTime startDate;

  /// End date of the report period (inclusive).
  final DateTime endDate;

  /// Aggregated report data.
  ///
  /// Structure varies by [type] but typically includes averaged scores,
  /// total screen times, top apps, and trend data.
  final Map<String, dynamic> data;

  /// Timestamp when this report was generated.
  final DateTime generatedAt;

  const ReportModel({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.data = const {},
    required this.generatedAt,
  });

  /// Number of days covered by this report.
  int get durationDays => endDate.difference(startDate).inDays + 1;

  /// Creates a [ReportModel] from a Firestore [DocumentSnapshot].
  factory ReportModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final docData = doc.data() ?? {};
    return ReportModel(
      id: doc.id,
      deviceId: docData['deviceId'] as String? ?? '',
      type: ReportType.fromString(docData['type'] as String?),
      startDate:
          (docData['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate:
          (docData['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      data: Map<String, dynamic>.from(docData['data'] as Map? ?? {}),
      generatedAt:
          (docData['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'deviceId': deviceId,
      'type': type.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'data': data,
      'generatedAt': Timestamp.fromDate(generatedAt),
    };
  }

  /// Creates a [ReportModel] from a plain JSON map.
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      type: ReportType.fromString(json['type'] as String?),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : DateTime.now(),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this model to a plain JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'data': data,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  ReportModel copyWith({
    String? id,
    String? deviceId,
    ReportType? type,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? data,
    DateTime? generatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      data: data ?? this.data,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ReportModel(id: $id, deviceId: $deviceId, type: ${type.displayName}, '
      'period: $startDate – $endDate)';
}
