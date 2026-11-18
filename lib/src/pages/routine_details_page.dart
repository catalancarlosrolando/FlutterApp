import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/src/components/Exercise.dart';
import 'package:flutter_application/src/pages/add_rutina_page.dart';

class RoutineDetails extends StatefulWidget {
  final Map<String, dynamic> rutina;
  final String? uid;
  final String? profileId;

  const RoutineDetails({
    super.key,
    required this.rutina,
    this.uid,
    this.profileId,
  });

  @override
  State<RoutineDetails> createState() => _RoutineDetailsState();
}

class _RoutineDetailsState extends State<RoutineDetails> {
  Future<void> _abrirEditarRutina(Map<String, dynamic> rutinaActual) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddRutinaPage(uid: widget.uid, rutinaParaEditar: rutinaActual),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rutinaId = widget.rutina['uid_doc'] as String?;
    final canStream =
        widget.uid != null &&
        widget.profileId != null &&
        rutinaId != null &&
        rutinaId.isNotEmpty;

    if (!canStream) {
      return _buildStaticScaffold(widget.rutina, colors);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.uid)
          .collection('perfiles')
          .doc(widget.profileId)
          .collection('rutinas')
          .doc(rutinaId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.rutina["name"] ?? "Rutina")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildStaticScaffold(widget.rutina, colors);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final rutinaLive = {'uid_doc': rutinaId, ...data};

        return _buildRoutineScaffold(rutinaLive, colors, canEdit: true);
      },
    );
  }

  Widget _buildStaticScaffold(Map<String, dynamic> rutina, ColorScheme colors) {
    return _buildRoutineScaffold(rutina, colors, canEdit: false);
  }

  Widget _buildRoutineScaffold(
    Map<String, dynamic> rutina,
    ColorScheme colors, {
    required bool canEdit,
  }) {
    final ejercicios =
        (rutina["ejercicios"] ?? rutina["exercises"]) as List<dynamic>? ?? [];

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
              "${rutina['tiempo'] ?? ''} · ${ejercicios.length} ejercicios",
              style: TextStyle(fontSize: 12.0, color: colors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          if (canEdit)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ActionChip(
                avatar: const Icon(Icons.edit, size: 16),
                label: const Text('Editar'),
                onPressed: () => _abrirEditarRutina(rutina),
              ),
            ),
        ],
      ),
      body: ejercicios.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: colors.onSurfaceVariant.withAlpha(120),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Esta rutina no tiene ejercicios.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    if (canEdit)
                      FilledButton.icon(
                        onPressed: () => _abrirEditarRutina(rutina),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar Rutina'),
                      ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: ejercicios.length,
              itemBuilder: (context, index) {
                final exercise = ejercicios[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Exercise(exercise: exercise),
                );
              },
            ),
    );
  }
}
