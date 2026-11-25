// ===========================================================
// weekly_volume_bar_chart.dart
// BarChart — Volumen semanal (Σ weight × reps por semana).
// ===========================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/historial_helpers.dart';

class WeeklyVolumeBarChart extends StatelessWidget {
  final List<WeeklyVolume> data;

  const WeeklyVolumeBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    if (data.isEmpty) {
      return _empty(colors, texts);
    }

    final maxY = data.map((e) => e.volume).reduce((a, b) => a > b ? a : b);
    final barGroups = List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[i].volume,
            color: colors.primary,
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });

    return BarChart(
      BarChartData(
        maxY: maxY * 1.15,
        minY: 0,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4 == 0 ? 1 : maxY / 4,
          getDrawingHorizontalLine:
              (_) => FlLine(color: colors.outline.withOpacity(0.3), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (val, meta) {
                if (val == meta.min || val == meta.max) return const SizedBox.shrink();
                return Text(
                  _formatVol(val),
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (val, meta) {
                final i = val.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                final label = DateFormat('d/M').format(data[i].weekStart);
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final week = DateFormat('d MMM').format(data[group.x].weekStart);
              return BarTooltipItem(
                '$week\n${_formatVol(rod.toY)} kg',
                TextStyle(
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

  String _formatVol(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  Widget _empty(ColorScheme colors, TextTheme texts) {
    return Center(
      child: Text(
        'Sin datos de volumen',
        style: texts.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}
