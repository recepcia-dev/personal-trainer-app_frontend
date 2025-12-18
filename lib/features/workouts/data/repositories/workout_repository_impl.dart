import '../../../../core/network/network_info.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_assignment.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_local_datasource.dart';
import '../datasources/workout_remote_datasource.dart';
import '../models/workout_model.dart';

/// Repository implementation with offline-first pattern
class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource remoteDataSource;
  final WorkoutLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WorkoutRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Workout>> fetchWorkouts({
    int skip = 0,
    int limit = 50,
    String? category,
    String? difficulty,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.fetchWorkouts(
          skip: skip,
          limit: limit,
          category: category,
          difficulty: difficulty,
        );
        await localDataSource.cacheWorkouts(models);
        return models.map((m) => m.toEntity()).toList();
      } catch (_) {
        return _getLocalWorkouts(skip: skip, limit: limit);
      }
    }
    return _getLocalWorkouts(skip: skip, limit: limit);
  }

  @override
  Future<List<Workout>> getLocalWorkouts({
    int skip = 0,
    int limit = 50,
  }) {
    return _getLocalWorkouts(skip: skip, limit: limit);
  }

  Future<List<Workout>> _getLocalWorkouts({
    int skip = 0,
    int limit = 50,
  }) async {
    final models = await localDataSource.getWorkouts(skip: skip, limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Workout?> getWorkoutById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getWorkoutById(id);
        await localDataSource.saveWorkout(model);
        return model.toEntity();
      } catch (_) {
        return _getLocalWorkoutById(id);
      }
    }
    return _getLocalWorkoutById(id);
  }

  Future<Workout?> _getLocalWorkoutById(String id) async {
    final model = await localDataSource.getWorkoutById(id);
    return model?.toEntity();
  }

  @override
  Future<Workout> createWorkout({
    required String name,
    String? description,
    String? category,
    String? difficulty,
    int? durationMinutes,
    bool isPublic = false,
  }) async {
    final model = await remoteDataSource.createWorkout(
      name: name,
      description: description,
      category: category,
      difficulty: difficulty,
      durationMinutes: durationMinutes,
      isPublic: isPublic,
    );
    await localDataSource.saveWorkout(model);
    return model.toEntity();
  }

  @override
  Future<Workout> updateWorkout(
    String id, {
    String? name,
    String? description,
    String? category,
    String? difficulty,
    int? durationMinutes,
    bool? isPublic,
    bool? isActive,
  }) async {
    final model = await remoteDataSource.updateWorkout(
      id,
      name: name,
      description: description,
      category: category,
      difficulty: difficulty,
      durationMinutes: durationMinutes,
      isPublic: isPublic,
      isActive: isActive,
    );
    await localDataSource.updateWorkout(model);
    return model.toEntity();
  }

  @override
  Future<void> deleteWorkout(String id) async {
    await remoteDataSource.deleteWorkout(id);
  }

  @override
  Future<void> cacheWorkouts(List<Workout> workouts) async {
    final models = workouts
        .map((w) => WorkoutModel(
          id: w.id,
          trainerId: w.trainerId,
          name: w.name,
          description: w.description,
          category: w.category,
          difficulty: w.difficulty,
          durationMinutes: w.durationMinutes,
          isPublic: w.isPublic,
          isActive: w.isActive,
          createdAt: w.createdAt,
          updatedAt: w.updatedAt,
        ))
        .toList();
    await localDataSource.cacheWorkouts(models);
  }

  @override
  Future<List<WorkoutAssignment>> getClientAssignments(String clientId) async {
    final models = await remoteDataSource.getAssignments(clientId: clientId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<WorkoutAssignment>> getWorkoutAssignments(String workoutId) async {
    final models = await remoteDataSource.getAssignments(workoutId: workoutId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<WorkoutAssignment> assignWorkout({
    required String workoutId,
    required String clientId,
    DateTime? startsAt,
    DateTime? endsAt,
    String? notes,
  }) async {
    final model = await remoteDataSource.assignWorkout(
      workoutId: workoutId,
      clientId: clientId,
      startsAt: startsAt,
      endsAt: endsAt,
      notes: notes,
    );
    return model.toEntity();
  }

  @override
  Future<WorkoutAssignment> updateAssignment(
    String assignmentId, {
    DateTime? startsAt,
    DateTime? endsAt,
    bool? isCompleted,
    String? notes,
  }) async {
    final model = await remoteDataSource.updateAssignment(
      assignmentId,
      startsAt: startsAt,
      endsAt: endsAt,
      isCompleted: isCompleted,
      notes: notes,
    );
    return model.toEntity();
  }

  @override
  Future<WorkoutAssignment> completeAssignment(String assignmentId) async {
    return updateAssignment(assignmentId, isCompleted: true);
  }
}
