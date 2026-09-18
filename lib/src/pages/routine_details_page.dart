import 'package:flutter/material.dart';

class RoutineDetails extends StatelessWidget {
  final Map<String, dynamic> rutina;
  const RoutineDetails({super.key, required this.rutina});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(rutina["name"] ?? "Detalles de la Rutina")),
      body: const Center(child: Text("Detalles de la Rutina")),
    );
  }
}
