package com.studyguardian.child

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.PowerManager
import android.os.Process
import android.os.StatFs
import android.os.SystemClock
import android.provider.Settings
import android.app.ActivityManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity for the StudyGuardian Child App.
 *
 * Handles the Dart ↔ Kotlin MethodChannel for:
 * - Usage stats queries
 * - Device status collection
 * - Foreground service control
 * - Battery optimization checks
 * - Installed app listing
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.studyguardian.child/native"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // ── Usage Stats ──────────────────────────────────────
                    "getUsageStats" -> {
                        val startTime = call.argument<Long>("startTime") ?: 0L
                        val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                        result.success(getUsageStats(startTime, endTime))
                    }
                    "hasUsagePermission" -> {
                        result.success(hasUsagePermission())
                    }
                    "requestUsagePermission" -> {
                        requestUsagePermission()
                        result.success(null)
                    }

                    // ── Device Info ──────────────────────────────────────
                    "getDeviceStatus" -> {
                        result.success(getDeviceStatus())
                    }
                    "getForegroundApp" -> {
                        result.success(getForegroundApp())
                    }

                    // ── Foreground Service ───────────────────────────────
                    "startForegroundService" -> {
                        val serviceIntent = Intent(this@MainActivity, com.studyguardian.child.services.ForegroundMonitoringService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(serviceIntent)
                        } else {
                            startService(serviceIntent)
                        }
                        result.success(null)
                    }
                    "stopForegroundService" -> {
                        val serviceIntent = Intent(this@MainActivity, com.studyguardian.child.services.ForegroundMonitoringService::class.java)
                        stopService(serviceIntent)
                        result.success(null)
                    }
                    "isForegroundServiceRunning" -> {
                        result.success(com.studyguardian.child.services.ForegroundMonitoringService.isRunning)
                    }

                    // ── Battery Optimization ─────────────────────────────
                    "isBatteryOptimizationDisabled" -> {
                        result.success(isBatteryOptimizationDisabled())
                    }
                    "requestDisableBatteryOptimization" -> {
                        requestDisableBatteryOptimization()
                        result.success(null)
                    }

                    // ── Package Detection ────────────────────────────────
                    "getInstalledApps" -> {
                        result.success(getInstalledApps())
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // Usage Stats
    // ═════════════════════════════════════════════════════════════════════════

    private fun getUsageStats(startTime: Long, endTime: Long): List<Map<String, Any>> {
        if (!hasUsagePermission()) return emptyList()

        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val stats = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, startTime, endTime
        )

        return stats
            .filter { it.totalTimeInForeground > 0 }
            .map { stat ->
                val pm = packageManager
                val appName = try {
                    pm.getApplicationLabel(
                        pm.getApplicationInfo(stat.packageName, 0)
                    ).toString()
                } catch (_: Exception) {
                    stat.packageName
                }

                mapOf<String, Any>(
                    "packageName" to stat.packageName,
                    "appName" to appName,
                    "foregroundTime" to (stat.totalTimeInForeground / 60000).toInt(), // Convert ms to minutes
                    "backgroundTime" to 0,
                    "openCount" to 0,
                    "longestSession" to 0
                )
            }
    }

    private fun hasUsagePermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.unsafeCheckOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsagePermission() {
        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
    }

    // ═════════════════════════════════════════════════════════════════════════
    // Device Status
    // ═════════════════════════════════════════════════════════════════════════

    private fun getDeviceStatus(): Map<String, Any> {
        val result = mutableMapOf<String, Any>()

        // Battery
        val bm = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        result["battery"] = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        result["isCharging"] = bm.isCharging

        // Storage
        val stat = StatFs(Environment.getDataDirectory().path)
        val totalBytes = stat.totalBytes
        val freeBytes = stat.availableBytes
        result["storageTotal"] = totalBytes
        result["storageUsed"] = totalBytes - freeBytes

        // RAM
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        am.getMemoryInfo(memInfo)
        result["ramTotal"] = memInfo.totalMem
        result["ramUsed"] = memInfo.totalMem - memInfo.availMem

        // Network
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = cm.activeNetwork
        val caps = if (network != null) cm.getNetworkCapabilities(network) else null
        result["wifiConnected"] = caps?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ?: false
        result["networkType"] = when {
            caps == null -> "none"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "cellular"
            else -> "other"
        }

        // WiFi SSID (requires location permission on Android 12+)
        try {
            val wm = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            @Suppress("DEPRECATION")
            result["wifiSSID"] = wm.connectionInfo.ssid ?: ""
        } catch (_: Exception) {
            result["wifiSSID"] = ""
        }

        // Screen state and uptime
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        result["screenOn"] = pm.isInteractive
        result["deviceUptime"] = (SystemClock.elapsedRealtime() / 1000).toInt()

        // Foreground app
        result["foregroundApp"] = getForegroundApp()

        // Placeholders for fields we can't easily obtain
        result["batteryHealth"] = "good"
        result["temperature"] = 0.0
        result["signalStrength"] = 0

        return result
    }

    private fun getForegroundApp(): String {
        if (!hasUsagePermission()) return ""

        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 60000 // Last 1 minute

        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)
        if (stats.isNullOrEmpty()) return ""

        return stats.maxByOrNull { it.lastTimeUsed }?.packageName ?: ""
    }

    // ═════════════════════════════════════════════════════════════════════════
    // Battery Optimization
    // ═════════════════════════════════════════════════════════════════════════

    private fun isBatteryOptimizationDisabled(): Boolean {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    @Suppress("BatteryLife")
    private fun requestDisableBatteryOptimization() {
        val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
        startActivity(intent)
    }

    // ═════════════════════════════════════════════════════════════════════════
    // Installed Apps
    // ═════════════════════════════════════════════════════════════════════════

    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        @Suppress("DEPRECATION")
        val packages = pm.getInstalledApplications(0)

        return packages.map { appInfo ->
            mapOf<String, Any>(
                "packageName" to appInfo.packageName,
                "appName" to pm.getApplicationLabel(appInfo).toString(),
                "isSystemApp" to ((appInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0)
            )
        }
    }
}
