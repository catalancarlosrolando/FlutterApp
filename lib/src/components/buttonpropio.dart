import 'package:flutter/material.dart';

class BotonPropio extends StatelessWidget {
  const BotonPropio({super.key});

  void _goToLandingPage(BuildContext context) {
    Navigator.pushNamed(context, '/landing');
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        // Tamaño fijo mínimo (ancho, alto)
        minimumSize: const Size(200.0, 50.0),

        // Color de fondo
        backgroundColor: Colors.yellow,

        // Color del texto/icono (foreground)
        foregroundColor: Colors.white,

        // Color del efecto al pasar el mouse por encima
        overlayColor: Colors.black,

        //elevacion del color
        elevation: 3.0,
        shadowColor: Colors.black,

        // Color del efecto splash al hacer clic
        splashFactory: InkRipple.splashFactory,

        // Bordes redondeados
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: Colors.yellow, width: 1.0),
        ),
      ),
      onPressed: () => _goToLandingPage(context),
      child: const Text(
        'Inicie sesión',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
