import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/Exercise.dart';

class RoutineDetails extends StatelessWidget {
  final Map<String, dynamic> rutina;
  const RoutineDetails({super.key, required this.rutina});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rutina["name"] ?? "Rutina",
              style: TextStyle(fontSize: 20.0, color: colors.onSurface),
            ),
            Text(
              "Detalles de la Rutina",
              style: TextStyle(fontSize: 12.0, color: colors.onSurface),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: _listItem(rutina, context),
          ),
        ),
      ),
    );
  }

  // Helper que extrae y arma las tarjetas de cada categoría
  List<Widget> _listItem(Map<String, dynamic>? data, BuildContext context) {
    if (data == null || data.isEmpty) return [];

    final List<Widget> cards = [];
    final List<dynamic>? exercises = data["exercises"];

    if (exercises != null) {
      for (var exercise in exercises) {
        cards.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Exercise(exercise: exercise),
          ),
        );
      }
    }

    return cards;
  }
}
