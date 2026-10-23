import 'package:flutter/material.dart';

class HeroLogin extends StatelessWidget {
  const HeroLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 164.0,
      width: 382.0,
      child: Column(
        spacing: 12,
        mainAxisAlignment: .start,
        children: [
          Image.asset(
            'assets/images/image.png',
            width: 64,
            height: 64,
            fit: BoxFit.contain,
          ),
          Text(
            "GymTracker Pro",
            style: TextStyle(color: Colors.white, fontSize: 34.0),
          ),
          Text(
            "Inicia sesión para continuar con tu progreso",
            style: TextStyle(color: Colors.white, fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
