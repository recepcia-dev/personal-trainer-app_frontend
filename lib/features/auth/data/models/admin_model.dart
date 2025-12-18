import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/admin.dart';

part 'admin_model.freezed.dart';
part 'admin_model.g.dart';

/// Data model for Admin - matches API response structure
///
/// Implements immutability via @freezed annotation
/// Provides JSON serialization via json_serializable
/// Extends domain Admin entity for use throughout application
@freezed
class AdminModel with _$AdminModel implements Admin {
  const factory AdminModel({
    required String email,
    required String name,
    String? firstName,
    String? lastName,
    int? age,
    double? weightKg,
    double? heightCm,
    DateTime? dateOfBirth,
    String? gender,
  }) = _AdminModel;

  factory AdminModel.fromJson(Map<String, dynamic> json) =>
      _$AdminModelFromJson(json);
}
