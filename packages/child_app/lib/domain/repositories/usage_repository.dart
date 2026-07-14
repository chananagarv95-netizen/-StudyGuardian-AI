import 'package:shared/models/daily_usage_model.dart';
import 'package:shared/models/study_analytics_model.dart';

/// Abstract repository for collecting and storing usage data.
abstract class UsageRepository {
  /// Collects app usage data from the native UsageStatsManager
  /// for the given date and stores it locally.
  Future<DailyUsageModel> collectDailyUsage(String deviceId, String date);

  /// Computes study analytics from the day's usage data.
  Future<StudyAnalyticsModel> computeStudyAnalytics(
      String deviceId, String date);

  /// Syncs locally cached usage data to Firestore.
  Future<void> syncUsageToFirestore(DailyUsageModel usage);

  /// Syncs locally cached analytics to Firestore.
  Future<void> syncAnalyticsToFirestore(StudyAnalyticsModel analytics);
}
