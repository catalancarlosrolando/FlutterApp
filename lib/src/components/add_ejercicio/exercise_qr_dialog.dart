import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Modal dialog that generates and displays a QR code for an exercise.
/// The QR content contains JSON with fields:
/// id, name, image, tiempo, series, reps, peso, descanso, description.
class ExerciseQrDialog extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseQrDialog({super.key, required this.exercise});

  static void show(BuildContext context, Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) => ExerciseQrDialog(exercise: exercise),
    );
  }

  String _buildQrPayload() {
    final Map<String, dynamic> data = {
      'id': exercise['id'] ?? exercise['name']?.toString().toLowerCase().replaceAll(' ', '_') ?? '',
      'name': exercise['name'] ?? '',
      'image': exercise['image'] ?? '',
      'tiempo': exercise['tiempo'] ?? '',
      'series': exercise['series'],
      'reps': exercise['reps']?.toString() ?? '',
      'peso': exercise['peso']?.toString() ?? '',
      'descanso': exercise['descanso']?.toString() ?? '',
      'description': exercise['description'] ?? '',
    };
    return jsonEncode(data);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final qrData = _buildQrPayload();
    final exerciseName = exercise['name'] ?? 'Ejercicio';

    return Dialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compartir Ejercicio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exerciseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 220.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Escanea este código desde la app para importar el ejercicio con sus configuraciones.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
