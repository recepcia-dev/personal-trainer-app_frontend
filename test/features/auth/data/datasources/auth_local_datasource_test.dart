import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/error/exceptions.dart';
import 'package:personal_trainer_app/features/auth/data/datasources/auth_local_datasource.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    dataSource = AuthLocalDataSourceImpl(
      secureStorage: mockSecureStorage,
    );
  });

  group('AuthLocalDataSource', () {
    group('saveTokens', () {
      test('saves both access and refresh tokens to secure storage', () async {
        // Arrange
        const accessToken = 'access_token_123';
        const refreshToken = 'refresh_token_456';

        when(() => mockSecureStorage.write(
              key: 'accessToken',
              value: accessToken,
            )).thenAnswer((_) async {});

        when(() => mockSecureStorage.write(
              key: 'refreshToken',
              value: refreshToken,
            )).thenAnswer((_) async {});

        // Act
        await dataSource.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Assert
        verify(() => mockSecureStorage.write(
              key: 'accessToken',
              value: accessToken,
            )).called(1);

        verify(() => mockSecureStorage.write(
              key: 'refreshToken',
              value: refreshToken,
            )).called(1);
      });

      test('throws CacheException when save fails', () async {
        // Arrange
        const accessToken = 'access_token_123';
        const refreshToken = 'refresh_token_456';

        when(() => mockSecureStorage.write(
              key: 'accessToken',
              value: accessToken,
            )).thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => dataSource.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('getAccessToken', () {
      test('returns access token when stored', () async {
        // Arrange
        const token = 'access_token_123';

        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => token);

        // Act
        final result = await dataSource.getAccessToken();

        // Assert
        expect(result, equals(token));
        verify(() => mockSecureStorage.read(key: 'accessToken')).called(1);
      });

      test('throws CacheException when no token stored', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => dataSource.getAccessToken(),
          throwsA(isA<CacheException>()),
        );
      });

      test('throws CacheException when token is empty', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => '');

        // Act & Assert
        expect(
          () => dataSource.getAccessToken(),
          throwsA(isA<CacheException>()),
        );
      });

      test('throws CacheException when storage read fails', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => dataSource.getAccessToken(),
          throwsA(isA<CacheException>()),
        );
      });

      test('CacheException contains descriptive error message', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => dataSource.getAccessToken(),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              contains('No access token stored'),
            ),
          ),
        );
      });
    });

    group('getRefreshToken', () {
      test('returns refresh token when stored', () async {
        // Arrange
        const token = 'refresh_token_456';

        when(() => mockSecureStorage.read(key: 'refreshToken'))
            .thenAnswer((_) async => token);

        // Act
        final result = await dataSource.getRefreshToken();

        // Assert
        expect(result, equals(token));
        verify(() => mockSecureStorage.read(key: 'refreshToken')).called(1);
      });

      test('throws CacheException when no token stored', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'refreshToken'))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => dataSource.getRefreshToken(),
          throwsA(isA<CacheException>()),
        );
      });

      test('throws CacheException when token is empty', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'refreshToken'))
            .thenAnswer((_) async => '');

        // Act & Assert
        expect(
          () => dataSource.getRefreshToken(),
          throwsA(isA<CacheException>()),
        );
      });

      test('throws CacheException when storage read fails', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'refreshToken'))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => dataSource.getRefreshToken(),
          throwsA(isA<CacheException>()),
        );
      });

      test('CacheException contains descriptive error message', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'refreshToken'))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => dataSource.getRefreshToken(),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              contains('No refresh token stored'),
            ),
          ),
        );
      });
    });

    group('clearTokens', () {
      test('deletes both access and refresh tokens from secure storage', () async {
        // Arrange
        when(() => mockSecureStorage.delete(key: 'accessToken'))
            .thenAnswer((_) async {});

        when(() => mockSecureStorage.delete(key: 'refreshToken'))
            .thenAnswer((_) async {});

        // Act
        await dataSource.clearTokens();

        // Assert
        verify(() => mockSecureStorage.delete(key: 'accessToken')).called(1);
        verify(() => mockSecureStorage.delete(key: 'refreshToken')).called(1);
      });

      test('throws CacheException when delete fails', () async {
        // Arrange
        when(() => mockSecureStorage.delete(key: 'accessToken'))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => dataSource.clearTokens(),
          throwsA(isA<CacheException>()),
        );
      });

      test('successfully clears tokens even if they do not exist', () async {
        // Arrange - delete returns null even if key doesn't exist
        when(() => mockSecureStorage.delete(key: 'accessToken'))
            .thenAnswer((_) async {});

        when(() => mockSecureStorage.delete(key: 'refreshToken'))
            .thenAnswer((_) async {});

        // Act - should complete without throwing
        await dataSource.clearTokens();

        // Assert - verify deletions were called
        verify(() => mockSecureStorage.delete(key: 'accessToken')).called(1);
        verify(() => mockSecureStorage.delete(key: 'refreshToken')).called(1);
      });
    });

    group('token persistence', () {
      test('retrieves previously saved access token', () async {
        // Arrange
        const accessToken = 'access_token_123';

        when(() => mockSecureStorage.write(
              key: 'accessToken',
              value: accessToken,
            )).thenAnswer((_) async {});

        when(() => mockSecureStorage.write(
              key: 'refreshToken',
              value: any(named: 'value'),
            )).thenAnswer((_) async {});

        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => accessToken);

        // Act - Save and then retrieve
        await dataSource.saveTokens(
          accessToken: accessToken,
          refreshToken: 'refresh_token',
        );

        final retrievedToken = await dataSource.getAccessToken();

        // Assert
        expect(retrievedToken, equals(accessToken));
      });

      test('retrieves previously saved refresh token', () async {
        // Arrange
        const refreshToken = 'refresh_token_456';

        when(() => mockSecureStorage.write(
              key: 'refreshToken',
              value: refreshToken,
            )).thenAnswer((_) async {});

        when(() => mockSecureStorage.write(
              key: 'accessToken',
              value: any(named: 'value'),
            )).thenAnswer((_) async {});

        when(() => mockSecureStorage.read(key: 'refreshToken'))
            .thenAnswer((_) async => refreshToken);

        // Act - Save and then retrieve
        await dataSource.saveTokens(
          accessToken: 'access_token',
          refreshToken: refreshToken,
        );

        final retrievedToken = await dataSource.getRefreshToken();

        // Assert
        expect(retrievedToken, equals(refreshToken));
      });

      test('tokens are cleared and no longer retrievable', () async {
        // Arrange
        when(() => mockSecureStorage.delete(key: 'accessToken'))
            .thenAnswer((_) async {});

        when(() => mockSecureStorage.delete(key: 'refreshToken'))
            .thenAnswer((_) async {});

        // After clearing, reading should return null
        when(() => mockSecureStorage.read(key: 'accessToken'))
            .thenAnswer((_) async => null);

        when(() => mockSecureStorage.read(key: 'refreshToken'))
            .thenAnswer((_) async => null);

        // Act - Clear tokens, then try to retrieve
        await dataSource.clearTokens();

        // Assert
        expect(
          () => dataSource.getAccessToken(),
          throwsA(isA<CacheException>()),
        );

        expect(
          () => dataSource.getRefreshToken(),
          throwsA(isA<CacheException>()),
        );
      });
    });
  });
}
