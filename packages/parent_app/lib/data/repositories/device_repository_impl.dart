import 'package:shared/models/device_model.dart';
import 'package:shared/models/device_status_model.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/utils/logger.dart';
import '../../domain/repositories/device_repository.dart';

/// Implementation of [DeviceRepository] using Firestore.
class DeviceRepositoryImpl implements DeviceRepository {
  final FirestoreService _firestoreService;

  DeviceRepositoryImpl({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<List<DeviceModel>> getDevicesByFamily(String familyId) async {
    try {
      return await _firestoreService.getDevicesByFamily(familyId);
    } catch (e, st) {
      AppLogger.e('DeviceRepo', 'Failed to get devices', e, st);
      return [];
    }
  }

  @override
  Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      return await _firestoreService.getDevice(deviceId);
    } catch (e, st) {
      AppLogger.e('DeviceRepo', 'Failed to get device', e, st);
      return null;
    }
  }

  @override
  Stream<DeviceStatusModel?> streamDeviceStatus(String deviceId) {
    return _firestoreService.streamDeviceStatus(deviceId);
  }

  @override
  Future<void> updateDevice(DeviceModel device) async {
    try {
      await _firestoreService.updateDevice(device.id, device.toFirestore());
    } catch (e, st) {
      AppLogger.e('DeviceRepo', 'Failed to update device', e, st);
      rethrow;
    }
  }
}
