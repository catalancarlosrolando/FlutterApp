import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/exercise_live/sets_table/set_check_button.dart';
import 'package:flutter_application/src/components/exercise_live/sets_table/set_metric_cell.dart';
import 'package:flutter_application/src/components/exercise_live/workout_set_model.dart';

/// Row representing a single set in the exercise sets table
class ExerciseSetRow extends StatelessWidget {
  final WorkoutSetItem setItem;
  final VoidCallback? onToggleCheck;
  final VoidCallback? onTapWeight;
  final VoidCallback? onTapReps;

  const ExerciseSetRow({
    super.key,
    required this.setItem,
    this.onToggleCheck,
    this.onTapWeight,
    this.onTapReps,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCompleted = setItem.isCompleted;
    final isActive = setItem.isActive && !isCompleted;

    final Color backgroundColor = isCompleted
        ? colors.secondaryContainer.withAlpha(80)
        : (isActive ? colors.surfaceContainerHigh : colors.surfaceContainerLow);

    final Border border = isCompleted
        ? Border.all(color: colors.primary.withAlpha(100), width: 1)
        : (isActive
            ? Border.all(color: colors.primary, width: 1.5)
            : Border.all(color: colors.outlineVariant, width: 0.5));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Set number
          SizedBox(
            width: 28,
            child: Text(
              '${setItem.setNumber}',
              style: TextStyle(
                color: isActive ? colors.primary : colors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 2. Previous performance
          Expanded(
            flex: 3,
            child: Text(
              setItem.previous,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),

          // 3. Weight (kg)
          SetMetricCell(
            value: setItem.weight.toStringAsFixed(1),
            width: 44,
            onTap: onTapWeight,
          ),

          // 4. Reps
          SetMetricCell(
            value: '${setItem.reps}',
            width: 36,
            onTap: onTapReps,
          ),

          // 5. Checkbox / Done button
          SetCheckButton(
            isCompleted: isCompleted,
            isActive: isActive,
            onTap: onToggleCheck,
          ),
        ],
      ),
    );
  }
}
