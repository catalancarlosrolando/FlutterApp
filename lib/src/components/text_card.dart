import 'package:flutter/material.dart';

class TextCard extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;
  final double fontSize;

  const TextCard({
    super.key,
    required this.text,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      text,
      maxLines: 3, // máximo 3 líneas
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: colors.onSurface,
        fontWeight: fontWeight,
        fontSize: fontSize,
      ),
    );
  }
}
