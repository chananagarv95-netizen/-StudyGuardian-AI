import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a point-in-time status snapshot of a monitored device.
///
/// Contains telemetry data including battery, network, storage, RAM,
/// and current foreground application. These snapshots are collected
/// periodically and stored in Firestore for real-time monitoring.
class DeviceStatusModel {
  /// The ID of the device this status belongs to.
  final String deviceId;

  /// Current battery level as a percentage (0–100).
  final int battery;

  /// Whether the device is currently charging.
  final bool isCharging;

  /// Battery health status (e.g., "good", "overheat", "dead").
  final String batteryHealth;

  /// Device temperature in degrees Celsius.
  final double temperature;

  /// Whether the device is connected to a Wi-Fi network.
  final bool wifiConnected;

  /// SSID of the connected Wi-Fi network.
  final String wifiSSID;

  /// Current network type (e.g., "wifi", "mobile", "none").
  final String networkType;

  /// Storage used in bytes.
  final int storageUsed;

  /// Total storage capacity in bytes.
  final int storageTotal;

  /// RAM currently in use in bytes.
  final int ramUsed;

  /// Total RAM available in bytes.
  final int ramTotal;

  /// Package name of the currently active foreground application.
  final String foregroundApp;

  /// Whether the screen is currently turned on.
  final bool screenOn;

  /// Timestamp of the last screen unlock, if available.
  final DateTime? lastUnlockTime;

  /// Device uptime in seconds since last boot.
  final int deviceUptime;

  /// Cellular or Wi-Fi signal strength in dBm.
  final int signalStrength;

  /// Timestamp when this status was last updated.
  final DateTime updatedAt;

  const DeviceStatusModel({
    required this.deviceId,
    required this.battery,
    required this.isCharging,
    required this.batteryHealth,
    required this.temperature,
    required this.wifiConnected,
    required this.wifiSSID,
    required this.networkType,
    required this.storageUsed,
    required this.storageTotal,
    required this.ramUsed,
    required this.ramTotal,
    required this.foregroundApp,
    required this.screenOn,
    this.lastUnlockTime,
    required this.deviceUptime,
    required this.signalStrength,
    required this.updatedAt,
  });

  /// Storage used as a percentage (0.0–100.0).
  double get storageUsedPercent =>
      storageTotal > 0 ? (storageUsed / storageTotal) * 100 : 0.0;

  /// RAM used as a percentage (0.0–100.0).
  double get ramUsedPercent =>
      ramTotal > 0 ? (ramUsed / ramTotal) * 100 : 0.0;

  /// Whether the battery is considered low (below 20%).
  bool get isBatteryLow => battery < 20;

  /// Whether the battery is fully charged.
  bool get isBatteryFull => battery >= 100;

