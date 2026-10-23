import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/exercise_live/rest_timer/quick_adjust_button.dart';

/// Middle row displaying the large countdown time and quick adjust buttons (-15s, +30s)
class RestTimerDisplay extends StatelessWidget {
  final String displayTime;
  final VoidCallback? onMinus15;
  final VoidCallback? onPlus30;

  const RestTimerDisplay({
    super.key,
    required this.displayTime,
    this.onMinus15,
    this.onPlus30,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          displayTime,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 44,
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
            height: 1.0,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuickAdjustButton(
              text: '-15s',
              textColor: colors.onSurfaceVariant,
              onTap: onMinus15,
            ),
            const SizedBox(width: 8),
            QuickAdjustButton(
              text: '+30s',
              textColor: colors.primary,
              onTap: onPlus30,
            ),
          ],
        ),
      ],
    );
  }
}
