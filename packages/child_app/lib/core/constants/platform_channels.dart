/// Platform channel constants for communication between Dart and Kotlin.
///
/// Defines the method channel name and all method identifiers used
/// by the child app to invoke native Android services.
library;

/// Single method channel name shared across all native service calls.
const String kPlatformChannelName = 'com.studyguardian.child/native';

// =============================================================================
// Usage Stats Methods
// =============================================================================

/// Queries Android UsageStatsManager for app usage data for a given date range.
/// Args: { "startTime": int (epoch ms), "endTime": int (epoch ms) }
/// Returns: List<Map<String, dynamic>> of per-app usage entries.
const String kMethodGetUsageStats = 'getUsageStats';

/// Checks whether the PACKAGE_USAGE_STATS permission has been granted.
/// Returns: bool
const String kMethodHasUsagePermission = 'hasUsagePermission';

/// Opens the system Settings page for granting Usage Access permission.
const String kMethodRequestUsagePermission = 'requestUsagePermission';

// =============================================================================
// Device Info Methods
// =============================================================================

/// Collects a comprehensive device status snapshot.
/// Returns: Map<String, dynamic> containing battery, storage, RAM,
/// network, foreground app, screen state, etc.
const String kMethodGetDeviceStatus = 'getDeviceStatus';

/// Returns the current foreground application's package name.
/// Returns: String (package name)
const String kMethodGetForegroundApp = 'getForegroundApp';

// =============================================================================
// Foreground Service Methods
// =============================================================================

/// Starts the persistent monitoring foreground service.
const String kMethodStartForegroundService = 'startForegroundService';

/// Stops the persistent monitoring foreground service.
const String kMethodStopForegroundService = 'stopForegroundService';

/// Checks whether the foreground service is currently running.
/// Returns: bool
const String kMethodIsForegroundServiceRunning = 'isForegroundServiceRunning';

// =============================================================================
// Battery Optimization Methods
// =============================================================================

/// Checks whether the app is exempted from battery optimization.
/// Returns: bool
const String kMethodIsBatteryOptimizationDisabled = 'isBatteryOptimizationDisabled';

/// Requests the user to disable battery optimization for this app.
const String kMethodRequestDisableBatteryOptimization = 'requestDisableBatteryOptimization';

// =============================================================================
// Package Detection Methods
// =============================================================================

/// Returns a list of all installed applications with metadata.
/// Returns: List<Map<String, dynamic>> with packageName, appName, category.
const String kMethodGetInstalledApps = 'getInstalledApps';
