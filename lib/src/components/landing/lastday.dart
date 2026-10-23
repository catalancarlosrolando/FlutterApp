import 'package:flutter/material.dart';

class LastDay extends StatelessWidget {
  const LastDay({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 45.0,
      width: 500,
      //color: colors.primaryContainer,
      padding: const EdgeInsets.all(12.0),
      //margin: EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        color: colors.onSurfaceVariant.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.outline, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Ultima Asistencia", style: TextStyle(color: colors.onSurface)),
          Text('14 de mayo 2026', style: TextStyle(color: colors.onSurface)),
        ],
      ),
    );
  }
}
