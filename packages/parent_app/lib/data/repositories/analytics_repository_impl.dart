import 'package:shared/models/study_analytics_model.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/utils/logger.dart';
import '../../domain/repositories/analytics_repository.dart';

/// Implementation of [AnalyticsRepository] using Firestore.
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final FirestoreService _firestoreService;

  AnalyticsRepositoryImpl({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<StudyAnalyticsModel?> getDailyAnalytics(
      String deviceId, String date) async {
    try {
      return await _firestoreService.getDailyAnalytics(deviceId, date);
    } catch (e, st) {
      AppLogger.e('AnalyticsRepo', 'Failed to get daily analytics', e, st);
      return null;
    }
  }

  @override
  Future<List<StudyAnalyticsModel>> getAnalyticsForDateRange(
      String deviceId, String startDate, String endDate) async {
    try {
      return await _firestoreService.getAnalyticsForDateRange(
          deviceId, startDate, endDate);
    } catch (e, st) {
      AppLogger.e('AnalyticsRepo', 'Failed to get analytics range', e, st);
      return [];
    }
  }
}
