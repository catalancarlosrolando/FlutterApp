import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/helpers/historial_helpers.dart';

class WeeklyVolumeBarChart extends StatelessWidget {
  final List<WeeklyVolume> volumes;

  const WeeklyVolumeBarChart({super.key, required this.volumes});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (volumes.isEmpty) {
      return const _ChartMessage('Todavía no hay volumen registrado.');
    }

    final maxVolume = volumes.fold<double>(
      0,
      (maximum, week) => week.volume > maximum ? week.volume : maximum,
    );

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxVolume == 0 ? 1 : maxVolume * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: true),
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
                  if (index < 0 || index >= volumes.length) {
                    return const SizedBox.shrink();
                  }
                  final date = volumes[index].weekStart;
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
          barGroups: [
            for (var index = 0; index < volumes.length; index++)
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: volumes[index].volume,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                    color: colors.primary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ChartMessage extends StatelessWidget {
  final String message;

  const _ChartMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 120, child: Center(child: Text(message)));
  }
}
