import 'package:drift/drift.dart' as drift;

import '../../../../database/app_database.dart';
import '../models/workout_model.dart';

/// Local data source for workout data - handles Drift database operations
abstract class WorkoutLocalDataSource {
  /// Get all workouts from local database
  Future<List<WorkoutModel>> getWorkouts({int skip = 0, int limit = 50});

  /// Get single workout by ID
  Future<WorkoutModel?> getWorkoutById(String id);

  /// Cache workouts to local database
  Future<void> cacheWorkouts(List<WorkoutModel> workouts);

  /// Save single workout locally
  Future<void> saveWorkout(WorkoutModel workout);

  /// Update workout locally
  Future<void> updateWorkout(WorkoutModel workout);

  /// Clear all workouts from cache
  Future<void> clearWorkouts();

  /// Check if workouts exist in cache
  Future<bool> hasWorkouts();
}

class WorkoutLocalDataSourceImpl implements WorkoutLocalDataSource {
  final AppDatabase database;

  WorkoutLocalDataSourceImpl({required this.database});

  @override
  Future<List<WorkoutModel>> getWorkouts({
    int skip = 0,
    int limit = 50,
  }) async {
    final results = await (database.select(database.workoutsTable)
          ..limit(limit, offset: skip))
        .get();

    return results
        .map((row) => WorkoutModel(
          id: row.remoteId,
          trainerId: row.trainerId,
          name: row.name,
          description: row.description,
          category: row.category,
          difficulty: row.difficulty,
          durationMinutes: row.durationMinutes,
          isPublic: row.isPublic,
          isActive: row.isActive,
          createdAt: row.createdAt ?? DateTime.now(),
          updatedAt: row.updatedAt ?? DateTime.now(),
        ))
        .toList();
  }

  @override
  Future<WorkoutModel?> getWorkoutById(String id) async {
    final result = await (database.select(database.workoutsTable)
          ..where((w) => w.remoteId.equals(id)))
        .getSingleOrNull();

    if (result == null) return null;

    return WorkoutModel(
      id: result.remoteId,
      trainerId: result.trainerId,
      name: result.name,
      description: result.description,
      category: result.category,
      difficulty: result.difficulty,
      durationMinutes: result.durationMinutes,
      isPublic: result.isPublic,
      isActive: result.isActive,
      createdAt: result.createdAt ?? DateTime.now(),
      updatedAt: result.updatedAt ?? DateTime.now(),
    );
  }

  @override
  Future<void> cacheWorkouts(List<WorkoutModel> workouts) async {
    await database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        database.workoutsTable,
        workouts.map((workout) => WorkoutsTableCompanion(
          remoteId: drift.Value(workout.id),
          trainerId: drift.Value(workout.trainerId),
          name: drift.Value(workout.name),
          description: drift.Value(workout.description),
          category: drift.Value(workout.category),
          difficulty: drift.Value(workout.difficulty),
          durationMinutes: drift.Value(workout.durationMinutes),
          isPublic: drift.Value(workout.isPublic),
          isActive: drift.Value(workout.isActive),
          isSynced: drift.Value(true),
          createdAt: drift.Value(workout.createdAt),
          updatedAt: drift.Value(workout.updatedAt),
        )),
      );
    });
  }

  @override
  Future<void> saveWorkout(WorkoutModel workout) async {
    await database.into(database.workoutsTable).insert(
      WorkoutsTableCompanion(
        remoteId: drift.Value(workout.id),
        trainerId: drift.Value(workout.trainerId),
        name: drift.Value(workout.name),
        description: drift.Value(workout.description),
        category: drift.Value(workout.category),
        difficulty: drift.Value(workout.difficulty),
        durationMinutes: drift.Value(workout.durationMinutes),
        isPublic: drift.Value(workout.isPublic),
        isActive: drift.Value(workout.isActive),
        isSynced: drift.Value(true),
        createdAt: drift.Value(workout.createdAt),
        updatedAt: drift.Value(workout.updatedAt),
      ),
      mode: drift.InsertMode.insertOrReplace,
    );
  }

  @override
  Future<void> updateWorkout(WorkoutModel workout) async {
    await (database.update(database.workoutsTable)
          ..where((w) => w.remoteId.equals(workout.id)))
        .write(
      WorkoutsTableCompanion(
        name: drift.Value(workout.name),
        description: drift.Value(workout.description),
        category: drift.Value(workout.category),
        difficulty: drift.Value(workout.difficulty),
        durationMinutes: drift.Value(workout.durationMinutes),
        isPublic: drift.Value(workout.isPublic),
        isActive: drift.Value(workout.isActive),
        updatedAt: drift.Value(workout.updatedAt),
      ),
    );
  }

  @override
  Future<void> clearWorkouts() async {
    await database.delete(database.workoutsTable).go();
  }

  @override
  Future<bool> hasWorkouts() async {
    final count = await database.select(database.workoutsTable).get();
    return count.isNotEmpty;
  }
}
