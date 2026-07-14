import 'package:flutter/services.dart';
import 'package:shared/utils/logger.dart';
import '../constants/platform_channels.dart';

/// Service that bridges Dart and Kotlin native code via a single [MethodChannel].
///
/// Wraps all platform channel calls with error handling and logging.
/// This is the only class that should directly invoke [MethodChannel] methods;
/// all other Dart code should use this service via Riverpod providers.
class PlatformChannelService {
  static const String _tag = 'PlatformChannel';

  /// The method channel used for all native communication.
  final MethodChannel _channel =
      const MethodChannel(kPlatformChannelName);

  // ===========================================================================
  // Usage Stats
  // ===========================================================================

  /// Queries native UsageStatsManager for app usage data in the given range.
  ///
  /// [startTime] and [endTime] are epoch milliseconds.
  /// Returns a list of per-app usage maps, or an empty list on failure.
  Future<List<Map<String, dynamic>>> getUsageStats(
      int startTime, int endTime) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        kMethodGetUsageStats,
        {'startTime': startTime, 'endTime': endTime},
      );

      if (result == null) return [];
      return result
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'Failed to get usage stats', e, st);
      return [];
    }
  }

  /// Checks whether the PACKAGE_USAGE_STATS permission is granted.
  Future<bool> hasUsagePermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>(kMethodHasUsagePermission);
      return result ?? false;
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'Failed to check usage permission', e, st);
      return false;
    }
  }

  /// Opens the system Settings page for Usage Access.
  Future<void> requestUsagePermission() async {
    try {
      await _channel.invokeMethod<void>(kMethodRequestUsagePermission);
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'Failed to request usage permission', e, st);
    }
  }

  // ===========================================================================
  // Device Info
  // ===========================================================================

  /// Collects a comprehensive device status snapshot from native code.
  ///
  /// Returns a map with keys: battery, isCharging, batteryHealth,
  /// temperature, wifiConnected, wifiSSID, networkType, storageUsed,
  /// storageTotal, ramUsed, ramTotal, foregroundApp, screenOn,
  /// deviceUptime, signalStrength.
  Future<Map<String, dynamic>> getDeviceStatus() async {
    try {
      final result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>(kMethodGetDeviceStatus);

      if (result == null) return {};
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'Failed to get device status', e, st);
      return {};
    }
  }

  /// Returns the package name of the current foreground application.
  Future<String> getForegroundApp() async {
    try {
      final result =
          await _channel.invokeMethod<String>(kMethodGetForegroundApp);
      return result ?? '';
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'Failed to get foreground app', e, st);
      return '';
    }
  }

  // ===========================================================================
  // Foreground Service
  // ===========================================================================

  /// Starts the persistent monitoring foreground service.
  Future<void> startForegroundService() async {
    try {
      await _channel.invokeMethod<void>(kMethodStartForegroundService);
      AppLogger.i(_tag, 'Foreground service started');
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'Failed to start foreground service', e, st);
    }
  }

  /// Stops the persistent monitoring foreground service.
  Future<void> stopForegroundService() async {
    try {
      await _channel.invokeMethod<void>(kMethodStopForegroundService);
      AppLogger.i(_tag, 'Foreground service stopped');
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'Failed to stop foreground service', e, st);
    }
  }

  /// Checks whether the foreground service is currently running.
  Future<bool> isForegroundServiceRunning() async {
    try {
      final result = await _channel
          .invokeMethod<bool>(kMethodIsForegroundServiceRunning);
      return result ?? false;
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'Failed to check foreground service status', e, st);
      return false;
    }
  }

  // ===========================================================================
  // Battery Optimization
  // ===========================================================================

  /// Checks whether the app is exempted from battery optimization.
  Future<bool> isBatteryOptimizationDisabled() async {
    try {
      final result = await _channel
          .invokeMethod<bool>(kMethodIsBatteryOptimizationDisabled);
      return result ?? false;
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'Failed to check battery optimization', e, st);
      return false;
    }
  }

  /// Requests the user to disable battery optimization for this app.
  Future<void> requestDisableBatteryOptimization() async {
    try {
      await _channel
          .invokeMethod<void>(kMethodRequestDisableBatteryOptimization);
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'Failed to request battery opt disable', e, st);
    }
  }

  // ===========================================================================
  // Package Detection
  // ===========================================================================

  /// Returns metadata for all installed applications.
  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result = await _channel
          .invokeMethod<List<dynamic>>(kMethodGetInstalledApps);

      if (result == null) return [];
      return result
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'Failed to get installed apps', e, st);
      return [];
    }
  }
}
