import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/progress_log.dart';

/// Represents logged data for a single exercise in a workout
class ExerciseLog {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final int prescribedSets;
  final int prescribedReps;
  final double? prescribedWeightKg;
  late int completedSets;
  late int completedReps;
  late double? completedWeightKg;
  bool isCompleted;

  ExerciseLog({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.prescribedSets,
    required this.prescribedReps,
    this.prescribedWeightKg,
  })  : completedSets = prescribedSets,
        completedReps = prescribedReps,
        completedWeightKg = prescribedWeightKg,
        isCompleted = false;
}

/// State for workout execution
class WorkoutExecutionState {
  final String workoutId;
  final String workoutName;
  final int estimatedMinutes;
  final List<ExerciseLog> exercises;
  final int completedCount;
  final DateTime startedAt;

  WorkoutExecutionState({
    required this.workoutId,
    required this.workoutName,
    required this.estimatedMinutes,
    required this.exercises,
    this.completedCount = 0,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  WorkoutExecutionState copyWith({
    String? workoutId,
    String? workoutName,
    int? estimatedMinutes,
    List<ExerciseLog>? exercises,
    int? completedCount,
    DateTime? startedAt,
  }) {
    return WorkoutExecutionState(
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      exercises: exercises ?? this.exercises,
      completedCount: completedCount ?? this.completedCount,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  /// Calculate elapsed time in minutes
  int get elapsedMinutes {
    return DateTime.now().difference(startedAt).inMinutes;
  }

  /// Get completion percentage
  double get completionPercentage {
    if (exercises.isEmpty) return 0;
    return (completedCount / exercises.length) * 100;
  }

  /// Check if all exercises are completed
  bool get allCompleted => completedCount == exercises.length;
}

/// Provider for managing workout execution
class WorkoutExecutionNotifier extends StateNotifier<WorkoutExecutionState> {
  WorkoutExecutionNotifier({
    required String workoutId,
    required String workoutName,
    required int estimatedMinutes,
    required List<Map<String, dynamic>> exercises,
  }) : super(
    WorkoutExecutionState(
      workoutId: workoutId,
      workoutName: workoutName,
      estimatedMinutes: estimatedMinutes,
      exercises: exercises
          .asMap()
          .entries
          .map(
            (entry) => ExerciseLog(
              id: const Uuid().v4(),
              exerciseId: entry.value['id'] ?? 'unknown',
              exerciseName: entry.value['name'] ?? 'Unnamed',
              prescribedSets: entry.value['sets'] ?? 3,
              prescribedReps: entry.value['reps'] ?? 10,
              prescribedWeightKg: entry.value['weight'],
            ),
          )
          .toList(),
    ),
  );

  /// Update exercise completion data
  void updateExercise(
    String exerciseId, {
    required int sets,
    required int reps,
    double? weightKg,
    required bool isCompleted,
  }) {
    final updatedExercises = state.exercises.map((ex) {
      if (ex.id == exerciseId) {
        ex.completedSets = sets;
        ex.completedReps = reps;
        ex.completedWeightKg = weightKg;
        ex.isCompleted = isCompleted;
      }
      return ex;
    }).toList();

    final newCompletedCount = updatedExercises.where((ex) => ex.isCompleted).length;
    state = state.copyWith(
      exercises: updatedExercises,
      completedCount: newCompletedCount,
    );
  }

  /// Toggle exercise completion status
  void toggleExerciseCompletion(String exerciseId) {
    final exercise = state.exercises.firstWhere((ex) => ex.id == exerciseId);
    updateExercise(
      exerciseId,
      sets: exercise.completedSets,
      reps: exercise.completedReps,
      weightKg: exercise.completedWeightKg,
      isCompleted: !exercise.isCompleted,
    );
  }

  /// Get all completed progress logs
  List<ProgressLog> getCompletedLogs(String clientId) {
    return state.exercises
        .where((ex) => ex.isCompleted)
        .map(
          (ex) => ProgressLog(
            id: const Uuid().v4(),
            clientId: clientId,
            exerciseId: ex.exerciseId,
            setsCompleted: ex.completedSets,
            repsPerSet: ex.completedReps,
            weightKg: ex.completedWeightKg,
            isSynced: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        )
        .toList();
  }

  /// Check if all exercises are completed
  bool get allCompleted => state.completedCount == state.exercises.length;
}

/// Create a family provider for workout execution
final workoutExecutionProvider = StateNotifierProvider.family<
    WorkoutExecutionNotifier,
    WorkoutExecutionState,
    ({
      String workoutId,
      String workoutName,
      int estimatedMinutes,
      List<Map<String, dynamic>> exercises,
    })>((ref, args) {
  return WorkoutExecutionNotifier(
    workoutId: args.workoutId,
    workoutName: args.workoutName,
    estimatedMinutes: args.estimatedMinutes,
    exercises: args.exercises,
  );
});
