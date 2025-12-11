import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/error/exceptions.dart';
import 'package:personal_trainer_app/core/network/dio_client.dart';
import 'package:personal_trainer_app/features/auth/data/datasources/auth_remote_datasource.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  group('AuthRemoteDataSourceImpl', () {
    late MockDioClient mockDioClient;
    late MockDio mockDio;
    late AuthRemoteDataSourceImpl dataSource;

    setUp(() {
      mockDioClient = MockDioClient();
      mockDio = MockDio();
      when(() => mockDioClient.dio).thenReturn(mockDio);
      dataSource = AuthRemoteDataSourceImpl(dioClient: mockDioClient);
    });

    group('sendMagicLink', () {
      const email = 'test@example.com';

      test('sends POST request with email to /api/v1/auth/magic-link endpoint',
          () async {
        // Arrange
        when(() => mockDio.post(
              '/api/v1/auth/magic-link',
              data: {'email': email},
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ));

        // Act
        await dataSource.sendMagicLink(email);

        // Assert
        verify(() => mockDio.post(
              '/api/v1/auth/magic-link',
              data: {'email': email},
            )).called(1);
      });

      test('returns void on successful response', () async {
        // Arrange
        when(() => mockDio.post(
              '/api/v1/auth/magic-link',
              data: {'email': email},
            )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ));

        // Act & Assert
        expect(
          dataSource.sendMagicLink(email),
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
              data: {'email': email},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.sendMagicLink(email),
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
              data: {'email': email},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.sendMagicLink(email),
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
              data: {'email': email},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.sendMagicLink(email),
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
              data: {'email': email},
            )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.sendMagicLink(email),
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
  });
}
