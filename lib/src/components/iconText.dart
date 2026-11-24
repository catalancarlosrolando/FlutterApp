import 'package:flutter/material.dart';
import 'package:flutter_application/src/theme/color_sheme.dart';

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
    return Row(
      spacing: 6.0,
      children: [
        Icon(icon, size: fontSize + 2, color: context.colors.primary),
        Text(
          text,
          style: TextStyle(color: context.colors.onSurface, fontSize: fontSize),
        ),
      ],
    );
  }
}
