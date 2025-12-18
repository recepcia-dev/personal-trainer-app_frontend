import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/exercise.dart';

part 'exercise_model.freezed.dart';
part 'exercise_model.g.dart';

/// Data model for Exercise - matches API response structure
///
/// Implements immutability via @freezed annotation
/// Provides JSON serialization via json_serializable
/// Implements domain Exercise entity
@freezed
class ExerciseModel with _$ExerciseModel {
  const factory ExerciseModel({
    required String id,
    required String name,
    required String category,
    String? description,
    @JsonKey(name: 'muscle_group') String? muscleGroup,
    String? equipment,
    @JsonKey(name: 'video_url') String? videoUrl,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ExerciseModel;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  /// Convert to domain entity
  const ExerciseModel._();

  Exercise toEntity() => Exercise(
    id: id,
    name: name,
    category: category,
    description: description,
    muscleGroup: muscleGroup,
    equipment: equipment,
    videoUrl: videoUrl,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Create model from domain entity
  factory ExerciseModel.fromEntity(Exercise entity) => ExerciseModel(
    id: entity.id,
    name: entity.name,
    category: entity.category,
    description: entity.description,
    muscleGroup: entity.muscleGroup,
    equipment: entity.equipment,
    videoUrl: entity.videoUrl,
    isActive: entity.isActive,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}
