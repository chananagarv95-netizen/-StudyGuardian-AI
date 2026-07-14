# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2026-07-11

### Added
- `shared` package with models, services, constants, and theme setup.
- Firebase integration scaffolding and documentation.
- `parent_app` structure, pubspec, routers, DI, and core utilities.
- `parent_app` UI widgets, charts, and shimmer loading indicators.
- `parent_app` screens including Splash, Login, Register, Dashboard, Pairing, Device List, App Usage, Analytics, Reports, Notifications, and Settings.
- Project state tracking and changelog setup.

## [0.1.1] - 2026-07-13

### Fixed
- **Critical:** All `toMap()`/`fromMap()` calls in `FirestoreService` changed to `toFirestore()`/`fromJson()` to match model APIs (~30 compile errors).
- **Critical:** Added missing `getFamiliesForUser()` method to `FirestoreService`.
- **Critical:** Fixed `markNotificationAsRead()` signature mismatch (was `markAsRead(id)`, callers expected `markNotificationAsRead(familyId, id)`).

### Added
- `AndroidManifest.xml` for parent app (was completely missing).
- `.gitignore` for the monorepo.
- Accurate `PROJECT_STATE.md` reflecting true completion status.

## [0.3.0] - 2026-07-14

### Added
- **Child App UI Implementation:**
  - Added `login_screen.dart` with Google Sign-In setup.
  - Added `join_family_screen.dart` to link child device to a family via code.
  - Added `permissions_screen.dart` to guide users in granting required monitoring permissions.
  - Added `home_screen.dart` dashboard showing connection and service status.
  - Added `settings_screen.dart` with manual sync and sign out options.
  - Updated `app_router.dart` to use the actual screens instead of placeholders.
- **Child App Native Services:**
  - Added `ForegroundMonitoringService.kt` to ensure the app stays alive for monitoring.
  - Added `BootReceiver.kt` to automatically restart the foreground service on device boot.
  - Updated `MainActivity.kt` to handle starting/stopping the foreground service.
  - Updated `AndroidManifest.xml` to declare the foreground service.

## [0.2.0] - 2026-07-14

### Added
- **Child App Foundation:**
  - `pubspec.yaml` with all dependencies (WorkManager, battery_plus, device_info_plus, permission_handler, etc.)
  - `main.dart` with Firebase, Hive, WorkManager, and local notifications initialization.
  - `app.dart` root widget with shared theme integration.
  - `core/di/providers.dart` — Riverpod DI with auth, family, device, monitoring, and permission providers.
  - `core/router/app_router.dart` — GoRouter with auth-aware redirects and 6 route definitions.
  - `core/constants/platform_channels.dart` — MethodChannel name and all method identifiers.
  - `core/services/platform_channel_service.dart` — Dart bridge for all native calls (usage stats, device info, foreground service, battery optimization, installed apps).
  - `core/services/work_manager_service.dart` — periodic 15-minute sync with offline queuing and retry.
  - `core/utils/extensions.dart` — BuildContext, DateTime, String, num extensions (consistent with parent app).
  - `domain/repositories/` — 4 abstract interfaces (auth, device, usage, sync).
  - `data/repositories/` — 4 implementations wired to shared services and platform channels.
  - `android/app/src/main/AndroidManifest.xml` — all monitoring permissions (USAGE_STATS, FOREGROUND_SERVICE, BOOT_COMPLETED, QUERY_ALL_PACKAGES, etc.)
  - `android/app/src/main/kotlin/.../MainActivity.kt` — full MethodChannel handler with UsageStatsManager, BatteryManager, StorageInfo, RAM, Network, and installed apps queries.
- `getFamiliesForChild()` method added to shared `FirestoreService`.

