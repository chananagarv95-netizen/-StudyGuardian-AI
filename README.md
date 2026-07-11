# 📚 StudyGuardian AI

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20FCM-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://developer.android.com)

> **A privacy-first parental monitoring system** that helps families balance screen time, track study habits, and promote healthy digital wellness — powered by Flutter, Firebase, and on-device AI analytics.

---

## 📖 Table of Contents

- [Overview](#overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Firebase Setup](#-firebase-setup)
- [Firestore Schema](#-firestore-schema)
- [Android Permissions](#-android-permissions)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Privacy & Ethics](#-privacy--ethics)
- [Troubleshooting](#-troubleshooting)
- [License](#-license)

---

## Overview

StudyGuardian AI is a **dual-app system** consisting of:

| App | Purpose | Installed On |
|-----|---------|-------------|
| **Parent App** | Dashboard for monitoring, reports, and notifications | Parent's phone |
| **Child App** | Background data collection and study tracking | Child's phone |

Both apps connect to a shared **Firebase backend** for real-time data synchronization. The child app runs background services to collect usage data, while the parent app provides an intuitive dashboard for monitoring and insights.

---

## ✨ Features

### 📊 Dashboard
- Real-time overview of child's device activity
- Today's screen time summary with hourly breakdown
- Active/inactive device status indicator
- Battery level and charging status
- Quick-access cards for all monitoring categories

### 📱 App Usage Monitoring
- Per-app usage time tracking with daily/weekly/monthly views
- App categorization (Education, Social Media, Games, Productivity, etc.)
- Most-used apps ranking with trend indicators
- Usage comparison charts across time periods
- Category-wise usage distribution pie charts

### 📖 Study Analytics
- Daily study time tracking with focus score calculation
- Study session detection (based on educational app usage patterns)
- Break detection and productivity rating
- Weekly study goal progress tracking
- Study vs. entertainment ratio analysis
- Historical trend charts with 7-day, 30-day, and 90-day views

### 🔔 Notifications
- Real-time alerts for excessive screen time
- Study milestone notifications (e.g., "2-hour study streak!")
- Device offline/online status changes
- Low battery warnings from child's device
- Custom notification preferences and thresholds
- Notification history with read/unread status

### 📋 Reports
- Automated daily, weekly, and monthly report generation
- Comprehensive usage summaries with key insights
- Exportable report data
- Trend analysis with actionable recommendations
- Comparative analysis across reporting periods

### 📱 Device Information
- Device model, Android version, and platform details
- Network connectivity type (WiFi, Mobile Data, Offline)
- Screen on/off state tracking
- Storage and memory usage overview
- Last seen timestamp with relative time display

### 🔄 Background Sync
- Persistent foreground service on child device (with notification)
- WorkManager-based periodic sync (every 15 minutes)
- Intelligent retry with exponential backoff on failure
- Offline data queuing with automatic upload when connectivity returns
- Battery-optimized sync scheduling

---

## 🏗 Architecture

StudyGuardian AI follows **MVVM + Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────┐
│                   PRESENTATION                       │
│  ┌─────────┐  ┌──────────┐  ┌─────────────────┐    │
│  │  Pages  │  │ Widgets  │  │  Riverpod       │    │
│  │  (UI)   │  │          │  │  Providers      │    │
│  └────┬────┘  └────┬─────┘  └───────┬─────────┘    │
│       └─────────────┴───────────────┘                │
├─────────────────────┬───────────────────────────────┤
│                   DOMAIN                             │
│  ┌─────────┐  ┌──────────┐  ┌─────────────────┐    │
│  │Entities │  │  Repos   │  │   Use Cases     │    │
│  │ (pure)  │  │(abstract)│  │                 │    │
│  └─────────┘  └──────────┘  └─────────────────┘    │
├─────────────────────┬───────────────────────────────┤
│                    DATA                              │
│  ┌─────────┐  ┌──────────┐  ┌─────────────────┐    │
│  │  DTOs   │  │  Repos   │  │  Data Sources   │    │
│  │(models) │  │  (impl)  │  │ Firebase │ Hive │    │
│  └─────────┘  └──────────┘  └─────────────────┘    │
├─────────────────────┬───────────────────────────────┤
│                  CORE                                │
│  ┌─────────┐  ┌──────────┐  ┌─────────────────┐    │
│  │ Theme   │  │  Utils   │  │   Constants     │    │
│  │         │  │          │  │   Error Types   │    │
│  └─────────┘  └──────────┘  └─────────────────┘    │
└─────────────────────────────────────────────────────┘
```

For a detailed architecture breakdown, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## 🛠 Tech Stack

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Framework** | Flutter | 3.22+ | Cross-platform UI toolkit |
| **Language** | Dart | 3.4+ | Application programming language |
| **State Management** | Riverpod | 2.5+ | Reactive state management |
| **Backend** | Firebase Firestore | Latest | Real-time NoSQL cloud database |
| **Authentication** | Firebase Auth | Latest | User authentication & identity |
| **Push Notifications** | Firebase Cloud Messaging | Latest | Remote push notifications |
| **Local Storage** | Hive | 2.2+ | Lightweight local key-value store |
| **Local Database** | Drift (SQLite) | 2.15+ | Structured local data persistence |
| **HTTP Client** | Dio | 5.4+ | HTTP networking with interceptors |
| **Routing** | GoRouter | 13.0+ | Declarative routing |
| **Code Generation** | Freezed + json_serializable | Latest | Immutable models & JSON serialization |
| **Dependency Injection** | Riverpod | 2.5+ | Compile-safe DI via providers |
| **Background Tasks** | WorkManager (Android) | 2.9+ | Periodic background sync |
| **Foreground Service** | flutter_foreground_task | 6.1+ | Persistent child monitoring service |
| **Charts** | fl_chart | 0.66+ | Beautiful interactive charts |
| **Date/Time** | intl | 0.19+ | Internationalization & formatting |
| **Permissions** | permission_handler | 11.3+ | Runtime permission management |
| **Connectivity** | connectivity_plus | 5.0+ | Network state monitoring |
| **Device Info** | device_info_plus | 10.1+ | Hardware & OS information |
| **Battery** | battery_plus | 5.0+ | Battery level & state monitoring |
| **Build System** | Gradle (Kotlin DSL) | 8.2+ | Android build configuration |

---

## 📁 Project Structure

```
study_guardian_ai/
├── README.md                          # This file
├── docs/
│   └── ARCHITECTURE.md               # Detailed architecture documentation
├── firebase/
│   ├── firestore.rules                # Firestore security rules
│   ├── firestore.indexes.json         # Composite index definitions
│   └── firebase_options_placeholder.dart  # Firebase config template
├── packages/
│   ├── shared/                        # Shared library (models, utils, services)
│   │   └── lib/
│   │       ├── core/
│   │       │   ├── constants/         # App-wide constants & strings
│   │       │   ├── error/             # Failure & exception classes
│   │       │   ├── network/           # Connectivity checker
│   │       │   ├── theme/             # Material 3 design tokens
│   │       │   └── utils/             # Helper functions & extensions
│   │       ├── data/
│   │       │   ├── datasources/       # Firebase, Hive, platform channels
│   │       │   ├── models/            # DTOs with JSON serialization
│   │       │   └── repositories/      # Repository implementations
│   │       └── domain/
│   │           ├── entities/          # Pure business objects
│   │           └── repositories/      # Abstract repository interfaces
│   ├── parent_app/                    # Parent monitoring dashboard
│   │   ├── android/
│   │   │   ├── app/
│   │   │   │   └── build.gradle.kts   # Module-level Gradle config
│   │   │   ├── build.gradle.kts       # Project-level Gradle config
│   │   │   ├── settings.gradle.kts    # Plugin & repository settings
│   │   │   └── gradle.properties      # Build properties
│   │   └── lib/
│   │       ├── features/
│   │       │   ├── auth/              # Login, registration, family setup
│   │       │   ├── dashboard/         # Main overview dashboard
│   │       │   ├── app_usage/         # App usage monitoring screens
│   │       │   ├── study_analytics/   # Study tracking & insights
│   │       │   ├── notifications/     # Notification center
│   │       │   ├── reports/           # Report generation & viewing
│   │       │   ├── device_info/       # Device status & details
│   │       │   └── settings/          # App preferences & config
│   │       └── main.dart              # App entry point
│   └── child_app/                     # Child data collection app
│       ├── android/
│       │   ├── app/
│       │   │   └── build.gradle.kts   # Module-level Gradle config
│       │   ├── build.gradle.kts       # Project-level Gradle config
│       │   ├── settings.gradle.kts    # Plugin & repository settings
│       │   └── gradle.properties      # Build properties
│       └── lib/
│           ├── features/
│           │   ├── auth/              # Child login & family join
│           │   ├── status/            # Current status display
│           │   └── settings/          # Child app preferences
│           ├── services/
│           │   ├── usage_tracker/     # UsageStats API integration
│           │   ├── sync_service/      # Firebase sync logic
│           │   └── foreground_service/ # Persistent monitoring service
│           └── main.dart              # App entry point
└── pubspec.yaml                       # Root workspace configuration
```

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

| Requirement | Minimum Version | Check Command |
|-------------|----------------|---------------|
| Flutter SDK | 3.22.0 | `flutter --version` |
| Dart SDK | 3.4.0 | `dart --version` |
| Android Studio | 2023.1+ | — |
| Android SDK | API 34 (Android 14) | SDK Manager |
| Java JDK | 17 | `java -version` |
| Node.js | 18+ | `node --version` |
| Firebase CLI | Latest | `firebase --version` |
| FlutterFire CLI | Latest | `flutterfire --version` |
| Git | 2.0+ | `git --version` |

### Install Firebase & FlutterFire CLIs

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Log in to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/study_guardian_ai.git
cd study_guardian_ai
```

### 2. Install Dependencies

```bash
# Install shared package dependencies
cd packages/shared
flutter pub get

# Install parent app dependencies
cd ../parent_app
flutter pub get

# Install child app dependencies
cd ../child_app
flutter pub get
```

### 3. Configure Firebase

Follow the detailed [Firebase Setup Guide](#-firebase-setup) below.

### 4. Generate Code (Freezed models, JSON serialization)

```bash
# In each package that uses code generation:
cd packages/shared
dart run build_runner build --delete-conflicting-outputs

cd ../parent_app
dart run build_runner build --delete-conflicting-outputs

cd ../child_app
dart run build_runner build --delete-conflicting-outputs
```

### 5. Build APKs

```bash
# Build Parent App (release)
cd packages/parent_app
flutter build apk --release

# Build Child App (release)
cd ../child_app
flutter build apk --release
```

### 6. Install on Devices

```bash
# Install Parent App on parent's phone
cd packages/parent_app
flutter install

# Install Child App on child's phone
cd ../child_app
flutter install
```

> **Note:** The child app and parent app should be installed on **separate devices**. The child app requires specific Android permissions that must be granted manually after installation.

---

## 🔥 Firebase Setup

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"**
3. Enter project name: `study-guardian-ai`
4. Enable Google Analytics (recommended)
5. Click **"Create project"**

### Step 2: Register Android Apps

Register **two separate Android apps** in the same Firebase project:

| App | Package Name |
|-----|-------------|
| Parent App | `com.studyguardian.parent` |
| Child App | `com.studyguardian.child` |

For each app:
1. Click **"Add app" → Android**
2. Enter the package name
3. Download `google-services.json`
4. Place it in the respective `android/app/` directory

### Step 3: Enable Authentication

1. Go to **Authentication → Sign-in method**
2. Enable **Email/Password** provider
3. (Optional) Enable **Google Sign-In** for convenience

### Step 4: Create Firestore Database

1. Go to **Firestore Database → Create database**
2. Select **Production mode**
3. Choose your preferred region (e.g., `us-central1`)
4. Deploy the security rules from `firebase/firestore.rules`

### Step 5: Deploy Security Rules & Indexes

```bash
# From the project root
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### Step 6: Enable Cloud Messaging

1. Go to **Cloud Messaging** in the Firebase Console
2. FCM is enabled by default for new projects
3. Note your **Server Key** for server-side notifications (if needed)

### Step 7: Configure FlutterFire

```bash
# In parent_app directory
cd packages/parent_app
flutterfire configure --project=study-guardian-ai

# In child_app directory
cd ../child_app
flutterfire configure --project=study-guardian-ai
```

This generates `lib/firebase_options.dart` in each app with your real credentials.

---

## 📊 Firestore Schema

### `users` Collection

| Field | Type | Description |
|-------|------|-------------|
| `email` | `string` | User's email address |
| `displayName` | `string` | Display name |
| `role` | `string` | `"parent"` or `"child"` |
| `familyId` | `string` | Reference to family document |
| `avatarUrl` | `string?` | Optional profile picture URL |
| `createdAt` | `timestamp` | Account creation time |
| `updatedAt` | `timestamp` | Last profile update |

### `families` Collection

| Field | Type | Description |
|-------|------|-------------|
| `familyName` | `string` | Family display name |
| `parentIds` | `array<string>` | UIDs of parent accounts |
| `childIds` | `array<string>` | UIDs of child accounts |
| `inviteCode` | `string` | 6-digit code for joining |
| `createdAt` | `timestamp` | Family creation time |

### `devices` Collection

| Field | Type | Description |
|-------|------|-------------|
| `userId` | `string` | Owner's UID |
| `familyId` | `string` | Family reference |
| `deviceName` | `string` | User-friendly device name |
| `platform` | `string` | `"android"` |
| `model` | `string` | Device model (e.g., "Pixel 7") |
| `androidVersion` | `string` | OS version |
| `lastSeen` | `timestamp` | Last activity timestamp |
| `isOnline` | `boolean` | Current online status |
| `createdAt` | `timestamp` | Device registration time |

### `deviceStatus` Collection

| Field | Type | Description |
|-------|------|-------------|
| `deviceId` | `string` | Reference to device document |
| `userId` | `string` | Device owner's UID |
| `familyId` | `string` | Family reference |
| `batteryLevel` | `number` | Battery percentage (0-100) |
| `isCharging` | `boolean` | Whether device is charging |
| `isScreenOn` | `boolean` | Screen on/off state |
| `networkType` | `string` | `"wifi"`, `"mobile"`, `"none"` |
| `lastUpdated` | `timestamp` | Last status update |

### `appUsage` Collection → `daily/{date}` → `apps/{packageName}`

**Top-level document (`appUsage/{deviceId}`):**

| Field | Type | Description |
|-------|------|-------------|
| `deviceId` | `string` | Device reference |
| `userId` | `string` | Device owner's UID |
| `familyId` | `string` | Family reference |

**Daily sub-document (`daily/{date}`):**

| Field | Type | Description |
|-------|------|-------------|
| `date` | `string` | ISO date (e.g., `"2025-01-15"`) |
| `totalScreenTimeMinutes` | `number` | Total screen time in minutes |
| `appUsageMap` | `map` | Package name → minutes map |
| `syncedAt` | `timestamp` | Last sync timestamp |

**App sub-document (`daily/{date}/apps/{packageName}`):**

| Field | Type | Description |
|-------|------|-------------|
| `packageName` | `string` | Android package name |
| `appName` | `string` | Human-readable app name |
| `categoryTag` | `string` | Category classification |
| `usageMinutes` | `number` | Total usage in minutes |
| `openCount` | `number` | Number of times opened |
| `firstUsed` | `timestamp` | First usage in the day |
| `lastUsed` | `timestamp` | Most recent usage |

### `studyAnalytics` Collection → `daily/{date}`

**Top-level document (`studyAnalytics/{userId}`):**

| Field | Type | Description |
|-------|------|-------------|
| `userId` | `string` | User reference |
| `familyId` | `string` | Family reference |

**Daily sub-document (`daily/{date}`):**

| Field | Type | Description |
|-------|------|-------------|
| `date` | `string` | ISO date |
| `totalStudyMinutes` | `number` | Total study time in minutes |
| `focusScore` | `number` | Focus score (0.0 - 1.0) |
| `studySessions` | `array<map>` | Array of session objects |
| `breaksTaken` | `number` | Number of breaks taken |
| `productivityRating` | `string` | `"low"`, `"medium"`, `"high"` |
| `syncedAt` | `timestamp` | Last sync timestamp |

### `reports` Collection

| Field | Type | Description |
|-------|------|-------------|
| `familyId` | `string` | Family reference |
| `childUserId` | `string` | Subject child's UID |
| `reportType` | `string` | `"daily"`, `"weekly"`, `"monthly"` |
| `generatedAt` | `timestamp` | Report generation time |
| `periodStart` | `timestamp` | Reporting period start |
| `periodEnd` | `timestamp` | Reporting period end |
| `data` | `map` | Report summary data |

### `notifications` Collection

| Field | Type | Description |
|-------|------|-------------|
| `familyId` | `string` | Family reference |
| `targetUserId` | `string` | Notification recipient UID |
| `sourceUserId` | `string` | Notification sender UID |
| `type` | `string` | Notification type identifier |
| `title` | `string` | Notification title |
| `body` | `string` | Notification body text |
| `data` | `map` | Additional structured data |
| `isRead` | `boolean` | Read/unread status |
| `createdAt` | `timestamp` | Creation timestamp |

---

## 🔐 Android Permissions

### Child App Permissions

| Permission | Purpose | Type |
|------------|---------|------|
| `INTERNET` | Firebase sync & data upload | Normal (auto-granted) |
| `ACCESS_NETWORK_STATE` | Detect connectivity changes | Normal (auto-granted) |
| `RECEIVE_BOOT_COMPLETED` | Restart services after reboot | Normal (auto-granted) |
| `FOREGROUND_SERVICE` | Run persistent monitoring service | Normal (auto-granted) |
| `FOREGROUND_SERVICE_DATA_SYNC` | Foreground service type declaration | Normal (auto-granted) |
| `POST_NOTIFICATIONS` | Show foreground service notification | Runtime (Android 13+) |
| `PACKAGE_USAGE_STATS` | Access UsageStats API for app usage data | Special (Settings redirect) |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Prevent service from being killed | Special (Settings redirect) |
| `WAKE_LOCK` | Keep CPU awake during sync operations | Normal (auto-granted) |

### Parent App Permissions

| Permission | Purpose | Type |
|------------|---------|------|
| `INTERNET` | Firebase data retrieval | Normal (auto-granted) |
| `ACCESS_NETWORK_STATE` | Detect connectivity for real-time updates | Normal (auto-granted) |
| `POST_NOTIFICATIONS` | Show alert notifications from child device | Runtime (Android 13+) |

> **Note:** The `PACKAGE_USAGE_STATS` permission requires the user to manually enable it in **Settings → Apps → Special access → Usage access**. The child app provides an in-app guide to walk users through this process.

---

## 🧪 Testing

### Run Unit Tests

```bash
# Shared package tests
cd packages/shared
flutter test

# Parent app tests
cd ../parent_app
flutter test

# Child app tests
cd ../child_app
flutter test
```

### Run Integration Tests

```bash
# Parent app integration tests
cd packages/parent_app
flutter test integration_test/

# Child app integration tests
cd ../child_app
flutter test integration_test/
```

### Run Tests with Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Testing Strategy

| Layer | Testing Approach |
|-------|-----------------|
| **Domain (Entities)** | Unit tests for business logic |
| **Domain (Repositories)** | Mock-based unit tests |
| **Data (Models)** | JSON serialization/deserialization tests |
| **Data (Repositories)** | Integration tests with Firebase emulator |
| **Data (Data Sources)** | Mock Firebase & Hive tests |
| **Presentation (Providers)** | Riverpod provider override tests |
| **Presentation (Widgets)** | Widget tests with golden files |
| **End-to-End** | Integration tests on real devices |

---

## 🚢 Deployment

### Building Release APKs

```bash
# Parent App
cd packages/parent_app
flutter build apk --release --target-platform android-arm64

# Child App
cd ../child_app
flutter build apk --release --target-platform android-arm64
```

The APKs will be generated at:
- `packages/parent_app/build/app/outputs/flutter-apk/app-release.apk`
- `packages/child_app/build/app/outputs/flutter-apk/app-release.apk`

### Building App Bundles (for Play Store)

```bash
# Parent App
cd packages/parent_app
flutter build appbundle --release

# Child App
cd ../child_app
flutter build appbundle --release
```

### Sideloading APKs

1. **Enable "Install from Unknown Sources"** on the target Android device:
   - Go to **Settings → Security → Unknown Sources** (or **Settings → Apps → Special access → Install unknown apps**)
   - Enable for your file manager or browser

2. **Transfer the APK** to the device via:
   - USB cable
   - Google Drive
   - ADB: `adb install app-release.apk`

3. **Open the APK** on the device and follow the installation prompts

4. **Grant Required Permissions** after installation (especially for the child app — see [Android Permissions](#-android-permissions))

### Release Signing

For production releases, create a keystore and configure signing:

```bash
# Generate a keystore
keytool -genkey -v -keystore study-guardian.jks -keyalg RSA -keysize 2048 -validity 10000 -alias study-guardian
```

Add the signing configuration to `android/app/build.gradle.kts`:

```kotlin
android {
    signingConfigs {
        create("release") {
            keyAlias = System.getenv("KEY_ALIAS") ?: "study-guardian"
            keyPassword = System.getenv("KEY_PASSWORD") ?: ""
            storeFile = file(System.getenv("KEYSTORE_PATH") ?: "study-guardian.jks")
            storePassword = System.getenv("STORE_PASSWORD") ?: ""
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

---

## 🔒 Privacy & Ethics

StudyGuardian AI is designed with a **privacy-first philosophy**:

### Data Collection Principles

- **Minimal Data Collection:** Only app usage statistics and study patterns are collected — no message content, browsing history, or personal communications are accessed
- **On-Device Processing:** Usage categorization and study detection happen locally on the child's device before syncing summaries
- **No Third-Party Sharing:** All data is stored exclusively in your Firebase project — no data is shared with third parties
- **Family-Scoped Access:** Only authenticated family members can access monitoring data

### Transparency

- **Visible Monitoring:** The child app displays a persistent notification indicating that monitoring is active — there is no hidden surveillance
- **Child Awareness:** The child can see their own usage data and study statistics within the child app
- **Open Source:** The complete source code is available for inspection

### Ethical Use Guidelines

- ✅ **DO** use to encourage healthy screen time habits
- ✅ **DO** use to celebrate study achievements together
- ✅ **DO** discuss monitoring openly with your children
- ✅ **DO** use insights to have constructive conversations
- ❌ **DON'T** use as a covert surveillance tool
- ❌ **DON'T** use to punish based on usage data
- ❌ **DON'T** collect data without the child's knowledge

### Compliance

- Designed with COPPA (Children's Online Privacy Protection Act) guidelines in mind
- No personally identifiable information is transmitted to external services
- All data can be deleted by removing the family from the Firebase project

---

## 🔧 Troubleshooting

### Common Issues

#### Child app stops collecting data in the background

**Cause:** Android battery optimization is killing the foreground service.

**Solution:**
1. Go to **Settings → Battery → Battery Optimization**
2. Find **StudyGuardian Child** and select **"Don't optimize"**
3. On some OEMs (Xiaomi, Huawei, Samsung), additional steps may be needed:
   - Xiaomi: **Settings → Battery → App battery saver → StudyGuardian → No restrictions**
   - Huawei: **Settings → Battery → Launch → StudyGuardian → Manage manually → Enable all**
   - Samsung: **Settings → Battery → Background usage limits → Never sleeping apps → Add StudyGuardian**

#### Usage data is not showing on the parent dashboard

**Cause:** UsageStats permission not granted on the child device.

**Solution:**
1. On the child device, go to **Settings → Apps → Special access → Usage access**
2. Find **StudyGuardian Child** and enable it
3. Restart the child app

#### Firebase connection errors

**Cause:** Incorrect `google-services.json` or missing Firebase configuration.

**Solution:**
1. Verify `google-services.json` is in `android/app/` directory
2. Re-run `flutterfire configure` in the affected app directory
3. Ensure Firebase project has Firestore and Auth enabled
4. Check that security rules are deployed: `firebase deploy --only firestore:rules`

#### Build fails with "Execution failed for task ':app:processDebugGoogleServices'"

**Cause:** Missing or malformed `google-services.json`.

**Solution:**
1. Download a fresh `google-services.json` from Firebase Console
2. Place it in the correct `android/app/` directory
3. Run `flutter clean && flutter pub get`

#### Notifications not received on parent device

**Cause:** FCM token not registered or notification permissions not granted.

**Solution:**
1. Ensure **POST_NOTIFICATIONS** permission is granted on Android 13+
2. Check that the device has Google Play Services installed
3. Verify FCM is enabled in the Firebase Console
4. Check Firestore for the notification document — if it exists, the issue is on the receiving end

#### Gradle build errors after updating Flutter

**Cause:** Gradle/AGP version incompatibility.

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

---

## 📄 License

```
MIT License

Copyright (c) 2025 StudyGuardian AI

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
