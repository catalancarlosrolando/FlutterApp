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

    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? colors.surfaceBright : Colors.transparent,
        foregroundColor: isSelected ? colors.onPrimary : colors.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      ),
      onPressed: onTap, // 👈 Le avisa al padre que se presionó este botón
      icon: Icon(
        icon,
        size: 20.0,
        color: isSelected ? colors.onSurface : colors.onSurface,
      ),
      label: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
      ),
    );
  }
}
