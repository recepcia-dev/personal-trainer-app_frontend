import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/error/failures.dart';
import 'package:personal_trainer_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:personal_trainer_app/features/auth/domain/usecases/register_fcm_token.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('RegisterFcmToken', () {
    late RegisterFcmToken registerFcmToken;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      registerFcmToken = RegisterFcmToken(mockAuthRepository);
    });

    const testFcmToken = 'test_fcm_token_123456';

    group('calls authRepository.registerFcmToken', () {
      test(
          'RegisterFcmToken calls authRepository.registerFcmToken with correct FCM token',
          () async {
        // Arrange
        when(
          () => mockAuthRepository.registerFcmToken(testFcmToken),
        ).thenAnswer((_) async => const Right(null));

        // Act
        await registerFcmToken.call(testFcmToken);

        // Assert
        verify(() => mockAuthRepository.registerFcmToken(testFcmToken))
            .called(1);
      });
    });

    group('RegisterFcmToken returns Right(void) on success', () {
      test('RegisterFcmToken returns Right(void) when token registration succeeds',
          () async {
        // Arrange
        when(
          () => mockAuthRepository.registerFcmToken(testFcmToken),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await registerFcmToken.call(testFcmToken);

        // Assert
        expect(result, equals(const Right<dynamic, void>(null)));
      });
    });

    group('RegisterFcmToken returns ServerFailure when server rejects token',
        () {
      test('RegisterFcmToken returns ServerFailure on server error', () async {
        // Arrange
        final failure = ServerFailure(
          message: 'Server rejected FCM token',
        );
        when(
          () => mockAuthRepository.registerFcmToken(testFcmToken),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await registerFcmToken.call(testFcmToken);

        // Assert
        expect(result, equals(Left<ServerFailure, void>(failure)));
      });
    });

    group('RegisterFcmToken returns NetworkFailure when network is unavailable',
        () {
      test('RegisterFcmToken returns NetworkFailure when offline', () async {
        // Arrange
        final failure = NetworkFailure(
          message: 'No internet connection',
        );
        when(
          () => mockAuthRepository.registerFcmToken(testFcmToken),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await registerFcmToken.call(testFcmToken);

        // Assert
        expect(result, equals(Left<NetworkFailure, void>(failure)));
      });
    });

    group('RegisterFcmToken accepts any FCM token string', () {
      test('RegisterFcmToken works with different token formats', () async {
        // Arrange
        const longToken =
            'very_long_fcm_token_that_firebase_generates_with_many_characters_1234567890';
        when(
          () => mockAuthRepository.registerFcmToken(longToken),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await registerFcmToken.call(longToken);

        // Assert
        expect(result, equals(const Right<dynamic, void>(null)));
        verify(() => mockAuthRepository.registerFcmToken(longToken)).called(1);
      });
    });

    group('RegisterFcmToken parameter validation', () {
      test('RegisterFcmToken passes token exactly as provided to repository',
          () async {
        // Arrange
        const specificToken = 'specific_token_xyz';
        when(
          () => mockAuthRepository.registerFcmToken(specificToken),
        ).thenAnswer((_) async => const Right(null));

        // Act
        await registerFcmToken.call(specificToken);

        // Assert
        verify(() => mockAuthRepository.registerFcmToken(specificToken))
            .called(1);
      });
    });
  });
}
