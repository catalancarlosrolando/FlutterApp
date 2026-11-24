import 'package:cloud_firestore/cloud_firestore.dart';

/// Bootstrap allowlist for initial admin accounts.
/// Add your own email here or set `role: "admin"` & `status: "approved"`
/// manually in Firebase Console once. Never auto-promote the first user.
const Set<String> adminBootstrapEmails = {
  // 'tu-email@ejemplo.com',
};

enum UserRole {
  admin,
  user;

  static UserRole fromString(String? value) {
    return value == 'admin' ? UserRole.admin : UserRole.user;
  }
}

enum UserStatus {
  pending,
  approved,
  rejected;

  static UserStatus fromString(String? value) {
    switch (value) {
      case 'approved':
        return UserStatus.approved;
      case 'rejected':
        return UserStatus.rejected;
      case 'pending':
      default:
        return UserStatus.pending;
    }
  }
}

/// User profile & access-control model stored at `users/{uid}`.
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final List<String> providers;
  final UserRole role;
  final UserStatus status;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.providers,
    required this.role,
    required this.status,
    this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isApproved => status == UserStatus.approved;
  bool get isPending => status == UserStatus.pending;
  bool get isRejected => status == UserStatus.rejected;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final rawProviders = data['providers'];
    final List<String> providers;
    if (rawProviders is Iterable) {
      providers = rawProviders.map((e) => e.toString()).toList();
    } else if (data['provider'] is String && (data['provider'] as String).isNotEmpty) {
      providers = [data['provider'] as String];
    } else {
      providers = const [];
    }

    return AppUser(
      uid: (data['uid'] as String?) ?? doc.id,
      email: (data['email'] as String?) ?? '',
      displayName: (data['displayName'] as String?) ?? '',
      photoUrl: (data['photoUrl'] as String?) ?? '',
      providers: providers,
      role: UserRole.fromString(data['role'] as String?),
      status: UserStatus.fromString(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      approvedBy: data['approvedBy'] as String?,
    );
  }
}
