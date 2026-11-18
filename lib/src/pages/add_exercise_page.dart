import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_application/src/components/add_ejercicio/ejercicio_config_form.dart';
import 'package:flutter_application/src/components/add_ejercicio/ejercicio_dropdown_catalog.dart';
import 'package:flutter_application/src/components/add_ejercicio/ejercicio_preview_image.dart';
import 'package:flutter_application/src/components/add_ejercicio/qr_scanner_modal.dart';
import 'package:flutter_application/src/components/buttonBlack.dart';

/// Pantalla "Configurar ejercicio".
///
/// Permite elegir un ejercicio desde el catálogo de Firestore O
/// escanear un código QR con la información completa del ejercicio:
/// {
///   "id": "press_banca",
///   "name": "Press de Banca Plano",
///   "image": "https://...",
///   "tiempo": "15 Minutos",
///   "series": "4",
///   "reps": "8-10",
///   "peso": "80 kg",
///   "descanso": "90 seg",
///   "description": "..."
/// }
///
/// Al presionar "+ Add", retorna el ejercicio configurado via Navigator.pop(context, ejercicio).
class AddExercisePage extends StatefulWidget {
  final Map<String, dynamic>? ejercicioParaEditar;

  const AddExercisePage({super.key, this.ejercicioParaEditar});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  // Ejercicio seleccionado (catálogo o QR)
  Map<String, dynamic>? _ejercicio;

  // Controladores y estados editables
  late final TextEditingController _seriesCtrl;
  late final TextEditingController _repsCtrl;
  late final TextEditingController _pesoCtrl;
  String _pesoUnit = 'kg';
  String _descanso = '90 seg';

  bool get _esEdicion => widget.ejercicioParaEditar != null;

  @override
  void initState() {
    super.initState();
    final edit = widget.ejercicioParaEditar;
    if (edit != null) {
      _ejercicio = Map<String, dynamic>.from(edit);
      _seriesCtrl = TextEditingController(
        text: edit['series']?.toString() ?? '4',
      );
      _repsCtrl = TextEditingController(
        text: edit['reps']?.toString() ?? '10-12',
      );

      final pStr = edit['peso']?.toString() ?? '80 kg';
      final partes = pStr.trim().split(' ');
      _pesoCtrl = TextEditingController(
        text: partes.isNotEmpty ? partes.first : '80',
      );
      if (partes.length > 1 && (partes[1] == 'lbs' || partes[1] == 'kg')) {
        _pesoUnit = partes[1];
      }

      if (edit['descanso'] != null) {
        _descanso = edit['descanso'].toString();
      }
    } else {
      _seriesCtrl = TextEditingController(text: '4');
      _repsCtrl = TextEditingController(text: '10-12');
      _pesoCtrl = TextEditingController(text: '80');
    }
  }

  @override
  void dispose() {
    _seriesCtrl.dispose();
    _repsCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  Future<void> _abrirEscannerQR() async {
    final rawCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerModal()),
    );

