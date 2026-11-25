import 'package:flutter_application/src/helpers/historial_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final history = [
    {
      'createdAt': DateTime(2026, 3, 10),
      'ejercicioId': 'press',
      'ejercicioNombre': 'Press de banca',
      'series': [
        {'weight': 50, 'reps': 10},
        {'weight': 40, 'reps': 0},
      ],
    },
    {
      'createdAt': DateTime(2026, 3, 12),
      'ejercicioId': 'press',
      'ejercicioNombre': 'Press de banca',
      'series': [
        {'weight': 60, 'reps': 5},
      ],
    },
    {
      'createdAt': DateTime(2026, 3, 18),
      'ejercicioId': 'squat',
      'ejercicioNombre': 'Sentadilla',
      'series': [
        {'weight': 100, 'reps': 3},
      ],
    },
  ];

  test('aggregates weekly volume by Monday and sorts weeks', () {
    final volumes = computeWeeklyVolume(history);

    expect(volumes, hasLength(2));
    expect(volumes[0].weekStart, DateTime(2026, 3, 9));
    expect(volumes[0].volume, 800);
    expect(volumes[1].weekStart, DateTime(2026, 3, 16));
    expect(volumes[1].volume, 300);
  });

  test('computes estimated max and valid weight-rep points', () {
    final orm = computeSessionORM(history);
    final points = computeScatterPoints(history);

    expect(orm, hasLength(3));
    expect(orm[0].orm, closeTo(66.67, 0.01));
    expect(orm[1].orm, 70);
    expect(points, hasLength(3));
    expect(points.first.weight, 50);
    expect(points.first.reps, 10);
  });

  test('extracts distinct exercise IDs and labels', () {
    expect(uniqueExerciseIds(history), ['press', 'squat']);
    expect(exerciseNames(history), {
      'press': 'Press de banca',
      'squat': 'Sentadilla',
    });
  });

  test('weekly variation is unavailable when an entire week is missing', () {
    final volumes = [
      WeeklyVolume(weekStart: DateTime(2026, 3, 2), volume: 100),
      WeeklyVolume(weekStart: DateTime(2026, 3, 16), volume: 150),
    ];

    expect(computeWeeklyVariationPct(volumes), isNull);
  });
}
