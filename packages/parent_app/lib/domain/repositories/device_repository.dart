import 'package:shared/models/device_model.dart';
import 'package:shared/models/device_status_model.dart';

/// Abstract repository for device operations.
abstract class DeviceRepository {
  /// Gets all devices belonging to a family.
  Future<List<DeviceModel>> getDevicesByFamily(String familyId);

  /// Gets a specific device by ID.
  Future<DeviceModel?> getDevice(String deviceId);

  /// Streams real-time device status updates.
  Stream<DeviceStatusModel?> streamDeviceStatus(String deviceId);

  /// Updates a device document.
  Future<void> updateDevice(DeviceModel device);
}
