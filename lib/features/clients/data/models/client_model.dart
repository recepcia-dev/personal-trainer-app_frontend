import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/client.dart';

part 'client_model.freezed.dart';
part 'client_model.g.dart';

/// Data model for Client - matches API response structure
///
/// Implements immutability via @freezed annotation
/// Provides JSON serialization via json_serializable
/// Implements domain Client entity
@freezed
class ClientModel with _$ClientModel {
  const factory ClientModel({
    required String id,
    @JsonKey(name: 'trainer_id') required String trainerId,
    @JsonKey(name: 'user_id') required String userId,
    required String email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    String? phone,
    int? age,
    @JsonKey(name: 'fitness_level') String? fitnessLevel,
    String? goals,
    String? notes,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ClientModel;

  factory ClientModel.fromJson(Map<String, dynamic> json) =>
      _$ClientModelFromJson(json);

  /// Convert to domain entity
  const ClientModel._();

  Client toEntity() => Client(
    id: id,
    trainerId: trainerId,
    userId: userId,
    email: email,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    age: age,
    fitnessLevel: fitnessLevel,
    goals: goals,
    notes: notes,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Create model from domain entity
  factory ClientModel.fromEntity(Client entity) => ClientModel(
    id: entity.id,
    trainerId: entity.trainerId,
    userId: entity.userId,
    email: entity.email,
    firstName: entity.firstName,
    lastName: entity.lastName,
    phone: entity.phone,
    age: entity.age,
    fitnessLevel: entity.fitnessLevel,
    goals: entity.goals,
    notes: entity.notes,
    isActive: entity.isActive,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}
