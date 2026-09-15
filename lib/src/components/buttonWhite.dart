import 'package:flutter/material.dart';

class BotonWhite extends StatelessWidget {
  final String text;
  final bool iconEnable;
  const BotonWhite({super.key, required this.text, required this.iconEnable});

  void _goToLandingPage(BuildContext context) {
    Navigator.pushNamed(context, '/landing');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextButton.icon(
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 48.0),
        backgroundColor: colors.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      onPressed: () => _goToLandingPage(context),
      icon: iconEnable ? Icon(Icons.arrow_forward, color: Colors.black) : null,
      label: Text(
        text,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
