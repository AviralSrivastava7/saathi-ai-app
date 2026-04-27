import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔒 BIOMETRIC SERVICE — On-Device Authentication
/// Handles fingerprint/face unlock for protecting sensitive sections.
/// Uses Flutter's local_auth plugin. All checks are local, no data sent anywhere.
class BiometricService {
  static const String _enabledKey = 'biometric_lock_enabled';
  static final LocalAuthentication _auth = LocalAuthentication();

  // ── Check if device supports biometrics ────────────────

  /// Returns true if the device has biometric hardware AND enrolled biometrics.
  static Future<bool> isDeviceSupported() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;

      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e) {
      debugPrint('[Biometric] Device check error: $e');
      return false;
    }
  }

  /// Returns true if biometric lock is enabled by the user in settings.
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Enable or disable biometric lock.
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    debugPrint('[Biometric] Lock ${enabled ? "enabled" : "disabled"}');
  }

  /// Returns true if lock is enabled AND device supports biometrics.
  static Future<bool> shouldAuthenticate() async {
    final enabled = await isEnabled();
    if (!enabled) return false;
    final supported = await isDeviceSupported();
    return supported;
  }

  // ── Authenticate using biometrics ─────────────────────

  /// Triggers the system biometric prompt. Returns true on success.
  static Future<bool> authenticate({
    String reason = 'Apni identity verify karein 🔒',
  }) async {
    try {
      final didAuth = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
      return didAuth;
    } catch (e) {
      debugPrint('[Biometric] Auth error: $e');
      return false;
    }
  }

  /// Get list of available biometric types on this device.
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('[Biometric] Get biometrics error: $e');
      return [];
    }
  }
}
