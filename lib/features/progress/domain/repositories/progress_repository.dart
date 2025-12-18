import 'package:fpdart/fpdart.dart';

import '../../../../core/failure.dart';
import '../entities/progress_log.dart';

/// Progress statistics data transfer object
class ProgressStats {
  final int totalExercisesLogged;
  final int uniqueExercises;
  final double totalWeightLifted;
  final double averageRepsPerSet;
  final DateTime? lastLoggedAt;

  ProgressStats({
    required this.totalExercisesLogged,
    required this.uniqueExercises,
    required this.totalWeightLifted,
    required this.averageRepsPerSet,
    this.lastLoggedAt,
  });
}

/// Exercise history data transfer object
class ExerciseHistory {
  final String exerciseId;
  final String exerciseName;
  final int totalLogs;
  final double totalVolume;
  final double? maxWeight;
  final double? averageWeight;
  final double averageReps;
  final DateTime? lastLoggedAt;

  ExerciseHistory({
    required this.exerciseId,
    required this.exerciseName,
    required this.totalLogs,
    required this.totalVolume,
    this.maxWeight,
    this.averageWeight,
    required this.averageReps,
    this.lastLoggedAt,
  });
}

/// Progress repository interface - defines contract for progress data operations
abstract class ProgressRepository {
  /// Log an exercise completion
  Future<Either<Failure, ProgressLog>> logExercise(
    String exerciseId,
    int setsCompleted,
    int repsPerSet, {
    double? weightKg,
    int? durationSeconds,
    String? notes,
  });

  /// Get user's progress logs (from local cache, fallback to remote)
  Future<Either<Failure, List<ProgressLog>>> getProgressLogs({
    String? exerciseId,
  });

  /// Get local progress logs (offline-first)
  Future<Either<Failure, List<ProgressLog>>> getLocalProgressLogs({
    String? exerciseId,
  });

  /// Get progress statistics for current user
  Future<Either<Failure, ProgressStats>> getProgressStats();

  /// Get exercise history for specific exercise
  Future<Either<Failure, ExerciseHistory>> getExerciseHistory(String exerciseId);

  /// Sync local progress logs with backend
  Future<Either<Failure, int>> syncProgressLogs();

  /// Save progress log locally
  Future<Either<Failure, void>> saveProgressLogLocally(ProgressLog log);

  /// Save multiple progress logs locally
  Future<Either<Failure, void>> saveProgressLogsLocally(List<ProgressLog> logs);
}
