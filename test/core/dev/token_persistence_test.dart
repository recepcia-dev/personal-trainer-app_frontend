import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test suite to validate token persistence with FlutterSecureStorage
///
/// These tests verify that:
/// 1. Tokens can be written to secure storage
/// 2. Tokens can be read back immediately after writing
/// 3. Tokens persist with proper iOS/Android configuration
void main() {
  // Initialize Flutter binding before running tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Token Persistence Tests', () {
    late FlutterSecureStorage storage;

    setUp(() {
      // Use the same configuration as main_dev.dart to ensure consistency
      storage = const FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await storage.delete(key: 'test_accessToken');
        await storage.delete(key: 'test_refreshToken');
      } catch (_) {
        // Ignore cleanup errors
      }
    });

    test('should write and read accessToken successfully', () async {
      const testToken = 'test_access_token_12345';

      // Write token
      await storage.write(key: 'test_accessToken', value: testToken);

      // Read token back
      final readToken = await storage.read(key: 'test_accessToken');

      // Verify token matches
      expect(readToken, equals(testToken));
      expect(readToken, isNotNull);
      expect(readToken, isNotEmpty);
    });

    test('should write and read refreshToken successfully', () async {
      const testToken = 'test_refresh_token_67890';

      // Write token
      await storage.write(key: 'test_refreshToken', value: testToken);

      // Read token back
      final readToken = await storage.read(key: 'test_refreshToken');

      // Verify token matches
      expect(readToken, equals(testToken));
      expect(readToken, isNotNull);
      expect(readToken, isNotEmpty);
    });

    test('should persist both tokens simultaneously', () async {
      const accessToken = 'access_token_abc';
      const refreshToken = 'refresh_token_xyz';

      // Write both tokens
      await storage.write(key: 'test_accessToken', value: accessToken);
      await storage.write(key: 'test_refreshToken', value: refreshToken);

      // Read both tokens back
      final readAccessToken = await storage.read(key: 'test_accessToken');
      final readRefreshToken = await storage.read(key: 'test_refreshToken');

      // Verify both tokens match
      expect(readAccessToken, equals(accessToken));
      expect(readRefreshToken, equals(refreshToken));
    });

    test('should return null for non-existent key', () async {
      final nonExistentToken = await storage.read(key: 'non_existent_key');

      expect(nonExistentToken, isNull);
    });

    test('should overwrite existing token with new value', () async {
      const oldToken = 'old_token_value';
      const newToken = 'new_token_value';

      // Write old token
      await storage.write(key: 'test_accessToken', value: oldToken);

      // Verify old token
      final readOldToken = await storage.read(key: 'test_accessToken');
      expect(readOldToken, equals(oldToken));

      // Overwrite with new token
      await storage.write(key: 'test_accessToken', value: newToken);

      // Verify new token
      final readNewToken = await storage.read(key: 'test_accessToken');
      expect(readNewToken, equals(newToken));
      expect(readNewToken, isNot(equals(oldToken)));
    });

    test('should delete token successfully', () async {
      const testToken = 'token_to_delete';

      // Write token
      await storage.write(key: 'test_accessToken', value: testToken);

      // Verify token exists
      final beforeDelete = await storage.read(key: 'test_accessToken');
      expect(beforeDelete, isNotNull);

      // Delete token
      await storage.delete(key: 'test_accessToken');

      // Verify token is gone
      final afterDelete = await storage.read(key: 'test_accessToken');
      expect(afterDelete, isNull);
    });

    test('should handle empty string token', () async {
      const emptyToken = '';

      // Write empty string
      await storage.write(key: 'test_accessToken', value: emptyToken);

      // Read it back
      final readToken = await storage.read(key: 'test_accessToken');

      // Verify it's stored as empty string (not null)
      expect(readToken, equals(''));
      expect(readToken, isNotNull);
    });

    test('should handle very long token strings', () async {
      // Simulate a real JWT token (typically 500-1000 characters)
      final longToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.' * 20;

      // Write long token
      await storage.write(key: 'test_accessToken', value: longToken);

      // Read it back
      final readToken = await storage.read(key: 'test_accessToken');

      // Verify full token is preserved
      expect(readToken, equals(longToken));
      expect(readToken?.length, equals(longToken.length));
    });
  });

  group('Production Token Keys Tests', () {
    late FlutterSecureStorage storage;

    setUp(() {
      storage = const FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );
    });

    tearDown(() async {
      // Clean up production keys after tests
      try {
        await storage.delete(key: 'accessToken');
        await storage.delete(key: 'refreshToken');
      } catch (_) {
        // Ignore cleanup errors
      }
    });

    test('should use exact production key names', () async {
      const accessToken = 'prod_access_token';
      const refreshToken = 'prod_refresh_token';

      // Write using production keys (as used in main_dev.dart)
      await storage.write(key: 'accessToken', value: accessToken);
      await storage.write(key: 'refreshToken', value: refreshToken);

      // Read using production keys
      final readAccessToken = await storage.read(key: 'accessToken');
      final readRefreshToken = await storage.read(key: 'refreshToken');

      // Verify both tokens match
      expect(readAccessToken, equals(accessToken));
      expect(readRefreshToken, equals(refreshToken));
    });
  });
}
