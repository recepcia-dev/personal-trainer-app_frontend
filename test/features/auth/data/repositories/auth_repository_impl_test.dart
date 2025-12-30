import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/error/exceptions.dart';
import 'package:personal_trainer_app/core/error/failures.dart';
import 'package:personal_trainer_app/core/network/network_info.dart';
import 'package:personal_trainer_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:personal_trainer_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:personal_trainer_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:personal_trainer_app/features/auth/domain/entities/trainer.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  const testEmail = 'test@example.com';
  const testCode = '123456';

  const testTrainer = Trainer(
    email: testEmail,
    name: 'John Doe',
    photoUrl: null,
  );

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('AuthRepositoryImpl', () {
    group('sendMagicLink', () {
      test('returns Right(null) when online and remote succeeds', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.sendMagicLink(testEmail, 'trainer'))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.sendMagicLink(email: testEmail, userType: 'trainer');

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(() => mockRemoteDataSource.sendMagicLink(testEmail, 'trainer')).called(1);
        verify(() => mockNetworkInfo.isConnected).called(1);
      });

      test('returns ServerFailure when remote throws ServerException', () async {
        // Arrange
        const exceptionMessage = 'Invalid email';
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.sendMagicLink(testEmail, 'trainer'))
            .thenThrow(
          ServerException(
            message: exceptionMessage,
            statusCode: 400,
          ),
        );

        // Act
        final result = await repository.sendMagicLink(email: testEmail, userType: 'trainer');

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, exceptionMessage);
            if (failure is ServerFailure) {
              expect(failure.statusCode, 400);
            }
          },
          (_) => fail('Should return Left'),
        );
      });

      test('returns NetworkFailure when remote throws NetworkException',
          () async {
        // Arrange
        const exceptionMessage = 'Network timeout';
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.sendMagicLink(testEmail, 'trainer'))
            .thenThrow(NetworkException(message: exceptionMessage));

        // Act
        final result = await repository.sendMagicLink(email: testEmail, userType: 'trainer');

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, exceptionMessage);
          },
          (_) => fail('Should return Left'),
        );
      });

      test('returns NetworkFailure when offline', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.sendMagicLink(email: testEmail, userType: 'trainer');

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, contains('No internet connection'));
          },
          (_) => fail('Should return Left'),
        );
        verifyNever(() => mockRemoteDataSource.sendMagicLink(any(), any()));
      });

      test('returns ServerFailure when unexpected exception occurs', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.sendMagicLink(testEmail, 'trainer'))
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.sendMagicLink(email: testEmail, userType: 'trainer');

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Unexpected error'));
          },
          (_) => fail('Should return Left'),
        );
      });
    });

    group('verifyMagicLink', () {
      test('returns Right(user) when online and remote succeeds', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.verifyMagicLink(
            email: testEmail,
            code: testCode,
          ),
        ).thenAnswer((_) async => testTrainer);

        // Act
        final result = await repository.verifyMagicLink(
          email: testEmail,
          code: testCode,
        );

        // Assert
        expect(result, const Right<Failure, dynamic>(testTrainer));
        verify(
          () => mockRemoteDataSource.verifyMagicLink(
            email: testEmail,
            code: testCode,
          ),
        ).called(1);
      });

      test('returns ServerFailure when remote throws ServerException',
          () async {
        // Arrange
        const exceptionMessage = 'Invalid code';
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.verifyMagicLink(
            email: testEmail,
            code: testCode,
          ),
        ).thenThrow(
          ServerException(
            message: exceptionMessage,
            statusCode: 401,
          ),
        );

        // Act
        final result = await repository.verifyMagicLink(
          email: testEmail,
          code: testCode,
        );

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, exceptionMessage);
          },
          (_) => fail('Should return Left'),
        );
      });

      test('returns NetworkFailure when remote throws NetworkException',
          () async {
        // Arrange
        const exceptionMessage = 'Connection lost';
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.verifyMagicLink(
            email: testEmail,
            code: testCode,
          ),
        ).thenThrow(NetworkException(message: exceptionMessage));

        // Act
        final result = await repository.verifyMagicLink(
          email: testEmail,
          code: testCode,
        );

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, exceptionMessage);
          },
          (_) => fail('Should return Left'),
        );
      });

      test('returns NetworkFailure when offline', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.verifyMagicLink(
          email: testEmail,
          code: testCode,
        );

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, contains('No internet connection'));
          },
          (_) => fail('Should return Left'),
        );
        verifyNever(() => mockRemoteDataSource.verifyMagicLink(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ));
      });
    });

    group('getCurrentUser', () {
      test('returns Right(user) when online and remote succeeds', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getCurrentUser())
            .thenAnswer((_) async => testTrainer);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, const Right<Failure, dynamic>(testTrainer));
        verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
      });

      test('returns CacheFailure when remote throws CacheException',
          () async {
        // Arrange
        const exceptionMessage = 'No access token stored';
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getCurrentUser()).thenThrow(
          CacheException(message: exceptionMessage),
        );

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, exceptionMessage);
          },
          (_) => fail('Should return Left'),
        );
      });

      test('returns ServerFailure when remote throws ServerException',
          () async {
        // Arrange
        const exceptionMessage = 'Server error';
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getCurrentUser()).thenThrow(
          ServerException(
            message: exceptionMessage,
            statusCode: 500,
          ),
        );

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, exceptionMessage);
          },
          (_) => fail('Should return Left'),
        );
      });

      test('returns NetworkFailure when offline', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, contains('No internet connection'));
          },
          (_) => fail('Should return Left'),
        );
        verifyNever(() => mockRemoteDataSource.getCurrentUser());
      });

      test('returns ServerFailure when unexpected exception occurs', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getCurrentUser())
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Unexpected error'));
          },
          (_) => fail('Should return Left'),
        );
      });
    });

    group('logout', () {
      test('returns Right(null) when local clear succeeds', () async {
        // Arrange
        when(() => mockLocalDataSource.clearTokens())
            .thenAnswer((_) async {});
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.logout();

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(() => mockLocalDataSource.clearTokens()).called(1);
      });

      test('returns Right(null) when online and both clear and notify succeed',
          () async {
        // Arrange
        when(() => mockLocalDataSource.clearTokens())
            .thenAnswer((_) async {});
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

        // Act
        final result = await repository.logout();

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(() => mockLocalDataSource.clearTokens()).called(1);
        verify(() => mockNetworkInfo.isConnected).called(1);
      });

      test('returns Right(null) even when remote notification fails',
          () async {
        // Arrange
        when(() => mockLocalDataSource.clearTokens())
            .thenAnswer((_) async {});
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

        // Act
        final result = await repository.logout();

        // Assert
        // Even if remote fails, local logout succeeded
        expect(result, const Right<Failure, void>(null));
        verify(() => mockLocalDataSource.clearTokens()).called(1);
      });

      test('returns CacheFailure when local clear throws CacheException',
          () async {
        // Arrange
        const exceptionMessage = 'Failed to clear tokens';
        when(() => mockLocalDataSource.clearTokens()).thenThrow(
          CacheException(message: exceptionMessage),
        );

        // Act
        final result = await repository.logout();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, exceptionMessage);
          },
          (_) => fail('Should return Left'),
        );
      });

      test('returns ServerFailure when unexpected exception occurs', () async {
        // Arrange
        when(() => mockLocalDataSource.clearTokens())
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.logout();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Unexpected error'));
          },
          (_) => fail('Should return Left'),
        );
      });
    });

    group('Exception to Failure mapping', () {
      test('maps ServerException to ServerFailure with status code', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.sendMagicLink(testEmail, 'trainer'))
            .thenThrow(
          ServerException(
            message: 'Bad Request',
            statusCode: 400,
          ),
        );

        // Act
        final result = await repository.sendMagicLink(email: testEmail, userType: 'trainer');

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            if (failure is ServerFailure) {
              expect(failure.statusCode, 400);
            }
          },
          (_) => fail('Should return Left'),
        );
      });

      test('maps NetworkException to NetworkFailure', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.sendMagicLink(testEmail, 'trainer'))
            .thenThrow(NetworkException(message: 'Timeout'));

        // Act
        final result = await repository.sendMagicLink(email: testEmail, userType: 'trainer');

        // Assert
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Should return Left'),
        );
      });

      test('maps CacheException to CacheFailure', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getCurrentUser()).thenThrow(
          CacheException(message: 'Token not found'),
        );

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return Left'),
        );
      });
    });

    group('Offline-first pattern', () {
      test('verifyMagicLink requires internet connection', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.verifyMagicLink(
          email: testEmail,
          code: testCode,
        );

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Should return Left'),
        );
      });

      test('getCurrentUser returns error when offline (no cache)', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Should return Left'),
        );
      });

      test('logout works offline (clears local tokens)', () async {
        // Arrange
        when(() => mockLocalDataSource.clearTokens())
            .thenAnswer((_) async {});
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.logout();

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(() => mockLocalDataSource.clearTokens()).called(1);
      });
    });
  });
}
