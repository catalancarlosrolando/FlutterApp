import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/exercise_live/exercise_set_row.dart';
import 'package:flutter_application/src/components/exercise_live/sets_table/add_set_button.dart';
import 'package:flutter_application/src/components/exercise_live/sets_table/exercise_table_columns_header.dart';
import 'package:flutter_application/src/components/exercise_live/sets_table/exercise_table_header.dart';
import 'package:flutter_application/src/components/exercise_live/workout_set_model.dart';

/// Generic exercise table card composed of modular subcomponents using Material 3 ColorScheme
class ExerciseSetsTable extends StatelessWidget {
  final String exerciseName;
  final String exerciseSubtitle;
  final String accessoryButtonText;
  final IconData accessoryIcon;
  final VoidCallback? onAccessoryPressed;
  final List<WorkoutSetItem> sets;
  final ValueChanged<int>? onToggleSet;
  final ValueChanged<int>? onTapWeight;
  final ValueChanged<int>? onTapReps;
  final VoidCallback? onAddSet;

  const ExerciseSetsTable({
    super.key,
    required this.exerciseName,
    required this.exerciseSubtitle,
    this.accessoryButtonText = 'Discos',
    this.accessoryIcon = Icons.calculate_outlined,
    this.onAccessoryPressed,
    required this.sets,
    this.onToggleSet,
    this.onTapWeight,
    this.onTapReps,
    this.onAddSet,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Exercise Name & Subtitle + Plate Calculator Trigger
          ExerciseTableHeader(
            exerciseName: exerciseName,
            exerciseSubtitle: exerciseSubtitle,
            accessoryButtonText: accessoryButtonText,
            accessoryIcon: accessoryIcon,
            onAccessoryPressed: onAccessoryPressed,
          ),

          const SizedBox(height: 10),

          // Table Columns Header (SET, ANTERIOR, KG, REPS, LISTO)
          const ExerciseTableColumnsHeader(),

          const SizedBox(height: 4),

          // Sets Rows List
          ...sets.asMap().entries.map((entry) {
            final index = entry.key;
            final setItem = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ExerciseSetRow(
                setItem: setItem,
                onToggleCheck: () => onToggleSet?.call(index),
                onTapWeight: () => onTapWeight?.call(index),
                onTapReps: () => onTapReps?.call(index),
              ),
            );
          }),

          const SizedBox(height: 2),

          // Add Set Button ("+ Añadir Serie")
          AddSetButton(onTap: onAddSet),
        ],
      ),
    );
  }
}
