import 'package:fpdart/fpdart.dart';

import '../../../../core/failure.dart';
import '../entities/progress_log.dart';
import '../repositories/progress_repository.dart';

/// Use case to log an exercise
class LogExerciseUseCase {
  final ProgressRepository repository;

  LogExerciseUseCase({required this.repository});

  Future<Either<Failure, ProgressLog>> call({
    required String exerciseId,
    required int setsCompleted,
    required int repsPerSet,
    double? weightKg,
    int? durationSeconds,
    String? notes,
  }) {
    return repository.logExercise(
      exerciseId,
      setsCompleted,
      repsPerSet,
      weightKg: weightKg,
      durationSeconds: durationSeconds,
      notes: notes,
    );
  }
}

/// Use case to get progress logs
class GetProgressLogsUseCase {
  final ProgressRepository repository;

  GetProgressLogsUseCase({required this.repository});

  Future<Either<Failure, List<ProgressLog>>> call({String? exerciseId}) {
    return repository.getProgressLogs(exerciseId: exerciseId);
  }
}

/// Use case to get progress statistics
class GetProgressStatsUseCase {
  final ProgressRepository repository;

  GetProgressStatsUseCase({required this.repository});

  Future<Either<Failure, ProgressStats>> call() {
    return repository.getProgressStats();
  }
}

/// Use case to get exercise history
class GetExerciseHistoryUseCase {
  final ProgressRepository repository;

  GetExerciseHistoryUseCase({required this.repository});

  Future<Either<Failure, ExerciseHistory>> call(String exerciseId) {
    return repository.getExerciseHistory(exerciseId);
  }
}

/// Use case to sync progress logs
class SyncProgressLogsUseCase {
  final ProgressRepository repository;

  SyncProgressLogsUseCase({required this.repository});

  Future<Either<Failure, int>> call() {
    return repository.syncProgressLogs();
  }
}
