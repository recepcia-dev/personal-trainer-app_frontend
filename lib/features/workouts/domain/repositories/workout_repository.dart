import '../entities/workout.dart';

/// Repository interface for workout data operations
abstract class WorkoutRepository {
  /// Fetch all workouts with pagination
  Future<List<Workout>> fetchWorkouts({
    int skip = 0,
    int limit = 50,
    String? category,
    String? difficulty,
  });

  /// Get workouts from local cache
  Future<List<Workout>> getLocalWorkouts({
    int skip = 0,
    int limit = 50,
  });

  /// Get single workout by ID
  Future<Workout?> getWorkoutById(String id);

  /// Create new workout
  Future<Workout> createWorkout({
    required String name,
    String? description,
    String? category,
    String? difficulty,
    int? durationMinutes,
    bool isPublic = false,
  });

  /// Update existing workout
  Future<Workout> updateWorkout(
    String id, {
    String? name,
    String? description,
    String? category,
    String? difficulty,
    int? durationMinutes,
    bool? isPublic,
    bool? isActive,
  });

  /// Delete workout (soft delete)
  Future<void> deleteWorkout(String id);

  /// Cache workouts to local database
  Future<void> cacheWorkouts(List<Workout> workouts);

  /// Get workout assignments for a client
  Future<List<WorkoutAssignment>> getClientAssignments(String clientId);

  /// Get assignments for a trainer's workout
  Future<List<WorkoutAssignment>> getWorkoutAssignments(String workoutId);

  /// Assign workout to client
  Future<WorkoutAssignment> assignWorkout({
    required String workoutId,
    required String clientId,
    DateTime? startsAt,
    DateTime? endsAt,
    String? notes,
  });

  /// Update workout assignment
  Future<WorkoutAssignment> updateAssignment(
    String assignmentId, {
    DateTime? startsAt,
    DateTime? endsAt,
    bool? isCompleted,
    String? notes,
  });

  /// Mark assignment as completed
  Future<WorkoutAssignment> completeAssignment(String assignmentId);
}
