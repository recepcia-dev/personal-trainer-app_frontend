import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/progress_log.dart';

part 'progress_log_model.freezed.dart';
part 'progress_log_model.g.dart';

/// Data model for ProgressLog - matches API response structure
///
/// Implements immutability via @freezed annotation
/// Provides JSON serialization via json_serializable
/// Implements domain ProgressLog entity
@freezed
class ProgressLogModel with _$ProgressLogModel {
  const factory ProgressLogModel({
    required String id,
    @JsonKey(name: 'remote_id') String? remoteId,
    @JsonKey(name: 'client_id') required String clientId,
    @JsonKey(name: 'exercise_id') required String exerciseId,
    @JsonKey(name: 'sets_completed') required int setsCompleted,
    @JsonKey(name: 'reps_per_set') required int repsPerSet,
    @JsonKey(name: 'weight_kg') double? weightKg,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    String? notes,
    @JsonKey(name: 'is_synced') required bool isSynced,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ProgressLogModel;

  factory ProgressLogModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressLogModelFromJson(json);

  /// Convert to domain entity
  const ProgressLogModel._();

  ProgressLog toEntity() => ProgressLog(
    id: id,
    remoteId: remoteId,
    clientId: clientId,
    exerciseId: exerciseId,
    setsCompleted: setsCompleted,
    repsPerSet: repsPerSet,
    weightKg: weightKg,
    durationSeconds: durationSeconds,
    notes: notes,
    isSynced: isSynced,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Create model from domain entity
  factory ProgressLogModel.fromEntity(ProgressLog entity) => ProgressLogModel(
    id: entity.id,
    remoteId: entity.remoteId,
    clientId: entity.clientId,
    exerciseId: entity.exerciseId,
    setsCompleted: entity.setsCompleted,
    repsPerSet: entity.repsPerSet,
    weightKg: entity.weightKg,
    durationSeconds: entity.durationSeconds,
    notes: entity.notes,
    isSynced: entity.isSynced,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}
