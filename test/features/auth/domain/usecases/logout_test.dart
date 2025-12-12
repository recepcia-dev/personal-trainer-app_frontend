import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/error/failures.dart';
import 'package:personal_trainer_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:personal_trainer_app/features/auth/domain/usecases/logout.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('Logout', () {
    late Logout logout;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      logout = Logout(mockAuthRepository);
    });

    group('calls authRepository.logout', () {
      test('Logout calls authRepository.logout with no parameters',
          () async {
        // Arrange
        when(
          () => mockAuthRepository.logout(),
        ).thenAnswer((_) async => const Right(null));

        // Act
        await logout.call();

        // Assert
        verify(() => mockAuthRepository.logout()).called(1);
      });
    });

    group('LogoutUseCase returns Right(void) on success', () {
      test('Logout returns Right(void) when logout succeeds', () async {
        // Arrange
        when(
          () => mockAuthRepository.logout(),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await logout.call();

        // Assert
        expect(result, equals(const Right<dynamic, void>(null)));
      });
    });

    group('Logout returns CacheFailure when token clearing from storage fails',
        () {
      test('Logout returns CacheFailure when repository fails', () async {
        // Arrange
        final failure = CacheFailure(
          message: 'Failed to clear tokens',
        );
        when(
          () => mockAuthRepository.logout(),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await logout.call();

        // Assert
        expect(result, equals(Left<CacheFailure, void>(failure)));
      });
    });

    group('Logout returns ServerFailure when unexpected error occurs', () {
      test('Logout returns ServerFailure for unexpected errors', () async {
        // Arrange
        final failure = ServerFailure(
          message: 'Unexpected error during logout',
        );
        when(
          () => mockAuthRepository.logout(),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await logout.call();

        // Assert
        expect(result, equals(Left<ServerFailure, void>(failure)));
      });
    });
  });
}