  /// Creates a [DeviceStatusModel] from a Firestore [DocumentSnapshot].
  factory DeviceStatusModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DeviceStatusModel(
      deviceId: data['deviceId'] as String? ?? '',
      battery: (data['battery'] as num?)?.toInt() ?? 0,
      isCharging: data['isCharging'] as bool? ?? false,
      batteryHealth: data['batteryHealth'] as String? ?? 'unknown',
      temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
      wifiConnected: data['wifiConnected'] as bool? ?? false,
      wifiSSID: data['wifiSSID'] as String? ?? '',
      networkType: data['networkType'] as String? ?? 'none',
      storageUsed: (data['storageUsed'] as num?)?.toInt() ?? 0,
      storageTotal: (data['storageTotal'] as num?)?.toInt() ?? 0,
      ramUsed: (data['ramUsed'] as num?)?.toInt() ?? 0,
      ramTotal: (data['ramTotal'] as num?)?.toInt() ?? 0,
      foregroundApp: data['foregroundApp'] as String? ?? '',
      screenOn: data['screenOn'] as bool? ?? false,
      lastUnlockTime:
          (data['lastUnlockTime'] as Timestamp?)?.toDate(),
      deviceUptime: (data['deviceUptime'] as num?)?.toInt() ?? 0,
      signalStrength: (data['signalStrength'] as num?)?.toInt() ?? 0,
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'deviceId': deviceId,
      'battery': battery,
      'isCharging': isCharging,
      'batteryHealth': batteryHealth,
      'temperature': temperature,
      'wifiConnected': wifiConnected,
      'wifiSSID': wifiSSID,
      'networkType': networkType,
      'storageUsed': storageUsed,
      'storageTotal': storageTotal,
      'ramUsed': ramUsed,
      'ramTotal': ramTotal,
      'foregroundApp': foregroundApp,
      'screenOn': screenOn,
      'lastUnlockTime': lastUnlockTime != null
          ? Timestamp.fromDate(lastUnlockTime!)
          : null,
      'deviceUptime': deviceUptime,
      'signalStrength': signalStrength,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a [DeviceStatusModel] from a plain JSON map.
  factory DeviceStatusModel.fromJson(Map<String, dynamic> json) {
    return DeviceStatusModel(
      deviceId: json['deviceId'] as String? ?? '',
      battery: (json['battery'] as num?)?.toInt() ?? 0,
      isCharging: json['isCharging'] as bool? ?? false,
      batteryHealth: json['batteryHealth'] as String? ?? 'unknown',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      wifiConnected: json['wifiConnected'] as bool? ?? false,
      wifiSSID: json['wifiSSID'] as String? ?? '',
      networkType: json['networkType'] as String? ?? 'none',
      storageUsed: (json['storageUsed'] as num?)?.toInt() ?? 0,
      storageTotal: (json['storageTotal'] as num?)?.toInt() ?? 0,
      ramUsed: (json['ramUsed'] as num?)?.toInt() ?? 0,
      ramTotal: (json['ramTotal'] as num?)?.toInt() ?? 0,
      foregroundApp: json['foregroundApp'] as String? ?? '',
      screenOn: json['screenOn'] as bool? ?? false,
      lastUnlockTime: json['lastUnlockTime'] != null
          ? DateTime.parse(json['lastUnlockTime'] as String)
          : null,
      deviceUptime: (json['deviceUptime'] as num?)?.toInt() ?? 0,
      signalStrength: (json['signalStrength'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this model to a plain JSON map.
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'battery': battery,
      'isCharging': isCharging,
      'batteryHealth': batteryHealth,
      'temperature': temperature,
      'wifiConnected': wifiConnected,
      'wifiSSID': wifiSSID,
      'networkType': networkType,
      'storageUsed': storageUsed,
      'storageTotal': storageTotal,
      'ramUsed': ramUsed,
      'ramTotal': ramTotal,
      'foregroundApp': foregroundApp,
      'screenOn': screenOn,
      'lastUnlockTime': lastUnlockTime?.toIso8601String(),
      'deviceUptime': deviceUptime,
      'signalStrength': signalStrength,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  DeviceStatusModel copyWith({
    String? deviceId,
    int? battery,
    bool? isCharging,
    String? batteryHealth,
    double? temperature,
    bool? wifiConnected,
    String? wifiSSID,
    String? networkType,
    int? storageUsed,
    int? storageTotal,
    int? ramUsed,
    int? ramTotal,
    String? foregroundApp,
    bool? screenOn,
    DateTime? lastUnlockTime,
    int? deviceUptime,
    int? signalStrength,
    DateTime? updatedAt,
  }) {
    return DeviceStatusModel(
      deviceId: deviceId ?? this.deviceId,
      battery: battery ?? this.battery,
      isCharging: isCharging ?? this.isCharging,
      batteryHealth: batteryHealth ?? this.batteryHealth,
      temperature: temperature ?? this.temperature,
      wifiConnected: wifiConnected ?? this.wifiConnected,
      wifiSSID: wifiSSID ?? this.wifiSSID,
      networkType: networkType ?? this.networkType,
      storageUsed: storageUsed ?? this.storageUsed,
      storageTotal: storageTotal ?? this.storageTotal,
      ramUsed: ramUsed ?? this.ramUsed,
      ramTotal: ramTotal ?? this.ramTotal,
      foregroundApp: foregroundApp ?? this.foregroundApp,
      screenOn: screenOn ?? this.screenOn,
      lastUnlockTime: lastUnlockTime ?? this.lastUnlockTime,
      deviceUptime: deviceUptime ?? this.deviceUptime,
      signalStrength: signalStrength ?? this.signalStrength,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceStatusModel &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(deviceId, updatedAt);

  @override
  String toString() =>
      'DeviceStatusModel(deviceId: $deviceId, battery: $battery%, '
      'screenOn: $screenOn, foregroundApp: $foregroundApp)';
}
