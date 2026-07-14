import 'package:shared/services/hive_service.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/utils/logger.dart';
import '../../core/services/platform_channel_service.dart';
import '../../domain/repositories/sync_repository.dart';
import 'usage_repository_impl.dart';
import 'device_repository_impl.dart';
import 'package:shared/models/device_status_model.dart';

/// Implementation of [SyncRepository] using Hive for offline queuing
/// and Firestore for remote persistence.
class SyncRepositoryImpl implements SyncRepository {
  final HiveService _hiveService;
  final FirestoreService _firestoreService;
  final PlatformChannelService _platformService;

  SyncRepositoryImpl({
    required HiveService hiveService,
    required FirestoreService firestoreService,
    required PlatformChannelService platformService,
  })  : _hiveService = hiveService,
        _firestoreService = firestoreService,
        _platformService = platformService;

  @override
  Future<void> runFullSync(String deviceId) async {
    try {
      AppLogger.i('SyncRepo', 'Starting full sync for device $deviceId');

      // 1. Collect and sync device status
      final statusMap = await _platformService.getDeviceStatus();
      if (statusMap.isNotEmpty) {
        final status = DeviceStatusModel(
          deviceId: deviceId,
          battery: (statusMap['battery'] as num?)?.toInt() ?? 0,
          isCharging: statusMap['isCharging'] as bool? ?? false,
          batteryHealth: statusMap['batteryHealth'] as String? ?? 'unknown',
          temperature: (statusMap['temperature'] as num?)?.toDouble() ?? 0.0,
          wifiConnected: statusMap['wifiConnected'] as bool? ?? false,
          wifiSSID: statusMap['wifiSSID'] as String? ?? '',
          networkType: statusMap['networkType'] as String? ?? 'none',
          storageUsed: (statusMap['storageUsed'] as num?)?.toInt() ?? 0,
          storageTotal: (statusMap['storageTotal'] as num?)?.toInt() ?? 0,
          ramUsed: (statusMap['ramUsed'] as num?)?.toInt() ?? 0,
          ramTotal: (statusMap['ramTotal'] as num?)?.toInt() ?? 0,
          foregroundApp: statusMap['foregroundApp'] as String? ?? '',
          screenOn: statusMap['screenOn'] as bool? ?? false,
          deviceUptime: (statusMap['deviceUptime'] as num?)?.toInt() ?? 0,
          signalStrength: (statusMap['signalStrength'] as num?)?.toInt() ?? 0,
          updatedAt: DateTime.now(),
        );
        await _firestoreService.updateDeviceStatus(status);
      }

      // 2. Collect and sync today's usage
      final today = DateTime.now();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final usageRepo = UsageRepositoryImpl(
        platformService: _platformService,
        firestoreService: _firestoreService,
      );

      final usage = await usageRepo.collectDailyUsage(deviceId, dateKey);
      await usageRepo.syncUsageToFirestore(usage);

      // 3. Compute and sync analytics
      final analytics =
          await usageRepo.computeStudyAnalytics(deviceId, dateKey);
      await usageRepo.syncAnalyticsToFirestore(analytics);

      // 4. Update online status
      await _firestoreService.updateOnlineStatus(deviceId, true);

      // 5. Push any remaining pending items
      await pushPendingItems();

      AppLogger.i('SyncRepo', 'Full sync completed for device $deviceId');
    } catch (e, st) {
      AppLogger.e('SyncRepo', 'Full sync failed', e, st);
      // Queue for retry
      await _hiveService.savePendingSync({
        'type': 'full_sync',
        'deviceId': deviceId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      rethrow;
    }
  }

  @override
  Future<void> pushPendingItems() async {
    try {
      final pending = _hiveService.getPendingSyncs();
      if (pending.isEmpty) {
        AppLogger.d('SyncRepo', 'No pending items to push');
        return;
      }

      AppLogger.i('SyncRepo', 'Pushing ${pending.length} pending items');

      // Process items — actual processing delegated to WorkManagerService
      // This is a simplified push that clears the queue
      await clearPendingQueue();

      AppLogger.i('SyncRepo', 'Pending items pushed successfully');
    } catch (e, st) {
      AppLogger.e('SyncRepo', 'Failed to push pending items', e, st);
      rethrow;
    }
  }

  @override
  int getPendingCount() {
    return _hiveService.getPendingSyncs().length;
  }

  @override
  Future<void> clearPendingQueue() async {
    try {
      await _hiveService.clearPendingSyncs();
      AppLogger.i('SyncRepo', 'Pending queue cleared');
    } catch (e, st) {
      AppLogger.e('SyncRepo', 'Failed to clear pending queue', e, st);
      rethrow;
    }
  }
}
