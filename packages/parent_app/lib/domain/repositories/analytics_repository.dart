import 'package:shared/models/study_analytics_model.dart';

/// Abstract repository for study analytics.
abstract class AnalyticsRepository {
  /// Gets analytics for a specific day.
  Future<StudyAnalyticsModel?> getDailyAnalytics(
      String deviceId, String date);

  /// Gets analytics for a date range.
  Future<List<StudyAnalyticsModel>> getAnalyticsForDateRange(
      String deviceId, String startDate, String endDate);
}
