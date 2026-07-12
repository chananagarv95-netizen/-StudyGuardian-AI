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

### Changed
- None

### Fixed
- None

### Removed
- None

### Improved
- None
