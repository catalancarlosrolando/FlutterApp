import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Manages biometric hardware checks, OS prompt, and encrypted credential storage.
/// Uses `flutter_secure_storage` (iOS Keychain / Android Keystore) — never SharedPreferences.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  static const _keyEnabled = 'biometric_enabled';
  static const _keyEmail = 'biometric_email';
  static const _keyPassword = 'biometric_password';
  static const _keyUid = 'biometric_uid';

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Checks whether the device supports biometrics and has at least one enrolled.
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;
      final enrolled = await _localAuth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Prompts the user for fingerprint / Face ID / device biometric.
  Future<bool> authenticate({
    String reason = 'Autenticate con tu biometría para ingresar',
  }) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) return false;
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isEnabled() async {
    final val = await _storage.read(key: _keyEnabled);
    return val == 'true';
  }

  Future<void> setEnabled({
    required bool enabled,
    required String uid,
    String? email,
    String? password,
  }) async {
    if (!enabled) {
      await clearAll();
      return;
    }
    await _storage.write(key: _keyEnabled, value: 'true');
    await _storage.write(key: _keyUid, value: uid);
    if (email != null && email.isNotEmpty) {
      await _storage.write(key: _keyEmail, value: email);
    }
    if (password != null && password.isNotEmpty) {
      await _storage.write(key: _keyPassword, value: password);
    }
  }

  /// Stores credentials only if biometric is already enabled (e.g. after password login).
  Future<void> updateCredentialsIfEnabled({
    required String uid,
    required String email,
    required String password,
  }) async {
    if (!await isEnabled()) return;
    await _storage.write(key: _keyUid, value: uid);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
  }

  Future<({String email, String password})?> getStoredCredentials() async {
    if (!await isEnabled()) return null;
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);
    if (email == null || email.isEmpty || password == null || password.isEmpty) {
      return null;
    }
    return (email: email, password: password);
  }

  Future<bool> hasStoredCredentials() async {
    return (await getStoredCredentials()) != null;
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _keyEnabled);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keyUid);
  }
}
