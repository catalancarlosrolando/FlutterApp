import 'package:flutter/material.dart';

/// Modal dialog to edit set weight (kg)
class EditWeightDialog extends StatefulWidget {
  final double initialWeight;

  const EditWeightDialog({
    super.key,
    required this.initialWeight,
  });

  static Future<double?> show(
    BuildContext context, {
    required double initialWeight,
  }) {
    return showDialog<double>(
      context: context,
      builder: (ctx) => EditWeightDialog(initialWeight: initialWeight),
    );
  }

  @override
  State<EditWeightDialog> createState() => _EditWeightDialogState();
}

class _EditWeightDialogState extends State<EditWeightDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialWeight.toString());
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
        'Modificar Peso (kg)',
        style: TextStyle(color: colors.onSurface, fontSize: 16),
      ),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: true,
        style: TextStyle(color: colors.onSurface),
        decoration: InputDecoration(
          suffixText: 'kg',
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
            final parsed = double.tryParse(_controller.text);
            Navigator.pop(context, parsed);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
