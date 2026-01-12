import 'package:freezed_annotation/freezed_annotation.dart';
import 'client_model.dart';
import 'trainer_model.dart';

part 'verify_magic_link_response_model.freezed.dart';
part 'verify_magic_link_response_model.g.dart';

/// Response model for magic link verification endpoint
///
/// Contains both authentication tokens and user data (either Trainer or Client).
/// The API returns user data with a 'role' field to determine the user type.
@freezed
class VerifyMagicLinkResponseModel with _$VerifyMagicLinkResponseModel {
  const factory VerifyMagicLinkResponseModel({
    required String accessToken,
    required String refreshToken,
    required String role, // 'trainer' or 'client'
    required Map<String, dynamic> user,
  }) = _VerifyMagicLinkResponseModel;

  factory VerifyMagicLinkResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyMagicLinkResponseModelFromJson(json);
}

/// Extension to parse user data based on role
extension VerifyMagicLinkResponseParsing on VerifyMagicLinkResponseModel {
  /// Returns the user as either TrainerModel or ClientModel based on role
  /// Uses fromApi factory to handle field mapping from API response format
  dynamic parseUser() {
    if (role == 'trainer') {
      return TrainerModel.fromApi(user);
    } else if (role == 'client') {
      return ClientModel.fromApi(user);
    }
    throw ArgumentError('Unknown role: $role');
  }
}
