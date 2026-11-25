import 'package:flutter/material.dart';

class MyButtonNavigator extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const MyButtonNavigator({
    super.key,
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? colors.surfaceBright : Colors.transparent,
        foregroundColor: isSelected ? colors.onPrimary : colors.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onTap, // 👈 Le avisa al padre que se presionó este botón
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20.0,
            color: isSelected ? colors.primary : colors.onSurfaceVariant,
          ),
          const SizedBox(height: 2),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
