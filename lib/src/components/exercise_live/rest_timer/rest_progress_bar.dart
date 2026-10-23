import 'package:flutter/material.dart';

/// Progress bar track for the RestTimerCard
class RestProgressBar extends StatelessWidget {
  final double progress;
  final double height;

  const RestProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        width: double.infinity,
        height: height,
        color: colors.surfaceContainerHighest,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: clampedProgress,
          child: Container(
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        ),
      ),
    );
  }
}
