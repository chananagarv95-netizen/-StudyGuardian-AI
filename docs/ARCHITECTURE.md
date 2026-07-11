# 🏗 StudyGuardian AI — Architecture Documentation

> This document provides a detailed breakdown of the system architecture, design patterns, data flow, and engineering decisions behind StudyGuardian AI.

---

## Table of Contents

- [System Overview](#system-overview)
- [Layer Responsibilities](#layer-responsibilities)
- [State Management](#state-management)
- [Data Sync Strategy](#data-sync-strategy)
- [Notification Flow](#notification-flow)
- [Background Processing Strategy](#background-processing-strategy)
- [Security Model](#security-model)
- [Offline Handling](#offline-handling)

---

## System Overview

StudyGuardian AI is a dual-app system that follows a **producer-consumer** model:

```
┌───────────────────────┐         ┌─────────────────┐         ┌───────────────────────┐
│      CHILD APP        │         │    FIREBASE      │         │     PARENT APP        │
│    (Data Producer)    │────────▶│   FIRESTORE      │────────▶│   (Data Consumer)     │
│                       │         │   (Cloud DB)     │         │                       │
│  • UsageStats API     │         │                  │         │  • Real-time streams  │
│  • Battery monitor    │         │  • users         │         │  • Dashboard UI       │
│  • Network monitor    │         │  • families      │         │  • Charts & reports   │
│  • Study detection    │         │  • devices       │         │  • Notifications      │
│  • Foreground service │         │  • deviceStatus  │         │  • Analytics views    │
│  • WorkManager sync   │         │  • appUsage      │         │                       │
│                       │         │  • studyAnalytics│         │                       │
│                       │         │  • reports       │         │                       │
│                       │         │  • notifications │         │                       │
└───────────────────────┘         └─────────────────┘         └───────────────────────┘
```

### Data Flow

1. **Collection (Child App):** The child app collects device usage data via Android platform APIs (UsageStatsManager, BatteryManager, ConnectivityManager) through platform channels and native plugins.

2. **Local Storage:** Collected data is first stored locally using Hive (for quick key-value caching) and optionally Drift/SQLite (for structured queries). This ensures data is never lost due to connectivity issues.

3. **Sync (Child → Firebase):** A combination of WorkManager (periodic, every 15 min) and a foreground service (real-time for critical events) pushes data to Firestore.

4. **Real-time Delivery (Firebase → Parent App):** The parent app uses Firestore snapshot listeners (streams) to receive real-time updates. When data changes in Firestore, the parent dashboard updates immediately.

5. **Notifications:** Critical events (excessive screen time, study milestones, device offline) trigger notification documents in Firestore. The parent app reads these via streams and displays push notifications using Firebase Cloud Messaging.

---

## Layer Responsibilities

The codebase follows **Clean Architecture** with three primary layers, plus a shared `core` layer:

### Presentation Layer

```
lib/features/{feature_name}/
├── pages/           # Full-screen page widgets (routes)
├── widgets/         # Reusable UI components for this feature
└── providers/       # Riverpod providers (state + logic)
```

**Responsibilities:**
- Render UI based on state from Riverpod providers
- Handle user interactions and delegate to providers
- Navigation and routing via GoRouter
- Display loading, error, and empty states
- No direct access to data sources — always through providers

**Key Principles:**
- Pages are stateless whenever possible (state lives in providers)
- Widgets are small, focused, and composable
- Providers encapsulate all business logic for the feature
- UI is reactive — it rebuilds automatically when state changes

### Domain Layer

```
lib/domain/
├── entities/        # Pure Dart classes (no dependencies)
└── repositories/    # Abstract interfaces (contracts)
```

**Responsibilities:**
- Define pure business objects (entities) that represent core concepts
- Define repository interfaces that the data layer must implement
- Contain no framework-specific code (no Flutter, Firebase, or Hive imports)
- Act as the stable core that rarely changes

**Entities include:**
- `UserEntity` — represents a user (parent or child)
- `FamilyEntity` — represents a family group
- `DeviceEntity` — represents a registered device
- `DeviceStatusEntity` — real-time device status snapshot
- `AppUsageEntity` — per-app usage data for a day
- `DailyUsageSummaryEntity` — aggregated daily usage
- `StudySessionEntity` — a single study session
- `DailyStudyAnalyticsEntity` — aggregated daily study metrics
- `ReportEntity` — a generated report
- `NotificationEntity` — an in-app notification

### Data Layer

```
lib/data/
├── datasources/     # Concrete data source implementations
│   ├── firebase/    # Firestore, Auth, FCM clients
│   ├── local/       # Hive, Drift/SQLite clients
│   └── platform/    # Platform channel wrappers
├── models/          # DTOs with fromJson/toJson
└── repositories/    # Repository implementations
```

**Responsibilities:**
- Implement repository interfaces defined in the domain layer
- Handle data serialization/deserialization (JSON ↔ Dart objects)
- Manage data source selection (remote vs. local cache)
- Handle error mapping (Firebase exceptions → domain Failures)
- Coordinate between multiple data sources

**Data flow within the Data layer:**

```
Provider → Repository(impl) → DataSource → Firebase/Hive/Platform
                ↕
         Model (DTO) ←→ Entity conversion
```

### Core Layer

```
lib/core/
├── constants/       # String constants, API keys, durations
├── error/           # Failure sealed class, exception types
├── network/         # InternetConnectionChecker wrapper
├── theme/           # Material 3 color scheme, text styles
└── utils/           # Extensions, formatters, permission helpers
```

**Responsibilities:**
- Provide app-wide constants and configuration
- Define error types used across all layers
- Provide utility functions and extensions
- Define the Material 3 theme and design tokens
- Network connectivity checking

---

## State Management

StudyGuardian AI uses **Riverpod 2.5+** for state management, chosen for its compile-time safety, testability, and excellent support for asynchronous data.

### Provider Architecture

```
┌─────────────────────────────────────────────────────┐
│                  UI WIDGETS                          │
│         (ref.watch / ref.listen)                     │
├─────────────────────────────────────────────────────┤
│              FEATURE PROVIDERS                       │
│  ┌──────────────────┐  ┌──────────────────────┐     │
│  │ StateNotifier     │  │ AsyncNotifier         │     │
│  │ Provider          │  │ Provider              │     │
│  │ (UI state mgmt)   │  │ (async data loading)  │     │
│  └────────┬─────────┘  └──────────┬───────────┘     │
│           └──────────┬────────────┘                  │
├──────────────────────┼──────────────────────────────┤
│           REPOSITORY PROVIDERS                       │
│  ┌──────────────────────────────────────────┐       │
│  │  Provider<Repository>                     │       │
│  │  (singleton, provides repo instances)     │       │
│  └──────────────────┬───────────────────────┘       │
├──────────────────────┼──────────────────────────────┤
│           DATA SOURCE PROVIDERS                      │
│  ┌──────────────────────────────────────────┐       │
│  │  Provider<FirebaseFirestore>               │       │
│  │  Provider<FirebaseAuth>                    │       │
│  │  Provider<HiveBox>                         │       │
│  └──────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────┘
```

### Provider Types Used

| Provider Type | Use Case | Example |
|---------------|----------|---------|
| `Provider` | Singleton services (repos, data sources) | `repositoryProvider` |
| `StateNotifierProvider` | Mutable UI state with complex logic | `dashboardStateProvider` |
| `AsyncNotifierProvider` | Async data with loading/error states | `appUsageProvider` |
| `StreamProvider` | Real-time Firestore streams | `deviceStatusStreamProvider` |
| `FutureProvider` | One-shot async data fetching | `reportProvider` |
| `StateProvider` | Simple mutable state (filters, toggles) | `selectedDateProvider` |

### State Management Patterns

**Pattern 1: Real-time Firestore Stream**
```dart
final deviceStatusStreamProvider = StreamProvider.family<DeviceStatusEntity, String>(
  (ref, deviceId) {
    final repo = ref.watch(deviceStatusRepositoryProvider);
    return repo.watchDeviceStatus(deviceId);
  },
);
```

**Pattern 2: Async Data with Manual Refresh**
```dart
final dailyUsageProvider = AsyncNotifierProvider.family<DailyUsageNotifier, DailyUsageSummaryEntity, String>(
  DailyUsageNotifier.new,
);

class DailyUsageNotifier extends FamilyAsyncNotifier<DailyUsageSummaryEntity, String> {
  @override
  Future<DailyUsageSummaryEntity> build(String deviceId) async {
    final repo = ref.watch(appUsageRepositoryProvider);
    return repo.getDailyUsage(deviceId, DateTime.now());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }
}
```

**Pattern 3: UI State Machine**
```dart
final dashboardStateProvider = StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(ref),
);

class DashboardState {
  final bool isLoading;
  final String? errorMessage;
  final List<DeviceEntity> devices;
  final DeviceEntity? selectedDevice;
  // ...
}
```

---

## Data Sync Strategy

The child app uses a **dual-mechanism** sync strategy to balance battery life with data freshness:

### 1. WorkManager — Periodic Background Sync

```
┌──────────────────────────────────────────────────┐
│                WORKMANAGER                         │
│                                                    │
│  Schedule: Every 15 minutes (minimum interval)     │
│  Constraints:                                      │
│    • Network: CONNECTED (required)                 │
│    • Battery: NOT_LOW (preferred)                   │
│                                                    │
│  Tasks:                                            │
│    1. Query UsageStatsManager for recent usage      │
│    2. Aggregate data by app + category              │
│    3. Diff against last synced data                 │
│    4. Upload changed records to Firestore           │
│    5. Update local "lastSynced" timestamp            │
│    6. Generate study analytics from usage patterns   │
│    7. Check for notification triggers                │
│                                                    │
│  Retry Policy:                                     │
│    • ExponentialBackoff                              │
│    • Max retries: 3                                  │
│    • Initial delay: 30 seconds                       │
└──────────────────────────────────────────────────┘
```

**Why WorkManager?**
- Guaranteed execution even if the app is killed
- Respects battery optimization and Doze mode
- Handles network constraints automatically
- Survives device reboots (with `RECEIVE_BOOT_COMPLETED`)

### 2. Foreground Service — Real-time Critical Events

```
┌──────────────────────────────────────────────────┐
│           FOREGROUND SERVICE                       │
│                                                    │
│  Notification: "StudyGuardian is monitoring..."     │
│  Type: DATA_SYNC                                    │
│                                                    │
│  Real-time Monitoring:                              │
│    • Screen on/off events (BroadcastReceiver)        │
│    • Battery level changes                           │
│    • Network connectivity changes                    │
│    • App foreground transitions (periodic poll)       │
│                                                    │
│  Immediate Sync Triggers:                            │
│    • Screen time exceeds configured threshold         │
│    • Device goes offline/online                       │
│    • Battery drops below 15%                          │
│    • Study session starts/ends                        │
│                                                    │
│  Sleep Schedule:                                     │
│    • Active polling: every 60 seconds                 │
│    • During low-activity: every 5 minutes             │
│    • Nighttime (11 PM - 6 AM): every 15 minutes       │
└──────────────────────────────────────────────────┘
```

**Why Foreground Service?**
- Required for persistent background execution on Android 8+
- Provides consistent monitoring that WorkManager's 15-min minimum can't achieve
- Enables real-time event detection (screen on/off, battery changes)
- User-visible notification ensures transparency

### Sync Data Flow

```
UsageStatsManager ──┐
BatteryManager ─────┤
ConnectivityMgr ────┤──▶ Collector ──▶ Local Cache ──▶ SyncEngine ──▶ Firestore
ScreenReceiver ─────┘      (Dart)       (Hive)        (Dart)        (Cloud)
                                           │
                                           ▼
                                     Offline Queue
                                   (retry on connect)
```

---

## Notification Flow

Notifications in StudyGuardian AI follow a **write-then-read** pattern through Firestore, avoiding the need for a dedicated server:

```
CHILD DEVICE                    FIRESTORE                    PARENT DEVICE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Event detected              
   (e.g., screen time > 3hrs)  
          │                    
          ▼                    
2. Create notification         
   document in Firestore  ────▶  3. Document written to
                                    /notifications/{id}
                                    {
                                      familyId: "abc",
                                      targetUserId: "parent-uid",
                                      sourceUserId: "child-uid",
                                      type: "excessive_screen_time",
                                      title: "Screen Time Alert",
                                      body: "Alex has used the phone 
                                             for 3+ hours today",
                                      isRead: false,
                                      createdAt: Timestamp.now()
                                    }
                                          │
                                          ▼
                               4. Firestore snapshot  ────▶  5. StreamProvider
                                  listener triggers            receives update
                                                                    │
                                                                    ▼
                                                              6. Show local
                                                                 notification
                                                                 (flutter_local_
                                                                  notifications)
                                                                    │
                                                                    ▼
                                                              7. Update badge
                                                                 count in UI
```

### Notification Types

| Type ID | Trigger | Severity |
|---------|---------|----------|
| `excessive_screen_time` | Screen time exceeds threshold | ⚠️ Warning |
| `study_milestone` | Study streak achieved | 🎉 Positive |
| `device_offline` | Child device goes offline for >30 min | ℹ️ Info |
| `device_online` | Child device comes back online | ℹ️ Info |
| `low_battery` | Battery below 15% | ⚠️ Warning |
| `new_app_installed` | New app detected on child device | ℹ️ Info |
| `study_session_started` | Educational app usage begins | 🎉 Positive |
| `daily_report_ready` | Automated daily report generated | ℹ️ Info |

### Why Not FCM for All Notifications?

While Firebase Cloud Messaging (FCM) is used for **push notifications when the parent app is closed**, the primary notification mechanism uses Firestore streams because:

1. **No server required:** FCM push requires a server or Cloud Function to send messages. Firestore streams work client-to-client.
2. **Automatic history:** All notifications are persisted in Firestore and can be queried later.
3. **Read receipts:** The `isRead` field provides built-in read/unread tracking.
4. **Filtering:** Parents can query notifications by type, date, or read status.

FCM is used as a **supplementary channel** to wake the parent app when it's in the background and display a system notification.

---

## Background Processing Strategy

### Android-Specific Considerations

Android's battery optimization features (Doze mode, App Standby, background limits) make persistent background processing challenging. StudyGuardian AI uses a multi-layered approach:

```
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 1: Foreground Service (Always Running)                    │
│  • Persistent notification visible to user                       │
│  • Polls usage data every 60 seconds                             │
│  • Listens for system broadcasts (screen, battery, connectivity) │
│  • Survives Doze mode (foreground services are exempt)            │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 2: WorkManager (Periodic Guaranteed)                      │
│  • Scheduled every 15 minutes                                     │
│  • Runs even if foreground service is killed by OEM               │
│  • Handles bulk data sync and analytics computation               │
│  • Constrained to network availability                            │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 3: Boot Receiver (Recovery)                                │
│  • Restarts foreground service on device reboot                   │
│  • Re-schedules WorkManager tasks                                 │
│  • Ensures monitoring resumes after power cycle                   │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 4: AlarmManager (Heartbeat)                                │
│  • Exact alarm every 30 minutes                                   │
│  • Health check: verifies foreground service is alive              │
│  • Restarts service if it was killed unexpectedly                  │
│  • Acts as a watchdog for Layer 1                                  │
└─────────────────────────────────────────────────────────────────┘
```

### OEM-Specific Handling

Many Android OEMs (Xiaomi, Huawei, Samsung, Oppo, Vivo, OnePlus) aggressively kill background apps. The child app addresses this with:

1. **Auto-start permission request:** Detects OEM and guides user to enable auto-start
2. **Battery optimization exemption:** Requests `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`
3. **OEM-specific settings deep links:** Provides direct links to OEM battery settings
4. **Self-recovery mechanisms:** Boot receiver + AlarmManager watchdog
5. **User education:** In-app guide explaining why these permissions are needed

---

## Security Model

### Authentication

```
┌─────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   Firebase Auth  │────▶│   Custom Claims   │────▶│  Firestore Rules │
│                  │     │   (optional)      │     │  (enforcement)   │
│  • Email/Pass    │     │  • role: parent   │     │  • isOwner()     │
│  • Google SSO    │     │  • familyId       │     │  • isFamilyMember│
│                  │     │                   │     │  • isParentIn... │
└─────────────────┘     └──────────────────┘     └──────────────────┘
```

### Authorization Matrix

| Action | Parent (own family) | Child (own data) | Child (sibling data) | Stranger |
|--------|:------------------:|:----------------:|:-------------------:|:--------:|
| Read user profile | ✅ (own) | ✅ (own) | ❌ | ❌ |
| Read family data | ✅ | ✅ | ✅ | ❌ |
| Write device status | ❌ | ✅ (own device) | ❌ | ❌ |
| Read device status | ✅ (family) | ✅ (own) | ❌ | ❌ |
| Write app usage | ❌ | ✅ (own device) | ❌ | ❌ |
| Read app usage | ✅ (family) | ✅ (own) | ❌ | ❌ |
| Read study analytics | ✅ (family) | ✅ (own) | ❌ | ❌ |
| Create notifications | ✅ | ✅ | ❌ | ❌ |
| Read notifications | ✅ (family) | ✅ (targeted) | ❌ | ❌ |
| Create reports | ✅ | ❌ | ❌ | ❌ |
| Read reports | ✅ (family) | ❌ | ❌ | ❌ |
| Delete reports | ✅ (family) | ❌ | ❌ | ❌ |

### Security Rules Enforcement

All authorization is enforced at the **Firestore security rules** level (see `firebase/firestore.rules`). Key helper functions:

- `isAuthenticated()` — checks `request.auth != null`
- `isOwner(userId)` — checks `request.auth.uid == userId`
- `isFamilyMember(familyId)` — checks if UID is in `parentIds` or `childIds`
- `isParentInFamily(familyId)` — checks if UID is in `parentIds`
- `isDeviceOwner(deviceId)` — checks if UID matches device's `userId`
- `isDeviceFamilyMember(deviceId)` — checks if UID is in the device's family

### Data Validation

Security rules also enforce data integrity:

- Required fields are validated on document creation
- Immutable fields (e.g., `createdAt`, `userId`, `email`, `role`) cannot be changed after creation
- Enum fields (e.g., `role`, `reportType`) are validated against allowed values
- Notifications are created with `isRead: false` (cannot be created as already read)
- Only the `isRead` field can be changed in notification updates by the target user

---

## Offline Handling

StudyGuardian AI is designed to work reliably even with intermittent connectivity:

### Child App — Offline-First Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    DATA COLLECTION                         │
│  (always works — no network dependency)                    │
│                                                            │
│  UsageStats API ──▶ Local Processor ──▶ Hive Cache          │
│  Battery API ──────▶                      │                 │
│  Network API ──────▶                      │                 │
│                                           ▼                 │
│                                    ┌─────────────┐          │
│                                    │ Sync Queue  │          │
│                                    │ (ordered)   │          │
│                                    └──────┬──────┘          │
│                                           │                 │
│                              ┌────────────┼────────────┐    │
│                              │  Network   │            │    │
│                              │  Available?│            │    │
│                              ▼            ▼            │    │
│                           ┌────┐      ┌──────┐        │    │
│                           │ YES│      │  NO  │        │    │
│                           └──┬─┘      └──┬───┘        │    │
│                              │           │             │    │
│                              ▼           ▼             │    │
│                         Upload to    Enqueue for       │    │
│                         Firestore    later retry       │    │
│                              │           │             │    │
│                              ▼           ▼             │    │
│                         Clear from   Keep in queue     │    │
│                         queue        + increment       │    │
│                                      retry count       │    │
└──────────────────────────────────────────────────────────┘
```

### Retry Strategy

```dart
/// Exponential backoff with jitter for retry scheduling
Duration calculateRetryDelay(int retryCount) {
  final baseDelay = Duration(seconds: 30);
  final maxDelay = Duration(minutes: 15);
  final exponentialDelay = baseDelay * pow(2, retryCount);
  final jitter = Duration(
    milliseconds: Random().nextInt(5000),
  );
  return min(exponentialDelay + jitter, maxDelay);
}
```

| Retry # | Base Delay | With Jitter (approx) |
|---------|-----------|---------------------|
| 1 | 30 seconds | 30-35 seconds |
| 2 | 1 minute | 60-65 seconds |
| 3 | 2 minutes | 120-125 seconds |
| 4 | 4 minutes | 240-245 seconds |
| 5 | 8 minutes | 480-485 seconds |
| 6+ | 15 minutes (max) | ~15 minutes |

### Parent App — Graceful Degradation

The parent app uses Firestore's built-in offline persistence:

1. **Firestore offline cache** is enabled by default — previously loaded data is available immediately
2. **Stream listeners** automatically reconnect when network returns
3. **UI indicators** show "Last updated: X minutes ago" when data may be stale
4. **Pull-to-refresh** allows manual refresh with network error feedback
5. **Cached reports** are stored in Hive for instant loading

### Hive Cache Structure

```
Hive Boxes:
├── device_status_cache      # Latest device status snapshot
├── daily_usage_cache        # Last 7 days of daily usage
├── study_analytics_cache    # Last 7 days of study data
├── sync_queue               # Pending sync operations (child app)
├── app_metadata_cache       # App names, categories, icons
├── notification_cache       # Recent notifications
└── settings                 # App preferences & config
```

### Conflict Resolution

When offline data is synced after a period of disconnection:

1. **Last-write-wins** for device status (latest data always wins)
2. **Merge by date** for daily usage (each date is a separate document)
3. **Append-only** for notifications (new documents, no conflicts)
4. **Idempotent writes** using deterministic document IDs where possible

---

## Additional Notes

### Performance Considerations

- **Firestore reads are optimized** by structuring data to minimize document reads per screen
- **Pagination** is used for notification and report lists (20 items per page)
- **Collection group queries** with composite indexes enable efficient cross-device queries
- **Image-free design** reduces bandwidth (no avatars or thumbnails in MVP)
- **Batch writes** are used when syncing multiple documents to reduce round trips

### Scalability

- The Firestore schema supports multiple children per family without schema changes
- Each child's data is partitioned by device ID, preventing write contention
- Daily subcollections automatically partition data over time
- The notification system supports high write throughput without conflicts

### Future Considerations

- **Cloud Functions** for server-side report generation and FCM push triggers
- **Firebase Remote Config** for dynamic threshold configuration
- **ML Kit** for on-device study pattern recognition
- **Web dashboard** for parent access from desktop browsers
- **iOS child app** (currently Android-only due to UsageStats API dependency)
