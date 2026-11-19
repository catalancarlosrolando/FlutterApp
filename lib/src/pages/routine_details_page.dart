import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/Exercise.dart';
import 'package:flutter_application/src/pages/add_rutina_page.dart';
import 'package:flutter_application/src/services/firebase_services.dart';

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

  Future<void> _confirmarYBorrarRutina(Map<String, dynamic> rutina) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colors = Theme.of(ctx).colorScheme;
        return AlertDialog(
          backgroundColor: colors.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '¿Eliminar rutina?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Se eliminará la rutina "${rutina['name'] ?? 'esta rutina'}". Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await borrarRutina(
          uid: widget.uid!,
          profileId: widget.profileId!,
          uidDoc: rutina['uid_doc'] as String,
        );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
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

    return StreamBuilder<Map<String, dynamic>?>(
      stream: streamRutina(
        uid: widget.uid!,
        profileId: widget.profileId!,
        rutinaId: rutinaId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.rutina["name"] ?? "Rutina")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final rutinaLive = snapshot.data;
        if (rutinaLive == null) {
          return _buildStaticScaffold(widget.rutina, colors);
        }

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
            MenuAnchor(
              style: MenuStyle(
                shadowColor: WidgetStatePropertyAll(colors.error),
              ),
              builder: (context, controller, child) => IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              ),
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.edit_outlined),
                  onPressed: () => _abrirEditarRutina(rutina),
                  child: const Text('Editar'),
                ),
                MenuItemButton(
                  leadingIcon: Icon(Icons.delete_outline, color: colors.error),
                  onPressed: () => _confirmarYBorrarRutina(rutina),
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: colors.error),
                  ),
                ),
              ],
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
                final exercise = Map<String, dynamic>.from(
                  ejercicios[index] as Map,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Exercise(
                    exercise: exercise,
                    uid: widget.uid,
                    profileId: widget.profileId,
                    rutinaId: widget.rutina['uid_doc'],
                    exerciseIndex: index,
                  ),
                );
              },
            ),
    );
  }
}
