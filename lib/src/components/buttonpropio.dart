import 'package:flutter/material.dart';

class BotonPropio extends StatelessWidget {
  const BotonPropio({super.key});

  void _goToLandingPage(BuildContext context) {
    Navigator.pushNamed(context, '/landing');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(200.0, 50.0),
        backgroundColor: colors.primary,

        // Color del texto/icono (foreground)
        foregroundColor: colors.onPrimary,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(width: 1.0),
        ),
      ),
      onPressed: () => _goToLandingPage(context),
      child: Text(
        'Inicie sesión',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: colors.onPrimary,
        ),
      ),
    );
  }
}
