import 'package:flutter/material.dart';

class Inputpropio extends StatelessWidget {
  final String text;
  final Widget icon;

  const Inputpropio({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      style: TextStyle(
        color: colors.surfaceContainerHighest,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        prefixIcon: icon,
        prefixIconColor: WidgetStateColor.fromMap(
          <WidgetStatesConstraint, Color>{
            WidgetState.focused: colors.primary,
            WidgetState.any: colors.onSurface,
          },
        ),
        //labelText: text,
        hintText: text,
        filled: true,
        fillColor: colors.surfaceContainerLow, // Color de fondo
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colors.surfaceContainerHigh),
        ),
      ),
    );
  }
}
