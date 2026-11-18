import 'package:flutter/material.dart';

/// Confirmation dialog before finishing the workout
class ConfirmFinishDialog extends StatelessWidget {
  final int completedSets;
  final int totalSets;
  final bool canSaveExerciseChanges;

  const ConfirmFinishDialog({
    super.key,
    required this.completedSets,
    required this.totalSets,
    this.canSaveExerciseChanges = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int completedSets,
    required int totalSets,
    bool canSaveExerciseChanges = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmFinishDialog(
        completedSets: completedSets,
        totalSets: totalSets,
        canSaveExerciseChanges: canSaveExerciseChanges,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final allDone = completedSets >= totalSets && totalSets > 0;

    return AlertDialog(
      backgroundColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            allDone ? Icons.check_circle : Icons.fitness_center,
            color: allDone ? Colors.green : colors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              allDone ? '¡Ejercicio completado!' : '¿Finalizar ejercicio?',
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        allDone
            ? 'Has completado todas las series ($completedSets/$totalSets).'
            : 'Has completado $completedSets de $totalSets series. ¿Deseas terminar?',
        style: TextStyle(color: colors.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Continuar',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: allDone ? Colors.green : colors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(allDone ? 'Finalizar' : 'Finalizar antes'),
        ),
      ],
    );
  }
}
