import 'package:shared/models/notification_model.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/utils/logger.dart';
import '../../domain/repositories/notification_repository.dart';

/// Implementation of [NotificationRepository] using Firestore.
class NotificationRepositoryImpl implements NotificationRepository {
  final FirestoreService _firestoreService;

  NotificationRepositoryImpl({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<List<NotificationModel>> getNotifications(String familyId) async {
    try {
      return await _firestoreService.getNotificationsByFamily(familyId);
    } catch (e, st) {
      AppLogger.e('NotifRepo', 'Failed to get notifications', e, st);
      return [];
    }
  }

  @override
  Stream<List<NotificationModel>> streamNotifications(String familyId) {
    return _firestoreService.streamNotifications(familyId);
  }

  @override
  Future<void> markAsRead(String familyId, String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(familyId, notificationId);
    } catch (e, st) {
      AppLogger.e('NotifRepo', 'Failed to mark as read', e, st);
      rethrow;
    }
  }

  @override
  Future<int> getUnreadCount(String familyId) async {
    try {
      return await _firestoreService.getUnreadNotificationCount(familyId);
    } catch (e, st) {
      AppLogger.e('NotifRepo', 'Failed to get unread count', e, st);
      return 0;
    }
  }
}
