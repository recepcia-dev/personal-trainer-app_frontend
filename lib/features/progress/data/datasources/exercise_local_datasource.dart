import 'package:drift/drift.dart' as drift;

import '../../../../database/app_database.dart';
import '../models/exercise_model.dart';

/// Local data source for exercise data - handles Drift database operations
abstract class ExerciseLocalDataSource {
  /// Get all exercises from local database
  Future<List<ExerciseModel>> getExercises({
    String? category,
    String? muscleGroup,
  });

  /// Get single exercise by remote ID
  Future<ExerciseModel?> getExerciseById(String remoteId);

  /// Cache exercises to local database
  Future<void> cacheExercises(List<ExerciseModel> exercises);

  /// Clear all exercises from cache
  Future<void> clearExercises();

  /// Check if exercises exist in cache
  Future<bool> hasExercises();
}

class ExerciseLocalDataSourceImpl implements ExerciseLocalDataSource {
  final AppDatabase database;

  ExerciseLocalDataSourceImpl({required this.database});

  @override
  Future<List<ExerciseModel>> getExercises({
    String? category,
    String? muscleGroup,
  }) async {
    // Apply all filters
    late final results;

    if (category != null && muscleGroup != null) {
      results = await (database.select(database.exercisesTable)
            ..where((ex) =>
                ex.isActive.equals(true) &
                ex.category.equals(category) &
                ex.muscleGroup.equals(muscleGroup)))
          .get();
    } else if (category != null) {
      results = await (database.select(database.exercisesTable)
            ..where((ex) =>
                ex.isActive.equals(true) & ex.category.equals(category)))
          .get();
    } else if (muscleGroup != null) {
      results = await (database.select(database.exercisesTable)
            ..where((ex) =>
                ex.isActive.equals(true) &
                ex.muscleGroup.equals(muscleGroup)))
          .get();
    } else {
      results = await (database.select(database.exercisesTable)
            ..where((ex) => ex.isActive.equals(true)))
          .get();
    }
    return results
        .map((row) => ExerciseModel(
          id: row.remoteId,
          name: row.name,
          category: row.category,
          description: row.description,
          muscleGroup: row.muscleGroup,
          equipment: row.equipment,
          videoUrl: row.videoUrl,
          isActive: row.isActive,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        ))
        .toList();
  }

  @override
  Future<ExerciseModel?> getExerciseById(String remoteId) async {
    final result = await (database.select(database.exercisesTable)
          ..where((ex) => ex.remoteId.equals(remoteId)))
        .getSingleOrNull();

    if (result == null) return null;

    return ExerciseModel(
      id: result.remoteId,
      name: result.name,
      category: result.category,
      description: result.description,
      muscleGroup: result.muscleGroup,
      equipment: result.equipment,
      videoUrl: result.videoUrl,
      isActive: result.isActive,
      createdAt: result.createdAt,
      updatedAt: result.updatedAt,
    );
  }

  @override
  Future<void> cacheExercises(List<ExerciseModel> exercises) async {
    await database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        database.exercisesTable,
        exercises.map((ex) => ExercisesTableCompanion(
          remoteId: drift.Value(ex.id),
          name: drift.Value(ex.name),
          category: drift.Value(ex.category),
          description: drift.Value(ex.description),
          muscleGroup: drift.Value(ex.muscleGroup),
          equipment: drift.Value(ex.equipment),
          videoUrl: drift.Value(ex.videoUrl),
          isActive: drift.Value(ex.isActive),
          isSynced: drift.Value(true),
          createdAt: drift.Value(ex.createdAt),
          updatedAt: drift.Value(ex.updatedAt),
        )),
      );
    });
  }

  @override
  Future<void> clearExercises() async {
    await database.delete(database.exercisesTable).go();
  }

  @override
  Future<bool> hasExercises() async {
    final count = await database.select(database.exercisesTable).get();
    return count.isNotEmpty;
  }
}
