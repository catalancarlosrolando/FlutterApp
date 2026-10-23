import 'package:flutter/material.dart';

/// Clickable metric cell (e.g. Kg or Reps) inside a workout set row
class SetMetricCell extends StatelessWidget {
  final String value;
  final double width;
  final VoidCallback? onTap;

  const SetMetricCell({
    super.key,
    required this.value,
    this.width = 40.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: SizedBox(
          width: width,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
