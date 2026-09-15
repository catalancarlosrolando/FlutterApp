import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final double fontSize;

  const IconText({
    super.key,
    required this.icon,
    required this.text,

    this.fontSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      spacing: 6.0,
      children: [
        Icon(icon, size: fontSize + 2, color: colors.onSurface),
        Text(
          text,
          style: TextStyle(color: colors.onSurface, fontSize: fontSize),
        ),
      ],
    );
  }
}
