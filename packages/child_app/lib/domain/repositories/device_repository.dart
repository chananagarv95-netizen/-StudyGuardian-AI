import 'package:shared/models/device_model.dart';
import 'package:shared/models/device_status_model.dart';

/// Abstract repository for device registration and status updates.
abstract class DeviceRepository {
  /// Registers this device in Firestore under the user's family.
  Future<DeviceModel> registerDevice(String userId, String familyId);

  /// Updates the device's online status and last-seen timestamp.
  Future<void> updateOnlineStatus(String deviceId, bool isOnline);

  /// Pushes a device status snapshot to Firestore.
  Future<void> updateDeviceStatus(DeviceStatusModel status);

  /// Fetches the current device document.
  Future<DeviceModel?> getDevice(String deviceId);
}
