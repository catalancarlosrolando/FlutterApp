import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/statistics/orm_line_chart.dart';
import 'package:flutter_application/src/components/statistics/scatter_weight_reps_chart.dart';
import 'package:flutter_application/src/components/statistics/weekly_volume_bar_chart.dart';
import 'package:flutter_application/src/helpers/historial_helpers.dart';
import 'package:flutter_application/src/services/firebase_services.dart';

class StatisticsPage extends StatefulWidget {
  final String uid;

  const StatisticsPage({super.key, required this.uid});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int? _selectedWeeks = 12;
  String? _selectedExerciseId;
  late final Stream<String?> _activeProfileStream;
  final Map<String, Stream<List<Map<String, dynamic>>>> _historyStreams = {};

  @override
  void initState() {
    super.initState();
    _activeProfileStream = streamPerfilActivoId(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: StreamBuilder<String?>(
        stream: _activeProfileStream,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.hasError) {
            return _message(
              'No se pudo obtener el perfil activo.',
              color: colors.error,
            );
          }
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profileId = profileSnapshot.data;
          if (profileId == null || profileId.isEmpty) {
            return _message('No hay un perfil activo para mostrar.');
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _historyStreams.putIfAbsent(
              profileId,
              () => streamHistorialSesiones(
                uid: widget.uid,
                profileId: profileId,
              ),
            ),
            builder: (context, historySnapshot) {
              if (historySnapshot.hasError) {
                return _message(
                  'No se pudo cargar el historial de entrenamiento.',
                  color: colors.error,
                );
              }
              if (historySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return _buildStatistics(
                context,
                historySnapshot.data ?? const [],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatistics(
    BuildContext context,
    List<Map<String, dynamic>> history,
  ) {
    final colors = Theme.of(context).colorScheme;
    final filteredHistory = filterByWeeks(history, _selectedWeeks);
    final exerciseIds = uniqueExerciseIds(history);
    final names = exerciseNames(history);
    final exerciseHistory = _selectedExerciseId == null
        ? filteredHistory
        : filterByExercise(filteredHistory, _selectedExerciseId!);
    final weeklyVolumes = computeWeeklyVolume(exerciseHistory);
    final ormSessions = computeSessionORM(exerciseHistory);
    final setPoints = computeScatterPoints(exerciseHistory);
    final totalVolume = weeklyVolumes.fold<double>(
      0,
      (total, week) => total + week.volume,
    );
    final totalSets = exerciseHistory.fold<int>(
      0,
      (total, session) => total + _seriesCount(session),
    );
    final totalMinutes = exerciseHistory.fold<int>(
      0,
      (total, session) =>
          total + (_toNumber(session['duracionSegundos']).toInt() ~/ 60),
    );
    final latestOrm = ormSessions.isEmpty
        ? null
        : ormSessions
              .map((session) => session.orm)
              .reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Tu entrenamiento, en números',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _rangeChip('4 semanas', 4),
            _rangeChip('12 semanas', 12),
            _rangeChip('Todo', null),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedExerciseId ?? '',
          decoration: const InputDecoration(
            labelText: 'Ejercicio',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            const DropdownMenuItem(value: '', child: Text('Todos')),
            for (final id in exerciseIds)
              DropdownMenuItem(value: id, child: Text(names[id] ?? id)),
          ],
          onChanged: (value) => setState(
            () => _selectedExerciseId = value == null || value.isEmpty
                ? null
                : value,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.65,
          children: [
            _MetricCard(
              label: 'Sesiones',
              value: '${exerciseHistory.length}',
              icon: Icons.fitness_center,
            ),
            _MetricCard(
              label: 'Volumen total',
              value: '${totalVolume.toStringAsFixed(0)} kg·reps',
              icon: Icons.bar_chart,
            ),
            _MetricCard(
              label: 'Series',
              value: '$totalSets',
              icon: Icons.repeat,
            ),
            _MetricCard(
              label: 'Tiempo',
              value: '$totalMinutes min',
              icon: Icons.timer_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Volumen semanal',
          subtitle: 'Peso × repeticiones',
          child: WeeklyVolumeBarChart(volumes: weeklyVolumes),
        ),
        _ChartCard(
          title: 'Progreso de fuerza',
          subtitle: latestOrm == null
              ? '1RM estimado por sesión'
              : '1RM estimado · máximo ${latestOrm.toStringAsFixed(1)} kg',
          child: OrmLineChart(sessions: ormSessions),
        ),
        _ChartCard(
          title: 'Peso y repeticiones',
          subtitle: 'Cada punto representa una serie registrada',
          child: ScatterWeightRepsChart(points: setPoints),
        ),
      ],
    );
  }

  Widget _rangeChip(String label, int? weeks) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedWeeks == weeks,
      onSelected: (_) => setState(() => _selectedWeeks = weeks),
    );
  }

  Widget _message(String message, {Color? color}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: color),
        ),
      ),
    );
  }

  int _seriesCount(Map<String, dynamic> session) {
    final series = session['series'];
    return series is List ? series.length : 0;
  }

  double _toNumber(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: colors.primary, size: 20),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
