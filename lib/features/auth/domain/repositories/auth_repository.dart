import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/client.dart';
import '../entities/trainer.dart';

/// Abstract repository interface for authentication operations
///
/// Defines the contract for all authentication-related operations.
/// Implementations should follow the offline-first pattern and return Either<Failure, T>
/// for proper error handling in the domain layer.
abstract class AuthRepository {
  /// Authenticates a trainer with email and password
  ///
  /// Returns a [Trainer] entity on success
  /// Throws [ServerFailure] if credentials are invalid or server error occurs
  /// Throws [NetworkFailure] if network is unavailable
  Future<Either<Failure, Trainer>> loginTrainer({
    required String email,
    required String password,
  });

  /// Sends a magic link to a client's email for passwordless login
  ///
  /// Used for client authentication flow
  /// Returns void on success (link sent to email)
  /// Throws [ServerFailure] if email not found or server error occurs
  /// Throws [NetworkFailure] if network is unavailable
  Future<Either<Failure, void>> sendMagicLink({
    required String email,
  });

  /// Verifies OTP and authenticates a client
  ///
  /// Called after client receives magic link and enters OTP
  /// Returns a [Client] entity on success
  /// Throws [ServerFailure] if OTP is invalid or expired
  /// Throws [NetworkFailure] if network is unavailable
  Future<Either<Failure, Client>> verifyOtp({
    required String email,
    required String otp,
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
}
