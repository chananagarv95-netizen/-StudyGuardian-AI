import 'package:shared/models/device_model.dart';
import 'package:shared/models/device_status_model.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/utils/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/device_repository.dart';

/// Implementation of [DeviceRepository] using Firestore and device_info_plus.
class DeviceRepositoryImpl implements DeviceRepository {
  final FirestoreService _firestoreService;

  DeviceRepositoryImpl({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<DeviceModel> registerDevice(String userId, String familyId) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final device = DeviceModel(
        id: const Uuid().v4(),
        userId: userId,
        familyId: familyId,
        deviceName: androidInfo.model,
        model: androidInfo.model,
        manufacturer: androidInfo.manufacturer,
        androidVersion: androidInfo.version.release,
        serialNumber: androidInfo.id,
        role: 'child',
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.createDevice(device);
      AppLogger.i('DeviceRepo', 'Device registered: ${device.id}');
      return device;
    } catch (e, st) {
      AppLogger.e('DeviceRepo', 'Failed to register device', e, st);
      rethrow;
    }
  }

  @override
  Future<void> updateOnlineStatus(String deviceId, bool isOnline) async {
    try {
      await _firestoreService.updateOnlineStatus(deviceId, isOnline);
    } catch (e, st) {
      AppLogger.e('DeviceRepo', 'Failed to update online status', e, st);
      rethrow;
    }
  }

  @override
  Future<void> updateDeviceStatus(DeviceStatusModel status) async {
    try {
      await _firestoreService.updateDeviceStatus(status);
    } catch (e, st) {
      AppLogger.e('DeviceRepo', 'Failed to update device status', e, st);
      rethrow;
    }
  }

  @override
  Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      return await _firestoreService.getDevice(deviceId);
    } catch (e, st) {
      AppLogger.e('DeviceRepo', 'Failed to get device', e, st);
      rethrow;
    }
  }
}
