import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/buttonWhite.dart';
import 'package:flutter_application/src/components/custom_image_loader.dart';

import 'package:flutter_application/src/components/iconText.dart';

class NextRoutine extends StatelessWidget {
  const NextRoutine({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final String rutina = "Rutina Tren Superior"; //Esto viene de la BD
    final String descripcion = "60 Minutos"; //Esto viene de la BD

    return Column(
      spacing: 12.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Proxima Rutina", style: TextStyle(color: colors.onSurface)),
        Container(
          //margin: EdgeInsets.all(14),
          //height: 325.0,
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomImageLoader(
                  imagePath: "assets/images/Chess/Pecho-Plano.jpg",
                ),
                Text(
                  rutina,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                IconText(icon: Icons.timer, text: descripcion),
                BotonWhite(text: "Ver Rutina", iconEnable: false),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
