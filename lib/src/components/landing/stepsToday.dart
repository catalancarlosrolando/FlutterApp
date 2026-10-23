import 'package:flutter/material.dart';

class StepsToday extends StatelessWidget {
  const StepsToday({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final porcentaje = 70;
    final stepsGoal = 1200;
    final stepsLeft = stepsGoal - porcentaje;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        spacing: 12.0,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                spacing: 4,
                children: [
                  Text(
                    "Pasos de Hoy",
                    style: TextStyle(color: colors.onSurface),
                  ),
                  Text(
                    '8420',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: colors.onSurface,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                //margin: EdgeInsets.all(30),
                child: Text(
                  '${porcentaje.toStringAsFixed(0)}% meta',
                  style: TextStyle(color: colors.surface),
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Objetivo: ${stepsGoal}",
                style: TextStyle(color: colors.onSurface),
              ),
              Text(
                "Faltan ${stepsLeft}",
                style: TextStyle(color: colors.onSurface),
              ),
            ],
          ),
          SizedBox(
            child: LinearProgressIndicator(
              value: porcentaje / 100,
              minHeight: 10.0,
              backgroundColor: colors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(colors.onSurface),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ],
      ),
    );
  }
}
