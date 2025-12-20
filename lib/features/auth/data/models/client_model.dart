import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/client.dart';

part 'client_model.freezed.dart';
part 'client_model.g.dart';

/// Data model for Client - matches API response structure
///
/// Implements immutability via @freezed annotation
/// Provides JSON serialization via json_serializable
/// Extends domain Client entity for use throughout application
@freezed
class ClientModel with _$ClientModel implements Client {
  const factory ClientModel({
    required String id,
    required String email,
    required String name,  // Computed from firstName + lastName
    @JsonKey(name: 'trainer_id') String? trainerId,  // Changed to String to match backend UUID
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    int? age,
    @JsonKey(name: 'weight_kg') double? weightKg,
    @JsonKey(name: 'height_cm') double? heightCm,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    String? gender,
    @JsonKey(name: 'fitness_level') String? fitnessLevel,
    @JsonKey(name: 'health_data_json') String? healthDataJson,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ClientModel;

  // Add a getter for fullName
  const ClientModel._();

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return name;
  }

  // Custom factory from API to compute name from first_name + last_name
  factory ClientModel.fromApi(Map<String, dynamic> json) {
    // Compute name from first_name and last_name if not provided
    final firstName = json['first_name'] as String?;
    final lastName = json['last_name'] as String?;
    final computedName = (firstName != null && lastName != null)
        ? '$firstName $lastName'
        : json['email'] as String? ?? 'Unknown';

    // Add computed name to JSON before passing to generated fromJson
    final modifiedJson = {...json, 'name': computedName};

    return _$ClientModelFromJson(modifiedJson);
  }

  factory ClientModel.fromJson(Map<String, dynamic> json) =>
      _$ClientModelFromJson(json);
}
