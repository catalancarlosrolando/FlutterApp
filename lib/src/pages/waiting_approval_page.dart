import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/services/auth_service.dart';

class WaitingApprovalPage extends StatefulWidget {
  const WaitingApprovalPage({super.key});

  @override
  State<WaitingApprovalPage> createState() => _WaitingApprovalPageState();
}

class _WaitingApprovalPageState extends State<WaitingApprovalPage> {
  bool _busy = false;
  bool _emailVerified =
      FirebaseAuth.instance.currentUser?.emailVerified ?? false;

  Future<void> _resendVerification() async {
    setState(() => _busy = true);
    try {
      await AuthService.instance.resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo de verificación reenviado.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo reenviar el correo. Intentá más tarde.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _busy = true);
    try {
      final verified = await AuthService.instance.reloadAndCheckEmailVerified();
      if (mounted) {
        setState(() => _emailVerified = verified);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verified
                  ? '¡Correo verificado!'
                  : 'Tu correo todavía no figura como verificado.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 72,
                  color: colors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Esperando aprobación',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tu cuenta (${user?.email ?? ''}) está pendiente de aprobación por un administrador.\n\nEsta pantalla se actualizará automáticamente en cuanto seas aprobado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                if (!_emailVerified) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Correo sin verificar. Revisá tu bandeja de entrada.',
                          style: TextStyle(color: colors.onSecondaryContainer),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _busy ? null : _resendVerification,
                              child: const Text('Reenviar correo'),
                            ),
                            FilledButton.tonal(
                              onPressed: _busy ? null : _checkVerification,
                              child: const Text('Ya verifiqué'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => AuthService.instance.signOut(),
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
