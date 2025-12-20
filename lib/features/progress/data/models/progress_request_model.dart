import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_request_model.freezed.dart';
part 'progress_request_model.g.dart';

/// Request model for registering workout progress
@freezed
class ProgressRequestModel with _$ProgressRequestModel {
  const factory ProgressRequestModel({
    @JsonKey(name: 'workout_assignment_id') String? workoutAssignmentId,
    @JsonKey(name: 'sets_completed') int? setsCompleted,
    @JsonKey(name: 'reps_completed') int? repsCompleted,
    @JsonKey(name: 'weight_kg_used') double? weightKgUsed,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    String? notes,
    @JsonKey(name: 'difficulty_rating') int? difficultyRating,
  }) = _ProgressRequestModel;

  factory ProgressRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressRequestModelFromJson(json);
}

/// Response model for progress entry
@freezed
class ProgressEntryModel with _$ProgressEntryModel {
  const factory ProgressEntryModel({
    required String id,
    @JsonKey(name: 'workout_assignment_id') String? workoutAssignmentId,
    @JsonKey(name: 'sets_completed') int? setsCompleted,
    @JsonKey(name: 'reps_completed') int? repsCompleted,
    @JsonKey(name: 'weight_kg_used') double? weightKgUsed,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    String? notes,
    @JsonKey(name: 'difficulty_rating') int? difficultyRating,
    @JsonKey(name: 'recorded_at') required DateTime recordedAt,
  }) = _ProgressEntryModel;

  factory ProgressEntryModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressEntryModelFromJson(json);
}
