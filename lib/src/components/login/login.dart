import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Import de tu estructura (ajustá el nombre del paquete si es otro)
import 'package:flutter_application/src/components/buttonBlack.dart';
import 'package:flutter_application/src/services/firebase_services.dart';

/// Login UI: ahora SOLO Google. Botón negro "Continuar con Google".
///
/// Usa google_sign_in 7.x (singleton + initialize() + authenticate()).
/// Necesita que main.dart llame a GoogleSignIn.instance.initialize() al
/// arrancar la app.
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _loading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Abre el selector de cuentas de Google (autenticación básica)
      final googleUser = await GoogleSignIn.instance.authenticate();

      // 2. Obtiene las credenciales directamente del usuario autenticado
      final auth = await googleUser.authentication;

      // 3. Crea la credencial para Firebase con el idToken
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );

      // 4. Inicia sesión en Firebase
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      // 5. Crea el documento del usuario en Firestore si no existe
      await crearUsuario(
        uid: userCred.user!.uid,
        email: userCred.user!.email ?? '',
        nombre: userCred.user!.displayName ?? '',
        photoUrl: userCred.user!.photoURL ?? '',
      );
    } catch (e) {
      // Si el usuario cierra el selector de cuentas, evitamos mostrar un error feo
      if (e.toString().contains('canceled')) {
        return;
      }

      if (mounted) {
        setState(
          () => _error = 'No se pudo iniciar sesión. Verificá tu conexión.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
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
          const SizedBox(height: 8),
          // Botón Google (tu componente).
          // ⚠️ Tu BotonBlack probablemente NO tenga parámetro onPressed todavía.
          // Agregáselo así en components/buttonBlack.dart:
          //   final VoidCallback? onPressed;
          //   ... onPressed: widget.onPressed,
          // y ya funciona. Si no querés tocarlo, reemplazá este BotonBlack
          // por el FilledButton.icon que dejo comentado abajo.
          BotonBlack(
            text: _loading ? 'Iniciando sesión...' : 'Continuar con Google',
            iconEnable: !_loading,
            icon: _loading ? Icons.language : Icons.language,
            onPressed: _loading ? null : _signInWithGoogle,
          ),
          const SizedBox(height: 24),
          if (_loading) const Center(child: CircularProgressIndicator()),
          Text(
            'Solo cuentas de Google',
            style: TextStyle(
              color: colors.onSurface.withAlpha(150),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

extension on GoogleSignInAuthentication {
  String? get accessToken => null;
}
