import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/src/models/app_user.dart';
import 'package:flutter_application/src/services/biometric_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Registers a new user with email/password, sends verification email,
  /// and creates `users/{uid}` with `status: pending` (unless allowlisted admin).
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String displayName = '',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      if (displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }
      await user.sendEmailVerification();
      await syncUserDoc(
        user,
        provider: 'password',
        overrideDisplayName: displayName.trim(),
      );

      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    }
  }

  /// Signs in with email/password and syncs `users/{uid}`.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      await syncUserDoc(user, provider: 'password');
      await BiometricService.instance.updateCredentialsIfEnabled(
        uid: user.uid,
        email: email.trim(),
        password: password,
      );
      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    }
  }

  /// Signs in with Google (`google_sign_in` 7.x) and syncs `users/{uid}`.
  /// Returns `null` if the user cancelled the account picker.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final auth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
      final cred = await _auth.signInWithCredential(credential);
      final user = cred.user!;
      await syncUserDoc(user, provider: 'google');
      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancel') || msg.contains('canceled')) {
        return null;
      }
      throw const AuthFailure(
        'No se pudo iniciar sesión con Google. Verificá tu conexión.',
      );
    }
  }

  /// Creates or updates `users/{uid}` without ever overwriting `role` or `status`
  /// on existing documents. Merges `providers` via `FieldValue.arrayUnion`.
  Future<void> syncUserDoc(
    User user, {
    required String provider,
    String? overrideDisplayName,
  }) async {
    final docRef = _db.collection('users').doc(user.uid);
    final snap = await docRef.get();
    final email = (user.email ?? '').trim().toLowerCase();
    final displayName = (overrideDisplayName?.isNotEmpty == true)
        ? overrideDisplayName!
        : (user.displayName ?? '');
    final photoUrl = user.photoURL ?? '';

    if (!snap.exists) {
      final isBootstrapAdmin = adminBootstrapEmails
          .map((e) => e.toLowerCase())
          .contains(email);

      // Crear perfil predeterminado en subcolección users/{uid}/perfiles
      final profileRef = docRef.collection('profiles').doc();
      final defaultProfileName = displayName.isNotEmpty
          ? displayName
          : (email.isNotEmpty ? email.split('@').first : 'Principal');

      await profileRef.set({
        'name': defaultProfileName,
        'image': photoUrl,
        'descripcion': 'Perfil predeterminado',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await docRef.set({
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'provider': provider,
        'providers': [provider],
        'defaultProfileId': profileRef.id,
        'role': isBootstrapAdmin ? 'admin' : 'user',
        'status': isBootstrapAdmin ? 'approved' : 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'approvedAt': isBootstrapAdmin ? FieldValue.serverTimestamp() : null,
        'approvedBy': isBootstrapAdmin ? 'bootstrap' : null,
      });
      return;
    }

    // Existing doc: merge cosmetic fields & providers array, and guarantee defaultProfileId.
    final updateData = <String, dynamic>{
      'provider': provider,
      'providers': FieldValue.arrayUnion([provider]),
    };
    if (email.isNotEmpty) updateData['email'] = email;
    if (displayName.isNotEmpty) updateData['displayName'] = displayName;
    if (photoUrl.isNotEmpty) updateData['photoUrl'] = photoUrl;

    final existingData = snap.data();
    final currentProfileId = existingData?['defaultProfileId'] as String?;
    if (currentProfileId == null || currentProfileId.isEmpty) {
      final perfilesSnap = await docRef.collection('profiles').limit(1).get();
      if (perfilesSnap.docs.isNotEmpty) {
        updateData['defaultProfileId'] = perfilesSnap.docs.first.id;
      } else {
        final profileRef = docRef.collection('profiles').doc();
        final defaultProfileName = displayName.isNotEmpty
            ? displayName
            : (email.isNotEmpty ? email.split('@').first : 'Principal');
        await profileRef.set({
          'name': defaultProfileName,
          'image': photoUrl,
          'descripcion': 'Perfil predeterminado',
          'createdAt': FieldValue.serverTimestamp(),
        });
        updateData['defaultProfileId'] = profileRef.id;
      }
    }

    await docRef.set(updateData, SetOptions(merge: true));
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.disconnect();
    } catch (_) {
      // Ignore if user wasn't signed in with Google.
    }
    await _auth.signOut();
  }

  // ===================== ADMIN OPERATIONS =====================

  Stream<List<AppUser>> streamPendingUsers() {
    return _db
        .collection('users')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((q) {
          final list = q.docs.map(AppUser.fromDoc).toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  Stream<List<AppUser>> streamAllUsers() {
    return _db.collection('users').snapshots().map((q) {
      final list = q.docs.map(AppUser.fromDoc).toList();
      list.sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
      return list;
    });
  }

  Future<void> approveUser({
    required String targetUid,
    required String adminUid,
  }) async {
    await _db.collection('users').doc(targetUid).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': adminUid,
    });
  }

  Future<void> rejectUser({
    required String targetUid,
    required String adminUid,
  }) async {
    await _db.collection('users').doc(targetUid).update({
      'status': 'rejected',
      'approvedAt': null,
      'approvedBy': adminUid,
    });
  }

  Future<void> setUserRole({
    required String targetUid,
    required UserRole role,
  }) async {
    await _db.collection('users').doc(targetUid).update({'role': role.name});
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Esperá unos minutos e intentá de nuevo.';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con ese correo usando otro método de ingreso.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verificá tu red.';
      default:
        return e.message ?? 'Error de autenticación (${e.code}).';
    }
  }
}
