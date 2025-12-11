import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for initiating passwordless authentication via magic link
///
/// Triggers the first step of the magic link + device-bound authentication flow:
/// 1. User enters email → [SendMagicLink] sends magic link to email
/// 2. User enters code from email → [VerifyMagicLink] validates code (F021)
/// 3. Device authentication → Local biometric/PIN (presentation layer)
///
/// Returns void on success (link sent to email)
/// Returns [ServerFailure] if email is invalid or server error
/// Returns [NetworkFailure] if network is unavailable
class SendMagicLink {
  const SendMagicLink(this.authRepository);

  final AuthRepository authRepository;

  Future<Either<Failure, void>> call({
    required String email,
  }) =>
      authRepository.sendMagicLink(email: email);
}
