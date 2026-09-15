import 'package:flutter/material.dart';

class ButtonLogin extends StatelessWidget {
  final String text;

  const ButtonLogin({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        //minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
      ),
      onPressed: () {
        // Lógica de autenticación
      },
      child: Text(
        text,
        textAlign: TextAlign.center,
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}
