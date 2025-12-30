import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/error/exceptions.dart';
import 'package:personal_trainer_app/core/network/dio_client.dart';
import 'package:personal_trainer_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:personal_trainer_app/features/auth/data/models/client_model.dart';
import 'package:personal_trainer_app/features/auth/data/models/trainer_model.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('AuthRemoteDataSourceImpl', () {
    late MockDioClient mockDioClient;
    late MockDio mockDio;
    late MockFlutterSecureStorage mockSecureStorage;
    late AuthRemoteDataSourceImpl dataSource;

    setUp(() {
      mockDioClient = MockDioClient();
      mockDio = MockDio();
      mockSecureStorage = MockFlutterSecureStorage();
      when(() => mockDioClient.dio).thenReturn(mockDio);
      when(() => mockSecureStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => {});
      dataSource = AuthRemoteDataSourceImpl(
        dioClient: mockDioClient,
        secureStorage: mockSecureStorage,
      );
    });

    group('sendMagicLink', () {
      const email = 'test@example.com';
      const userType = 'trainer';

      test('sends POST request with email and userType to /api/v1/auth/magic-link endpoint',
          () async {
        // Arrange
        when(() => mockDio.post(
              '/api/v1/auth/magic-link',
              data: {'email': email, 'user_type': userType},
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ));

        // Act
        await dataSource.sendMagicLink(email, userType);

        // Assert
        verify(() => mockDio.post(
              '/api/v1/auth/magic-link',
              data: {'email': email, 'user_type': userType},
            )).called(1);
      });

      test('returns void on successful response', () async {
        // Arrange
        when(() => mockDio.post(
              '/api/v1/auth/magic-link',
              data: {'email': email, 'user_type': userType},
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ));

        // Act & Assert
        expect(
          dataSource.sendMagicLink(email, userType),
          completes,
        );
      });

      test('throws ServerException when server returns error response',
          () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/magic-link'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
            data: {'message': 'Invalid email'},
          ),
          message: 'Bad request',
        );

        when(() => mockDio.post(
              '/api/v1/auth/magic-link',
              data: {'email': email, 'user_type': userType},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.sendMagicLink(email, userType),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws ServerException with status code when server returns 500',
          () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/magic-link'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
            data: {'message': 'Internal server error'},
          ),
          message: 'Internal server error',
        );

        when(() => mockDio.post(
              '/api/v1/auth/magic-link',
              data: {'email': email, 'user_type': userType},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.sendMagicLink(email, userType),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws ServerException when network connection fails', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/magic-link'),
          message: 'Connection failed',
          type: DioExceptionType.connectionTimeout,
        );

        when(() => mockDio.post(
              '/api/v1/auth/magic-link',
              data: {'email': email, 'user_type': userType},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.sendMagicLink(email, userType),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws ServerException with message when Dio throws exception',
          () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/magic-link'),
          message: 'Network error',
        );

        when(() => mockDio.post(
              '/api/v1/auth/magic-link',
              data: {'email': email, 'user_type': userType},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.sendMagicLink(email, userType),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              contains('Failed to send magic link'),
            ),
          ),
        );
      });
    });

    group('verifyMagicLink', () {
      const email = 'test@example.com';
      const code = '123456';

      test('sends POST request with email and code to /api/v1/auth/verify-magic-link endpoint',
          () async {
        // Arrange
        final responseData = {
          'accessToken': 'access_token_123',
          'refreshToken': 'refresh_token_123',
          'role': 'trainer',
          'user': {
            'id': 'trainer_123',
            'email': email,
            'name': 'John Trainer',
            'photoUrl': null,
          },
        };

        when(() => mockDio.post(
              '/api/v1/auth/verify-magic-link',
              data: {'email': email, 'code': code},
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: responseData,
        ));

        // Act
        await dataSource.verifyMagicLink(email: email, code: code);

        // Assert
        verify(() => mockDio.post(
              '/api/v1/auth/verify-magic-link',
              data: {'email': email, 'code': code},
            )).called(1);
      });

      test('stores access token to secure storage on successful response',
          () async {
        // Arrange
        final responseData = {
          'accessToken': 'access_token_123',
          'refreshToken': 'refresh_token_123',
          'role': 'trainer',
          'user': {
            'id': 'trainer_123',
            'email': email,
            'name': 'John Trainer',
            'photoUrl': null,
          },
        };

        when(() => mockDio.post(
              '/api/v1/auth/verify-magic-link',
              data: {'email': email, 'code': code},
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: responseData,
        ));

        // Act
        await dataSource.verifyMagicLink(email: email, code: code);

        // Assert
        verify(() => mockSecureStorage.write(
              key: 'accessToken',
              value: 'access_token_123',
            )).called(1);
      });

      test('stores refresh token to secure storage on successful response',
          () async {
        // Arrange
        final responseData = {
          'accessToken': 'access_token_123',
          'refreshToken': 'refresh_token_123',
          'role': 'trainer',
          'user': {
            'id': 'trainer_123',
            'email': email,
            'name': 'John Trainer',
            'photoUrl': null,
          },
        };

        when(() => mockDio.post(
              '/api/v1/auth/verify-magic-link',
              data: {'email': email, 'code': code},
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: responseData,
        ));

        // Act
        await dataSource.verifyMagicLink(email: email, code: code);

        // Assert
        verify(() => mockSecureStorage.write(
              key: 'refreshToken',
              value: 'refresh_token_123',
            )).called(1);
      });

      test('returns TrainerModel when role is trainer', () async {
        // Arrange
        final responseData = {
          'accessToken': 'access_token_123',
          'refreshToken': 'refresh_token_123',
          'role': 'trainer',
          'user': {
            'id': 'trainer_456',
            'email': email,
            'name': 'John Trainer',
            'photoUrl': 'https://example.com/photo.jpg',
          },
        };

        when(() => mockDio.post(
              '/api/v1/auth/verify-magic-link',
              data: {'email': email, 'code': code},
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: responseData,
        ));

        // Act
        final result = await dataSource.verifyMagicLink(email: email, code: code);

        // Assert
        expect(result, isA<TrainerModel>());
        expect((result as TrainerModel).email, equals(email));
        expect(result.name, equals('John Trainer'));
      });

      test('returns ClientModel when role is client', () async {
        // Arrange
        final responseData = {
          'accessToken': 'access_token_123',
          'refreshToken': 'refresh_token_123',
          'role': 'client',
          'user': {
            'id': 'client_789',
            'email': email,
            'name': 'Jane Client',
            'trainer_id': 42,
          },
        };

        when(() => mockDio.post(
              '/api/v1/auth/verify-magic-link',
              data: {'email': email, 'code': code},
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: responseData,
        ));

        // Act
        final result = await dataSource.verifyMagicLink(email: email, code: code);

        // Assert
        expect(result, isA<ClientModel>());
        expect((result as ClientModel).email, equals(email));
        expect(result.name, equals('Jane Client'));
        expect(result.trainerId, equals(42));
      });

      test('throws ServerException when code is invalid (400 response)',
          () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/verify-magic-link'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
            data: {'message': 'Invalid code'},
          ),
          message: 'Bad request',
        );

        when(() => mockDio.post(
              '/api/v1/auth/verify-magic-link',
              data: {'email': email, 'code': code},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.verifyMagicLink(email: email, code: code),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws ServerException when code is expired (401 response)',
          () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/verify-magic-link'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
            data: {'message': 'Code expired'},
          ),
          message: 'Unauthorized',
        );

        when(() => mockDio.post(
              '/api/v1/auth/verify-magic-link',
              data: {'email': email, 'code': code},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.verifyMagicLink(email: email, code: code),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws ServerException when server returns 500 error', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/verify-magic-link'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
            data: {'message': 'Internal server error'},
          ),
          message: 'Internal server error',
        );

        when(() => mockDio.post(
              '/api/v1/auth/verify-magic-link',
              data: {'email': email, 'code': code},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.verifyMagicLink(email: email, code: code),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws ServerException when network connection fails', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/verify-magic-link'),
          message: 'Connection timeout',
          type: DioExceptionType.connectionTimeout,
        );

        when(() => mockDio.post(
              '/api/v1/auth/verify-magic-link',
              data: {'email': email, 'code': code},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.verifyMagicLink(email: email, code: code),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws ServerException with message when Dio throws exception',
          () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/verify-magic-link'),
          message: 'Network error',
        );

        when(() => mockDio.post(
              '/api/v1/auth/verify-magic-link',
              data: {'email': email, 'code': code},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.verifyMagicLink(email: email, code: code),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              contains('Failed to verify magic link'),
            ),
          ),
        );
      });
    });

    group('getCurrentUser', () {
      test('throws CacheException when no access token is stored', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => dataSource.getCurrentUser(),
          throwsA(isA<CacheException>()),
        );
      });

      test('throws CacheException when access token is empty', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => '');

        // Act & Assert
        expect(
          () => dataSource.getCurrentUser(),
          throwsA(isA<CacheException>()),
        );
      });

      test(
          'sends POST request with Bearer token to /api/v1/auth/me endpoint',
          () async {
        // Arrange
        const token = 'access_token_123';
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => token);

        final responseData = {
          'id': 'trainer_123',
          'email': 'trainer@example.com',
          'first_name': 'John',
          'last_name': 'Trainer',
          'photoUrl': null,
          'user_type': 'trainer',
        };

        when(() => mockDio.post(
              '/api/v1/auth/me',
              options: any(named: 'options'),
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: responseData,
        ));

        // Act
        await dataSource.getCurrentUser();

        // Assert
        verify(() => mockDio.post(
              '/api/v1/auth/me',
              options: any(named: 'options'),
            )).called(1);
      });

      test('returns TrainerModel when role is trainer', () async {
        // Arrange
        const token = 'access_token_123';
        const email = 'trainer@example.com';
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => token);

        final responseData = {
          'id': 'trainer_456',
          'email': email,
          'first_name': 'John',
          'last_name': 'Trainer',
          'photoUrl': 'https://example.com/photo.jpg',
          'user_type': 'trainer',
        };

        when(() => mockDio.post(
              '/api/v1/auth/me',
              options: any(named: 'options'),
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: responseData,
        ));

        // Act
        final result = await dataSource.getCurrentUser();

        // Assert
        expect(result, isA<TrainerModel>());
        expect((result as TrainerModel).email, equals(email));
        expect(result.name, equals('John Trainer'));
      });

      test('returns ClientModel when role is client', () async {
        // Arrange
        const token = 'access_token_123';
        const email = 'client@example.com';
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => token);

        final responseData = {
          'id': 'client_789',
          'email': email,
          'first_name': 'Jane',
          'last_name': 'Client',
          'trainer_id': 42,
          'user_type': 'client',
        };

        when(() => mockDio.post(
              '/api/v1/auth/me',
              options: any(named: 'options'),
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: responseData,
        ));

        // Act
        final result = await dataSource.getCurrentUser();

        // Assert
        expect(result, isA<ClientModel>());
        expect((result as ClientModel).email, equals(email));
        expect(result.name, equals('Jane Client'));
        expect(result.trainerId, isNull); // trainerId is not set in getCurrentUser response
      });

      test('throws ServerException when token is invalid (401 response)',
          () async {
        // Arrange
        const token = 'invalid_token';
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => token);

        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/me'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
            data: {'message': 'Unauthorized'},
          ),
          message: 'Unauthorized',
        );

        when(() => mockDio.post(
              '/api/v1/auth/me',
              options: any(named: 'options'),
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.getCurrentUser(),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws ServerException when token is expired (401 response)',
          () async {
        // Arrange
        const token = 'expired_token';
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => token);

        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/me'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
            data: {'message': 'Token expired'},
          ),
          message: 'Unauthorized',
        );

        when(() => mockDio.post(
              '/api/v1/auth/me',
              options: any(named: 'options'),
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.getCurrentUser(),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws ServerException when server returns 500 error', () async {
        // Arrange
        const token = 'access_token_123';
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => token);

        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/me'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
            data: {'message': 'Internal server error'},
          ),
          message: 'Internal server error',
        );

        when(() => mockDio.post(
              '/api/v1/auth/me',
              options: any(named: 'options'),
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.getCurrentUser(),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws ServerException when network connection fails', () async {
        // Arrange
        const token = 'access_token_123';
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => token);

        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/me'),
          message: 'Connection timeout',
          type: DioExceptionType.connectionTimeout,
        );

        when(() => mockDio.post(
              '/api/v1/auth/me',
              options: any(named: 'options'),
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.getCurrentUser(),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws ServerException with message when Dio throws exception',
          () async {
        // Arrange
        const token = 'access_token_123';
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => token);

        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/me'),
          message: 'Network error',
        );

        when(() => mockDio.post(
              '/api/v1/auth/me',
              options: any(named: 'options'),
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.getCurrentUser(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              contains('Failed to get current user'),
            ),
          ),
        );
      });
    });
  });
}
