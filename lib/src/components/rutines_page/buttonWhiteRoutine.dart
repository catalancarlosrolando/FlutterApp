import 'package:flutter/material.dart';

class BotonWhiteRoutine extends StatelessWidget {
  final String text;
  final bool iconEnable;
  final VoidCallback? onTap;

  const BotonWhiteRoutine({
    super.key,
    required this.text,
    required this.iconEnable,
    this.onTap,
  });

  void _goToRoutineDetail(BuildContext context) {
    Navigator.pushNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextButton.icon(
      style: TextButton.styleFrom(
        //minimumSize: Size(30.0, 20.0),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: colors.onSurface, width: 1.0),
        ),
      ),
      onPressed: onTap ?? () => _goToRoutineDetail(context),
      icon: iconEnable ? Icon(Icons.edit, color: colors.onSurface) : null,
      label: Text(
        text,
        style: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          color: colors.onSurface,
        ),
      ),
    );
  }
}
