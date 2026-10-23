import 'package:flutter/material.dart';

/// Modal dialog for Plate Calculator using Material 3 ColorScheme
class PlateCalculatorDialog extends StatefulWidget {
  final double initialWeight;
  final ValueChanged<double>? onApplyWeight;

  const PlateCalculatorDialog({
    super.key,
    this.initialWeight = 80.0,
    this.onApplyWeight,
  });

  static Future<double?> show(
    BuildContext context, {
    double initialWeight = 80.0,
  }) {
    return showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PlateCalculatorDialog(
        initialWeight: initialWeight,
        onApplyWeight: (w) => Navigator.of(context).pop(w),
      ),
    );
  }

  @override
  State<PlateCalculatorDialog> createState() => _PlateCalculatorDialogState();
}

class _PlateCalculatorDialogState extends State<PlateCalculatorDialog> {
  late double _targetWeight;
  double _barWeight = 20.0; // 20: Olimpica, 15: Mujeres, 10: EZ

  final List<double> _availablePlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];

  @override
  void initState() {
    super.initState();
    _targetWeight = widget.initialWeight;
  }

  Map<double, int> _calculatePlatesPerSide() {
    double weightNeededPerSide = (_targetWeight - _barWeight) / 2.0;
    if (weightNeededPerSide < 0) weightNeededPerSide = 0;

    final result = <double, int>{};
    for (var plate in _availablePlates) {
      if (weightNeededPerSide >= plate) {
        int count = (weightNeededPerSide / plate).floor();
        result[plate] = count;
        weightNeededPerSide -= count * plate;
      }
    }
    return result;
  }

  Color _getPlateColor(double plate, ColorScheme colors) {
    if (plate >= 20.0) return colors.primary;
    if (plate >= 10.0) return colors.tertiary;
    if (plate >= 5.0) return colors.secondary;
    return colors.outline;
  }

  double _getPlateHeight(double plate) {
    if (plate >= 20.0) return 64.0;
    if (plate >= 10.0) return 50.0;
    if (plate >= 5.0) return 38.0;
    return 28.0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final platesPerSide = _calculatePlatesPerSide();
    final double netPerSide = (_targetWeight - _barWeight) / 2.0;
    final displayNet = netPerSide > 0 ? netPerSide.toStringAsFixed(1) : '0.0';

    return Dialog(
      backgroundColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Calculadora de Discos',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.onSurfaceVariant, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bar Selector
              Text(
                'Tipo de barra inicial',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  children: [
                    _BarOption(
                      title: 'Olímpica (20 kg)',
                      isSelected: _barWeight == 20.0,
                      onTap: () => setState(() => _barWeight = 20.0),
                    ),
                    _BarOption(
                      title: 'Mujeres (15 kg)',
                      isSelected: _barWeight == 15.0,
                      onTap: () => setState(() => _barWeight = 15.0),
                    ),
                    _BarOption(
                      title: 'EZ (10 kg)',
                      isSelected: _barWeight == 10.0,
                      onTap: () => setState(() => _barWeight = 10.0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Target Weight Cluster
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'PESO TOTAL OBJETIVO',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepperButton(
                          text: '-2.5',
                          onTap: () {
                            if (_targetWeight > _barWeight) {
                              setState(() => _targetWeight -= 2.5);
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${_targetWeight.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _StepperButton(
                          text: '+2.5',
                          onTap: () {
                            setState(() => _targetWeight += 2.5);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$displayNet kg en discos por cada lado',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Visual Schematic
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribución por lado (Manga)',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bar Schematic Graphic
                    Container(
                      width: double.infinity,
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Collar stop
                          Container(
                            width: 12,
                            height: 60,
                            decoration: BoxDecoration(
                              color: colors.outline,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Discs
                          ...platesPerSide.entries.expand((entry) {
                            final plate = entry.key;
                            final count = entry.value;
                            final color = _getPlateColor(plate, colors);
                            final height = _getPlateHeight(plate);
                            return List.generate(
                              count,
                              (i) => Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Container(
                                  width: 16,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            );
                          }),
                          // Sleeve shaft
                          Expanded(
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Lock collar (red / error)
                          Container(
                            width: 8,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colors.error,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Plates Breakdown List
                    if (platesPerSide.isEmpty)
                      Text(
                        'Solo la barra, sin discos adicionales.',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      )
                    else
                      ...platesPerSide.entries.map((entry) {
                        final plate = entry.key;
                        final count = entry.value;
                        final color = _getPlateColor(plate, colors);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${count}x Disco ${plate.toStringAsFixed(plate % 1 == 0 ? 0 : 2)} kg',
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${(count * plate).toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    widget.onApplyWeight?.call(_targetWeight);
                  },
                  child: const Text(
                    'Aplicar a la serie activa',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _BarOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? colors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _StepperButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outlineVariant, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
