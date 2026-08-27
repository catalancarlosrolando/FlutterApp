import 'package:flutter/material.dart';

class Inputpropio extends StatelessWidget {
  final String text;

  const Inputpropio({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      style: TextStyle(
        color: colors.onPrimary,
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: "",
        hintText: text,
        filled: true,
        fillColor: colors.surface, // Color de fondo
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
      ),
    );
  }
}
