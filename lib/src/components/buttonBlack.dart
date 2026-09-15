import 'package:flutter/material.dart';

class BotonBlack extends StatelessWidget {
  final String text;
  final bool iconEnable;
  final IconData icon;
  const BotonBlack({
    super.key,
    required this.text,
    required this.iconEnable,
    required this.icon,
  });

  void _goToLandingPage(BuildContext context) {
    Navigator.pushNamed(context, '/landing');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextButton.icon(
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 48.0),
        backgroundColor: colors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      onPressed: () => _goToLandingPage(context),
      icon: iconEnable ? Icon(icon, color: Colors.white) : null,
      label: Text(
        text,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ),
    );
  }
}
