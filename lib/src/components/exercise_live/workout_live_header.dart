import 'package:flutter/material.dart';

/// Generic header component for workout screens using Material 3 ColorScheme
class WorkoutLiveHeader extends StatelessWidget {
  final String title;
  final String liveText;
  final String actionText;
  final bool isWorkoutActive;
  final VoidCallback? onActionPressed;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const WorkoutLiveHeader({
    super.key,
    required this.title,
    this.liveText = 'EN VIVO',
    this.actionText = 'Iniciar',
    this.isWorkoutActive = false,
    this.onActionPressed,
    this.onBackPressed,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBackButton)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: onBackPressed ?? () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: colors.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge Row (Dot + Label)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isWorkoutActive ? colors.primary : colors.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      liveText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isWorkoutActive
                            ? colors.primary
                            : colors.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Routine / Exercise Title
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Action Button: "Iniciar" / "Finalizar"
        InkWell(
          onTap: onActionPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: isWorkoutActive ? colors.error : colors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWorkoutActive ? Icons.stop_circle_outlined : Icons.play_arrow,
                  size: 16,
                  color: isWorkoutActive ? colors.onError : colors.onPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  actionText,
                  style: TextStyle(
                    color: isWorkoutActive ? colors.onError : colors.onPrimary,
                    fontSize: 13,
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
