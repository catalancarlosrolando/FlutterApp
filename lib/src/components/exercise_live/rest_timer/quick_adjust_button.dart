import 'package:flutter/material.dart';

/// Small button for quick time adjustment (-15s, +30s)
class QuickAdjustButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final VoidCallback? onTap;

  const QuickAdjustButton({
    super.key,
    required this.text,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: colors.outlineVariant,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? colors.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
