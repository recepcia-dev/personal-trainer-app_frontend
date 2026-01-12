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
    required String id,
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

  // Custom factory from API to compute name from first_name + last_name
  // The API returns first_name and last_name, but the model expects a name field
  // Falls back to name field if present, then email if no name fields provided
  factory TrainerModel.fromApi(Map<String, dynamic> json) {
    // First check if name field already exists (direct API response)
    if (json.containsKey('name') && json['name'] != null) {
      return _$TrainerModelFromJson(json);
    }

    // Otherwise compute name from first_name and last_name
    final firstName = json['first_name'] as String?;
    final lastName = json['last_name'] as String?;
    final computedName = (firstName != null && lastName != null)
        ? '$firstName $lastName'
        : json['email'] as String? ?? 'Unknown';

    // Add computed name to JSON before passing to generated fromJson
    final modifiedJson = {...json, 'name': computedName};

    return _$TrainerModelFromJson(modifiedJson);
  }

  factory TrainerModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerModelFromJson(json);
}
