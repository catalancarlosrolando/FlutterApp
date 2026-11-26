import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/helpers/historial_helpers.dart';

class VolumeSparkline extends StatelessWidget {
  final List<WeeklyVolume> volumes;
  final Color color;

  const VolumeSparkline({
    super.key,
    required this.volumes,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (volumes.length < 2) {
      return const SizedBox(
        height: 46,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Entrená para ver tu progreso semanal.'),
        ),
      );
    }

    final maximum = volumes.fold<double>(
      0,
      (current, volume) => volume.volume > current ? volume.volume : current,
    );

    return SizedBox(
      height: 46,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (volumes.length - 1).toDouble(),
          minY: 0,
          maxY: maximum == 0 ? 1 : maximum * 1.1,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var index = 0; index < volumes.length; index++)
                  FlSpot(index.toDouble(), volumes[index].volume),
              ],
              isCurved: true,
              color: color,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
