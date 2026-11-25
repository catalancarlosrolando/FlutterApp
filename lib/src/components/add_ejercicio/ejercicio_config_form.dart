import 'package:flutter/material.dart';

class SerieConfigItem {
  final TextEditingController repsCtrl;
  final TextEditingController pesoCtrl;
  String pesoUnit;

  SerieConfigItem({
    String reps = '10',
    String peso = '40',
    this.pesoUnit = 'kg',
  })  : repsCtrl = TextEditingController(text: reps),
        pesoCtrl = TextEditingController(text: peso);

  void dispose() {
    repsCtrl.dispose();
    pesoCtrl.dispose();
  }
}

class EjercicioConfigForm extends StatelessWidget {
  final List<SerieConfigItem> series;
  final String descanso;
  final VoidCallback onAddSerie;
  final ValueChanged<int> onRemoveSerie;
  final ValueChanged<String> onDescansoChanged;
  final void Function(int index, String unit) onUnitChanged;

  static const chipsDescanso = ['45 seg', '60 seg', '90 seg', '120 seg', '5 min'];

  const EjercicioConfigForm({
    super.key,
    required this.series,
    required this.descanso,
    required this.onAddSerie,
    required this.onRemoveSerie,
    required this.onDescansoChanged,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de Series
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Series (${series.length})',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Reps y Peso por serie',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Lista de series una a una
        ...series.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.outlineVariant.withAlpha(100),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Número de serie
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primary.withAlpha(35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Repeticiones
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: item.repsCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: colors.onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Reps',
                      labelStyle: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Peso
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: item.pesoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: colors.onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Peso',
                      labelStyle: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Selector de unidad (kg / lbs)
                _unitToggle(colors, item.pesoUnit, (u) => onUnitChanged(index, u)),

                // Botón eliminar serie
                if (series.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: colors.error,
                    tooltip: 'Eliminar serie',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => onRemoveSerie(index),
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: 6),

        // Botón agregar serie de una a una
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAddSerie,
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Agregar serie',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(
                color: colors.primary.withAlpha(160),
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // DESCANSO
        _label(colors, 'Descanso entre series'),
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

  Widget _unitToggle(ColorScheme colors, String currentUnit, ValueChanged<String> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(currentUnit == 'kg' ? 'lbs' : 'kg'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          currentUnit,
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
