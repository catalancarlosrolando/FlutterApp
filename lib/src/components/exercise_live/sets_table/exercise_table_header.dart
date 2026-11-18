import 'package:flutter/material.dart';

/// Header row for ExerciseSetsTable: title, subtitle, and accessory action button (e.g. Discos)
class ExerciseTableHeader extends StatelessWidget {
  final String exerciseName;
  final String exerciseSubtitle;
  final IconData accessoryIcon;
  final VoidCallback? onAccessoryPressed;

  const ExerciseTableHeader({
    super.key,
    required this.exerciseName,
    required this.exerciseSubtitle,
    this.accessoryIcon = Icons.calculate_outlined,
    this.onAccessoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exerciseName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                exerciseSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
