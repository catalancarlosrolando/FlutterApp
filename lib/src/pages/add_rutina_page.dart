import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/src/pages/add_ejercicio_page.dart';
import 'package:flutter_application/src/pages/home_page.dart';

import 'package:flutter_application/src/services/firebase_services.dart';

/// Pantalla "Crear nueva rutina" (dark theme) según mockup.
/// - Header con título + chip "Borrador"
/// - Input de nombre con check verde "nombre válido y disponible"
/// - Tabs de categoría (Push / Pull / Legs / Upper)
/// - Lista de ejercicios ya agregados (con series/reps/peso/descanso)
/// - Botón "Add Exercise" + "Save Routine"
///
/// En esta versión: el ejercicio se agrega a un array LOCAL en memoria
/// mientras armás la rutina. Al tocar "Save Routine" se crea la rutina
/// en Firestore CON todos los ejercicios de una sola vez.
///
/// El botón "Add Exercise" abre la pantalla add_ejercicio_page.dart (ruta
/// /addEjercicio). Como esa página está dentro de otra ruta, le pasamos
/// por argumentos un callback para recibir el ejercicio configurado.
class AddRutinaPage extends StatefulWidget {
  final String? uid;
  final Map<String, dynamic>? rutinaParaEditar;

  const AddRutinaPage({super.key, this.uid, this.rutinaParaEditar});

  @override
  State<AddRutinaPage> createState() => _AddRutinaPageState();
}

