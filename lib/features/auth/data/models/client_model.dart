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
    required String email,
    required String name,
    required int trainerId,
  }) = _ClientModel;

  factory ClientModel.fromJson(Map<String, dynamic> json) =>
      _$ClientModelFromJson(json);
}
