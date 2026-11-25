// ===========================================================
// orm_line_chart.dart
// LineChart — 1RM estimado por sesión + línea de tendencia.
// ===========================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/historial_helpers.dart';

class ORMLineChart extends StatelessWidget {
  final List<SessionORM> data;

  const ORMLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    if (data.isEmpty) {
      return Center(
        child: Text(
          'Sin datos de fuerza',
          style: texts.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      );
    }

    final spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i].orm),
    );

    final trendSpots = _trendLine(spots);

    final allY = spots.map((s) => s.y).toList();
    final minY = allY.reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = allY.reduce((a, b) => a > b ? a : b) * 1.1;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          // Línea de datos reales
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: colors.primary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (spot, pct, bar, idx) => FlDotCirclePainter(
                    radius: 3,
                    color: colors.primary,
                    strokeWidth: 1.5,
                    strokeColor: colors.surface,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: colors.primary.withOpacity(0.08),
            ),
          ),
          // Línea de tendencia
          if (trendSpots.length >= 2)
            LineChartBarData(
              spots: trendSpots,
              isCurved: false,
              color: colors.primary.withOpacity(0.45),
              barWidth: 1.5,
              dashArray: [6, 4],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine:
              (_) => FlLine(color: colors.outline.withOpacity(0.3), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (val, meta) {
                if (val == meta.min || val == meta.max) return const SizedBox.shrink();
                return Text(
                  '${val.toStringAsFixed(0)} kg',
                  style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: (data.length / 5).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (val, meta) {
                final i = val.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('d/M').format(data[i].date),
                    style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((s) {
                // Solo mostrar tooltip en la línea de datos (index 0)
                if (s.barIndex != 0) {
                  return LineTooltipItem('', const TextStyle());
                }
                final i = s.spotIndex;
                final date = DateFormat('d MMM').format(data[i].date);
                return LineTooltipItem(
                  '$date\n${s.y.toStringAsFixed(1)} kg',
                  TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  /// Regresión lineal simple sobre los spots para dibujar la línea de tendencia.
  List<FlSpot> _trendLine(List<FlSpot> spots) {
    if (spots.length < 2) return [];
    final n = spots.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (final s in spots) {
      sumX += s.x;
      sumY += s.y;
      sumXY += s.x * s.y;
      sumX2 += s.x * s.x;
    }
    final denom = n * sumX2 - sumX * sumX;
    if (denom == 0) return [];
    final slope = (n * sumXY - sumX * sumY) / denom;
    final intercept = (sumY - slope * sumX) / n;
    return [
      FlSpot(spots.first.x, slope * spots.first.x + intercept),
      FlSpot(spots.last.x, slope * spots.last.x + intercept),
    ];
  }
}
