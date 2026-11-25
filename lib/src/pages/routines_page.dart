import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/rutines_page/cardRoutine.dart';
import 'package:flutter_application/src/pages/routine_details_page.dart';
import 'package:flutter_application/src/services/firebase_services.dart';

class MyRoutines extends StatefulWidget {
  final String uid;
  const MyRoutines({super.key, required this.uid});

  @override
  State<MyRoutines> createState() => _MyRoutinesState();
}

class _MyRoutinesState extends State<MyRoutines> {
  final List<String> _categorias = ['push', 'pull', 'legs', 'core'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: _categorias.length,
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
              Tab(text: "Legs"),
              Tab(text: "Core"),
            ],
          ),
        ),

        // Stream reactivo para obtener perfil activo y sus rutinas
        body: StreamBuilder<String?>(
          stream: streamPerfilActivoId(widget.uid),
          builder: (context, activeSnap) {
            if (activeSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final profileId = activeSnap.data;
            if (profileId == null || profileId.isEmpty) {
              return Center(
                child: Text(
                  'No se encontró un perfil activo.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              );
            }

            return StreamBuilder<Map<String, List>>(
              stream: streamRutinasPorCategoria(widget.uid, profileId),
              builder: (context, snapshot) {
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

                final data = snapshot.data ?? {};

                return TabBarView(
                  children: _categorias.map((cat) {
                    final rutinas = data[cat] ?? [];

                    if (rutinas.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay rutinas para ${cat.toUpperCase()}',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      );
                    }

                    // Adaptativo: teléfono → ListView 1 columna (card horizontal).
                    // Tablet (ancho > 600) → GridView 2 columnas (card vertical).
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final esTablet = constraints.maxWidth > 600;

                        if (esTablet) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.78,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: rutinas.length,
                            itemBuilder: (context, index) {
                              final rutina =
                                  rutinas[index] as Map<String, dynamic>;
                              final exercisesList =
                                  (rutina["ejercicios"] ?? rutina["exercises"])
                                      as List<dynamic>?;
                              final exercisesCount = exercisesList?.length ?? 0;
                              final finalizada =
                                  (rutina["completed"] as bool?) ?? false;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: CardRoutine(
                                  rutinaName: rutina["name"] ?? "",
                                  descripcion: rutina['description'] ?? '',
                                  time: rutina['time'] ?? 'nada',
                                  exercisesCount: exercisesCount.toString(),
                                  image: rutina["image"] ?? "",
                                  finalizada: finalizada,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (context) => RoutineDetails(
                                          rutina: rutina,
                                          uid: widget.uid,
                                          profileId: profileId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }

                        // Teléfono: lista de 1 columna (comportamiento original)
                        return ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: rutinas.length,
                          itemBuilder: (context, index) {
                            final rutina =
                                rutinas[index] as Map<String, dynamic>;
                            final exercisesList =
                                (rutina["ejercicios"] ?? rutina["exercises"])
                                    as List<dynamic>?;
                            final exercisesCount = exercisesList?.length ?? 0;

                            final finalizada =
                                (rutina["finalizada"] as bool?) ?? false;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: CardRoutine(
                                rutinaName: rutina["name"] ?? "",
                                descripcion: rutina['description'] ?? '',
                                time: rutina['time'] ?? '',
                                exercisesCount: exercisesCount.toString(),
                                image: rutina["image"] ?? "",
                                finalizada: finalizada,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) => RoutineDetails(
                                        rutina: rutina,
                                        uid: widget.uid,
                                        profileId: profileId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
