import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/heroLogin.dart';
import 'package:flutter_application/src/components/login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 12,
              children: [HeroLogin(), Login()],
            ),
          ),
        ),
      ),

      //Botton Text
    );
  }
}
