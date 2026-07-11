import 'package:shared/models/daily_usage_model.dart';

/// Abstract repository for app usage data.
abstract class UsageRepository {
  /// Gets usage data for a specific day.
  Future<DailyUsageModel?> getDailyUsage(String deviceId, String date);

  /// Gets usage data for a date range.
  Future<List<DailyUsageModel>> getUsageForDateRange(
      String deviceId, String startDate, String endDate);

  /// Gets the last 7 days of usage data.
  Future<List<DailyUsageModel>> getWeeklyUsage(String deviceId);
}
