/// Firebase initialization service for StudyGuardian AI.
///
/// Provides a singleton instance that ensures Firebase is initialized
/// exactly once across the application lifecycle.
library;

import 'package:firebase_core/firebase_core.dart';

import '../utils/logger.dart';

/// Singleton service responsible for initializing Firebase.
///
/// Usage:
/// ```dart
/// await FirebaseService.instance.initialize();
/// ```
class FirebaseService {
  /// The single shared instance of [FirebaseService].
  static final FirebaseService instance = FirebaseService._internal();

  /// Factory constructor that always returns the singleton [instance].
  factory FirebaseService() => instance;

  FirebaseService._internal();

  /// Whether Firebase has already been initialized.
  bool _initialized = false;

  /// Returns `true` if Firebase has been successfully initialized.
  bool get isInitialized => _initialized;

  /// Initializes Firebase if it has not already been initialized.
  ///
  /// This method is idempotent — calling it multiple times is safe.
  /// On success, sets [_initialized] to `true` so subsequent calls
  /// return immediately.
  ///
  /// Throws any exception raised by [Firebase.initializeApp] after
  /// logging the error.
  Future<void> initialize() async {
    if (_initialized) {
      AppLogger.info('Firebase already initialized, skipping.');
      return;
    }

    try {
      await Firebase.initializeApp();
      _initialized = true;
      AppLogger.info('Firebase initialized successfully.');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize Firebase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
