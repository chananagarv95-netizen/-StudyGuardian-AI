import 'package:shared/models/app_usage_model.dart';
import 'package:shared/models/app_category.dart';
import 'package:shared/models/daily_usage_model.dart';
import 'package:shared/models/study_analytics_model.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/utils/app_classifier.dart';
import 'package:shared/utils/study_score_calculator.dart';
import 'package:shared/utils/summary_generator.dart';
import 'package:shared/utils/logger.dart';
import '../../core/services/platform_channel_service.dart';
import '../../domain/repositories/usage_repository.dart';

/// Implementation of [UsageRepository] using platform channels and Firestore.
class UsageRepositoryImpl implements UsageRepository {
  final PlatformChannelService _platformService;
  final FirestoreService _firestoreService;

  UsageRepositoryImpl({
    required PlatformChannelService platformService,
    required FirestoreService firestoreService,
  })  : _platformService = platformService,
        _firestoreService = firestoreService;

  @override
  Future<DailyUsageModel> collectDailyUsage(
      String deviceId, String date) async {
    try {
      // Parse date to get start/end epoch
      final dateTime = DateTime.parse(date);
      final startOfDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Query native UsageStatsManager
      final rawUsage = await _platformService.getUsageStats(
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      );

      // Transform raw usage into AppUsageModel list
      final apps = rawUsage.map((entry) {
        final packageName = entry['packageName'] as String? ?? '';
        return AppUsageModel(
          packageName: packageName,
          appName: entry['appName'] as String? ?? packageName,
          category: AppClassifier.classifyApp(
              packageName, entry['appName'] as String? ?? packageName),
          foregroundTime: (entry['foregroundTime'] as num?)?.toInt() ?? 0,
          backgroundTime: (entry['backgroundTime'] as num?)?.toInt() ?? 0,
          openCount: (entry['openCount'] as num?)?.toInt() ?? 0,
          longestSession: (entry['longestSession'] as num?)?.toInt() ?? 0,
        );
      }).where((app) => app.foregroundTime > 0).toList();

      // Compute totals
      final totalScreenTime =
          apps.fold<int>(0, (sum, app) => sum + app.foregroundTime);

      final usage = DailyUsageModel(
        deviceId: deviceId,
        date: date,
        totalScreenTime: totalScreenTime,
        unlockCount: 0, // Will be populated from device status
        screenOnTime: totalScreenTime,
        screenOffTime: 0,
        apps: apps,
      );

      AppLogger.i('UsageRepo', 'Collected ${apps.length} apps, '
          '${totalScreenTime}m total screen time for $date');
      return usage;
    } catch (e, st) {
      AppLogger.e('UsageRepo', 'Failed to collect daily usage', e, st);
      rethrow;
    }
  }

  @override
  Future<StudyAnalyticsModel> computeStudyAnalytics(
      String deviceId, String date) async {
    try {
      // First collect usage if not already available
      final usage = await collectDailyUsage(deviceId, date);

      // Compute per-category time from apps
      int educationTime = 0;
      int entertainmentTime = 0;
      int socialMediaTime = 0;
      int gameTime = 0;
      int longestStudySession = 0;
      final List<String> distractingApps = [];

      for (final app in usage.apps) {
        switch (app.category) {
          case AppCategory.education:
            educationTime += app.foregroundTime;
            if (app.longestSession > longestStudySession) {
              longestStudySession = app.longestSession;
            }
            break;
          case AppCategory.entertainment:
            entertainmentTime += app.foregroundTime;
            break;
          case AppCategory.socialMedia:
            socialMediaTime += app.foregroundTime;
            distractingApps.add(app.appName);
            break;
          case AppCategory.games:
            gameTime += app.foregroundTime;
            distractingApps.add(app.appName);
            break;
          default:
            break;
        }
      }

      // Use shared calculator methods
      final studyScore = StudyScoreCalculator.calculateStudyScore(
        educationTime,
        usage.totalScreenTime,
      );

      final focusScore = StudyScoreCalculator.calculateFocusScore(
        usage.apps.length, // app switch count approximation
        socialMediaTime,
        usage.totalScreenTime,
      );

      final distractionScore = StudyScoreCalculator.calculateDistractionScore(
        entertainmentTime,
        socialMediaTime,
        gameTime,
        usage.totalScreenTime,
      );

      final productivityPercent = StudyScoreCalculator.calculateProductivity(
        educationTime,
        entertainmentTime,
        gameTime,
        socialMediaTime,
      );

      final analytics = StudyAnalyticsModel(
        deviceId: deviceId,
        date: date,
        studyScore: studyScore,
        focusScore: focusScore,
        distractionScore: distractionScore,
        productivityPercent: productivityPercent,
        studyHours: educationTime / 60.0,
        entertainmentHours: entertainmentTime / 60.0,
        longestStudySession: longestStudySession,
        mostDistractingApps: distractingApps.take(5).toList(),
        aiSummary: '', // Will be filled after creation via SummaryGenerator
        totalScreenTime: usage.totalScreenTime,
        educationTime: educationTime,
        gameTime: gameTime,
        socialMediaTime: socialMediaTime,
      );

      // Generate summary from both models
      final summary =
          SummaryGenerator.generateDailySummary(usage, analytics);

      // Return a copy with the summary filled in
      final analyticsWithSummary = analytics.copyWith(aiSummary: summary);

      AppLogger.i('UsageRepo', 'Computed analytics for $date: '
          'study=${analyticsWithSummary.studyScore}, '
          'focus=${analyticsWithSummary.focusScore}');
      return analyticsWithSummary;
    } catch (e, st) {
      AppLogger.e('UsageRepo', 'Failed to compute study analytics', e, st);
      rethrow;
    }
  }

  @override
  Future<void> syncUsageToFirestore(DailyUsageModel usage) async {
    try {
      await _firestoreService.saveDailyUsage(usage);
      AppLogger.i(
          'UsageRepo', 'Usage synced for ${usage.deviceId}/${usage.date}');
    } catch (e, st) {
      AppLogger.e('UsageRepo', 'Failed to sync usage', e, st);
      rethrow;
    }
  }

  @override
  Future<void> syncAnalyticsToFirestore(StudyAnalyticsModel analytics) async {
    try {
      await _firestoreService.saveStudyAnalytics(analytics);
      AppLogger.i('UsageRepo',
          'Analytics synced for ${analytics.deviceId}/${analytics.date}');
    } catch (e, st) {
      AppLogger.e('UsageRepo', 'Failed to sync analytics', e, st);
      rethrow;
    }
  }
}
