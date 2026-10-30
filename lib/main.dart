import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/src/pages/main_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

// Ajustá los imports a tu estructura de paquetes
import 'package:flutter_application/src/pages/login_page.dart';
import 'package:flutter_application/src/pages/home_page.dart';
import 'package:flutter_application/src/pages/add_rutina_page.dart';
import 'package:flutter_application/src/pages/add_ejercicio_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ⚠️ NUEVO en google_sign_in 7.x: hay que inicializar el singleton una vez.
  // El serverClientId es el "Web Client ID" de Firebase (lo conseguís en
  // Firebase Console → Authentication → Sign-in method → Google → Web SDK configuration).
  // Sin esto, el accessToken no se obtiene y Firebase Auth falla.

  await GoogleSignIn.instance.initialize(
    // 🔑 Reemplazá con tu Web Client ID de Firebase:
    serverClientId:
        'firebase-adminsdk-fbsvc@flutter-50644.iam.gserviceaccount.com',
  );

  runApp(const FitAccessApp());
}

class FitAccessApp extends StatelessWidget {
  const FitAccessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitAccess',
      // Dark theme como el de tus mockups
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF2563EB),
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => const Gate(),
        '/addEjercicio': (context) => const AddEjercicioPage(),
      },
    );
  }
}

/// Gate: muestra LoginPage si no hay sesión, HomePage si la hay.
/// Reacciona en tiempo real a login/logout (StreamBuilder).
class Gate extends StatelessWidget {
  const Gate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.data == null) return const LoginPage();
        return MainNavigationPage(uid: snap.data!.uid);
      },
    );
  }
}
