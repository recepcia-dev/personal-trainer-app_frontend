import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/progress_log.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';
import '../datasources/progress_remote_datasource.dart';
import '../models/progress_log_model.dart';

/// Progress repository implementation with offline-first pattern
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressRemoteDataSource remoteDataSource;
  final ProgressLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProgressRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProgressLog>> logExercise(
    String exerciseId,
    int setsCompleted,
    int repsPerSet, {
    double? weightKg,
    int? durationSeconds,
    String? notes,
  }) async {
    // Create local log immediately for offline-first
    final localLog = ProgressLogModel(
      id: const Uuid().v4(),
      remoteId: null,
      clientId: '', // Will be set by the provider
      exerciseId: exerciseId,
      setsCompleted: setsCompleted,
      repsPerSet: repsPerSet,
      weightKg: weightKg,
      durationSeconds: durationSeconds,
      notes: notes,
      isSynced: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // Save locally first
      final savedLog = await localDataSource.saveProgressLog(localLog);

      // Try to sync with remote if connected
      if (await networkInfo.isConnected) {
        try {
          final remoteLog = await remoteDataSource.logExercise(
            exerciseId: exerciseId,
            setsCompleted: setsCompleted,
            repsPerSet: repsPerSet,
            weightKg: weightKg,
            durationSeconds: durationSeconds,
            notes: notes,
          );

          // Update local with remote ID and sync status
          await localDataSource.markLogAsSynced(savedLog.id, remoteLog.id);

          return Right(remoteLog.toEntity());
        } catch (e) {
          // Remote sync failed, but local save succeeded
          return Right(savedLog.toEntity());
        }
      }

      return Right(savedLog.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to log exercise: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProgressLog>>> getProgressLogs({
    String? exerciseId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Fetch from remote
        final remoteLogs = await remoteDataSource.fetchProgressLogs(
          exerciseId: exerciseId,
        );

        // Cache locally
        await localDataSource.saveProgressLogs(remoteLogs);

        return Right(remoteLogs.map((m) => m.toEntity()).toList());
      } catch (e) {
        // Fallback to local
        return _getLocalProgressLogs(exerciseId: exerciseId);
      }
    } else {
      // Offline: use local
      return _getLocalProgressLogs(exerciseId: exerciseId);
    }
  }

  @override
  Future<Either<Failure, List<ProgressLog>>> getLocalProgressLogs({
    String? exerciseId,
  }) async {
    return _getLocalProgressLogs(exerciseId: exerciseId);
  }

  @override
  Future<Either<Failure, ProgressStats>> getProgressStats() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteStats = await remoteDataSource.getProgressStats();
        return Right(ProgressStats(
          totalExercisesLogged: remoteStats['total_exercises_logged'] ?? 0,
          uniqueExercises: remoteStats['unique_exercises'] ?? 0,
          totalWeightLifted: (remoteStats['total_weight_lifted'] ?? 0).toDouble(),
          averageRepsPerSet: (remoteStats['average_reps_per_set'] ?? 0).toDouble(),
          lastLoggedAt: remoteStats['last_logged_at'] != null
              ? DateTime.parse(remoteStats['last_logged_at'])
              : null,
        ));
      } catch (e) {
        // Fallback to local stats
        return _getLocalStats();
      }
    } else {
      return _getLocalStats();
    }
  }

  @override
  Future<Either<Failure, ExerciseHistory>> getExerciseHistory(String exerciseId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteHistory = await remoteDataSource.getExerciseHistory(exerciseId);
        return Right(ExerciseHistory(
          exerciseId: remoteHistory['exercise_id'],
          exerciseName: remoteHistory['exercise_name'],
          totalLogs: remoteHistory['total_logs'] ?? 0,
          totalVolume: (remoteHistory['total_volume'] ?? 0).toDouble(),
          maxWeight: remoteHistory['max_weight']?.toDouble(),
          averageWeight: remoteHistory['average_weight']?.toDouble(),
          averageReps: (remoteHistory['average_reps'] ?? 0).toDouble(),
          lastLoggedAt: remoteHistory['last_logged_at'] != null
              ? DateTime.parse(remoteHistory['last_logged_at'])
              : null,
        ));
      } catch (e) {
        // Fallback to local history
        return _getLocalExerciseHistory(exerciseId);
      }
    } else {
      return _getLocalExerciseHistory(exerciseId);
    }
  }

  @override
  Future<Either<Failure, int>> syncProgressLogs() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final unsyncedLogs = await localDataSource.getUnsyncedLogs();
      int syncedCount = 0;

      for (final log in unsyncedLogs) {
        try {
          final remoteLog = await remoteDataSource.logExercise(
            exerciseId: log.exerciseId,
            setsCompleted: log.setsCompleted,
            repsPerSet: log.repsPerSet,
            weightKg: log.weightKg,
            durationSeconds: log.durationSeconds,
            notes: log.notes,
          );

          await localDataSource.markLogAsSynced(log.id, remoteLog.id);
          syncedCount++;
        } catch (e) {
          // Continue syncing other logs
          continue;
        }
      }

      return Right(syncedCount);
    } catch (e) {
      return Left(ServerFailure('Failed to sync logs: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveProgressLogLocally(ProgressLog log) async {
    try {
      final model = ProgressLogModel.fromEntity(log);
      await localDataSource.saveProgressLog(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save locally: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveProgressLogsLocally(
      List<ProgressLog> logs) async {
    try {
      final models = logs.map((l) => ProgressLogModel.fromEntity(l)).toList();
      await localDataSource.saveProgressLogs(models);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save logs locally: $e'));
    }
  }

  Future<Either<Failure, List<ProgressLog>>> _getLocalProgressLogs({
    String? exerciseId,
  }) async {
    try {
      final localLogs = await localDataSource.getProgressLogs(exerciseId: exerciseId);
      return Right(localLogs.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get local logs: $e'));
    }
  }

  Future<Either<Failure, ProgressStats>> _getLocalStats() async {
    try {
      final stats = await localDataSource.getLocalStats();
      return Right(ProgressStats(
        totalExercisesLogged: stats['total_exercises_logged'] ?? 0,
        uniqueExercises: stats['unique_exercises'] ?? 0,
        totalWeightLifted: (stats['total_weight_lifted'] ?? 0).toDouble(),
        averageRepsPerSet: (stats['average_reps_per_set'] ?? 0).toDouble(),
        lastLoggedAt: stats['last_logged_at'],
      ));
    } catch (e) {
      return Left(CacheFailure('Failed to get local stats: $e'));
    }
  }

  Future<Either<Failure, ExerciseHistory>> _getLocalExerciseHistory(
      String exerciseId) async {
    try {
      final history = await localDataSource.getExerciseHistory(exerciseId);
      return Right(ExerciseHistory(
        exerciseId: history['exercise_id'],
        exerciseName: history['exercise_name'] ?? 'Unknown',
        totalLogs: history['total_logs'] ?? 0,
        totalVolume: (history['total_volume'] ?? 0).toDouble(),
        maxWeight: history['max_weight']?.toDouble(),
        averageWeight: history['average_weight']?.toDouble(),
        averageReps: (history['average_reps'] ?? 0).toDouble(),
        lastLoggedAt: history['last_logged_at'],
      ));
    } catch (e) {
      return Left(CacheFailure('Failed to get exercise history: $e'));
    }
  }
}
