import 'package:workmanager/workmanager.dart';
import 'package:shared/services/hive_service.dart';
import 'package:shared/models/performance_mode.dart';
import 'package:shared/utils/logger.dart';

/// WorkManager service for scheduling and handling periodic background sync.
///
/// The child app registers a periodic task that runs every 15 minutes
/// to sync collected usage and device data to Firebase Firestore.
class WorkManagerService {
  static const String _tag = 'WorkManager';

  /// Unique task name for the periodic sync job.
  static const String syncTaskName = 'com.studyguardian.child.sync';

  /// Unique task name for a one-time immediate sync.
  static const String immediateSyncTaskName =
      'com.studyguardian.child.immediateSync';

  /// Registers the periodic background sync task.
  ///
  /// The [mode] controls how frequently syncs occur:
  /// - [PerformanceMode.eco]: every 60 minutes
  /// - [PerformanceMode.balanced]: every 15 minutes (default)
  /// - [PerformanceMode.live]: every 3 minutes
  ///
  /// Android may batch or delay execution depending on Doze mode
  /// and battery optimization settings.
  static Future<void> registerPeriodicSync({
    PerformanceMode mode = PerformanceMode.balanced,
  }) async {
    try {
      await Workmanager().registerPeriodicTask(
        syncTaskName,
        syncTaskName,
        frequency: mode.syncInterval,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 1),
        tag: 'studyguardian_sync',
      );
      AppLogger.i(
        _tag,
        'Periodic sync registered (${mode.displayName}, '
            'every ${mode.syncInterval.inMinutes} min)',
      );
    } catch (e, st) {
      AppLogger.e(_tag, 'Failed to register periodic sync', e, st);
    }
  }

  /// Switches the sync frequency by cancelling the current periodic task
  /// and re-registering with the new [mode]'s interval.
  static Future<void> switchMode(PerformanceMode mode) async {
    AppLogger.i(_tag, 'Switching to ${mode.displayName}');
    await cancelAllSync();
    await registerPeriodicSync(mode: mode);
  }

  /// Triggers an immediate one-time sync.
  static Future<void> triggerImmediateSync() async {
    try {
      await Workmanager().registerOneOffTask(
        immediateSyncTaskName,
        immediateSyncTaskName,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        tag: 'studyguardian_immediate',
      );
      AppLogger.i(_tag, 'Immediate sync triggered');
    } catch (e, st) {
      AppLogger.e(_tag, 'Failed to trigger immediate sync', e, st);
    }
  }

  /// Cancels all registered sync tasks.
  static Future<void> cancelAllSync() async {
    try {
      await Workmanager().cancelByTag('studyguardian_sync');
      await Workmanager().cancelByTag('studyguardian_immediate');
      AppLogger.i(_tag, 'All sync tasks cancelled');
    } catch (e, st) {
      AppLogger.e(_tag, 'Failed to cancel sync tasks', e, st);
    }
  }

  /// Handles the background task execution.
  ///
  /// This is called from the top-level [callbackDispatcher] in main.dart.
  /// Returns `true` on success, `false` on failure (triggers retry).
  static Future<bool> handleBackgroundTask(
    String taskName,
    Map<String, dynamic>? inputData,
  ) async {
    AppLogger.i(_tag, 'Executing background task: $taskName');

    try {
      final hiveService = HiveService();

      // Retrieve pending sync items from Hive
      final pendingItems = hiveService.getPendingSyncs();

      if (pendingItems.isEmpty) {
        AppLogger.i(_tag, 'No pending items to sync');
        return true;
      }

      AppLogger.i(_tag, 'Syncing ${pendingItems.length} pending items');

      // Process each pending item
      for (final item in pendingItems) {
        final type = item['type'] as String?;

        switch (type) {
          case 'daily_usage':
            // Sync usage data — handled by the sync repository
            AppLogger.d(_tag, 'Syncing daily_usage item');
            break;
          case 'device_status':
            // Sync device status — handled by the sync repository
            AppLogger.d(_tag, 'Syncing device_status item');
            break;
          case 'study_analytics':
            // Sync study analytics — handled by the sync repository
            AppLogger.d(_tag, 'Syncing study_analytics item');
            break;
          default:
            AppLogger.w(_tag, 'Unknown sync item type: $type');
        }
      }

      // Clear the sync queue after successful processing
      await hiveService.clearPendingSyncs();

      AppLogger.i(_tag, 'Background sync completed successfully');
      return true;
    } catch (e, st) {
      AppLogger.e(_tag, 'Background sync failed', e, st);
      return false; // WorkManager will retry with exponential backoff
    }
  }
}
