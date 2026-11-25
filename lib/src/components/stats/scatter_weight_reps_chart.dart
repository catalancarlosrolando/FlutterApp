// ===========================================================
// scatter_weight_reps_chart.dart
// ScatterChart — peso vs reps (doble progresión).
// ===========================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../helpers/historial_helpers.dart';

class ScatterWeightRepsChart extends StatelessWidget {
  final List<SetPoint> data;

  const ScatterWeightRepsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    if (data.isEmpty) {
      return Center(
        child: Text(
          'Sin series registradas',
          style: texts.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      );
    }

    final allW = data.map((p) => p.weight);
    final allR = data.map((p) => p.reps);
    final minW = allW.reduce((a, b) => a < b ? a : b);
    final maxW = allW.reduce((a, b) => a > b ? a : b);
    final minR = allR.reduce((a, b) => a < b ? a : b);
    final maxR = allR.reduce((a, b) => a > b ? a : b);

    final wPad = ((maxW - minW) * 0.15).clamp(5.0, double.infinity);
    final rPad = ((maxR - minR) * 0.15).clamp(2.0, double.infinity);

    final scatterSpots = data.map((p) {
      return ScatterSpot(
        p.weight,
        p.reps,
        dotPainter: FlDotCirclePainter(
          radius: 5,
          color: colors.primary.withOpacity(0.65),
          strokeColor: colors.primary,
          strokeWidth: 1,
        ),
      );
    }).toList();

    return ScatterChart(
      ScatterChartData(
        scatterSpots: scatterSpots,
        minX: minW - wPad,
        maxX: maxW + wPad,
        minY: (minR - rPad).clamp(0, double.infinity),
        maxY: maxR + rPad,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine:
              (_) => FlLine(color: colors.outline.withOpacity(0.3), strokeWidth: 1),
          getDrawingVerticalLine:
              (_) => FlLine(color: colors.outline.withOpacity(0.3), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              'Reps',
              style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (val, meta) {
                if (val == meta.min || val == meta.max) return const SizedBox.shrink();
                return Text(
                  val.toStringAsFixed(0),
                  style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              'Peso (kg)',
              style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (val, meta) {
                if (val == meta.min || val == meta.max) return const SizedBox.shrink();
                return Text(
                  '${val.toStringAsFixed(0)} kg',
                  style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        scatterTouchData: ScatterTouchData(
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipItems: (spot) {
              return ScatterTooltipItem(
                '${spot.x.toStringAsFixed(1)} kg\n${spot.y.toStringAsFixed(0)} reps',
                textStyle: TextStyle(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
