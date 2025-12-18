import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/workout.dart';

part 'workout_model.freezed.dart';
part 'workout_model.g.dart';

/// Data model for Workout - matches API response structure
@freezed
class WorkoutModel with _$WorkoutModel {
  const factory WorkoutModel({
    required String id,
    @JsonKey(name: 'trainer_id') required String trainerId,
    required String name,
    String? description,
    String? category,
    String? difficulty,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'is_public') required bool isPublic,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _WorkoutModel;

  factory WorkoutModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutModelFromJson(json);

  const WorkoutModel._();

  /// Convert to domain entity
  Workout toEntity() => Workout(
    id: id,
    trainerId: trainerId,
    name: name,
    description: description,
    category: category,
    difficulty: difficulty,
    durationMinutes: durationMinutes,
    isPublic: isPublic,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

/// Data model for Workout Assignment
@freezed
class WorkoutAssignmentModel with _$WorkoutAssignmentModel {
  const factory WorkoutAssignmentModel({
    required String id,
    @JsonKey(name: 'workout_id') required String workoutId,
    @JsonKey(name: 'client_id') required String clientId,
    @JsonKey(name: 'assigned_by') required String assignedBy,
    @JsonKey(name: 'assigned_at') required DateTime assignedAt,
    @JsonKey(name: 'starts_at') DateTime? startsAt,
    @JsonKey(name: 'ends_at') DateTime? endsAt,
    @JsonKey(name: 'is_completed') required bool isCompleted,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _WorkoutAssignmentModel;

  factory WorkoutAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutAssignmentModelFromJson(json);

  const WorkoutAssignmentModel._();

  /// Convert to domain entity
  WorkoutAssignment toEntity() => WorkoutAssignment(
    id: id,
    workoutId: workoutId,
    clientId: clientId,
    assignedBy: assignedBy,
    assignedAt: assignedAt,
    startsAt: startsAt,
    endsAt: endsAt,
    isCompleted: isCompleted,
    completedAt: completedAt,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
