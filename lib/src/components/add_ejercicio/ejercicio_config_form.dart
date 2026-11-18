import 'package:flutter/material.dart';

class EjercicioConfigForm extends StatelessWidget {
  final TextEditingController seriesCtrl;
  final TextEditingController repsCtrl;
  final TextEditingController pesoCtrl;
  final String pesoUnit;
  final String descanso;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<String> onDescansoChanged;

  static const chipsDescanso = ['45 seg', '60 seg', '90 seg', '120 seg', '5 min'];

  const EjercicioConfigForm({
    super.key,
    required this.seriesCtrl,
    required this.repsCtrl,
    required this.pesoCtrl,
    required this.pesoUnit,
    required this.descanso,
    required this.onUnitChanged,
    required this.onDescansoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SERIES
        _label(colors, 'Series'),
        TextField(
          controller: seriesCtrl,
          keyboardType: TextInputType.number,
          style: TextStyle(color: colors.onSurface),
          decoration: _inputDecoration(colors),
        ),
        const SizedBox(height: 16),

        // REPS
        _label(colors, 'Reps'),
        TextField(
          controller: repsCtrl,
          style: TextStyle(color: colors.onSurface),
          decoration: _inputDecoration(colors).copyWith(
            hintText: 'Ej: 10-12',
          ),
        ),
        const SizedBox(height: 16),

        // PESO
        _label(colors, 'Peso objetivo'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: pesoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: colors.onSurface),
                decoration: _inputDecoration(colors).copyWith(
                  hintText: '80.0',
                ),
              ),
            ),
            const SizedBox(width: 12),
            _unitToggle(colors),
          ],
        ),
        const SizedBox(height: 16),

        // DESCANSO
        _label(colors, 'Descanso'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chipsDescanso.map((d) {
            final selected = descanso == d;
            return ChoiceChip(
              label: Text(d),
              selected: selected,
              onSelected: (_) => onDescansoChanged(d),
              selectedColor: colors.primary,
              labelStyle: TextStyle(
                color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
              backgroundColor: colors.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _label(ColorScheme colors, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
    );
  }

  Widget _unitToggle(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['kg', 'lbs'].map((u) {
          final selected = pesoUnit == u;
          return GestureDetector(
            onTap: () => onUnitChanged(u),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                u,
                style: TextStyle(
                  color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  InputDecoration _inputDecoration(ColorScheme colors) {
    return InputDecoration(
      filled: true,
      fillColor: colors.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
