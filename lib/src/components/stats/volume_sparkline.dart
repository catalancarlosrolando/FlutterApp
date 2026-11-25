// ===========================================================
// volume_sparkline.dart
// Sparkline mini — versión reducida del BarChart semanal,
// sin ejes, sin etiquetas, solo barras de color. Para usar
// como fondo/overlay en la card de la homepage.
// ===========================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../helpers/historial_helpers.dart';

class VolumeSparkline extends StatelessWidget {
  final List<WeeklyVolume> data;
  final Color? barColor;

  const VolumeSparkline({super.key, required this.data, this.barColor});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final color = barColor ?? Colors.white.withOpacity(0.7);
    final maxY = data.map((e) => e.volume).reduce((a, b) => a > b ? a : b);

    final barGroups = List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[i].volume,
            color: color,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ],
      );
    });

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        minY: 0,
        barGroups: barGroups,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(enabled: false),
      ),
    );
  }
}
