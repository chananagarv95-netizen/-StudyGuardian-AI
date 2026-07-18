import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/services/fcm_service.dart';
import 'package:shared/services/hive_service.dart';
import 'package:shared/models/user_model.dart';
import 'package:shared/models/device_model.dart';
import 'package:shared/models/device_status_model.dart';
import 'package:shared/models/daily_usage_model.dart';
import 'package:shared/models/study_analytics_model.dart';
import 'package:shared/models/report_model.dart';
import 'package:shared/models/notification_model.dart';
import 'package:shared/models/family_model.dart';

import '../services/security_service.dart';

// ─── Service Providers ───────────────────────────────────────────────────────

/// Provides the authentication service singleton.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provides the Firestore service singleton.
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

/// Provides the FCM service singleton.
final fcmServiceProvider = Provider<FCMService>((ref) => FCMService());

/// Provides the Hive local storage service singleton.
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

/// Provides the security service for PIN and biometric authentication.
final securityServiceProvider = Provider<SecurityService>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return SecurityService(hiveService: hiveService);
});

/// Whether a parent PIN has been configured.
final hasPinProvider = Provider<bool>((ref) {
  return ref.watch(securityServiceProvider).hasPin;
});

/// Whether biometric authentication is enabled.
final isBiometricEnabledProvider = Provider<bool>((ref) {
  return ref.watch(securityServiceProvider).isBiometricEnabled;
});

// ─── Auth Providers ──────────────────────────────────────────────────────────

/// Streams the Firebase auth state (null when signed out).
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Fetches the current user's profile document from Firestore.
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return null;

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUser(user.uid);
});

// ─── Selection Providers ─────────────────────────────────────────────────────

/// Currently selected child device ID for monitoring.
final selectedDeviceIdProvider = StateProvider<String?>((ref) => null);

/// Theme mode for the app (defaults to dark).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// The current parent's role within their family.
/// Returns null if the user is not loaded or is not a parent.
final currentParentRoleProvider = Provider<ParentRole?>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || !user.isParent) return null;
  return user.parentRole;
});

// ─── Family & Device Providers ───────────────────────────────────────────────

/// Fetches the current user's family.
final familyProvider = FutureProvider<FamilyModel?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;

  final firestoreService = ref.watch(firestoreServiceProvider);

  // Search for families where user is a parent
  final families = await firestoreService.getFamiliesForUser(user.id);
  if (families.isEmpty) return null;
  return families.first;
});

/// Lists all child devices in the family.
final devicesProvider = FutureProvider<List<DeviceModel>>((ref) async {
  final family = ref.watch(familyProvider).valueOrNull;
  if (family == null) return [];

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getDevicesByFamily(family.id);
});

/// Auto-selects the first device if none is selected.
final activeDeviceProvider = Provider<String?>((ref) {
  final selected = ref.watch(selectedDeviceIdProvider);
  if (selected != null) return selected;

  final devices = ref.watch(devicesProvider).valueOrNull;
  if (devices != null && devices.isNotEmpty) {
    return devices.first.id;
  }
  return null;
});

// ─── Real-time Data Providers ────────────────────────────────────────────────

/// Streams the selected device's real-time status.
final deviceStatusStreamProvider =
    StreamProvider<DeviceStatusModel?>((ref) {
  final deviceId = ref.watch(activeDeviceProvider);
  if (deviceId == null) return Stream.value(null);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamDeviceStatus(deviceId);
});

/// Streams notifications for the family.
final notificationStreamProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final family = ref.watch(familyProvider).valueOrNull;
  if (family == null) return Stream.value([]);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamNotifications(family.id);
});

/// Count of unread notifications.
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationStreamProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.read).length;
});

// ─── Usage & Analytics Providers ─────────────────────────────────────────────

/// Fetches today's usage data for the selected device.
final dailyUsageProvider =
    FutureProvider.family<DailyUsageModel?, String>((ref, date) async {
  final deviceId = ref.watch(activeDeviceProvider);
  if (deviceId == null) return null;

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getDailyUsage(deviceId, date);
});

/// Fetches usage for a date range.
final usageRangeProvider = FutureProvider.family<List<DailyUsageModel>,
    ({String startDate, String endDate})>((ref, range) async {
  final deviceId = ref.watch(activeDeviceProvider);
  if (deviceId == null) return [];

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUsageForDateRange(
      deviceId, range.startDate, range.endDate);
});

/// Fetches today's study analytics for the selected device.
final studyAnalyticsProvider =
    FutureProvider.family<StudyAnalyticsModel?, String>((ref, date) async {
  final deviceId = ref.watch(activeDeviceProvider);
  if (deviceId == null) return null;

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getDailyAnalytics(deviceId, date);
});

/// Fetches reports for the selected device.
final reportsProvider =
    FutureProvider.family<List<ReportModel>, ReportType>((ref, type) async {
  final deviceId = ref.watch(activeDeviceProvider);
  if (deviceId == null) return [];

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getReportsByType(deviceId, type);
});

/// Fetches all reports for selected device.
final allReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  final deviceId = ref.watch(activeDeviceProvider);
  if (deviceId == null) return [];

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getReportsByDevice(deviceId);
});
