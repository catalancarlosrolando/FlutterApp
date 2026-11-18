import 'package:flutter/material.dart';

import 'package:flutter_application/src/services/firebase_services.dart';

/// Componente que consume el Stream de catálogo de Firestore
/// y muestra un DropdownButtonFormField para elegir ejercicio.
class EjercicioDropdownCatalog extends StatefulWidget {
  final Map<String, dynamic>? selectedEjercicio;
  final ValueChanged<Map<String, dynamic>?> onSelected;

  const EjercicioDropdownCatalog({
    super.key,
    required this.selectedEjercicio,
    required this.onSelected,
  });

  @override
  State<EjercicioDropdownCatalog> createState() => _EjercicioDropdownCatalogState();
}

class _EjercicioDropdownCatalogState extends State<EjercicioDropdownCatalog> {
  Stream<List<Map<String, dynamic>>>? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream ??= streamCatalogoEjercicios();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _placeholder(colors, 'Cargando catálogo...');
        }
        if (snap.hasError) {
          return _placeholder(colors, 'Error: ${snap.error}');
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return _placeholder(colors, 'Catálogo vacío. Corré seed_ejercicios.dart');
        }

        // Buscar coincidencia en la lista por ID
        Map<String, dynamic>? currentItem;
        if (widget.selectedEjercicio != null) {
          currentItem = list.cast<Map<String, dynamic>?>().firstWhere(
                (e) => e?['id'] == widget.selectedEjercicio!['id'],
                orElse: () => null,
              );
        }

        return DropdownButtonFormField<Map<String, dynamic>>(
          initialValue: currentItem,
          dropdownColor: colors.surfaceContainerHigh,
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surfaceContainerHigh,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          hint: Text(
            widget.selectedEjercicio != null
                ? widget.selectedEjercicio!['name'] ?? 'Seleccionar del catálogo'
                : 'Seleccionar del catálogo',
            style: TextStyle(color: colors.onSurface),
          ),
          items: list.map((e) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: e,
              child: Text(
                e['name'] ?? '',
                style: TextStyle(color: colors.onSurface),
              ),
            );
          }).toList(),
          onChanged: widget.onSelected,
        );
      },
    );
  }

  Widget _placeholder(ColorScheme colors, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: colors.onSurfaceVariant)),
    );
  }
}
