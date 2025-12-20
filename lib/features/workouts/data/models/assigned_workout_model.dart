import 'package:freezed_annotation/freezed_annotation.dart';

part 'assigned_workout_model.freezed.dart';
part 'assigned_workout_model.g.dart';

/// Model for workout assigned to a client
@freezed
class AssignedWorkoutModel with _$AssignedWorkoutModel {
  const factory AssignedWorkoutModel({
    required String id,
    @JsonKey(name: 'workout_id') required String workoutId,
    @JsonKey(name: 'workout_name') required String workoutName,
    int? sets,
    int? reps,
    @JsonKey(name: 'weight_kg') double? weightKg,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'rest_seconds') int? restSeconds,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    String? notes,
    @JsonKey(name: 'is_active') required int isActive,
  }) = _AssignedWorkoutModel;

  factory AssignedWorkoutModel.fromJson(Map<String, dynamic> json) =>
      _$AssignedWorkoutModelFromJson(json);
}
