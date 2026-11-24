import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/login/heroLogin.dart';
import 'package:flutter_application/src/components/login/login.dart';
import 'package:flutter_application/src/services/auth_gate_notifier.dart';

class LoginPage extends StatelessWidget {
  final AuthGateNotifier authGate;
  const LoginPage({super.key, required this.authGate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 12,
              children: [
                const HeroLogin(),
                Login(authGate: authGate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