    if (rawCode == null || !mounted) return;
    _procesarQR(rawCode);
  }

  void _procesarQR(String rawCode) {
    try {
      final decoded = jsonDecode(rawCode.trim());
      if (decoded is Map<String, dynamic>) {
        setState(() {
          _ejercicio = {
            'id':
                decoded['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            'name': decoded['name']?.toString() ?? 'Ejercicio QR',
            'image': decoded['image']?.toString() ?? '',
            'tiempo': decoded['tiempo']?.toString() ?? '15 Minutos',
            'description': decoded['description']?.toString() ?? '',
            'finalizado': decoded['finalizado'] == true,
          };

          if (decoded['series'] != null) {
            _seriesCtrl.text = decoded['series'].toString();
          }
          if (decoded['reps'] != null) {
            _repsCtrl.text = decoded['reps'].toString();
          }
          if (decoded['peso'] != null) {
            final pStr = decoded['peso'].toString();
            final partes = pStr.split(' ');
            _pesoCtrl.text = partes.first;
            if (partes.length > 1 &&
                (partes[1] == 'lbs' || partes[1] == 'kg')) {
              _pesoUnit = partes[1];
            }
          }
          if (decoded['descanso'] != null) {
            _descanso = decoded['descanso'].toString();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Ejercicio cargado desde QR: ${_ejercicio!['name']}!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        return;
      }
    } catch (_) {
      // Formato no JSON
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El código QR no contiene el formato JSON esperado.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _cancelar() => Navigator.pop(context);

  void _agregar() {
    if (_ejercicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Elegí un ejercicio del catálogo o escaneá un QR primero',
          ),
        ),
      );
      return;
    }

    final ejercicioFinal = <String, dynamic>{
      'id': _ejercicio!['id'],
      'name': _ejercicio!['name'],
      'image': _ejercicio!['image'],
      'tiempo': _ejercicio!['tiempo'],
      'series': _seriesCtrl.text.trim(),
      'reps': _repsCtrl.text.trim(),
      'peso': '${_pesoCtrl.text.trim()} $_pesoUnit',
      'descanso': _descanso,
      'description': _ejercicio!['description'],
      'finalizado': _ejercicio!['finalizado'] == true,
    };

    Navigator.pop(context, ejercicioFinal);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(_esEdicion ? 'Editar ejercicio' : 'Configurar ejercicio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // === DROPDOWN CATÁLOGO FIRESTORE ===
          Text(
            'Catálogo de ejercicios',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 8),
          EjercicioDropdownCatalog(
            selectedEjercicio: _ejercicio,
            onSelected: (seleccionado) {
              if (seleccionado != null) {
                setState(() => _ejercicio = seleccionado);
              }
            },
          ),
          const SizedBox(height: 16),

          // Separador visual "O"
          Row(
            children: [
              Expanded(child: Divider(color: colors.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'O',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
              Expanded(child: Divider(color: colors.outlineVariant)),
            ],
          ),
          const SizedBox(height: 16),

          // === BOTÓN ESCANEAR QR ===
          FilledButton.icon(
            onPressed: _abrirEscannerQR,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.qr_code_scanner, size: 24),
            label: const Text(
              'Escanear ejercicio con código QR',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // === DETALLES DEL EJERCICIO SELECCIONADO / ESCANEADO ===
          if (_ejercicio != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.primary.withAlpha(120),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: colors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _ejercicio!['name'] ?? 'Ejercicio',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if ((_ejercicio!['description'] as String?)
                                ?.isNotEmpty ==
                            true) ...[
                          const SizedBox(height: 4),
                          Text(
                            _ejercicio!['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if ((_ejercicio!['tiempo'] as String?)?.isNotEmpty ==
                            true) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Tiempo estimado: ${_ejercicio!['tiempo']}',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Preview de imagen
          EjercicioPreviewImage(
            imageUrl: _ejercicio?['image'],
            title: _ejercicio?['name'],
          ),
          const SizedBox(height: 24),

          // Formulario de parámetros
          EjercicioConfigForm(
            seriesCtrl: _seriesCtrl,
            repsCtrl: _repsCtrl,
            pesoCtrl: _pesoCtrl,
            pesoUnit: _pesoUnit,
            descanso: _descanso,
            onUnitChanged: (u) => setState(() => _pesoUnit = u),
            onDescansoChanged: (d) => setState(() => _descanso = d),
          ),
          const SizedBox(height: 40),

          // Botones Cancelar / Add
          Row(
            children: [
              Expanded(
                child: BotonBlack(
                  text: 'Cancelar',
                  iconEnable: false,
                  icon: Icons.cancel,
                  onPressed: _cancelar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BotonBlack(
                  text: _esEdicion ? 'Guardar' : 'Agregar',
                  iconEnable: true,
                  success: true,
                  icon: _esEdicion ? Icons.check : Icons.add,
                  onPressed: _agregar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
