import 'workout_exercise.dart';

/// Domain entity representing a complete workout
///
/// A workout contains multiple exercises configured by a trainer
/// and can be assigned to multiple clients.
class Workout {
  final String id;
  final String trainerId;
  final String name;
  final String? description;
  final String? category;
  final String? difficulty; // beginner, intermediate, advanced
  final int? durationMinutes;
  final bool isPublic;
  final bool isActive;
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Workout({
    required this.id,
    required this.trainerId,
    required this.name,
    this.description,
    this.category,
    this.difficulty,
    this.durationMinutes,
    required this.isPublic,
    required this.isActive,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get total exercise count
  int get exerciseCount => exercises.length;

  /// Get total estimated sets
  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets);

  /// Copy with method for creating modified instances
  Workout copyWith({
    String? id,
    String? trainerId,
    String? name,
    String? description,
    String? category,
    String? difficulty,
    int? durationMinutes,
    bool? isPublic,
    bool? isActive,
    List<WorkoutExercise>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workout(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isPublic: isPublic ?? this.isPublic,
      isActive: isActive ?? this.isActive,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Workout(id: $id, name: $name, difficulty: $difficulty, exercises: ${exercises.length}, mins: $durationMinutes)';
}
