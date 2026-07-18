/// Hive local storage service for StudyGuardian AI.
///
/// Manages three Hive boxes:
/// - **cache**: General key-value cache for offline data.
/// - **pending_sync**: Queue for data that needs to be synced with Firestore.
/// - **settings**: Persistent user/app settings.
library;

import 'package:hive_flutter/hive_flutter.dart';

import '../utils/logger.dart';

/// Service that wraps Hive operations for local persistence.
class HiveService {
  /// Box name for general cache data.
  static const String _cacheBox = 'cache';

  /// Box name for pending sync queue items.
  static const String _syncBox = 'pending_sync';

  /// Box name for persistent settings.
  static const String _settingsBox = 'settings';

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initializes Hive for Flutter and opens all required boxes.
  ///
  /// Must be called once before any other [HiveService] method.
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      await Future.wait([
        Hive.openBox(_cacheBox),
        Hive.openBox(_syncBox),
        Hive.openBox(_settingsBox),
      ]);

      AppLogger.i('Service', 'Hive initialized – boxes opened: $_cacheBox, $_syncBox, $_settingsBox');
    } catch (e, stackTrace) {
      AppLogger.e('Service', 'Failed to initialize Hive', e, stackTrace);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Cache
  // ---------------------------------------------------------------------------

  /// Saves [value] to the cache box under [key].
  Future<void> saveToCache(String key, dynamic value) async {
    try {
      final box = Hive.box(_cacheBox);
      await box.put(key, value);
    } catch (e, stackTrace) {
      AppLogger.e('Service', 'Failed to save to cache (key: $key)', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves the cached value for [key], or `null` if not present.
  dynamic getFromCache(String key) {
    try {
      final box = Hive.box(_cacheBox);
      return box.get(key);
    } catch (e, stackTrace) {
      AppLogger.e('Service', 'Failed to get from cache (key: $key)', e, stackTrace);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Pending Sync Queue
  // ---------------------------------------------------------------------------

  /// Adds [data] to the pending-sync queue, keyed by the current
  /// timestamp in milliseconds to preserve insertion order.
  Future<void> savePendingSync(Map<String, dynamic> data) async {
    try {
      final box = Hive.box(_syncBox);
      final key = DateTime.now().millisecondsSinceEpoch.toString();
      await box.put(key, data);
      AppLogger.i('Service', 'Pending sync item saved (key: $key)');
    } catch (e, stackTrace) {
      AppLogger.e('Service', 'Failed to save pending sync item', e, stackTrace);
      rethrow;
    }
  }

  /// Returns all pending-sync items as a list of maps.
  ///
  /// Items are returned in insertion order (oldest first).
  List<Map<String, dynamic>> getPendingSyncs() {
    try {
      final box = Hive.box(_syncBox);
      return box.values
          .map((value) => Map<String, dynamic>.from(value as Map))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Service', 'Failed to get pending syncs', e, stackTrace);
      rethrow;
    }
  }

  /// Removes all items from the pending-sync queue.
  Future<void> clearPendingSyncs() async {
    try {
      final box = Hive.box(_syncBox);
      await box.clear();
      AppLogger.i('Service', 'Pending sync queue cleared.');
    } catch (e, stackTrace) {
      AppLogger.e('Service', 'Failed to clear pending syncs', e, stackTrace);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  /// Saves a setting [value] under [key].
  Future<void> saveSettings(String key, dynamic value) async {
    try {
      final box = Hive.box(_settingsBox);
      await box.put(key, value);
    } catch (e, stackTrace) {
      AppLogger.e('Service', 'Failed to save setting (key: $key)', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves the setting for [key], returning [defaultValue] if not present.
  dynamic getSettings(String key, {dynamic defaultValue}) {
    try {
      final box = Hive.box(_settingsBox);
      return box.get(key, defaultValue: defaultValue);
    } catch (e, stackTrace) {
      AppLogger.e('Service', 'Failed to get setting (key: $key)', e, stackTrace);
      rethrow;
    }
  }
}
