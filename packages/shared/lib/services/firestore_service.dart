/// Firestore database service for StudyGuardian AI.
///
/// Provides complete CRUD operations for every Firestore collection
/// used by the application: users, families, devices, device_status,
/// daily_usage, study_analytics, reports, and notifications.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/family_model.dart';
import '../models/device_model.dart';
import '../models/device_status_model.dart';
import '../models/daily_usage_model.dart';
import '../models/study_analytics_model.dart';
import '../models/report_model.dart';
import '../models/notification_model.dart';
import '../utils/logger.dart';

/// Service layer for all Firestore database operations.
class FirestoreService {
  /// Firestore instance used by this service.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===========================================================================
  // Users
  // ===========================================================================

  /// Creates or overwrites a user document at `users/{user.id}`.
  Future<void> createUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toFirestore());
      AppLogger.i('Firestore', 'User created: ${user.id}');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to create user ${user.id}',
          e, stackTrace);
      rethrow;
    }
  }

  /// Fetches the user document for [userId].
  ///
  /// Returns `null` if the document does not exist.
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromJson(doc.data()!);
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get user $userId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Updates specific fields on the user document for [userId].
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(userId).update(data);
      AppLogger.i('Firestore', 'User updated: $userId');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to update user $userId',
          e, stackTrace);
      rethrow;
    }
  }

  // ===========================================================================
  // Families
  // ===========================================================================

  /// Creates or overwrites a family document at `families/{family.id}`.
  Future<void> createFamily(FamilyModel family) async {
    try {
      await _db.collection('families').doc(family.id).set(family.toFirestore());
      AppLogger.i('Firestore', 'Family created: ${family.id}');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to create family ${family.id}',
          e, stackTrace);
      rethrow;
    }
  }

  /// Fetches the family document for [familyId].
  ///
  /// Returns `null` if the document does not exist.
  Future<FamilyModel?> getFamily(String familyId) async {
    try {
      final doc = await _db.collection('families').doc(familyId).get();
      if (!doc.exists || doc.data() == null) return null;
      return FamilyModel.fromJson(doc.data()!);
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get family $familyId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Finds a family by its unique [code] (pairing code).
  ///
  /// Returns `null` if no family with the given pairing code exists.
  Future<FamilyModel?> getFamilyByPairingCode(String code) async {
    try {
      final query = await _db
          .collection('families')
          .where('pairingCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return FamilyModel.fromJson(query.docs.first.data());
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get family by pairing code',
          e, stackTrace);
      rethrow;
    }
  }

  /// Updates specific fields on the family document for [familyId].
  Future<void> updateFamily(
      String familyId, Map<String, dynamic> data) async {
    try {
      await _db.collection('families').doc(familyId).update(data);
      AppLogger.i('Firestore', 'Family updated: $familyId');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to update family $familyId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Returns all families where [userId] is listed as a parent.
  Future<List<FamilyModel>> getFamiliesForUser(String userId) async {
    try {
      final query = await _db
          .collection('families')
          .where('parentIds', arrayContains: userId)
          .get();

      return query.docs
          .map((doc) => FamilyModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get families for user $userId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Returns all families where [userId] is listed as a child.
  Future<List<FamilyModel>> getFamiliesForChild(String userId) async {
    try {
      final query = await _db
          .collection('families')
          .where('childIds', arrayContains: userId)
          .get();

      return query.docs
          .map((doc) => FamilyModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get families for child $userId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Adds [parentId] to the `parentIds` array on the family document.
  ///
  /// Uses [FieldValue.arrayUnion] so duplicates are automatically ignored.
  Future<void> addParentToFamily(String familyId, String parentId) async {
    try {
      await _db.collection('families').doc(familyId).update({
        'parentIds': FieldValue.arrayUnion([parentId]),
      });
      AppLogger.i('Firestore', 'Parent $parentId added to family $familyId');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to add parent $parentId to family $familyId', e, stackTrace);
      rethrow;
    }
  }

  /// Adds [childId] to the `childIds` array on the family document.
  ///
  /// Uses [FieldValue.arrayUnion] so duplicates are automatically ignored.
  Future<void> addChildToFamily(String familyId, String childId) async {
    try {
      await _db.collection('families').doc(familyId).update({
        'childIds': FieldValue.arrayUnion([childId]),
      });
      AppLogger.i('Firestore', 'Child $childId added to family $familyId');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to add child $childId to family $familyId', e, stackTrace);
      rethrow;
    }
  }

  // ===========================================================================
  // Devices
  // ===========================================================================

  /// Creates or overwrites a device document at `devices/{device.id}`.
  Future<void> createDevice(DeviceModel device) async {
    try {
      await _db.collection('devices').doc(device.id).set(device.toFirestore());
      AppLogger.i('Firestore', 'Device created: ${device.id}');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to create device ${device.id}',
          e, stackTrace);
      rethrow;
    }
  }

  /// Fetches the device document for [deviceId].
  ///
  /// Returns `null` if the document does not exist.
  Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      final doc = await _db.collection('devices').doc(deviceId).get();
      if (!doc.exists || doc.data() == null) return null;
      return DeviceModel.fromJson(doc.data()!);
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get device $deviceId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Returns all devices belonging to the family identified by [familyId].
  Future<List<DeviceModel>> getDevicesByFamily(String familyId) async {
    try {
      final query = await _db
          .collection('devices')
          .where('familyId', isEqualTo: familyId)
          .get();

      return query.docs
          .map((doc) => DeviceModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get devices for family $familyId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Updates specific fields on the device document for [deviceId].
  Future<void> updateDevice(
      String deviceId, Map<String, dynamic> data) async {
    try {
      await _db.collection('devices').doc(deviceId).update(data);
      AppLogger.i('Firestore', 'Device updated: $deviceId');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to update device $deviceId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Updates the online status and last-seen timestamp for [deviceId].
  Future<void> updateOnlineStatus(String deviceId, bool isOnline) async {
    try {
      await _db.collection('devices').doc(deviceId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
      AppLogger.i('Firestore', 'Device $deviceId online status updated to $isOnline');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to update online status for device $deviceId', e, stackTrace);
      rethrow;
    }
  }

  // ===========================================================================
  // Device Status
  // ===========================================================================

  /// Creates or overwrites the device status document at
  /// `device_status/{status.deviceId}`.
  Future<void> updateDeviceStatus(DeviceStatusModel status) async {
    try {
      await _db
          .collection('device_status')
          .doc(status.deviceId)
          .set(status.toFirestore());
      AppLogger.i('Firestore', 'Device status updated for ${status.deviceId}');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to update device status for ${status.deviceId}', e, stackTrace);
      rethrow;
    }
  }

  /// Fetches the device status for [deviceId].
  ///
  /// Returns `null` if no status document exists.
  Future<DeviceStatusModel?> getDeviceStatus(String deviceId) async {
    try {
      final doc =
          await _db.collection('device_status').doc(deviceId).get();
      if (!doc.exists || doc.data() == null) return null;
      return DeviceStatusModel.fromJson(doc.data()!);
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get device status for $deviceId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Returns a real-time stream of the [DeviceStatusModel] for [deviceId].
  ///
  /// Emits `null` when the document does not exist.
  Stream<DeviceStatusModel?> streamDeviceStatus(String deviceId) {
    return _db
        .collection('device_status')
        .doc(deviceId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return DeviceStatusModel.fromJson(snapshot.data()!);
    }).handleError((Object e, StackTrace stackTrace) {
      AppLogger.e('Firestore', 'Error streaming device status for $deviceId',
          e, stackTrace);
    });
  }

  // ===========================================================================
  // App Usage (Daily)
  // ===========================================================================

  /// Saves daily usage data at `daily_usage/{deviceId}_{date}`.
  Future<void> saveDailyUsage(DailyUsageModel usage) async {
    try {
      final docId = '${usage.deviceId}_${usage.date}';
      await _db.collection('daily_usage').doc(docId).set(usage.toFirestore());
      AppLogger.i('Firestore', 'Daily usage saved: $docId');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to save daily usage',
          e, stackTrace);
      rethrow;
    }
  }

  /// Fetches the daily usage document for [deviceId] on [date].
  ///
  /// [date] should be in `yyyy-MM-dd` format.
  /// Returns `null` if no document exists.
  Future<DailyUsageModel?> getDailyUsage(
      String deviceId, String date) async {
    try {
      final docId = '${deviceId}_$date';
      final doc = await _db.collection('daily_usage').doc(docId).get();
      if (!doc.exists || doc.data() == null) return null;
      return DailyUsageModel.fromJson(doc.data()!);
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get daily usage for $deviceId on $date',
          e, stackTrace);
      rethrow;
    }
  }

  /// Returns daily usage documents for [deviceId] within the inclusive
  /// date range from [startDate] to [endDate].
  ///
  /// Dates should be in `yyyy-MM-dd` format.
  Future<List<DailyUsageModel>> getUsageForDateRange(
    String deviceId,
    String startDate,
    String endDate,
  ) async {
    try {
      final query = await _db
          .collection('daily_usage')
          .where('deviceId', isEqualTo: deviceId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date')
          .get();

      return query.docs
          .map((doc) => DailyUsageModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get usage for $deviceId ($startDate – $endDate)', e, stackTrace);
      rethrow;
    }
  }

  // ===========================================================================
  // Study Analytics
  // ===========================================================================

  /// Saves study analytics at `study_analytics/{deviceId}_{date}`.
  Future<void> saveStudyAnalytics(StudyAnalyticsModel analytics) async {
    try {
      final docId = '${analytics.deviceId}_${analytics.date}';
      await _db
          .collection('study_analytics')
          .doc(docId)
          .set(analytics.toFirestore());
      AppLogger.i('Firestore', 'Study analytics saved: $docId');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to save study analytics',
          e, stackTrace);
      rethrow;
    }
  }

  /// Fetches study analytics for [deviceId] on [date].
  ///
  /// [date] should be in `yyyy-MM-dd` format.
  /// Returns `null` if no document exists.
  Future<StudyAnalyticsModel?> getDailyAnalytics(
      String deviceId, String date) async {
    try {
      final docId = '${deviceId}_$date';
      final doc =
          await _db.collection('study_analytics').doc(docId).get();
      if (!doc.exists || doc.data() == null) return null;
      return StudyAnalyticsModel.fromJson(doc.data()!);
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get study analytics for $deviceId on $date', e, stackTrace);
      rethrow;
    }
  }

  /// Returns study analytics for [deviceId] within the inclusive date range
  /// from [startDate] to [endDate].
  ///
  /// Dates should be in `yyyy-MM-dd` format.
  Future<List<StudyAnalyticsModel>> getAnalyticsForDateRange(
    String deviceId,
    String startDate,
    String endDate,
  ) async {
    try {
      final query = await _db
          .collection('study_analytics')
          .where('deviceId', isEqualTo: deviceId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date')
          .get();

      return query.docs
          .map((doc) => StudyAnalyticsModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get analytics for $deviceId ($startDate – $endDate)', e, stackTrace);
      rethrow;
    }
  }

  // ===========================================================================
  // Reports
  // ===========================================================================

  /// Saves a report document at `reports/{report.id}`.
  Future<void> saveReport(ReportModel report) async {
    try {
      await _db.collection('reports').doc(report.id).set(report.toFirestore());
      AppLogger.i('Firestore', 'Report saved: ${report.id}');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to save report ${report.id}',
          e, stackTrace);
      rethrow;
    }
  }

  /// Returns all reports for the given [deviceId], ordered by
  /// `createdAt` descending.
  Future<List<ReportModel>> getReportsByDevice(String deviceId) async {
    try {
      final query = await _db
          .collection('reports')
          .where('deviceId', isEqualTo: deviceId)
          .orderBy('generatedAt', descending: true)
          .get();

      return query.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get reports for device $deviceId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Returns all reports for [deviceId] filtered by [type], ordered by
  /// `createdAt` descending.
  Future<List<ReportModel>> getReportsByType(
      String deviceId, ReportType type) async {
    try {
      final query = await _db
          .collection('reports')
          .where('deviceId', isEqualTo: deviceId)
          .where('type', isEqualTo: type.name)
          .orderBy('generatedAt', descending: true)
          .get();

      return query.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get reports for device $deviceId of type ${type.name}', e, stackTrace);
      rethrow;
    }
  }

  // ===========================================================================
  // Notifications
  // ===========================================================================

  /// Saves a notification document at `notifications/{notification.id}`.
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      await _db
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toFirestore());
      AppLogger.i('Firestore', 'Notification saved: ${notification.id}');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to save notification ${notification.id}', e, stackTrace);
      rethrow;
    }
  }

  /// Returns notifications for [familyId], ordered by `timestamp`
  /// descending, limited to [limit] documents (default 50).
  Future<List<NotificationModel>> getNotificationsByFamily(
    String familyId, {
    int limit = 50,
  }) async {
    try {
      final query = await _db
          .collection('notifications')
          .where('familyId', isEqualTo: familyId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => NotificationModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get notifications for family $familyId', e, stackTrace);
      rethrow;
    }
  }

  /// Marks the notification with [notificationId] as read.
  ///
  /// [familyId] is accepted for API consistency but not used in the query.
  Future<void> markNotificationAsRead(String familyId, String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'read': true,
      });
      AppLogger.i('Firestore', 'Notification marked as read: $notificationId');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to mark notification $notificationId as read', e, stackTrace);
      rethrow;
    }
  }

  /// Alias for backward compatibility.
  Future<void> markAsRead(String notificationId) =>
      markNotificationAsRead('', notificationId);

  /// Returns the number of unread notifications for [familyId].
  Future<int> getUnreadCount(String familyId) async {
    try {
      final query = await _db
          .collection('notifications')
          .where('familyId', isEqualTo: familyId)
          .where('read', isEqualTo: false)
          .count()
          .get();

      return query.count ?? 0;
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get unread notification count for family $familyId', e, stackTrace);
      rethrow;
    }
  }

  /// Returns a real-time stream of notifications for [familyId], ordered
  /// by `timestamp` descending.
  Stream<List<NotificationModel>> streamNotifications(String familyId) {
    return _db
        .collection('notifications')
        .where('familyId', isEqualTo: familyId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data()))
            .toList())
        .handleError((Object e, StackTrace stackTrace) {
      AppLogger.e('Firestore', 'Error streaming notifications for family $familyId', e, stackTrace);
    });
  }

  // ===========================================================================
  // Role Management
  // ===========================================================================

  /// Updates the parent role for a user.
  Future<void> updateParentRole(String userId, String parentRoleName) async {
    try {
      await _db.collection('users').doc(userId).update({
        'parentRole': parentRoleName,
      });
      AppLogger.i('Firestore', 'Updated parent role for $userId to $parentRoleName');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to update parent role for $userId', e, stackTrace);
      rethrow;
    }
  }

  /// Removes a secondary parent from a family.
  /// Only removes from the parentIds array — does not delete the user account.
  Future<void> removeSecondaryParent(
      String familyId, String parentId) async {
    try {
      await _db.collection('families').doc(familyId).update({
        'parentIds': FieldValue.arrayRemove([parentId]),
      });
      AppLogger.i('Firestore', 'Removed secondary parent $parentId from family $familyId');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to remove parent $parentId from family $familyId', e, stackTrace);
      rethrow;
    }
  }

  // ===========================================================================
  // Performance Mode
  // ===========================================================================

  /// Updates the performance mode for a device.
  Future<void> updatePerformanceMode(
    String deviceId,
    String modeName, {
    DateTime? liveModeExpiresAt,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'performanceMode': modeName,
      };
      if (liveModeExpiresAt != null) {
        data['liveModeExpiresAt'] =
            Timestamp.fromDate(liveModeExpiresAt);
      } else {
        data['liveModeExpiresAt'] = null;
      }
      await _db.collection('devices').doc(deviceId).update(data);
      AppLogger.i('Firestore', 'Updated performance mode for device $deviceId to $modeName');
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to update performance mode for device $deviceId', e, stackTrace);
      rethrow;
    }
  }

  // ===========================================================================
  // Single Report Fetch
  // ===========================================================================

  /// Fetches a single report by its [reportId].
  Future<ReportModel?> getReport(String reportId) async {
    try {
      final doc = await _db.collection('reports').doc(reportId).get();
      if (!doc.exists) return null;
      return ReportModel.fromFirestore(doc);
    } catch (e, stackTrace) {
      AppLogger.e('Firestore', 'Failed to get report $reportId', e, stackTrace);
      rethrow;
    }
  }
}
