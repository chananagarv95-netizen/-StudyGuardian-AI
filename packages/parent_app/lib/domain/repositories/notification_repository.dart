import 'package:shared/models/notification_model.dart';

/// Abstract repository for notifications.
abstract class NotificationRepository {
  /// Gets all notifications for a family.
  Future<List<NotificationModel>> getNotifications(String familyId);

  /// Streams real-time notification updates.
  Stream<List<NotificationModel>> streamNotifications(String familyId);

  /// Marks a notification as read.
  Future<void> markAsRead(String familyId, String notificationId);

  /// Gets count of unread notifications.
  Future<int> getUnreadCount(String familyId);
}
