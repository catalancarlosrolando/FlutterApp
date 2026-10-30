import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application/src/components/login/heroLogin.dart';
import 'package:flutter_application/src/components/login/login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    // El gate de auth lo manejás en main.dart o donde tengas el StreamBuilder.
    // Acá solo la UI.
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Si ya hay sesión, este widget no debería mostrarse
            // (lo controlás en main.dart con el gate). Si llegás acá
            // logueado, mostrás un loader mientras el gate redirige.
            if (snap.data != null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 12,
                    children: const [HeroLogin(), Login()],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
