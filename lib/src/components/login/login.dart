import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/buttonBlack.dart';
import 'package:flutter_application/src/services/auth_gate_notifier.dart';
import 'package:flutter_application/src/services/auth_service.dart';
import 'package:flutter_application/src/services/biometric_service.dart';
import 'package:go_router/go_router.dart';

/// Login form: Email/Password section + Google Sign-In + Biometric shortcut (when enabled).
class Login extends StatefulWidget {
  final AuthGateNotifier authGate;
  const Login({super.key, required this.authGate});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _biometricReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    final available = await BiometricService.instance.isBiometricAvailable();
    final hasCreds = await BiometricService.instance.hasStoredCredentials();
    if (mounted) {
      setState(() => _biometricReady = available && hasCreds);
    }
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;
      widget.authGate.markBiometricUnlocked();
      final cred = await AuthService.instance.signInWithEmail(
        email: email,
        password: password,
      );
      if (mounted) {
        await _maybeOfferBiometric(
          uid: cred.user!.uid,
          email: email,
          password: password,
        );
      }
    } on AuthFailure catch (e) {
      await widget.authGate.refreshBiometricRequirement();
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      await widget.authGate.refreshBiometricRequirement();
      if (mounted) {
        setState(() => _error = 'Error inesperado al iniciar sesión.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _maybeOfferBiometric({
    required String uid,
    required String email,
    required String password,
  }) async {
    final available = await BiometricService.instance.isBiometricAvailable();
    final alreadyEnabled = await BiometricService.instance.isEnabled();
    if (!available || alreadyEnabled || !mounted) return;

    final enable = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Activar ingreso biométrico?'),
        content: const Text(
          'Podrás desbloquear la app con tu huella o Face ID en próximos inicios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ahora no'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Activar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (enable == true) {
      await BiometricService.instance.setEnabled(
        enabled: true,
        uid: uid,
        email: email,
        password: password,
      );
      await widget.authGate.refreshBiometricRequirement();
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      widget.authGate.markBiometricUnlocked();
      final cred = await AuthService.instance.signInWithGoogle();
      if (cred == null) {
        await widget.authGate.refreshBiometricRequirement();
      }
    } on AuthFailure catch (e) {
      await widget.authGate.refreshBiometricRequirement();
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      await widget.authGate.refreshBiometricRequirement();
      if (mounted) {
        setState(
          () => _error = 'No se pudo iniciar sesión. Verificá tu conexión.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithBiometrics() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ok = await BiometricService.instance.authenticate(
        reason: 'Autenticate con tu biometría para iniciar sesión',
      );
      if (!ok) {
        if (mounted) {
          setState(
            () => _error = 'Biometría cancelada o fallida. Ingresá con tu correo y contraseña.',
          );
        }
        return;
      }

      final creds = await BiometricService.instance.getStoredCredentials();
      if (creds == null) {
        if (mounted) {
          setState(
            () => _error =
                'No hay credenciales guardadas. Ingresá con tu contraseña.',
          );
        }
        return;
      }

      await AuthService.instance.signInWithEmail(
        email: creds.email,
        password: creds.password,
      );
      widget.authGate.markBiometricUnlocked();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showPasswordResetDialog() async {
    final resetCtrl = TextEditingController(text: _emailCtrl.text.trim());
    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer contraseña'),
        content: TextField(
          controller: resetCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enviar enlace'),
          ),
        ],
      ),
    );

    if (sent == true && resetCtrl.text.trim().isNotEmpty && mounted) {
      try {
        await AuthService.instance.sendPasswordReset(resetCtrl.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Te enviamos un correo para restablecer tu contraseña.',
              ),
            ),
          );
        }
      } on AuthFailure catch (e) {
        if (mounted) setState(() => _error = e.message);
      }
    }
    resetCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: colors.onErrorContainer),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Section 1: Email / Password
            TextFormField(
              controller: _emailCtrl,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final val = (v ?? '').trim();
                if (val.isEmpty) return 'Ingresá tu correo';
                final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!regex.hasMatch(val)) return 'Correo no válido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              enabled: !_loading,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _signInWithEmail(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresá tu contraseña';
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading ? null : _showPasswordResetDialog,
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: 4),
            FilledButton(
              onPressed: _loading ? null : _signInWithEmail,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_loading ? 'Ingresando...' : 'Iniciar sesión'),
            ),
            if (_biometricReady) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _loading ? null : _signInWithBiometrics,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.fingerprint),
                label: const Text('Ingresar con biometría'),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'o continuá con',
                    style: TextStyle(
                      color: colors.onSurface.withAlpha(150),
                      fontSize: 12,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            // Section 2: Google Sign-In
            BotonBlack(
              text: _loading ? 'Iniciando sesión...' : 'Continuar con Google',
              iconEnable: !_loading,
              icon: Icons.language,
              onPressed: _loading ? null : _signInWithGoogle,
            ),
            const SizedBox(height: 16),
            if (_loading) const Center(child: CircularProgressIndicator()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('¿No tenés cuenta?'),
                TextButton(
                  onPressed: _loading ? null : () => context.go('/register'),
                  child: const Text('Registrate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
