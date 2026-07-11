/// Firebase Cloud Messaging service for StudyGuardian AI.
///
/// Manages push notification permissions, token lifecycle, and
/// message handling. Uses a Firestore `notification_queue` collection
/// to enqueue outbound notifications for processing by Cloud Functions.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../utils/logger.dart';

/// Service that wraps Firebase Cloud Messaging (FCM) operations.
class FCMService {
  /// Firebase Cloud Messaging instance.
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Firestore instance for queuing outbound notifications.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initializes FCM by requesting notification permissions and
  /// retrieving the device FCM token.
  ///
  /// Should be called once during application startup after Firebase
  /// has been initialized.
  Future<void> initialize() async {
    try {
      // Request notification permissions (required on iOS & web).
      final NotificationSettings settings =
          await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      AppLogger.info(
        'FCM permission status: ${settings.authorizationStatus}',
      );

      // Retrieve the current FCM token.
      final String? token = await _messaging.getToken();
      AppLogger.info('FCM token retrieved: ${token != null ? '***' : 'null'}');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize FCM',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Token Management
  // ---------------------------------------------------------------------------

  /// Returns the current FCM registration token, or `null` if unavailable.
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get FCM token',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// A stream that emits a new token whenever the FCM registration
  /// token is refreshed.
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  // ---------------------------------------------------------------------------
  // Sending Notifications (via Firestore queue)
  // ---------------------------------------------------------------------------

  /// Enqueues a push notification for delivery by a Cloud Function.
  ///
  /// Writes a document to the `notification_queue` collection containing
  /// [targetFcmToken], [title], [body], and optional [data] payload.
  /// A Cloud Function should watch this collection and send the actual
  /// FCM message.
  Future<void> sendNotificationViaFirestore({
    required String targetFcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _db.collection('notification_queue').add({
        'targetFcmToken': targetFcmToken,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });

      AppLogger.info(
        'Notification queued: "$title" → token ***${targetFcmToken.substring(targetFcmToken.length > 6 ? targetFcmToken.length - 6 : 0)}',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to queue notification via Firestore',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Message Handling
  // ---------------------------------------------------------------------------

  /// Registers a [handler] that is called whenever a push notification
  /// is received while the app is in the foreground.
  void onMessage(void Function(RemoteMessage) handler) {
    try {
      FirebaseMessaging.onMessage.listen(
        handler,
        onError: (Object error) {
          AppLogger.error(
            'Error in onMessage listener',
            error: error,
          );
        },
      );
      AppLogger.info('FCM onMessage listener registered.');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to register onMessage listener',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Top-level / static handler for background messages.
  ///
  /// Must be a top-level function or a static method to be used with
  /// [FirebaseMessaging.onBackgroundMessage].
  ///
  /// Usage:
  /// ```dart
  /// FirebaseMessaging.onBackgroundMessage(FCMService.handleBackgroundMessage);
  /// ```
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    try {
      AppLogger.info(
        'Background message received: ${message.messageId ?? 'no-id'} '
        '— title: ${message.notification?.title ?? 'N/A'}',
      );
      // Add custom background processing logic here if needed.
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error handling background message',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
