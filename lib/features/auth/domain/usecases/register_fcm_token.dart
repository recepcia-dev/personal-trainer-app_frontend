import 'package:dartz/dartz.dart';
import 'package:personal_trainer_app/core/error/failures.dart';
import 'package:personal_trainer_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for registering the device's FCM token with the backend.
///
/// After receiving an FCM token from Firebase Cloud Messaging,
/// this use case sends it to the backend so the server can use it
/// to send push notifications to this specific device.
class RegisterFcmToken {
  final AuthRepository authRepository;

  RegisterFcmToken(this.authRepository);

  /// Register the FCM token.
  ///
  /// Parameters:
  ///   - fcmToken: The Firebase Cloud Messaging token from Firebase
  ///
  /// Returns:
  ///   - Right(void) on success
  ///   - Left(Failure) if registration fails (ServerFailure, NetworkFailure, etc.)
  ///
  /// Throws nothing - all errors are wrapped in Either type.
  Future<Either<Failure, void>> call(String fcmToken) {
    return authRepository.registerFcmToken(fcmToken);
  }
}
