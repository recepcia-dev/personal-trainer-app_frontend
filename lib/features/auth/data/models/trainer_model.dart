import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/trainer.dart';

part 'trainer_model.freezed.dart';
part 'trainer_model.g.dart';

/// Data model for Trainer - matches API response structure
///
/// Implements immutability via @freezed annotation
/// Provides JSON serialization via json_serializable
/// Extends domain Trainer entity for use throughout application
@freezed
class TrainerModel with _$TrainerModel implements Trainer {
  const factory TrainerModel({
    required String email,
    required String name,
    String? photoUrl,
    String? firstName,
    String? lastName,
    int? age,
    double? weightKg,
    double? heightCm,
    DateTime? dateOfBirth,
    String? gender,
    String? trainerUniqueCode,  // Unique code for trainers to share with clients
    String? specialty,           // Trainer specialization
    String? bio,                 // Trainer bio
  }) = _TrainerModel;

  factory TrainerModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerModelFromJson(json);
}
