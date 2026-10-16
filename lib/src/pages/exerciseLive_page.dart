import 'package:flutter/material.dart';

class ExerciseLivePage extends StatefulWidget {
  final Map<String, dynamic> exercise;
  const ExerciseLivePage({super.key, required this.exercise});

  @override
  State<ExerciseLivePage> createState() => _ExerciseLivePageState();
}

class _ExerciseLivePageState extends State<ExerciseLivePage> {
  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Live ${exercise["tiempo"]}",
                  style: TextStyle(fontSize: 10.0, color: Colors.green),
                ),
                Text(
                  exercise["name"] ?? "Ejercicio",
                  style: TextStyle(fontSize: 25.0, color: colors.onSurface),
                ),
              ],
            ),
            Column(
              children: [
                TextButton(onPressed: () => {}, child: Icon(Icons.favorite)),
              ],
            ),
          ],
        ),
      ),
      body: Center(child: Text("Ejercicio en vivo")),
    );
  }
}
