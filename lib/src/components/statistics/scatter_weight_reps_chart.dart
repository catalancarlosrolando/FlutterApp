import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/helpers/historial_helpers.dart';

class ScatterWeightRepsChart extends StatelessWidget {
  final List<SetPoint> points;

  const ScatterWeightRepsChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (points.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('Aún no hay series para comparar.')),
      );
    }

    final maxWeight = points.fold<double>(
      0,
      (maximum, point) => point.weight > maximum ? point.weight : maximum,
    );
    final maxReps = points.fold<double>(
      0,
      (maximum, point) => point.reps > maximum ? point.reps : maximum,
    );

    return SizedBox(
      height: 220,
      child: ScatterChart(
        ScatterChartData(
          minX: 0,
          maxX: maxWeight * 1.15,
          minY: 0,
          maxY: maxReps * 1.15,
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: colors.outlineVariant, strokeWidth: 0.5),
            getDrawingVerticalLine: (_) =>
                FlLine(color: colors.outlineVariant, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: const AxisTitles(
              axisNameWidget: Text('Peso (kg)'),
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          scatterSpots: [
            for (final point in points)
              ScatterSpot(
                point.weight,
                point.reps,
                dotPainter: FlDotCirclePainter(
                  radius: 4,
                  color: colors.primary,
                  strokeWidth: 1,
                  strokeColor: colors.surface,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
