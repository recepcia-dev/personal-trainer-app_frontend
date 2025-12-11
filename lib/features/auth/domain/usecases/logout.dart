import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging out the current user
///
/// Completes the authentication lifecycle:
/// 1. User enters email → [SendMagicLink] sends magic link
/// 2. User enters code from email → [VerifyMagicLink] validates code
/// 3. User authenticates locally with device → Local biometric/PIN (presentation layer)
/// 4. User is authenticated and logged in
/// 5. User logout → [Logout] clears tokens and session (THIS STEP)
///
/// Returns void on success (tokens cleared)
/// Returns [CacheFailure] if token clearing from storage fails
class Logout {
  const Logout(this.authRepository);

  final AuthRepository authRepository;

  Future<Either<Failure, void>> call() => authRepository.logout();
}
