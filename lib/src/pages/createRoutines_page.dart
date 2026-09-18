import 'package:flutter/material.dart';

class CreateRoutine extends StatefulWidget {
  const new({super.key});

  @override
  State<CreateRoutine> createState() => _CreateRoutineState();
}

class _CreateRoutineState extends State<CreateRoutine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crear Rutina")),
      body: Center(child: Text("Crear Rutina")),
    );
  }
}
