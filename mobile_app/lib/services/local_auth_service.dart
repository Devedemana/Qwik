import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalAuthService {
  static final _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();
  static const _keyBiometricEnabled = 'biometric_enabled';
  static const _keySecureEmail = 'biometric_email';
  static const _keySecurePassword = 'biometric_password';

  /// Whether the device supports biometrics at all.
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Whether the user has opted in to biometric login.
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  /// Save user's opt-in preference.
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  /// Save credentials securely so biometric can re-login after logout.
  static Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _keySecureEmail, value: email);
    await _storage.write(key: _keySecurePassword, value: password);
  }

  /// Read saved credentials. Returns null if none stored.
  static Future<({String email, String password})?> getCredentials() async {
    final email = await _storage.read(key: _keySecureEmail);
    final password = await _storage.read(key: _keySecurePassword);
    if (email == null || password == null) return null;
    return (email: email, password: password);
  }

  /// Clear stored credentials (call when user explicitly disables biometrics).
  static Future<void> clearCredentials() async {
    await _storage.delete(key: _keySecureEmail);
    await _storage.delete(key: _keySecurePassword);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, false);
  }

  /// Prompt the user to authenticate. Returns true on success.
  static Future<bool> authenticate({String reason = 'Verify your identity to continue'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN/pattern as fallback
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Returns list of enrolled biometric types (fingerprint, face, etc.)
  static Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }
}
