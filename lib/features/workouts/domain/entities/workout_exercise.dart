/// Domain entity representing an exercise within a workout
///
/// This is the core business model for defining sets, reps, and weight
/// for each exercise in a workout routine.
class WorkoutExercise {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final int orderIndex;
  final int sets;
  final int reps;
  final int? restSeconds;
  final double? weightKg;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkoutExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.orderIndex,
    required this.sets,
    required this.reps,
    this.restSeconds,
    this.weightKg,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Display string for showing exercise summary
  String get displayString => '$sets sets × $reps reps${weightKg != null ? ' @ ${weightKg}kg' : ''}';

  /// Copy with method for creating modified instances
  WorkoutExercise copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    int? orderIndex,
    int? sets,
    int? reps,
    int? restSeconds,
    double? weightKg,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      orderIndex: orderIndex ?? this.orderIndex,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'WorkoutExercise(id: $id, exercise: $exerciseName, order: $orderIndex, sets: $sets, reps: $reps, weight: $weightKg kg)';
}
