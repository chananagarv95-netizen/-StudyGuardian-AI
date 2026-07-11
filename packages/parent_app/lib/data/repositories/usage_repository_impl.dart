import 'package:shared/models/daily_usage_model.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/utils/logger.dart';
import '../../domain/repositories/usage_repository.dart';

/// Implementation of [UsageRepository] using Firestore.
class UsageRepositoryImpl implements UsageRepository {
  final FirestoreService _firestoreService;

  UsageRepositoryImpl({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<DailyUsageModel?> getDailyUsage(String deviceId, String date) async {
    try {
      return await _firestoreService.getDailyUsage(deviceId, date);
    } catch (e, st) {
      AppLogger.e('UsageRepo', 'Failed to get daily usage', e, st);
      return null;
    }
  }

  @override
  Future<List<DailyUsageModel>> getUsageForDateRange(
      String deviceId, String startDate, String endDate) async {
    try {
      return await _firestoreService.getUsageForDateRange(
          deviceId, startDate, endDate);
    } catch (e, st) {
      AppLogger.e('UsageRepo', 'Failed to get usage range', e, st);
      return [];
    }
  }

  @override
  Future<List<DailyUsageModel>> getWeeklyUsage(String deviceId) async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final startDate =
          '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';
      final endDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      return await _firestoreService.getUsageForDateRange(
          deviceId, startDate, endDate);
    } catch (e, st) {
      AppLogger.e('UsageRepo', 'Failed to get weekly usage', e, st);
      return [];
    }
  }
}
