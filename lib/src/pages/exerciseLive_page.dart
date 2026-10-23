import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/exercise_live/dialogs/exercise_live_dialogs.dart';
import 'package:flutter_application/src/components/exercise_live/exercise_details_expansion_card.dart';
import 'package:flutter_application/src/components/exercise_live/exercise_sets_table.dart';
import 'package:flutter_application/src/components/exercise_live/plate_calculator_dialog.dart';
import 'package:flutter_application/src/components/exercise_live/rest_timer_card.dart';
import 'package:flutter_application/src/components/exercise_live/workout_live_header.dart';
import 'package:flutter_application/src/components/exercise_live/workout_set_model.dart';

/// Screen representing US-05 Modo Entrenamiento en Vivo y Rest Timer (Node ID: u5Scr)
/// Clean, modular, and styled using Material 3 ColorScheme from Theme.of(context).colorScheme
class ExerciseLivePage extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseLivePage({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseLivePage> createState() => _ExerciseLivePageState();
}

class _ExerciseLivePageState extends State<ExerciseLivePage> {
  // Exercise live timer state
  bool _isWorkoutStarted = false;
  int _workoutElapsedSeconds = 0;
  Timer? _workoutTimer;

  // Rest timer state
  late int _restTotalSeconds;
  late int _restSecondsRemaining;
  bool _isRestRunning = false;
  Timer? _restTimer;

  // Haptic state
  bool _isHapticOn = true;

  // Sets calculated from parameters
  late List<WorkoutSetItem> _sets;

  @override
  void initState() {
    super.initState();
    _initDataFromExercise();
  }

  void _initDataFromExercise() {
    _restTotalSeconds = ExerciseDataParser.parseSeconds(widget.exercise['descanso']);
    _restSecondsRemaining = _restTotalSeconds;
    _sets = ExerciseDataParser.createInitialSets(widget.exercise);
  }

  void _startWorkout() {
    setState(() => _isWorkoutStarted = true);

    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _workoutElapsedSeconds++);
      }
    });
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() => _isRestRunning = true);

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_restSecondsRemaining > 0 && _isRestRunning) {
        setState(() => _restSecondsRemaining--);
      } else {
        // Rest finished, reset clock back to initial rest time
        setState(() {
          _isRestRunning = false;
          _restSecondsRemaining = _restTotalSeconds;
        });
        timer.cancel();
      }
    });
  }

  /// Si el usuario termina el descanso antes, el reloj vuelve atrás al tiempo inicial de descanso
  void _resetOrSkipRest() {
    _restTimer?.cancel();
    setState(() {
      _isRestRunning = false;
      _restSecondsRemaining = _restTotalSeconds;
    });
  }

  void _adjustRestTime(int deltaSeconds) {
    setState(() {
      _restSecondsRemaining += deltaSeconds;
      if (_restSecondsRemaining < 0) _restSecondsRemaining = 0;
    });
  }

  void _toggleHaptic() {
    setState(() => _isHapticOn = !_isHapticOn);
  }

  void _handleToggleSet(int index) {
    setState(() {
      final current = _sets[index];
      current.isCompleted = !current.isCompleted;

      if (current.isCompleted) {
        current.isActive = false;
        final nextIndex = _sets.indexWhere((s) => !s.isCompleted);
        if (nextIndex != -1) {
          for (int i = 0; i < _sets.length; i++) {
            _sets[i].isActive = (i == nextIndex);
          }
        }
      } else {
        current.isActive = true;
      }
    });
  }

  void _handleAddSet() {
    setState(() {
      final lastSet = _sets.isNotEmpty ? _sets.last : null;
      final newSetNumber = _sets.length + 1;
      final newWeight = lastSet?.weight ?? 40.0;
      final newReps = lastSet?.reps ?? 10;

      _sets.add(
        WorkoutSetItem(
          setNumber: newSetNumber,
          previous: '${newWeight.toStringAsFixed(1)} kg x $newReps',
          weight: newWeight,
          reps: newReps,
          isCompleted: false,
          isActive: !_sets.any((s) => s.isActive && !s.isCompleted),
        ),
      );
    });
  }

  Future<void> _openPlateCalculator() async {
    final activeSet = _sets.firstWhere(
      (s) => s.isActive,
      orElse: () => _sets.first,
    );

    final appliedWeight = await PlateCalculatorDialog.show(
      context,
      initialWeight: activeSet.weight,
    );

    if (appliedWeight != null && mounted) {
      setState(() => activeSet.weight = appliedWeight);
    }
  }

  Future<void> _editWeight(int index) async {
    final newWeight = await EditWeightDialog.show(
      context,
      initialWeight: _sets[index].weight,
    );

    if (newWeight != null && mounted) {
      setState(() => _sets[index].weight = newWeight);
    }
  }

  Future<void> _editReps(int index) async {
    final newReps = await EditRepsDialog.show(
      context,
      initialReps: _sets[index].reps,
    );

    if (newReps != null && mounted) {
      setState(() => _sets[index].reps = newReps);
    }
  }

  Future<void> _handleHeaderAction() async {
    if (!_isWorkoutStarted) {
      _startWorkout();
      return;
    }

    final confirmed = await ConfirmFinishDialog.show(
      context,
      completedSets: _sets.where((s) => s.isCompleted).length,
      totalSets: _sets.length,
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  String _formatWorkoutElapsed() {
    if (!_isWorkoutStarted) {
      return 'DURACIÓN • ${widget.exercise['tiempo'] ?? "15 Min"}';
    }
    final mins = (_workoutElapsedSeconds ~/ 60).toString();
    final secs = (_workoutElapsedSeconds % 60).toString().padLeft(2, '0');
    return 'EN VIVO • $mins:$secs MIN';
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final exercise = widget.exercise;

    final activeSet = _sets.firstWhere(
      (s) => s.isActive,
      orElse: () => _sets.firstWhere((s) => !s.isCompleted, orElse: () => _sets.last),
    );

    final nextSetText = 'Siguiente: Serie ${activeSet.setNumber} con ${activeSet.weight.toStringAsFixed(1)} kg';
    final exerciseName = exercise['name'] ?? 'Ejercicio';
    final exerciseDescanso = exercise['descanso'] ?? '60 seg';

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Live Workout (Node u5Header)
              WorkoutLiveHeader(
                title: exerciseName,
                liveText: _formatWorkoutElapsed(),
                actionText: _isWorkoutStarted ? 'Finalizar' : 'Iniciar',
                isWorkoutActive: _isWorkoutStarted,
                onActionPressed: _handleHeaderAction,
                showBackButton: true,
                onBackPressed: () => Navigator.of(context).maybePop(),
              ),

              const SizedBox(height: 18),

              // 2. Rest Timer Card (Node u5TimerOverlayCard)
              RestTimerCard(
                title: 'DESCANSO • ${exerciseName.toUpperCase()}',
                secondsRemaining: _restSecondsRemaining,
                totalSeconds: _restTotalSeconds,
                nextSetText: nextSetText,
                hapticText: _isHapticOn ? 'Vibración On' : 'Vibración Off',
                isHapticActive: _isHapticOn,
                isTimerRunning: _isRestRunning,
                onToggleHaptic: _toggleHaptic,
                onMinus15: () => _adjustRestTime(-15),
                onPlus30: () => _adjustRestTime(30),
                onStartRest: _startRestTimer,
                onResetOrSkipRest: _resetOrSkipRest,
              ),

              const SizedBox(height: 18),

              // 3. Ejercicio 1 Live Table (Node u5Ex1Sec)
              ExerciseSetsTable(
                exerciseName: '1. $exerciseName',
                exerciseSubtitle: '${_sets.length} series • ${exercise['reps'] ?? "10-12"} reps • Descanso $exerciseDescanso',
                accessoryButtonText: 'Discos',
                accessoryIcon: Icons.calculate_outlined,
                onAccessoryPressed: _openPlateCalculator,
                sets: _sets,
                onToggleSet: _handleToggleSet,
                onTapWeight: _editWeight,
                onTapReps: _editReps,
                onAddSet: _handleAddSet,
              ),

              const SizedBox(height: 18),

              // 4. Detalle / Preview del Ejercicio (Node u5Ex2Sec)
              ExerciseDetailsExpansionCard(
                estimatedTime: exercise['tiempo'] ?? '15 Minutos',
                imagePath: exercise['image'] as String?,
                description: exercise['description'] as String?,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
