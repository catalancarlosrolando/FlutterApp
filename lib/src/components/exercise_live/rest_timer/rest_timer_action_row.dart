import 'package:flutter/material.dart';

/// Bottom action row for RestTimerCard: next set information and action button (Iniciar/Reiniciar descanso)
class RestTimerActionRow extends StatelessWidget {
  final String nextSetText;
  final bool isTimerRunning;
  final VoidCallback? onStartRest;
  final VoidCallback? onResetOrSkipRest;

  const RestTimerActionRow({
    super.key,
    required this.nextSetText,
    this.isTimerRunning = false,
    this.onStartRest,
    this.onResetOrSkipRest,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            nextSetText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (isTimerRunning)
          InkWell(
            onTap: onResetOrSkipRest,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Text(
                'Reiniciar descanso',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else
          InkWell(
            onTap: onStartRest,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, size: 14, color: colors.onPrimary),
                  const SizedBox(width: 4),
                  Text(
                    'Iniciar Descanso',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
