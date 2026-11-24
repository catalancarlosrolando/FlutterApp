import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/services/auth_service.dart';

class RejectedPage extends StatelessWidget {
  final String? email;
  const RejectedPage({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    final userEmail = email ?? FirebaseAuth.instance.currentUser?.email;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block_rounded, size: 72, color: colors.error),
                const SizedBox(height: 16),
                Text(
                  'Acceso denegado',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'La solicitud de acceso para ${userEmail ?? 'tu cuenta'} fue rechazada o revocada por un administrador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => AuthService.instance.signOut(),
                  style: FilledButton.styleFrom(backgroundColor: colors.error),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
