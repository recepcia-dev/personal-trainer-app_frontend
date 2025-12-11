import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/error/failures.dart';
import 'package:personal_trainer_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:personal_trainer_app/features/auth/domain/usecases/send_magic_link.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('SendMagicLink', () {
    late MockAuthRepository mockAuthRepository;
    late SendMagicLink sendMagicLink;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      sendMagicLink = SendMagicLink(mockAuthRepository);
    });

    test('calls authRepository.sendMagicLink with email parameter', () async {
      // Arrange
      const email = 'test@example.com';
      when(() => mockAuthRepository.sendMagicLink(email: email))
          .thenAnswer((_) async => const Right(null));

      // Act
      await sendMagicLink(email: email);

      // Assert
      verify(() => mockAuthRepository.sendMagicLink(email: email)).called(1);
    });

    test('returns Right(void) on successful magic link send', () async {
      // Arrange
      const email = 'test@example.com';
      when(() => mockAuthRepository.sendMagicLink(email: email))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await sendMagicLink(email: email);

      // Assert
      expect(result, const Right<Failure, void>(null));
    });

    test('returns ServerFailure when email is invalid', () async {
      // Arrange
      const email = 'invalid-email';
      when(() => mockAuthRepository.sendMagicLink(email: email)).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Invalid email')),
      );

      // Act
      final result = await sendMagicLink(email: email);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('returns NetworkFailure when network is unavailable', () async {
      // Arrange
      const email = 'test@example.com';
      when(() => mockAuthRepository.sendMagicLink(email: email)).thenAnswer(
        (_) async => const Left(NetworkFailure(message: 'No internet connection')),
      );

      // Act
      final result = await sendMagicLink(email: email);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });
}
