import 'package:flutter/material.dart';

/// Top row for the RestTimerCard: exercise tag/label and vibration toggle badge
class RestTimerHeader extends StatelessWidget {
  final String title;
  final bool isTimerRunning;
  final String hapticText;
  final bool isHapticActive;
  final VoidCallback? onToggleHaptic;

  const RestTimerHeader({
    super.key,
    required this.title,
    this.isTimerRunning = false,
    this.hapticText = 'Vibración On',
    this.isHapticActive = true,
    this.onToggleHaptic,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_filled,
                size: 16,
                color: isTimerRunning ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isTimerRunning ? colors.primary : colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onToggleHaptic,
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: isHapticActive
                  ? colors.primaryContainer
                  : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              hapticText,
              style: TextStyle(
                color: isHapticActive
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
