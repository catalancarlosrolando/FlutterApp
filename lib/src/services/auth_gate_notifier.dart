import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application/src/models/app_user.dart';
import 'package:flutter_application/src/services/biometric_service.dart';

/// Drives `go_router` redirects in real time by combining:
/// 1. `FirebaseAuth.instance.authStateChanges()`
/// 2. Live Firestore snapshot of `users/{uid}`
/// 3. Biometric app-lock state (only applies when `status == approved`)
class AuthGateNotifier extends ChangeNotifier {
  AuthGateNotifier() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;

  User? _firebaseUser;
  AppUser? _appUser;
  bool _isLoading = true;
  bool _biometricLockRequired = false;
  bool _biometricUnlocked = false;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _firebaseUser != null;
  bool get isAdmin => _appUser?.isAdmin ?? false;
  UserStatus get status => _appUser?.status ?? UserStatus.pending;

  /// True when the user has an active approved session, biometric lock is enabled,
  /// and they haven't unlocked yet in this app session.
  bool get needsBiometricUnlock =>
      isSignedIn &&
      status == UserStatus.approved &&
      _biometricLockRequired &&
      !_biometricUnlocked;

  void markBiometricUnlocked() {
    if (!_biometricUnlocked) {
      _biometricUnlocked = true;
      notifyListeners();
    }
  }

  Future<void> refreshBiometricRequirement() async {
    final enabled = await BiometricService.instance.isEnabled();
    final available = await BiometricService.instance.isBiometricAvailable();
    _biometricLockRequired = enabled && available;
    if (!_biometricLockRequired) {
      _biometricUnlocked = true;
    }
    notifyListeners();
  }

  Future<void> _onAuthChanged(User? user) async {
    await _userDocSub?.cancel();
    _userDocSub = null;
    _firebaseUser = user;

    if (user == null) {
      _appUser = null;
      _isLoading = false;
      _biometricLockRequired = false;
      _biometricUnlocked = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final bioEnabled = await BiometricService.instance.isEnabled();
    final bioAvailable = await BiometricService.instance.isBiometricAvailable();
    _biometricLockRequired = bioEnabled && bioAvailable;

    _userDocSub = _db.collection('users').doc(user.uid).snapshots().listen(
      (snap) {
        if (snap.exists) {
          _appUser = AppUser.fromDoc(snap);
        } else {
          // Fallback while initial doc creation completes
          _appUser = AppUser(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? '',
            photoUrl: user.photoURL ?? '',
            providers: const [],
            role: UserRole.user,
            status: UserStatus.pending,
          );
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}
