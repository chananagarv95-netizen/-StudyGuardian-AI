import 'dart:async';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/models/notification_model.dart';
import 'package:shared/utils/logger.dart';
import 'package:uuid/uuid.dart';
import 'platform_channel_service.dart';

/// Periodically checks whether required Android permissions for monitoring
/// have been revoked by the user.
///
/// If permissions are revoked:
/// 1. Sends a notification to the parent via Firestore.
/// 2. Exposes the revocation state for the UI to display a persistent banner.
///
/// This service does NOT attempt to bypass Android security or re-grant
/// permissions automatically.
class PermissionRevokedHandler {
  static const String _tag = 'PermissionRevokedHandler';
  static const Duration _checkInterval = Duration(minutes: 5);

  final PlatformChannelService _platformService;
  final FirestoreService _firestoreService;
  final String _familyId;
  final String _deviceId;
  final String _deviceName;

  Timer? _timer;
  bool _usagePermissionRevoked = false;
  bool _notifiedParent = false;

  /// Whether the usage stats permission has been revoked.
  bool get isUsagePermissionRevoked => _usagePermissionRevoked;

  PermissionRevokedHandler({
    required PlatformChannelService platformService,
    required FirestoreService firestoreService,
    required String familyId,
    required String deviceId,
    required String deviceName,
  })  : _platformService = platformService,
        _firestoreService = firestoreService,
        _familyId = familyId,
        _deviceId = deviceId,
        _deviceName = deviceName;

  /// Starts periodic permission monitoring.
  void startMonitoring() {
    AppLogger.i(_tag, 'Starting permission monitoring');
    _checkPermissions(); // Check immediately
    _timer = Timer.periodic(_checkInterval, (_) => _checkPermissions());
  }

  /// Stops periodic permission monitoring.
  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    AppLogger.i(_tag, 'Stopped permission monitoring');
  }

  Future<void> _checkPermissions() async {
    try {
      final hasUsagePermission =
          await _platformService.hasUsagePermission();

      if (!hasUsagePermission && !_usagePermissionRevoked) {
        _usagePermissionRevoked = true;
        AppLogger.w(_tag, 'Usage stats permission has been revoked');

        if (!_notifiedParent) {
          await _notifyParent();
          _notifiedParent = true;
        }
      } else if (hasUsagePermission && _usagePermissionRevoked) {
        _usagePermissionRevoked = false;
        _notifiedParent = false;
        AppLogger.i(_tag, 'Usage stats permission has been restored');
      }
    } catch (e) {
      AppLogger.e(_tag, 'Error checking permissions', e);
    }
  }

  Future<void> _notifyParent() async {
    try {
      final notification = NotificationModel(
        id: const Uuid().v4(),
        familyId: _familyId,
        type: NotificationType.deviceOffline,
        title: '⚠️ Permission Revoked',
        body:
            'Usage stats permission was revoked on $_deviceName. '
            'Monitoring data may be incomplete.',
        deviceId: _deviceId,
        deviceName: _deviceName,
        timestamp: DateTime.now(),
      );
      await _firestoreService.saveNotification(notification);
      AppLogger.i(_tag, 'Parent notified about permission revocation');
    } catch (e) {
      AppLogger.e(_tag, 'Failed to notify parent about revocation', e);
    }
  }

  /// Cleans up resources.
  void dispose() {
    stopMonitoring();
  }
}
