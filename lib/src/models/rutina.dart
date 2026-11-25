import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de una serie individual contenida en el array `series` de un ejercicio.
class ExerciseSet {
  final int setNumber;
  final int reps;
  final double weigth;

  const ExerciseSet({
    required this.setNumber,
    required this.reps,
    required this.weigth,
  });

  factory ExerciseSet.fromMap(Map<String, dynamic> map, [int fallbackSetNumber = 1]) {
    return ExerciseSet(
      setNumber: (map['set'] ?? map['setNumber'] as num?)?.toInt() ?? fallbackSetNumber,
      reps: (map['reps'] as num?)?.toInt() ?? int.tryParse(map['reps']?.toString() ?? '') ?? 10,
      weigth: (map['peso'] ?? map['weight'] ?? map['weigth'] as num?)?.toDouble() ??
          double.tryParse(RegExp(r'[\d.]+').firstMatch(map['peso']?.toString() ?? map['weight']?.toString() ?? '')?.group(0) ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'set': setNumber,
      'reps': reps,
      'peso': weigth,
      'weight': weigth,
      'weigth': weigth,
    };
  }
}

/// Modelo de un ejercicio contenido en el array `ejercicios` de una rutina.
class Exercise {
  final String id;
  final String name;
  final String image;
  final String time;
  final String description;
  final bool completed;
  final int? series;
  final List<ExerciseSet> seriesList;
  final int? reps;
  final double? weigth;
  final int? rest;

  const Exercise({
    required this.id,
    required this.name,
    this.image = '',
    this.time = '',
    this.description = '',
    this.completed = false,
    this.series,
    this.seriesList = const [],
    this.reps,
    this.weigth,
    this.rest,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    final rawSeries = map['series'];
    List<ExerciseSet> sList = [];
    int? sCount;
    if (rawSeries is List) {
      sList = rawSeries.asMap().entries.map((e) {
        final val = e.value is Map<String, dynamic>
            ? e.value as Map<String, dynamic>
            : (e.value is Map ? Map<String, dynamic>.from(e.value as Map) : <String, dynamic>{});
        return ExerciseSet.fromMap(val, e.key + 1);
      }).toList();
      sCount = sList.length;
    } else if (rawSeries is num) {
      sCount = rawSeries.toInt();
    } else if (rawSeries is String) {
      sCount = int.tryParse(rawSeries);
    }

    return Exercise(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      image: (map['image'] as String?) ?? '',
      time: (map['tiempo'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      completed: (map['finalizado'] as bool?) ?? false,
      series: sCount,
      seriesList: sList,
      reps: (map['reps'] as num?)?.toInt() ?? int.tryParse(map['reps']?.toString() ?? ''),
      weigth: (map['peso'] as num?)?.toDouble() ?? (map['weigth'] as num?)?.toDouble(),
      rest: (map['descanso'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'tiempo': time,
      'description': description,
      'finalizado': completed,
      'series': seriesList.isNotEmpty
          ? seriesList.map((s) => s.toMap()).toList()
          : (series ?? 0),
      if (reps != null) 'reps': reps,
      if (weigth != null) 'peso': weigth,
      if (rest != null) 'descanso': rest,
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? image,
    String? time,
    String? description,
    bool? completed,
    int? series,
    List<ExerciseSet>? seriesList,
    int? reps,
    double? weigth,
    int? rest,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      time: time ?? this.time,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      series: series ?? this.series,
      seriesList: seriesList ?? this.seriesList,
      reps: reps ?? this.reps,
      weigth: weigth ?? this.weigth,
      rest: rest ?? this.rest,
    );
  }
}

/// Modelo de rutina almacenado en `users/{uid}/perfiles/{profileId}/rutinas/{rutinaId}`.
/// Cada rutina contiene un array `ejercicios` de tipo `List<Map<String, dynamic>>`.
class Rutina {
  final String id;
  final String category;
  final String name;
  final String description;
  final String image;
  final String time;
  final bool completed;
  final List<Exercise> exercises;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Rutina({
    required this.id,
    this.category = 'push',
    required this.name,
    this.description = '',
    this.image = '',
    this.time = '',
    this.completed = false,
    this.exercises = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Rutina.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Rutina.fromMap(doc.id, data);
  }

  factory Rutina.fromMap(String id, Map<String, dynamic> map) {
    final rawEjercicios = map['ejercicios'] ?? map['exercises'];
    final List<Exercise> exercises;
    if (rawEjercicios is List) {
      exercises = rawEjercicios
          .whereType<Map<String, dynamic>>()
          .map(Exercise.fromMap)
          .toList();
    } else {
      exercises = const [];
    }

    return Rutina(
      id: id,
      category: (map['category'] as String?) ?? 'push',
      name: (map['name'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      image: (map['image'] as String?) ?? '',
      time: (map['time'] as String?) ?? '',
      completed: (map['completed'] as bool?) ?? false,
      exercises: exercises,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'name': name,
      'description': description,
      'image': image,
      'time': time,
      'completed': completed,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Rutina copyWith({
    String? id,
    String? category,
    String? name,
    String? description,
    String? image,
    String? time,
    bool? completed,
    List<Exercise>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rutina(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      time: time ?? this.time,
      completed: completed ?? this.completed,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
