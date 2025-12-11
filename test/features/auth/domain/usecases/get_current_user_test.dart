import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/error/failures.dart';
import 'package:personal_trainer_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:personal_trainer_app/features/auth/domain/usecases/get_current_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentUser getCurrentUser;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    getCurrentUser = GetCurrentUser(mockAuthRepository);
  });

  group('GetCurrentUser', () {
    test('calls authRepository.getCurrentUser', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      // Act
      await getCurrentUser();

      // Assert
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });

    test('returns Right(user) on successful retrieval', () async {
      // Arrange
      const expectedUser = 'Authenticated User';
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(expectedUser));

      // Act
      final result = await getCurrentUser();

      // Assert
      expect(result, const Right<Failure, String>(expectedUser));
    });

    test('returns Right(null) when no user is authenticated', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await getCurrentUser();

      // Assert
      expect(result, const Right<Failure, dynamic>(null));
    });

    test('returns ServerFailure if server error occurs', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
        (_) async =>
            const Left(ServerFailure(message: 'Server error occurred')),
      );

      // Act
      final result = await getCurrentUser();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('returns NetworkFailure if network is unavailable', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
        (_) async =>
            const Left(NetworkFailure(message: 'No internet connection')),
      );

      // Act
      final result = await getCurrentUser();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });
}
