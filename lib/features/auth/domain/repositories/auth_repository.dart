import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/client.dart';
import '../entities/trainer.dart';

/// Abstract repository interface for authentication operations
///
/// Implements passwordless, credential-free authentication using magic links
/// combined with device-bound biometric/PIN verification.
///
/// Authentication Flow (Option A - Sequential):
/// 1. User enters email → [sendMagicLink] sends magic link
/// 2. User enters code from email → [verifyMagicLink] validates code
/// 3. Device biometric/PIN → handled in presentation layer (local_auth)
/// 4. On success → User is authenticated
///
/// All methods follow the offline-first pattern and return Either<Failure, T>
/// for proper error handling in the domain layer.
abstract class AuthRepository {
  /// Sends a magic link to the user's email for passwordless authentication
  ///
  /// Works for both trainers and clients. Initiates the authentication flow
  /// by sending a time-limited magic link via email.
  ///
  /// Returns void on success (link sent to email)
  /// Throws [ServerFailure] if email is invalid or server error occurs
  /// Throws [NetworkFailure] if network is unavailable
  Future<Either<Failure, void>> sendMagicLink({
    required String email,
  });

  /// Verifies the magic link code entered by the user
  ///
  /// Called after user receives magic link and enters the verification code.
  /// This is step 2 of the sequential flow. After success, the presentation
  /// layer will prompt for device-bound authentication (biometric/PIN).
  ///
  /// Returns authenticated user ([Trainer] or [Client]) on success
  /// Throws [ServerFailure] if code is invalid, expired, or server error
  /// Throws [NetworkFailure] if network is unavailable
  Future<Either<Failure, dynamic>> verifyMagicLink({
    required String email,
    required String code,
  });

  /// Retrieves the currently authenticated user
  ///
  /// Could return either [Trainer] or [Client] depending on user type
  /// Returns null if no user is currently authenticated
  /// Throws [CacheFailure] if token retrieval from storage fails
  Future<Either<Failure, dynamic>> getCurrentUser();

  /// Logs out the current user
  ///
  /// Clears authentication tokens and user session
  /// Returns void on success
  /// Throws [CacheFailure] if token clearing from storage fails
  Future<Either<Failure, void>> logout();

  /// Binds the current device to the authenticated user's session
  ///
  /// Called after successful biometric/PIN authentication.
  /// Registers this device with the backend to enable device-bound authentication.
  /// Prevents the same token from being used on different devices.
  ///
  /// Returns void on success
  /// Throws [ServerFailure] if device binding fails or server error occurs
  /// Throws [NetworkFailure] if network is unavailable
  /// Throws [CacheFailure] if device ID cannot be retrieved
  Future<Either<Failure, void>> bindDevice();

  /// Registers the device's Firebase Cloud Messaging (FCM) token with the backend
  ///
  /// Called after receiving an FCM token from Firebase Cloud Messaging.
  /// Sends the token to the backend so the server can use it to send
  /// push notifications to this specific device.
  ///
  /// Parameters:
  ///   - fcmToken: The Firebase Cloud Messaging token
  ///
  /// Returns void on success
  /// Throws [ServerFailure] if token registration fails or server error occurs
  /// Throws [NetworkFailure] if network is unavailable
  /// Throws [CacheFailure] if no authenticated user exists
  Future<Either<Failure, void>> registerFcmToken(String fcmToken);
}
