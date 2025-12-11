import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/error/failures.dart';
import 'package:personal_trainer_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:personal_trainer_app/features/auth/domain/usecases/verify_magic_link.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late VerifyMagicLink verifyMagicLink;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    verifyMagicLink = VerifyMagicLink(mockAuthRepository);
  });

  group('VerifyMagicLink', () {
    const email = 'trainer@example.com';
    const code = '123456';

    test('calls authRepository.verifyMagicLink with email and code', () async {
      // Arrange
      when(() => mockAuthRepository.verifyMagicLink(
            email: email,
            code: code,
          )).thenAnswer((_) async => const Right(null));

      // Act
      await verifyMagicLink(email: email, code: code);

      // Assert
      verify(() => mockAuthRepository.verifyMagicLink(
            email: email,
            code: code,
          )).called(1);
    });

    test('returns Right(user) on successful verification', () async {
      // Arrange
      const expectedUser = 'Authenticated User';
      when(() => mockAuthRepository.verifyMagicLink(
            email: email,
            code: code,
          )).thenAnswer((_) async => const Right(expectedUser));

      // Act
      final result = await verifyMagicLink(email: email, code: code);

      // Assert
      expect(result, const Right<Failure, String>(expectedUser));
    });

    test('returns ServerFailure if code is invalid', () async {
      // Arrange
      const invalidEmail = 'trainer@example.com';
      const invalidCode = 'invalid-code';
      when(() => mockAuthRepository.verifyMagicLink(
            email: invalidEmail,
            code: invalidCode,
          )).thenAnswer((_) async => const Left(ServerFailure(message: 'Invalid or expired code')));

      // Act
      final result = await verifyMagicLink(email: invalidEmail, code: invalidCode);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('returns NetworkFailure if network is unavailable', () async {
      // Arrange
      const networkEmail = 'trainer@example.com';
      const networkCode = '123456';
      when(() => mockAuthRepository.verifyMagicLink(
            email: networkEmail,
            code: networkCode,
          )).thenAnswer((_) async => const Left(NetworkFailure(message: 'No internet connection')));

      // Act
      final result = await verifyMagicLink(email: networkEmail, code: networkCode);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('passes email and code exactly as provided', () async {
      // Arrange
      const customEmail = 'client@app.com';
      const customCode = '654321';
      when(() => mockAuthRepository.verifyMagicLink(
            email: customEmail,
            code: customCode,
          )).thenAnswer((_) async => const Right(null));

      // Act
      await verifyMagicLink(email: customEmail, code: customCode);

      // Assert
      verify(() => mockAuthRepository.verifyMagicLink(
            email: customEmail,
            code: customCode,
          )).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
