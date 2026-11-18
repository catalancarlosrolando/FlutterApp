import 'package:flutter/material.dart';

class BotonBlack extends StatelessWidget {
  final String text;
  final bool iconEnable;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool success;
  const BotonBlack({
    super.key,
    required this.text,
    required this.iconEnable,
    required this.icon,
    required this.onPressed,
    this.success = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextButton.icon(
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 48.0),
        backgroundColor: success ? colors.tertiary : colors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      onPressed: onPressed,
      icon: iconEnable ? Icon(icon, color: colors.onSurfaceVariant) : null,
      label: Text(
        text,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: success ? colors.onTertiary : colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
