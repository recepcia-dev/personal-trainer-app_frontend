import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_exercise.dart';

/// State for the workout builder
class WorkoutBuilderState {
  final String workoutId;
  final String workoutName;
  final String? category;
  final String? difficulty;
  final int? estimatedMinutes;
  final List<WorkoutExercise> exercises;

  WorkoutBuilderState({
    String? workoutId,
    this.workoutName = '',
    this.category,
    this.difficulty = 'intermediate',
    this.estimatedMinutes = 45,
    this.exercises = const [],
  }) : workoutId = workoutId ?? const Uuid().v4();

  WorkoutBuilderState copyWith({
    String? workoutId,
    String? workoutName,
    String? category,
    String? difficulty,
    int? estimatedMinutes,
    List<WorkoutExercise>? exercises,
  }) {
    return WorkoutBuilderState(
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      exercises: exercises ?? this.exercises,
    );
  }
}

/// Provider for managing workout builder state
class WorkoutBuilderNotifier extends StateNotifier<WorkoutBuilderState> {
  WorkoutBuilderNotifier() : super(WorkoutBuilderState());

  /// Update workout name
  void setWorkoutName(String name) {
    state = state.copyWith(workoutName: name);
  }

  /// Update category
  void setCategory(String? category) {
    state = state.copyWith(category: category);
  }

  /// Update difficulty
  void setDifficulty(String difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  /// Update estimated minutes
  void setEstimatedMinutes(int minutes) {
    state = state.copyWith(estimatedMinutes: minutes);
  }

  /// Add exercise to the workout
  void addExercise({
    required String exerciseId,
    required String exerciseName,
    required int sets,
    required int reps,
    int? restSeconds,
    double? weightKg,
    String? notes,
  }) {
    final newExercise = WorkoutExercise(
      id: const Uuid().v4(),
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      orderIndex: state.exercises.length,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      weightKg: weightKg,
      notes: notes,
    );

    state = state.copyWith(
      exercises: [...state.exercises, newExercise],
    );
  }

  /// Update exercise in the workout
  void updateExercise(String exerciseId, {
    required int sets,
    required int reps,
    int? restSeconds,
    double? weightKg,
    String? notes,
  }) {
    final updated = state.exercises.map((ex) {
      if (ex.id == exerciseId) {
        return ex.copyWith(
          sets: sets,
          reps: reps,
          restSeconds: restSeconds,
          weightKg: weightKg,
          notes: notes,
        );
      }
      return ex;
    }).toList();

    state = state.copyWith(exercises: updated);
  }

  /// Remove exercise from the workout
  void removeExercise(String exerciseId) {
    final filtered = state.exercises
        .where((ex) => ex.id != exerciseId)
        .toList();

    // Re-order exercises
    final reordered = [
      for (var i = 0; i < filtered.length; i++)
        filtered[i].copyWith(orderIndex: i),
    ];

    state = state.copyWith(exercises: reordered);
  }

  /// Reorder exercises
  void reorderExercises(int oldIndex, int newIndex) {
    final exercises = [...state.exercises];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);

    // Update order indices
    final reordered = [
      for (var i = 0; i < exercises.length; i++)
        exercises[i].copyWith(orderIndex: i),
    ];

    state = state.copyWith(exercises: reordered);
  }

  /// Reset builder to create a new workout
  void reset() {
    state = WorkoutBuilderState();
  }

  /// Load an existing workout for editing
  void loadWorkout(Workout workout) {
    state = state.copyWith(
      workoutId: workout.id,
      workoutName: workout.name,
      category: workout.category,
      difficulty: workout.difficulty,
      estimatedMinutes: workout.durationMinutes,
      exercises: workout.exercises,
    );
  }
}

/// Riverpod provider for workout builder
final workoutBuilderProvider = StateNotifierProvider<WorkoutBuilderNotifier, WorkoutBuilderState>((ref) {
  return WorkoutBuilderNotifier();
});

/// Provider to get the complete workout object from the builder state
final workoutFromBuilderProvider = Provider<Workout?>((ref) {
  final builderState = ref.watch(workoutBuilderProvider);
  final user = ref.watch(authStateProvider);

  if (user == null || builderState.workoutName.isEmpty) {
    return null;
  }

  return Workout(
    id: builderState.workoutId,
    trainerId: user.email,
    name: builderState.workoutName,
    category: builderState.category,
    difficulty: builderState.difficulty,
    durationMinutes: builderState.estimatedMinutes,
    isPublic: false,
    isActive: true,
    exercises: builderState.exercises,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
});
