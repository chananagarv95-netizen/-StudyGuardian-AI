import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared/services/hive_service.dart';
import 'package:shared/utils/logger.dart';

/// Provides PIN-based and biometric authentication for the parent app.
///
/// PIN is stored locally in Hive as a SHA-256 hash for security.
/// Biometric authentication uses the device's built-in fingerprint or
/// face recognition via the [local_auth] package.
class SecurityService {
  static const String _tag = 'SecurityService';
  static const String _pinKey = 'parent_pin_hash';
  static const String _biometricEnabledKey = 'biometric_enabled';

  final HiveService _hiveService;
  final LocalAuthentication _localAuth;

  SecurityService({
    required HiveService hiveService,
    LocalAuthentication? localAuth,
  })  : _hiveService = hiveService,
        _localAuth = localAuth ?? LocalAuthentication();

  // ─── PIN Management ────────────────────────────────────────────────────────

  /// Whether a parent PIN has been set.
  bool get hasPin =>
      _hiveService.getSettings(_pinKey) != null;

  /// Sets or updates the parent PIN.
  ///
  /// The PIN is stored as a SHA-256 hash — the raw PIN is never persisted.
  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _hiveService.saveSettings(_pinKey, hash);
    AppLogger.i(_tag, 'Parent PIN set');
  }

  /// Verifies the given PIN against the stored hash.
  ///
  /// Returns `true` if the PIN matches, `false` otherwise.
  bool verifyPin(String pin) {
    final storedHash = _hiveService.getSettings(_pinKey) as String?;
    if (storedHash == null) return false;
    return _hashPin(pin) == storedHash;
  }

  /// Removes the stored PIN.
  Future<void> clearPin() async {
    await _hiveService.saveSettings(_pinKey, null);
    AppLogger.i(_tag, 'Parent PIN cleared');
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  // ─── Biometric Authentication ──────────────────────────────────────────────

  /// Whether biometric authentication has been enabled by the user.
  bool get isBiometricEnabled =>
      _hiveService.getSettings(_biometricEnabledKey) as bool? ?? false;

  /// Enables or disables biometric authentication.
  Future<void> setBiometricEnabled(bool enabled) async {
    await _hiveService.saveSettings(_biometricEnabledKey, enabled);
    AppLogger.i(_tag, 'Biometric auth ${enabled ? "enabled" : "disabled"}');
  }

  /// Checks whether the device supports biometric authentication.
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      AppLogger.e(_tag, 'Error checking biometric availability', e);
      return false;
    }
  }

  /// Returns the available biometric types on this device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      AppLogger.e(_tag, 'Error getting biometrics', e);
      return [];
    }
  }

  /// Triggers biometric authentication.
  ///
  /// Returns `true` if the user successfully authenticates, `false` otherwise.
  Future<bool> authenticateWithBiometric({
    String reason = 'Authenticate to access StudyGuardian settings',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/pattern fallback
        ),
      );
    } on PlatformException catch (e) {
      AppLogger.e(_tag, 'Biometric auth error', e);
      return false;
    }
  }

  // ─── Combined Authentication ───────────────────────────────────────────────

  /// Attempts biometric auth first (if enabled), then falls back to PIN.
  ///
  /// Returns `true` if the user authenticates successfully via either method.
  /// If biometric is not enabled or fails, the caller should show a PIN dialog.
  Future<bool> authenticate() async {
    if (isBiometricEnabled) {
      final biometricAvailable = await isBiometricAvailable();
      if (biometricAvailable) {
        final success = await authenticateWithBiometric();
        if (success) return true;
      }
    }
    // Caller must handle PIN entry via UI
    return false;
  }
}