class _AddRutinaPageState extends State<AddRutinaPage> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tiempoCtrl = TextEditingController(text: '45 Minutos');
  String _categoria = 'push';
  bool _guardando = false;

  // Ejercicios en memoria mientras armás la rutina
  final List<Map<String, dynamic>> _ejercicios = [];

  bool get _esEdicion => widget.rutinaParaEditar != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final r = widget.rutinaParaEditar!;
      _nameCtrl.text = r['name'] ?? '';
      _descCtrl.text = r['description'] ?? '';
      if ((r['tiempo'] as String?)?.isNotEmpty == true) {
        _tiempoCtrl.text = r['tiempo'];
      }
      _categoria = (r['categoria'] as String?)?.toLowerCase() ?? 'push';
      final listaEj = (r['ejercicios'] ?? r['exercises']) as List<dynamic>?;
      if (listaEj != null) {
        for (var item in listaEj) {
          if (item is Map) {
            _ejercicios.add(Map<String, dynamic>.from(item));
          }
        }
      }
    }
  }

  // Imágenes por categoría (subí estas a Cloudinary también y reemplazá acá)
  static const _imagenesPorCategoria = {
    'push': 'https://res.cloudinary.com/dhnldaqx4/image/upload/v1793370847/Push.webp',
    'pull': 'https://res.cloudinary.com/dhnldaqx4/image/upload/v1793364163/Pull.webp',
    'legs': 'https://res.cloudinary.com/dhnldaqx4/image/upload/v1793370847/Legs.webp',
    'core': 'https://res.cloudinary.com/dhnldaqx4/image/upload/v1793370847/Core.jpg',
  };

  bool get _nombreValido =>
      _nameCtrl.text.trim().isNotEmpty && _nameCtrl.text.trim().length >= 4;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _tiempoCtrl.dispose();
    super.dispose();
  }

  Future<void> _agregarEjercicio() async {
    final ejercicio = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEjercicioPage(),
        // Si necesitas pasar argumentos sin rutas nombradas,
        // puedes recibirlos directamente en el constructor de AddEjercicioPage.
      ),
    );
    if (ejercicio != null && ejercicio is Map<String, dynamic>) {
      setState(() => _ejercicios.add(ejercicio));
    }
  }

  void _quitarEjercicio(int i) {
    setState(() => _ejercicios.removeAt(i));
  }

  Future<void> _guardarRutina() async {
    if (!_nombreValido) return;
    setState(() => _guardando = true);

    try {
      final uid = widget.uid ?? FirebaseAuth.instance.currentUser!.uid;
      final profileId = await getPerfilActivoId(uid);
      if (profileId == null || profileId.isEmpty) {
        throw Exception('No hay perfil activo seleccionado.');
      }

      if (_esEdicion) {
        final uidDoc = widget.rutinaParaEditar!['uid_doc'];
        await updateRutina(
          uid: uid,
          profileId: profileId,
          uidDoc: uidDoc,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          tiempo: _tiempoCtrl.text.trim(),
          categoria: _categoria,
          image: _imagenesPorCategoria[_categoria] ?? widget.rutinaParaEditar!['image'] ?? '',
          ejercicios: _ejercicios,
        );
      } else {
        await addRutina(
          uid: uid,
          profileId: profileId,
          categoria: _categoria,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          image: _imagenesPorCategoria[_categoria] ?? '',
          tiempo: _tiempoCtrl.text.trim(),
          ejercicios: _ejercicios,
        );
      }

      // Verificamos que el widget siga montado antes de usar el contexto
      if (!mounted) return;

      // 1. Mostrar el Toast / SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_esEdicion
              ? '¡Rutina actualizada exitosamente!'
              : '¡Rutina guardada exitosamente!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // 2. Volver al home o pantalla anterior de forma segura
      // Si hay pantallas previas en el historial, hacemos pop:
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        // Si no hay historial (es la raíz), redirigimos al home (ajustá '/home' a la ruta de tu pantalla principal)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(uid: uid), // 👈 Sin 'const' y enviando el uid
          ),
          (route) => false, // Limpia el historial para que no pueda volver con ' atrás' al formulario vacío
        );
      }
    } catch (e) {
      // Si ocurre un error, sí detenemos el estado de carga y mostramos el error en pantalla
      if (mounted) {
        setState(() => _guardando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(_esEdicion ? 'Editar rutina' : 'Crear nueva rutina'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _esEdicion ? 'Edición' : 'Borrador',
              style: TextStyle(color: colors.onSurface, fontSize: 13),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // === NOMBRE ===
          Text(
            'Nombre de la rutina',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: TextStyle(color: colors.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _nombreValido
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : null,
              hintText: 'Ej: Hipertrofia Pecho & Tríceps',
              hintStyle: TextStyle(color: colors.onSurfaceVariant),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_nombreValido)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                'Nombre válido y disponible',
                style: TextStyle(color: Colors.green.shade300, fontSize: 12),
              ),
            ),
          const SizedBox(height: 24),

          // === CATEGORÍA ===
          Text(
            'Categoría',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _buildCategoriaTabs(colors),
          const SizedBox(height: 24),

          // === EJERCICIOS AGREGADOS ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ejercicios (${_ejercicios.length})',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _agregarEjercicio,
                icon: const Icon(Icons.add),
                label: const Text('Add Exercise'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_ejercicios.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outlineVariant.withAlpha(100),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Aún no agregaste ejercicios.\nTocá "Add Exercise".',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            )
          else
            ..._ejercicios.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              return _EjercicioCard(
                ejercicio: e,
                onQuitar: () => _quitarEjercicio(i),
              );
            }),
          const SizedBox(height: 32),

          // === TIEMPO (opcional) ===
          Text(
            'Tiempo estimado',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _tiempoCtrl,
            style: TextStyle(color: colors.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Ej: 45 Minutos',
              hintStyle: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 32),

          // === DESCRIPCIÓN ===
          Text(
            'Descripción',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            style: TextStyle(color: colors.onSurface),
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText:
                  'Ej: Rutina de empuje para desarrollo de fuerza y masa...',
              hintStyle: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 32),

          // === BOTÓN GUARDAR ===
          FilledButton(
            onPressed: (_guardando || !_nombreValido) ? null : _guardarRutina,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _guardando
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Text(
                    _esEdicion ? 'Actualizar Rutina' : 'Save Routine',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCategoriaTabs(ColorScheme colors) {
    final tabs = [
      {'key': 'push', 'label': 'Push'},
      {'key': 'pull', 'label': 'Pull'},
      {'key': 'legs', 'label': 'Legs'},
      {'key': 'core', 'label': 'Upper'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: tabs.map((t) {
          final selected = _categoria == t['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _categoria = t['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  t['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Card de un ejercicio ya agregado a la rutina (memoria).
class _EjercicioCard extends StatelessWidget {
  final Map<String, dynamic> ejercicio;
  final VoidCallback onQuitar;

  const _EjercicioCard({required this.ejercicio, required this.onQuitar});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Imagen (URL Cloudinary, cargada con Image.network)
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
                    '${ejercicio['series']} series · ${ejercicio['reps']} reps\n'
                    '${ejercicio['peso']} · descanso ${ejercicio['descanso']}',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error),
              onPressed: onQuitar,
            ),
          ],
        ),
      ),
    );
  }
}
