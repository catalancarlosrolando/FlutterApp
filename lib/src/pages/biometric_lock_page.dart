import 'package:flutter/material.dart';
import 'package:flutter_application/src/services/auth_gate_notifier.dart';
import 'package:flutter_application/src/services/auth_service.dart';
import 'package:flutter_application/src/services/biometric_service.dart';

/// Gates an existing approved Firebase session behind device biometrics.
/// Falls back to signing out so the user can enter email/password on Login.
class BiometricLockPage extends StatefulWidget {
  final AuthGateNotifier authGate;
  const BiometricLockPage({super.key, required this.authGate});

  @override
  State<BiometricLockPage> createState() => _BiometricLockPageState();
}

class _BiometricLockPageState extends State<BiometricLockPage> {
  bool _authenticating = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _promptBiometric());
  }

  Future<void> _promptBiometric() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _message = null;
    });

    final ok = await BiometricService.instance.authenticate(
      reason: 'Desbloqueá FitAccess con tu biometría',
    );
    if (!mounted) return;

    if (ok) {
      widget.authGate.markBiometricUnlocked();
    } else {
      setState(() {
        _authenticating = false;
        _message =
            'No se pudo verificar tu biometría. Reintentá o usá tu contraseña.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fingerprint, size: 76, color: colors.primary),
                const SizedBox(height: 16),
                Text(
                  'Desbloqueo biométrico',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _message ?? 'Verificá tu identidad para acceder a tu cuenta.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _authenticating ? null : _promptBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(
                    _authenticating ? 'Verificando...' : 'Desbloquear',
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => AuthService.instance.signOut(),
                  child: const Text('Usar contraseña / Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
