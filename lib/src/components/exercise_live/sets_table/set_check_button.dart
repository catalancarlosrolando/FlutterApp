import 'package:flutter/material.dart';

/// Check button for toggling completion state of a workout set
class SetCheckButton extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;
  final VoidCallback? onTap;

  const SetCheckButton({
    super.key,
    required this.isCompleted,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isCompleted ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
          border: isCompleted
              ? null
              : Border.all(
                  color: isActive ? colors.primary : colors.outlineVariant,
                  width: isActive ? 1.5 : 1.0,
                ),
        ),
        child: isCompleted
            ? Icon(
                Icons.check,
                size: 14,
                color: colors.onPrimary,
              )
            : null,
      ),
    );
  }
}
