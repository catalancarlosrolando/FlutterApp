import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/helpers/historial_helpers.dart';

class OrmLineChart extends StatelessWidget {
  final List<SessionORM> sessions;

  const OrmLineChart({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (sessions.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('Aún no hay registros para estimar el 1RM.')),
      );
    }

    final values = sessions.map((session) => session.orm).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final padding = range == 0 ? maxValue * 0.1 : range * 0.15;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (sessions.length - 1).toDouble().clamp(1, double.infinity),
          minY: (minValue - padding).clamp(0, double.infinity),
          maxY: maxValue + padding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue == 0 ? 1 : maxValue / 4,
            getDrawingHorizontalLine: (_) =>
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
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 ||
                      index >= sessions.length ||
                      value != index.toDouble()) {
                    return const SizedBox.shrink();
                  }
                  final date = sessions[index].date;
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      '${date.day}/${date.month}',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var index = 0; index < sessions.length; index++)
                  FlSpot(index.toDouble(), sessions[index].orm),
              ],
              isCurved: true,
              color: colors.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: sessions.length <= 12,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 3,
                      color: colors.primary,
                      strokeWidth: 1,
                      strokeColor: colors.surface,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: colors.primary.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
