import 'package:flutter/material.dart';

import 'package:flutter_application/src/services/firebase_services.dart';

/// Pantalla "Configurar ejercicio" (dark theme) según mockup.
///
/// - Título "Configurar ejercicio"
/// - Dropdown de ejercicios del catálogo (trae de Firestore)
/// - Botones "Subir imagen" / "Álbum" (en este demo usamos la imagen del catálogo,
///   los botones quedan visibles para futuras versiones custom)
/// - Series (input numérico)
/// - Reps (input texto, ej "10-12")
/// - Peso con toggle kg/lbs
/// - Descanso con chips predefinidos (45/60/90/120/5 min)
/// - Botones "+ Add" y "Cancelar"
///
/// Al tocar "+ Add", devuelve el ejercicio configurado por Navigator.pop(context, ejercicio).
/// La pantalla que la llamó (add_rutina_page.dart) lo recibe y lo agrega a la
/// lista en memoria.
class AddEjercicioPage extends StatefulWidget {
  const AddEjercicioPage({super.key});

  @override
  State<AddEjercicioPage> createState() => _AddEjercicioPageState();
}

class _AddEjercicioPageState extends State<AddEjercicioPage> {
  // Stream del catálogo (reactivo)
  Stream<List<Map<String, dynamic>>>? _stream;
  Map<String, dynamic>? _ejercicioSeleccionado;

  // Campos editables por el usuario
  final _seriesCtrl = TextEditingController(text: '4');
  final _repsCtrl = TextEditingController(text: '10-12');
  final _pesoCtrl = TextEditingController(text: '100');
  String _pesoUnit = 'kg'; // o 'lbs'
  String _descanso = '90 seg';

  static const _chipsDescanso = ['45 seg', '60 seg', '90 seg', '120 seg', '5 min'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream ??= streamCatalogoEjercicios();
  }

  @override
  void dispose() {
    _seriesCtrl.dispose();
    _repsCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  void _cancelar() => Navigator.pop(context);

  void _agregar() {
    if (_ejercicioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elegí un ejercicio primero')),
      );
      return;
    }
    final ejercicio = <String, dynamic>{
      'id': _ejercicioSeleccionado!['id'],
      'name': _ejercicioSeleccionado!['name'],
      'image': _ejercicioSeleccionado!['image'],
      'tiempo': _ejercicioSeleccionado!['tiempo'],
      'series': _seriesCtrl.text.trim(),
      'reps': _repsCtrl.text.trim(),
      'peso': '${_pesoCtrl.text.trim()} $_pesoUnit',
      'descanso': _descanso,
      'description': _ejercicioSeleccionado!['description'],
    };
    Navigator.pop(context, ejercicio);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: const Text('Configurar ejercicio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // === EJERCICIO (DROPDOWN) ===
          Text('Ejercicio',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 8),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _stream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return _dropdownPlaceholder(colors, 'Cargando catálogo...');
              }
              if (snap.hasError) {
                return _dropdownPlaceholder(colors, 'Error: ${snap.error}');
              }
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return _dropdownPlaceholder(colors,
                    'Catálogo vacío. Corré seed_ejercicios.dart');
              }
              return _buildDropdown(colors, list);
            },
          ),
          const SizedBox(height: 16),

          // === IMAGEN (opcional) ===
          if (_ejercicioSeleccionado != null &&
              (_ejercicioSeleccionado!['image'] as String).isNotEmpty)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _ejercicioSeleccionado!['image'],
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 180,
                    color: colors.surfaceContainerHigh,
                    child: Icon(Icons.broken_image, size: 60,
                        color: colors.onSurfaceVariant),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 40,
                      color: colors.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text('Imagen del ejercicio',
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          // Botones Subir imagen / Álbum (no funcionales en este demo,
          // pero quedan visuales)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.upload),
                  label: const Text('Subir imagen'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Álbum'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // === SERIES ===
          _buildFieldLabel(colors, 'Series'),
          TextField(
            controller: _seriesCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(color: colors.onSurface),
            decoration: _inputDecoration(colors),
          ),
          const SizedBox(height: 16),

          // === REPS ===
          _buildFieldLabel(colors, 'Reps'),
          TextField(
            controller: _repsCtrl,
            style: TextStyle(color: colors.onSurface),
            decoration: _inputDecoration(colors).copyWith(
              hintText: 'Ej: 10-12',
            ),
          ),
          const SizedBox(height: 16),

          // === PESO con toggle kg/lbs ===
          _buildFieldLabel(colors, 'Peso objetivo'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pesoCtrl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: colors.onSurface),
                  decoration: _inputDecoration(colors).copyWith(
                    hintText: '100.0',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildUnitToggle(colors),
            ],
          ),
          const SizedBox(height: 16),

          // === DESCANSO con chips ===
          _buildFieldLabel(colors, 'Descanso'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _chipsDescanso.map((d) {
              final selected = _descanso == d;
              return ChoiceChip(
                label: Text(d),
                selected: selected,
                onSelected: (_) => setState(() => _descanso = d),
                selectedColor: colors.primary,
                labelStyle: TextStyle(
                  color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                ),
                backgroundColor: colors.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),

          // === BOTONES ===
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelar,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancelar',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _agregar,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDropdown(ColorScheme colors, List<Map<String, dynamic>> list) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _ejercicioSeleccionado,
      dropdownColor: colors.surfaceContainerHigh,
      decoration: _inputDecoration(colors),
      items: list.map((e) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: e,
          child: Text(e['name'] ?? '',
              style: TextStyle(color: colors.onSurface)),
        );
      }).toList(),
      onChanged: (v) => setState(() => _ejercicioSeleccionado = v),
    );
  }

  Widget _dropdownPlaceholder(ColorScheme colors, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: colors.onSurfaceVariant)),
    );
  }

  Widget _buildUnitToggle(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['kg', 'lbs'].map((u) {
          final selected = _pesoUnit == u;
          return GestureDetector(
            onTap: () => setState(() => _pesoUnit = u),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(u,
                  style: TextStyle(
                    color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFieldLabel(ColorScheme colors, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
    );
  }

  InputDecoration _inputDecoration(ColorScheme colors) {
    return InputDecoration(
      filled: true,
      fillColor: colors.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
