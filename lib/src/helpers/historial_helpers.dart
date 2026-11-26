// ===========================================================
// historial_helpers.dart
// Funciones puras para transformar el historial de sesiones
// en datos listos para los 3 gráficos de fl_chart.
// ===========================================================

import 'package:cloud_firestore/cloud_firestore.dart';

// ── Tipos de salida ──────────────────────────────────────────

/// Un punto del BarChart (volumen semanal).
class WeeklyVolume {
  final DateTime weekStart; // lunes de esa semana
  final double volume; // Σ weight × reps
  WeeklyVolume({required this.weekStart, required this.volume});
}

/// Un punto del LineChart (1RM estimado por sesión).
class SessionORM {
  final DateTime date;
  final double orm; // max(weight × (1 + reps/30))
  SessionORM({required this.date, required this.orm});
}

/// Un punto del ScatterChart (peso vs reps de una serie).
class SetPoint {
  final double weight;
  final double reps;
  SetPoint({required this.weight, required this.reps});
}

// ── Helpers internos ─────────────────────────────────────────

DateTime _weekStart(DateTime d) {
  // lunes de la semana
  return DateTime(d.year, d.month, d.day - (d.weekday - 1));
}

DateTime _sessionDate(Map<String, dynamic> sesion) {
  final raw = sesion['createdAt'];
  if (raw is Timestamp) return raw.toDate();
  if (raw is DateTime) return raw;
  return DateTime.now();
}

List<Map<String, dynamic>> _parseSeries(Map<String, dynamic> sesion) {
  final raw = sesion['series'];
  if (raw is List) {
    return raw.cast<Map<String, dynamic>>();
  }
  return [];
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

// ── Filtros por rango de fecha ────────────────────────────────

/// Filtra el historial a las últimas [weeks] semanas.
/// Pasa [weeks] = null para obtener todo el historial.
List<Map<String, dynamic>> filterByWeeks(
  List<Map<String, dynamic>> historial,
  int? weeks,
) {
  if (weeks == null) return historial;
  final cutoff = DateTime.now().subtract(Duration(days: weeks * 7));
  return historial.where((s) {
    final d = _sessionDate(s);
    return d.isAfter(cutoff);
  }).toList();
}

/// Filtra el historial a un ejercicio concreto.
List<Map<String, dynamic>> filterByExercise(
  List<Map<String, dynamic>> historial,
  String ejercicioId,
) {
  return historial.where((s) => s['ejercicioId'] == ejercicioId).toList();
}

// ── Transformaciones ─────────────────────────────────────────

/// Volumen semanal: Σ weight × reps, agrupado por semana (lunes).
List<WeeklyVolume> computeWeeklyVolume(List<Map<String, dynamic>> historial) {
  final map = <DateTime, double>{};

  for (final sesion in historial) {
    final week = _weekStart(_sessionDate(sesion));
    double vol = 0;
    for (final serie in _parseSeries(sesion)) {
      vol += _toDouble(serie['weight']) * _toDouble(serie['reps']);
    }
    map[week] = (map[week] ?? 0) + vol;
  }

  final result =
      map.entries
          .map((e) => WeeklyVolume(weekStart: e.key, volume: e.value))
          .toList()
        ..sort((a, b) => a.weekStart.compareTo(b.weekStart));

  return result;
}

/// 1RM estimado (Epley): max(weight × (1 + reps/30)) por sesión.
List<SessionORM> computeSessionORM(List<Map<String, dynamic>> historial) {
  final result = <SessionORM>[];

  for (final sesion in historial) {
    final date = _sessionDate(sesion);
    double maxORM = 0;
    for (final serie in _parseSeries(sesion)) {
      final w = _toDouble(serie['weight']);
      final r = _toDouble(serie['reps']);
      if (r > 0) {
        final orm = w * (1 + r / 30);
        if (orm > maxORM) maxORM = orm;
      }
    }
    if (maxORM > 0) {
      result.add(SessionORM(date: date, orm: maxORM));
    }
  }

  result.sort((a, b) => a.date.compareTo(b.date));
  return result;
}

/// Scatter: todos los puntos (weight, reps) de las series del historial.
List<SetPoint> computeScatterPoints(List<Map<String, dynamic>> historial) {
  final result = <SetPoint>[];
  for (final sesion in historial) {
    for (final serie in _parseSeries(sesion)) {
      final w = _toDouble(serie['weight']);
      final r = _toDouble(serie['reps']);
      if (w > 0 && r > 0) result.add(SetPoint(weight: w, reps: r));
    }
  }
  return result;
}

/// Variación de volumen entre la última semana y la anterior.
/// Retorna p.ej. +12.3 o -8.0 (porcentaje). null si no hay datos.
double? computeWeeklyVariationPct(List<WeeklyVolume> volumes) {
  if (volumes.length < 2) return null;
  final latest = volumes[volumes.length - 1];
  final previous = volumes[volumes.length - 2];
  if (latest.weekStart.difference(previous.weekStart).inDays != 7) return null;
  final last = latest.volume;
  final prev = previous.volume;
  if (prev == 0) return null;
  return ((last - prev) / prev) * 100;
}

/// Retorna los ids únicos de ejercicios en el historial.
List<String> uniqueExerciseIds(List<Map<String, dynamic>> historial) {
  final seen = <String>{};
  final ids = <String>[];
  for (final s in historial) {
    final id = s['ejercicioId'] as String? ?? '';
    if (id.isNotEmpty && seen.add(id)) ids.add(id);
  }
  return ids;
}

/// Retorna un Map de id -> nombre de ejercicio.
Map<String, String> exerciseNames(List<Map<String, dynamic>> historial) {
  final map = <String, String>{};
  for (final s in historial) {
    final id = s['ejercicioId'] as String? ?? '';
    final nombre = s['ejercicioNombre'] as String? ?? id;
    if (id.isNotEmpty) map[id] = nombre;
  }
  return map;
}

/// Retorna la URL de imagen de un ejercicio dado su id.
String? exerciseImage(List<Map<String, dynamic>> historial, String id) {
  for (final s in historial) {
    if (s['ejercicioId'] == id) {
      return s['ejercicioImage'] as String?;
    }
  }
  return null;
}
