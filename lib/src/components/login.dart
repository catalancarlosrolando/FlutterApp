import 'package:flutter/material.dart';

import 'package:flutter_application/src/components/buttonWhite.dart';
import 'package:flutter_application/src/components/checkbox.dart';

import 'package:flutter_application/src/components/inputpropio.dart';
import 'package:flutter_application/src/components/buttonBlack.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Usuario o correo", style: TextStyle(color: Colors.white)),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Inputpropio(
              text: "tumail@email.com",
              icon: Icon(Icons.email),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contraseña", style: TextStyle(color: Color(0xffa2a2ab))),
            ],
          ),

          Inputpropio(text: "••••••••••••••", icon: Icon(Icons.lock_outline)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  MiCheckbox(),
                  Text(
                    "Remember me",
                    style: TextStyle(color: colors.onPrimary),
                  ),
                ],
              ),

              Text(
                "¿Olvidaste tu contraseña?",
                style: TextStyle(
                  color: colors.primary,

                  decorationColor: colors.primary,
                ),
              ),
            ],
          ),
          BotonWhite(text: "Inicie sesión", iconEnable: false),
          //linea seguida de un texto
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: colors.surfaceContainerHigh,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  "O",
                  style: TextStyle(
                    color: colors.onSurface.withAlpha(150),
                    fontSize: 14.0,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: colors.surfaceContainerHigh,
                  thickness: 1,
                ),
              ),
            ],
          ),

          BotonBlack(
            text: "Continuar con Google",
            iconEnable: true,
            icon: Icons.language,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Text(
                "¿No tienes una cuenta?",
                style: TextStyle(color: colors.onPrimary),
              ),
              Text("Registrate", style: TextStyle(color: colors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
