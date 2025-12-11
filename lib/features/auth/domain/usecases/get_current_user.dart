import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for retrieving the currently authenticated user
///
/// Completes the authentication flow:
/// 1. User enters email → [SendMagicLink] sends magic link to email
/// 2. User enters code from email → [VerifyMagicLink] validates code
/// 3. User authenticates locally with device → Local biometric/PIN (presentation layer)
/// 4. Retrieve authenticated user → [GetCurrentUser] returns user info (THIS STEP)
///
/// Returns authenticated user (Trainer or Client) on success
/// Returns null if no user is currently authenticated
/// Returns [ServerFailure] if server error occurs
/// Returns [NetworkFailure] if network is unavailable
class GetCurrentUser {
  const GetCurrentUser(this.authRepository);

  final AuthRepository authRepository;

  Future<Either<Failure, dynamic>> call() => authRepository.getCurrentUser();
}
