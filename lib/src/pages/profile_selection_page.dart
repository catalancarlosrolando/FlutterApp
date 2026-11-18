import 'package:flutter/material.dart';
import 'package:flutter_application/src/services/firebase_services.dart';

class ProfileSelectionPage extends StatelessWidget {
  final String uid;
  const ProfileSelectionPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Elegir Perfil')),
      body: StreamBuilder<String?>(
        stream: streamPerfilActivoId(uid),
        builder: (context, activeSnap) {
          final perfilActivoId = activeSnap.data;

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: streamPerfiles(uid),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final perfiles = snap.data ?? [];
              if (perfiles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 64,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No hay perfiles disponibles.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: perfiles.length,
                itemBuilder: (context, index) {
                  final perfil = perfiles[index];
                  final id = perfil['id'] as String;
                  final nombre = perfil['nombre'] ?? 'Sin nombre';
                  final esActivo = id == perfilActivoId;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: esActivo
                          ? colors.primary
                          : colors.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        color: esActivo ? colors.onPrimary : colors.onSurface,
                      ),
                    ),
                    title: Text(
                      nombre,
                      style: TextStyle(
                        fontWeight: esActivo
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: esActivo
                        ? Text(
                            'Perfil activo',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    trailing: esActivo
                        ? Icon(Icons.check_circle, color: colors.primary)
                        : null,
                    onTap: () async {
                      if (!esActivo) {
                        await cambiarPerfilActivo(uid, id);
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Perfil'),
        onPressed: () => _mostrarDialogoNuevoPerfil(context, colors),
      ),
    );
  }

  void _mostrarDialogoNuevoPerfil(BuildContext context, ColorScheme colors) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'Crear nuevo perfil',
          style: TextStyle(color: colors.onSurface),
        ),
        content: TextField(
          style: TextStyle(color: colors.onSurface),
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej. Volumen, Definición, Fuerza',
            labelText: 'Nombre del perfil',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final nombre = ctrl.text.trim();
              if (nombre.isNotEmpty) {
                final nuevoId = await crearNuevoPerfil(uid, nombre);
                await cambiarPerfilActivo(uid, nuevoId);
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(
              'Crear y Seleccionar',
              style: TextStyle(color: colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
