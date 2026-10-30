import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_application/src/services/firebase_services.dart';

/// Home: muestra la PRÓXIMA rutina no finalizada (la "siguiente").
/// Usa StreamBuilder para que reaccione en tiempo real a cambios en Firestore.
///
/// Si todas están finalizadas o no hay rutinas → estado vacío.
/// Botón de logout arriba a la derecha.
class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: const Text('Tu próxima rutina'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // google_sign_in 7.x: disconnect() en vez de signOut()
              await GoogleSignIn.instance.disconnect();
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: streamProximaRutina(widget.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error: ${snap.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.error),
                ),
              ),
            );
          }
          final rutina = snap.data;
          if (rutina == null) {
            return _EmptyState(colors: colors);
          }
          return _RutinaCard(rutina: rutina, colors: colors);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: colors.onSurfaceVariant.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              'No tenés rutinas pendientes',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Creá una nueva rutina con el botón + de abajo\npara empezar a entrenar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _RutinaCard extends StatelessWidget {
  final Map<String, dynamic> rutina;
  final ColorScheme colors;

  const _RutinaCard({required this.rutina, required this.colors});

  @override
  Widget build(BuildContext context) {
    final ejercicios = List.from(rutina['ejercicios'] ?? []);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header de la rutina
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              (rutina['image'] as String).isNotEmpty
                  ? Image.network(
                      rutina['image'],
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 180,
                        color: colors.surfaceContainerHigh,
                        child: Icon(
                          Icons.fitness_center,
                          size: 60,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      color: colors.surfaceContainerHigh,
                      child: Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (rutina['categoria'] ?? '').toString().toUpperCase(),
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          rutina['name'] ?? '',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${rutina['tiempo']} · ${ejercicios.length} ejercicios',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 12),
        if ((rutina['description'] as String).isNotEmpty)
          Text(
            rutina['description'],
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          ),
        const SizedBox(height: 24),

        // Lista de ejercicios
        Text(
          'Ejercicios',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...ejercicios.map((e) => _EjercicioItem(ejercicio: e, colors: colors)),

        const SizedBox(height: 32),

        // Botón "Marcar como finalizada"
        FilledButton.icon(
          onPressed: () async {
            await setRutinaFinalizada(rutina['uid_doc'], true);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Rutina completada! 💪')),
              );
            }
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.check),
          label: const Text(
            'Marcar como finalizada',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _EjercicioItem extends StatelessWidget {
  final Map<String, dynamic> ejercicio;
  final ColorScheme colors;

  const _EjercicioItem({required this.ejercicio, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 64,
                child: (ejercicio['image'] as String?)?.isNotEmpty == true
                    ? Image.network(
                        ejercicio['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: colors.surfaceContainerHighest,
                          child: Icon(
                            Icons.fitness_center,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Container(
                        color: colors.surfaceContainerHighest,
                        child: Icon(
                          Icons.fitness_center,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ejercicio['name'] ?? '',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ejercicio['series']} series · ${ejercicio['reps']} reps · ${ejercicio['peso']}\nDescanso: ${ejercicio['descanso']}',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
