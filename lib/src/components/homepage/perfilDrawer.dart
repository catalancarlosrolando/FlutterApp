import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/homepage/Drawer.dart';
import 'package:flutter_application/src/services/firebase_services.dart';

class PerfilDrawer extends StatelessWidget {
  final String uid;
  final String profileId;

  const PerfilDrawer({super.key, required this.uid, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: streamPerfil(uid, profileId),
      builder: (context, snapshot) {
        final user = FirebaseAuth.instance.currentUser;
        final perfil = snapshot.data;

        return MyDrawer(
          uid: uid,
          photoUrl: perfil?['image'] as String? ?? user?.photoURL ?? '',
          displayName: perfil?['nombre'] as String? ?? user?.displayName ?? '',
          email: user?.email ?? '',
          colors: Theme.of(context).colorScheme,
          isDark: Theme.of(context).brightness == Brightness.dark,
        );
      },
    );
  }
}
