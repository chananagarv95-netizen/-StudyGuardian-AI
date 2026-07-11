import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a physical device registered in the StudyGuardian AI system.
///
/// Each device belongs to a user within a family group and reports its
/// status periodically. Devices can have a `'parent'` or `'child'` role
/// indicating whether they are monitoring or being monitored.
class DeviceModel {
  /// Unique identifier for this device.
  final String id;

  /// The ID of the user who owns this device.
  final String userId;

  /// The ID of the family group this device belongs to.
  final String familyId;

  /// User-facing name for this device (e.g., "Arjun's Tablet").
  final String deviceName;

  /// Device model name (e.g., "Galaxy Tab S9").
  final String model;

  /// Device manufacturer (e.g., "Samsung").
  final String manufacturer;

  /// Android version running on this device.
  final String androidVersion;

  /// Device serial number for unique hardware identification.
  final String serialNumber;

  /// Device role: `'parent'` or `'child'`.
  final String role;

  /// Timestamp of the last heartbeat received from this device.
  final DateTime lastSeen;

  /// Whether the device is currently online and reporting.
  final bool isOnline;

  /// Firebase Cloud Messaging token for push notifications to this device.
  final String? fcmToken;

  /// Timestamp when this device was first registered.
  final DateTime createdAt;

  const DeviceModel({
    required this.id,
    required this.userId,
    required this.familyId,
    required this.deviceName,
    required this.model,
    required this.manufacturer,
    required this.androidVersion,
    required this.serialNumber,
    required this.role,
    required this.lastSeen,
    this.isOnline = false,
    this.fcmToken,
    required this.createdAt,
  });

  /// Whether this device has the parent role.
  bool get isParent => role == 'parent';

  /// Whether this device has the child role.
  bool get isChild => role == 'child';

  /// Creates a [DeviceModel] from a Firestore [DocumentSnapshot].
  factory DeviceModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DeviceModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      familyId: data['familyId'] as String? ?? '',
      deviceName: data['deviceName'] as String? ?? '',
      model: data['model'] as String? ?? '',
      manufacturer: data['manufacturer'] as String? ?? '',
      androidVersion: data['androidVersion'] as String? ?? '',
      serialNumber: data['serialNumber'] as String? ?? '',
      role: data['role'] as String? ?? 'child',
      lastSeen:
          (data['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOnline: data['isOnline'] as bool? ?? false,
      fcmToken: data['fcmToken'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'familyId': familyId,
      'deviceName': deviceName,
      'model': model,
      'manufacturer': manufacturer,
      'androidVersion': androidVersion,
      'serialNumber': serialNumber,
      'role': role,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'isOnline': isOnline,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a [DeviceModel] from a plain JSON map.
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      deviceName: json['deviceName'] as String? ?? '',
      model: json['model'] as String? ?? '',
      manufacturer: json['manufacturer'] as String? ?? '',
      androidVersion: json['androidVersion'] as String? ?? '',
      serialNumber: json['serialNumber'] as String? ?? '',
      role: json['role'] as String? ?? 'child',
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : DateTime.now(),
      isOnline: json['isOnline'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this model to a plain JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'familyId': familyId,
      'deviceName': deviceName,
      'model': model,
      'manufacturer': manufacturer,
      'androidVersion': androidVersion,
      'serialNumber': serialNumber,
      'role': role,
      'lastSeen': lastSeen.toIso8601String(),
      'isOnline': isOnline,
      'fcmToken': fcmToken,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  DeviceModel copyWith({
    String? id,
    String? userId,
    String? familyId,
    String? deviceName,
    String? model,
    String? manufacturer,
    String? androidVersion,
    String? serialNumber,
    String? role,
    DateTime? lastSeen,
    bool? isOnline,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      deviceName: deviceName ?? this.deviceName,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      androidVersion: androidVersion ?? this.androidVersion,
      serialNumber: serialNumber ?? this.serialNumber,
      role: role ?? this.role,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serialNumber == other.serialNumber;

  @override
  int get hashCode => Object.hash(id, serialNumber);

  @override
  String toString() =>
      'DeviceModel(id: $id, deviceName: $deviceName, model: $model, role: $role, isOnline: $isOnline)';
}
