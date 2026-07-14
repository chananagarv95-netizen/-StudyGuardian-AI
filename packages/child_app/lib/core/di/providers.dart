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
import 'package:shared/models/family_model.dart';
import '../services/platform_channel_service.dart';

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

/// Provides the platform channel service for native Android communication.
final platformChannelServiceProvider =
    Provider<PlatformChannelService>((ref) => PlatformChannelService());

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

// ─── Theme Provider ──────────────────────────────────────────────────────────

/// Theme mode for the child app (defaults to dark).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// ─── Family & Device Providers ───────────────────────────────────────────────

/// Fetches the current user's family.
final familyProvider = FutureProvider<FamilyModel?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;

  final firestoreService = ref.watch(firestoreServiceProvider);

  // Search for families where user is a child
  final families = await firestoreService.getFamiliesForChild(user.id);
  if (families.isEmpty) return null;
  return families.first;
});

/// The device ID for this child device, stored in Hive.
final deviceIdProvider = Provider<String?>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return hiveService.getSettings('deviceId') as String?;
});

/// Fetches this device's document from Firestore.
final deviceProvider = FutureProvider<DeviceModel?>((ref) async {
  final deviceId = ref.watch(deviceIdProvider);
  if (deviceId == null) return null;

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getDevice(deviceId);
});

// ─── Monitoring State Providers ──────────────────────────────────────────────

/// Whether the foreground monitoring service is currently running.
final monitoringActiveProvider = StateProvider<bool>((ref) => false);

/// Whether the periodic background sync is registered.
final syncActiveProvider = StateProvider<bool>((ref) => false);

// ─── Permission State Providers ──────────────────────────────────────────────

/// Whether the PACKAGE_USAGE_STATS permission is granted.
final usagePermissionProvider = FutureProvider<bool>((ref) async {
  final platformService = ref.watch(platformChannelServiceProvider);
  return platformService.hasUsagePermission();
});

/// Whether battery optimization is disabled for this app.
final batteryOptimizationProvider = FutureProvider<bool>((ref) async {
  final platformService = ref.watch(platformChannelServiceProvider);
  return platformService.isBatteryOptimizationDisabled();
});

/// Whether the foreground service is running.
final foregroundServiceProvider = FutureProvider<bool>((ref) async {
  final platformService = ref.watch(platformChannelServiceProvider);
  return platformService.isForegroundServiceRunning();
});

// ─── Device Status Provider ──────────────────────────────────────────────────

/// Fetches the current device status from native code.
final localDeviceStatusProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final platformService = ref.watch(platformChannelServiceProvider);
  return platformService.getDeviceStatus();
});
