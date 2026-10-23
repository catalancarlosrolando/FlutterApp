import 'package:flutter/material.dart';

/// Modal dialog to edit set repetitions
class EditRepsDialog extends StatefulWidget {
  final int initialReps;

  const EditRepsDialog({
    super.key,
    required this.initialReps,
  });

  static Future<int?> show(
    BuildContext context, {
    required int initialReps,
  }) {
    return showDialog<int>(
      context: context,
      builder: (ctx) => EditRepsDialog(initialReps: initialReps),
    );
  }

  @override
  State<EditRepsDialog> createState() => _EditRepsDialogState();
}

class _EditRepsDialogState extends State<EditRepsDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialReps.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Modificar Repeticiones',
        style: TextStyle(color: colors.onSurface, fontSize: 16),
      ),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        style: TextStyle(color: colors.onSurface),
        decoration: InputDecoration(
          suffixText: 'reps',
          suffixStyle: TextStyle(color: colors.onSurfaceVariant),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.outlineVariant),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: colors.onSurfaceVariant)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          onPressed: () {
            final parsed = int.tryParse(_controller.text);
            Navigator.pop(context, parsed);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
