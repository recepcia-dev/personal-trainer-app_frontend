import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for verifying magic link code during passwordless authentication
///
/// Implements the second step of the magic link + device-bound authentication flow:
/// 1. User enters email → [SendMagicLink] sends magic link to email
/// 2. User enters code from email → [VerifyMagicLink] validates code (THIS STEP)
/// 3. Device authentication → Local biometric/PIN (presentation layer)
///
/// Returns authenticated user (Trainer or Client) on success
/// Returns [ServerFailure] if code is invalid, expired, or server error
/// Returns [NetworkFailure] if network is unavailable
class VerifyMagicLink {
  const VerifyMagicLink(this.authRepository);

  final AuthRepository authRepository;

  Future<Either<Failure, dynamic>> call({
    required String email,
    required String code,
  }) =>
      authRepository.verifyMagicLink(email: email, code: code);
}
