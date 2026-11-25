import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/statistics/volume_sparkline.dart';
import 'package:flutter_application/src/helpers/historial_helpers.dart';
import 'package:flutter_application/src/pages/statistics_page.dart';
import 'package:flutter_application/src/services/firebase_services.dart';

class HomeStatisticsCard extends StatefulWidget {
  final String uid;
  final String profileId;

  const HomeStatisticsCard({
    super.key,
    required this.uid,
    required this.profileId,
  });

  @override
  State<HomeStatisticsCard> createState() => _HomeStatisticsCardState();
}

class _HomeStatisticsCardState extends State<HomeStatisticsCard> {
  late Stream<List<Map<String, dynamic>>> _historyStream;

  @override
  void initState() {
    super.initState();
    _createHistoryStream();
  }

  @override
  void didUpdateWidget(covariant HomeStatisticsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid ||
        oldWidget.profileId != widget.profileId) {
      _createHistoryStream();
    }
  }

  void _createHistoryStream() {
    _historyStream = streamHistorialSesiones(
      uid: widget.uid,
      profileId: widget.profileId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => StatisticsPage(uid: widget.uid)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _historyStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'No se pudieron cargar tus estadísticas.',
                  style: TextStyle(color: colors.error),
                );
              }

              final sessions = snapshot.data ?? const <Map<String, dynamic>>[];
              final volumes = computeWeeklyVolume(filterByWeeks(sessions, 8));
              final latestVolume = volumes.isEmpty ? 0.0 : volumes.last.volume;
              final variation = computeWeeklyVariationPct(volumes);
              final variationColor = variation == null
                  ? colors.onSurfaceVariant
                  : variation >= 0
                  ? colors.primary
                  : colors.error;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tu progreso',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Ver estadísticas',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: colors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Volumen semanal',
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${latestVolume.toStringAsFixed(0)} kg·reps',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      if (variation != null)
                        Text(
                          '${variation >= 0 ? '+' : ''}${variation.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: variationColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  VolumeSparkline(volumes: volumes, color: colors.primary),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
