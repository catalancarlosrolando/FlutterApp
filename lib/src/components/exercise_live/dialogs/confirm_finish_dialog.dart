import 'package:flutter/material.dart';

/// Confirmation dialog before finishing the workout
class ConfirmFinishDialog extends StatelessWidget {
  final int completedSets;
  final int totalSets;

  const ConfirmFinishDialog({
    super.key,
    required this.completedSets,
    required this.totalSets,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int completedSets,
    required int totalSets,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmFinishDialog(
        completedSets: completedSets,
        totalSets: totalSets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '¿Finalizar ejercicio?',
        style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Has completado $completedSets de $totalSets series. ¿Deseas terminar?',
        style: TextStyle(color: colors.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Continuar', style: TextStyle(color: colors.onSurfaceVariant)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Finalizar'),
        ),
      ],
    );
  }
}
