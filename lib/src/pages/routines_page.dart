import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/rutines_page/cardRoutine.dart';
import 'package:flutter_application/src/pages/routine_details_page.dart';
import 'package:flutter_application/src/provider/routines_provider.dart'
    show routineProvider;

class MyRoutines extends StatefulWidget {
  const MyRoutines({super.key});

  @override
  State<MyRoutines> createState() => _MyRoutinesState();
}

class _MyRoutinesState extends State<MyRoutines> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 4 Pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                "Mis Rutinas",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "Explora y edita tus rutinas por grupo muscular.",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Push"),
              Tab(text: "Pull"),
              Tab(text: "legs"),
              Tab(text: "core"),
            ],
          ),
        ),

        // FutureBuilder para cargar las rutinas
        body: FutureBuilder<Map<String, dynamic>>(
          future: routineProvider.cargarData(),
          builder:
              (
                BuildContext context,
                AsyncSnapshot<Map<String, dynamic>> snapshot,
              ) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Retorna el TabBarView con la lista de 4 ListView independientes
                return TabBarView(
                  children: [
                    // ListView 1: Push
                    ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: _listItem(snapshot.data, 'push'),
                    ),
                    // ListView 2: Pull
                    ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: _listItem(snapshot.data, 'pull'),
                    ),
                    // ListView 3: Legs
                    ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: _listItem(snapshot.data, 'legs'),
                    ),
                    // ListView 4: Core
                    ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: _listItem(snapshot.data, 'core'),
                    ),
                  ],
                );
              },
        ),
      ),
    );
  }

  // Helper que extrae y arma las tarjetas de cada categoría
  List<Widget> _listItem(Map<String, dynamic>? data, String categoria) {
    if (data == null || data.isEmpty) return [];

    final List<Widget> cards = [];
    final List<dynamic>? rutinas = data[categoria];

    if (rutinas != null) {
      for (var rutina in rutinas) {
        final exercisesCount =
            (rutina["exercises"] as List<dynamic>?)?.length ?? 0;
        cards.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: CardRoutine(
              rutinaName: rutina["name"] ?? "",
              descripcion: rutina['description'] ?? '',
              time: rutina['tiempo'] ?? '',
              exercisesCount: exercisesCount.toString(),
              image: rutina["image"] ?? "",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => RoutineDetails(rutina: rutina),
                  ),
                );
              },
            ),
          ),
        );
      }
    }

    return cards;
  }
}
