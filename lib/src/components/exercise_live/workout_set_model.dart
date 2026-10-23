/// Model representing a single workout set.
class WorkoutSetItem {
  final int setNumber;
  final String previous;
  double weight;
  int reps;
  bool isCompleted;
  bool isActive;

  WorkoutSetItem({
    required this.setNumber,
    required this.previous,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
    this.isActive = false,
  });

  WorkoutSetItem copyWith({
    int? setNumber,
    String? previous,
    double? weight,
    int? reps,
    bool? isCompleted,
    bool? isActive,
  }) {
    return WorkoutSetItem(
      setNumber: setNumber ?? this.setNumber,
      previous: previous ?? this.previous,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Helper to parse and create sets from exercise data maps
class ExerciseDataParser {
  ExerciseDataParser._();

  static int parseSeconds(dynamic val) {
    if (val == null) return 60;
    final match = RegExp(r'\d+').firstMatch(val.toString());
    return match != null ? (int.tryParse(match.group(0)!) ?? 60) : 60;
  }

  static double parseWeight(dynamic val) {
    if (val == null) return 40.0;
    final match = RegExp(r'[\d.]+').firstMatch(val.toString());
    return match != null ? (double.tryParse(match.group(0)!) ?? 40.0) : 40.0;
  }

  static int parseReps(dynamic val) {
    if (val == null) return 10;
    final match = RegExp(r'\d+').firstMatch(val.toString());
    return match != null ? (int.tryParse(match.group(0)!) ?? 10) : 10;
  }

  static int parseSeriesCount(dynamic val) {
    if (val == null) return 4;
    final match = RegExp(r'\d+').firstMatch(val.toString());
    return match != null ? (int.tryParse(match.group(0)!) ?? 4) : 4;
  }

  static List<WorkoutSetItem> createInitialSets(Map<String, dynamic> exercise) {
    final seriesCount = parseSeriesCount(exercise['series']);
    final defaultWeight = parseWeight(exercise['peso']);
    final defaultReps = parseReps(exercise['reps']);

    return List.generate(seriesCount, (index) {
      final setNum = index + 1;
      return WorkoutSetItem(
        setNumber: setNum,
        previous: '${defaultWeight.toStringAsFixed(1)} kg x $defaultReps',
        weight: defaultWeight,
        reps: defaultReps,
        isCompleted: false,
        isActive: index == 0,
      );
    });
  }
}
