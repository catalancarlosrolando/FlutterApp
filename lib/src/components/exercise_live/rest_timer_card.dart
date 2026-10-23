import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/exercise_live/rest_timer/rest_progress_bar.dart';
import 'package:flutter_application/src/components/exercise_live/rest_timer/rest_timer_action_row.dart';
import 'package:flutter_application/src/components/exercise_live/rest_timer/rest_timer_display.dart';
import 'package:flutter_application/src/components/exercise_live/rest_timer/rest_timer_header.dart';

/// Generic rest timer card composed of modular subcomponents using Material 3 ColorScheme
class RestTimerCard extends StatelessWidget {
  final String title;
  final int secondsRemaining;
  final int totalSeconds;
  final String? formattedTime;
  final String nextSetText;
  final String hapticText;
  final bool isHapticActive;
  final bool isTimerRunning;
  final VoidCallback? onToggleHaptic;
  final VoidCallback? onMinus15;
  final VoidCallback? onPlus30;
  final VoidCallback? onStartRest;
  final VoidCallback? onResetOrSkipRest;

  const RestTimerCard({
    super.key,
    this.title = 'DESCANSO EN CURSO',
    required this.secondsRemaining,
    required this.totalSeconds,
    this.formattedTime,
    this.nextSetText = 'Siguiente: Serie 1',
    this.hapticText = 'Vibración On',
    this.isHapticActive = true,
    this.isTimerRunning = false,
    this.onToggleHaptic,
    this.onMinus15,
    this.onPlus30,
    this.onStartRest,
    this.onResetOrSkipRest,
  });

  String _formatSeconds(int totalSecs) {
    if (totalSecs < 0) totalSecs = 0;
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final displayTime = formattedTime ?? _formatSeconds(secondsRemaining);
    final progress = totalSeconds > 0
        ? (secondsRemaining / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTimerRunning ? colors.primary : colors.outlineVariant,
          width: isTimerRunning ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RestTimerHeader(
            title: title,
            isTimerRunning: isTimerRunning,
            hapticText: hapticText,
            isHapticActive: isHapticActive,
            onToggleHaptic: onToggleHaptic,
          ),
          const SizedBox(height: 12),
          RestTimerDisplay(
            displayTime: displayTime,
            onMinus15: onMinus15,
            onPlus30: onPlus30,
          ),
          const SizedBox(height: 12),
          RestProgressBar(progress: progress),
          const SizedBox(height: 12),
          RestTimerActionRow(
            nextSetText: nextSetText,
            isTimerRunning: isTimerRunning,
            onStartRest: onStartRest,
            onResetOrSkipRest: onResetOrSkipRest,
          ),
        ],
      ),
    );
  }
}
