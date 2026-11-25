import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/main.dart';
import 'package:flutter_application/src/services/auth_gate_notifier.dart';
import 'package:flutter_application/src/services/auth_service.dart';
import 'package:flutter_application/src/services/biometric_service.dart';

class SettingsPage extends StatefulWidget {
  final AuthGateNotifier authGate;
  const SettingsPage({super.key, required this.authGate});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _bioAvailable = false;
  bool _bioEnabled = false;
  bool _loadingBio = true;

  @override
  void initState() {
    super.initState();
    _loadBioState();
  }

  Future<void> _loadBioState() async {
    final available = await BiometricService.instance.isBiometricAvailable();
    final enabled = await BiometricService.instance.isEnabled();
    if (mounted) {
      setState(() {
        _bioAvailable = available;
        _bioEnabled = enabled;
        _loadingBio = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!value) {
      await BiometricService.instance.setEnabled(enabled: false, uid: user.uid);
      await widget.authGate.refreshBiometricRequirement();
      if (mounted) setState(() => _bioEnabled = false);
      return;
    }

    // Verify biometrics before enabling
    final verified = await BiometricService.instance.authenticate(
      reason: 'Confirmá tu biometría para activar el bloqueo biométrico',
    );
    if (!verified) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo verificar tu biometría.')),
        );
      }
      return;
    }

    // Optional: capture password for full re-login when signed out
    String? password;
    final hasPasswordProvider =
        widget.authGate.appUser?.providers.contains('password') ?? false;
    if (hasPasswordProvider && mounted) {
      password = await _askPasswordForStorage();
    }

    await BiometricService.instance.setEnabled(
      enabled: true,
      uid: user.uid,
      email: user.email,
      password: password,
    );
    widget.authGate.markBiometricUnlocked();
    await widget.authGate.refreshBiometricRequirement();

    if (mounted) {
      setState(() => _bioEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingreso biométrico activado.')),
      );
    }
  }

  Future<String?> _askPasswordForStorage() async {
    final ctrl = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guardar contraseña de respaldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opcional: ingresá tu contraseña para guardarla cifrada en el Keychain/Keystore y poder iniciar sesión con biometría incluso tras cerrar sesión.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Solo bloqueo local'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return (res != null && res.isNotEmpty) ? res : null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final appUser = widget.authGate.appUser;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: (appUser?.photoUrl.isNotEmpty == true)
                    ? NetworkImage(appUser!.photoUrl)
                    : null,
                child: (appUser?.photoUrl.isEmpty ?? true)
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(
                appUser?.displayName.isNotEmpty == true
                    ? appUser!.displayName
                    : (user?.email ?? ''),
              ),
              subtitle: Text(
                '${user?.email ?? ''}\nRol: ${appUser?.role.name ?? 'user'} • Estado: ${appUser?.status.name ?? 'pending'}',
              ),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: const Text('Acceso con biometría'),
                  subtitle: Text(
                    _loadingBio
                        ? 'Comprobando hardware...'
                        : (_bioAvailable
                              ? 'Protegé la app con huella o Face ID'
                              : 'No disponible o sin biometría configurada en este dispositivo'),
                  ),
                  value: _bioEnabled,
                  onChanged: (!_bioAvailable || _loadingBio)
                      ? null
                      : _toggleBiometric,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  title: Text(isDark ? 'Modo oscuro' : 'Modo claro'),
                  value: isDark,
                  onChanged: (val) {
                    themeNotifier.value = val
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => AuthService.instance.signOut(),
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
