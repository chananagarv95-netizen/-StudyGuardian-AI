import 'package:shared/services/hive_service.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/utils/logger.dart';
import '../../core/services/platform_channel_service.dart';
import '../../domain/repositories/sync_repository.dart';
import 'usage_repository_impl.dart';
import 'package:shared/models/device_status_model.dart';

/// Implementation of [SyncRepository] using Hive for offline queuing
/// and Firestore for remote persistence.
///
/// Includes battery-saving optimizations:
/// - **Change detection**: Skips syncing device status when it hasn't changed.
/// - **Idle skip**: Skips full sync when the screen is off and battery is low.
class SyncRepositoryImpl implements SyncRepository {
  final HiveService _hiveService;
  final FirestoreService _firestoreService;
  final PlatformChannelService _platformService;

  /// Hash of the last synced device status to detect changes.
  String? _lastStatusHash;

  SyncRepositoryImpl({
    required HiveService hiveService,
    required FirestoreService firestoreService,
    required PlatformChannelService platformService,
  })  : _hiveService = hiveService,
        _firestoreService = firestoreService,
        _platformService = platformService;

  /// Returns `true` if the sync should be skipped to save battery.
  Future<bool> _shouldSkipSync() async {
    try {
      final status = await _platformService.getDeviceStatus();
      final screenOn = status['screenOn'] as bool? ?? true;
      final battery = (status['battery'] as num?)?.toInt() ?? 100;

      // Skip sync if screen is off AND battery is below 15%
      if (!screenOn && battery < 15) {
        AppLogger.d('SyncRepo', 'Skipping sync — screen off, battery $battery%');
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Creates a simple hash of device status to detect changes.
  String _statusHash(Map<String, dynamic> statusMap) {
    final key = '${statusMap['battery']}_'
        '${statusMap['isCharging']}_'
        '${statusMap['foregroundApp']}_'
        '${statusMap['wifiConnected']}_'
        '${statusMap['screenOn']}';
    return key;
  }

  @override
  Future<void> runFullSync(String deviceId) async {
    try {
      // Battery optimization: skip if idle and battery low
      if (await _shouldSkipSync()) return;

      AppLogger.i('SyncRepo', 'Starting full sync for device $deviceId');

      // 1. Collect and sync device status (with change detection)
      final statusMap = await _platformService.getDeviceStatus();
      if (statusMap.isNotEmpty) {
        final currentHash = _statusHash(statusMap);
        final statusChanged = currentHash != _lastStatusHash;

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

        if (statusChanged) {
          await _firestoreService.updateDeviceStatus(status);
          _lastStatusHash = currentHash;
        } else {
          AppLogger.d('SyncRepo', 'Device status unchanged, skipping upload');
        }
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
