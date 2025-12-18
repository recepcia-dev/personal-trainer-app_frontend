import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../models/progress_log_model.dart';

/// Local data source for progress data - handles Drift database operations
abstract class ProgressLocalDataSource {
  /// Get progress logs from local database
  Future<List<ProgressLogModel>> getProgressLogs({String? exerciseId});

  /// Save progress log locally
  Future<ProgressLogModel> saveProgressLog(ProgressLogModel log);

  /// Save multiple progress logs locally
  Future<void> saveProgressLogs(List<ProgressLogModel> logs);

  /// Get unsynced progress logs
  Future<List<ProgressLogModel>> getUnsyncedLogs();

  /// Mark log as synced
  Future<void> markLogAsSynced(String id, String remoteId);

  /// Clear all progress logs
  Future<void> clearProgressLogs();

  /// Check if progress logs exist
  Future<bool> hasProgressLogs();

  /// Get total stats (for offline-first stats)
  Future<Map<String, dynamic>> getLocalStats();

  /// Get exercise history from local cache
  Future<Map<String, dynamic>> getExerciseHistory(String exerciseId);
}

class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  final AppDatabase database;

  ProgressLocalDataSourceImpl({required this.database});

  @override
  Future<List<ProgressLogModel>> getProgressLogs({String? exerciseId}) async {
    late final results;

    if (exerciseId != null) {
      results = await (database.select(database.progressLogsTable)
            ..where((log) => log.exerciseId.equals(exerciseId)))
          .get();
    } else {
      results = await database.select(database.progressLogsTable).get();
    }

    return results.map(_mapToModel).toList();
  }

  @override
  Future<ProgressLogModel> saveProgressLog(ProgressLogModel log) async {
    final id = log.remoteId ?? const Uuid().v4();
    final companion = ProgressLogsTableCompanion(
      remoteId: drift.Value(log.remoteId),
      clientId: drift.Value(log.clientId),
      exerciseId: drift.Value(log.exerciseId),
      setsCompleted: drift.Value(log.setsCompleted),
      repsPerSet: drift.Value(log.repsPerSet),
      weightKg: drift.Value(log.weightKg),
      durationSeconds: drift.Value(log.durationSeconds),
      notes: drift.Value(log.notes),
      isSynced: drift.Value(log.isSynced),
      createdAt: drift.Value(log.createdAt),
      updatedAt: drift.Value(log.updatedAt),
    );

    await database.into(database.progressLogsTable).insert(companion);

    return log.copyWith(id: id);
  }

  @override
  Future<void> saveProgressLogs(List<ProgressLogModel> logs) async {
    await database.batch((batch) {
      batch.insertAll(
        database.progressLogsTable,
        logs.map((log) => ProgressLogsTableCompanion(
          remoteId: drift.Value(log.remoteId),
          clientId: drift.Value(log.clientId),
          exerciseId: drift.Value(log.exerciseId),
          setsCompleted: drift.Value(log.setsCompleted),
          repsPerSet: drift.Value(log.repsPerSet),
          weightKg: drift.Value(log.weightKg),
          durationSeconds: drift.Value(log.durationSeconds),
          notes: drift.Value(log.notes),
          isSynced: drift.Value(log.isSynced),
          createdAt: drift.Value(log.createdAt),
          updatedAt: drift.Value(log.updatedAt),
        )),
      );
    });
  }

  @override
  Future<List<ProgressLogModel>> getUnsyncedLogs() async {
    final results = await (database.select(database.progressLogsTable)
          ..where((log) => log.isSynced.equals(false)))
        .get();
    return results.map(_mapToModel).toList();
  }

  @override
  Future<void> markLogAsSynced(String id, String remoteId) async {
    await (database.update(database.progressLogsTable)
          ..where((log) => log.id.equals(int.parse(id))))
        .write(
      ProgressLogsTableCompanion(
        remoteId: drift.Value(remoteId),
        isSynced: drift.Value(true),
      ),
    );
  }

  @override
  Future<void> clearProgressLogs() async {
    await database.delete(database.progressLogsTable).go();
  }

  @override
  Future<bool> hasProgressLogs() async {
    final count = await database.select(database.progressLogsTable).get();
    return count.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>> getLocalStats() async {
    final logs = await database.select(database.progressLogsTable).get();

    if (logs.isEmpty) {
      return {
        'total_exercises_logged': 0,
        'unique_exercises': 0,
        'total_weight_lifted': 0.0,
        'average_reps_per_set': 0.0,
        'last_logged_at': null,
      };
    }

    final totalExercisesLogged = logs.length;
    final uniqueExercises = logs.map((log) => log.exerciseId).toSet().length;
    final totalWeightLifted = logs
        .fold<double>(0, (sum, log) => sum + ((log.weightKg ?? 0) * log.setsCompleted));
    final averageRepsPerSet =
        logs.fold<double>(0, (sum, log) => sum + log.repsPerSet) / totalExercisesLogged;
    final lastLoggedAt = logs.isNotEmpty ? logs.last.createdAt : null;

    return {
      'total_exercises_logged': totalExercisesLogged,
      'unique_exercises': uniqueExercises,
      'total_weight_lifted': totalWeightLifted,
      'average_reps_per_set': averageRepsPerSet,
      'last_logged_at': lastLoggedAt,
    };
  }

  @override
  Future<Map<String, dynamic>> getExerciseHistory(String exerciseId) async {
    final logs = await (database.select(database.progressLogsTable)
          ..where((log) => log.exerciseId.equals(exerciseId)))
        .get();

    if (logs.isEmpty) {
      return {
        'exercise_id': exerciseId,
        'total_logs': 0,
        'total_volume': 0.0,
        'max_weight': null,
        'average_weight': null,
        'average_reps': 0.0,
        'last_logged_at': null,
      };
    }

    final totalLogs = logs.length;
    final weights = logs.where((log) => log.weightKg != null).map((log) => log.weightKg!).toList();
    final totalVolume = logs.fold<double>(
      0,
      (sum, log) => sum + ((log.weightKg ?? 0) * log.repsPerSet * log.setsCompleted),
    );
    final maxWeight = weights.isNotEmpty ? weights.reduce((a, b) => a > b ? a : b) : null;
    final averageWeight = weights.isNotEmpty ? weights.reduce((a, b) => a + b) / weights.length : null;
    final averageReps = logs.fold<double>(0, (sum, log) => sum + log.repsPerSet) / totalLogs;
    final lastLoggedAt = logs.last.createdAt;

    return {
      'exercise_id': exerciseId,
      'total_logs': totalLogs,
      'total_volume': totalVolume,
      'max_weight': maxWeight,
      'average_weight': averageWeight,
      'average_reps': averageReps,
      'last_logged_at': lastLoggedAt,
    };
  }

  ProgressLogModel _mapToModel(ProgressLogsTableData row) => ProgressLogModel(
    id: row.id.toString(),
    remoteId: row.remoteId,
    clientId: row.clientId,
    exerciseId: row.exerciseId.toString(),
    setsCompleted: row.setsCompleted,
    repsPerSet: row.repsPerSet,
    weightKg: row.weightKg,
    durationSeconds: row.durationSeconds,
    notes: row.notes,
    isSynced: row.isSynced,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
