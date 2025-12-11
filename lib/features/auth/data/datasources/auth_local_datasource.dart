import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exceptions.dart';

/// Abstract interface for local authentication data operations.
///
/// Implementations handle secure token storage for authentication persistence.
/// All methods throw exceptions on failure (exceptions are caught by repositories).
///
/// Responsibilities:
/// - Store access and refresh tokens securely
/// - Retrieve tokens for authenticated requests
/// - Clear tokens on logout
/// - Enable token persistence across app restarts
///
/// Implementation MUST use flutter_secure_storage (NOT shared_preferences).
abstract class AuthLocalDataSource {
  /// Save authentication tokens securely.
  ///
  /// Stores both access and refresh tokens in secure storage.
  /// These tokens are encrypted using platform-native mechanisms:
  /// - iOS: Keychain
  /// - Android: Keystore
  ///
  /// Parameters:
  ///   - accessToken: Short-lived JWT for API authorization
  ///   - refreshToken: Long-lived token for obtaining new access tokens
  ///
  /// Throws:
  ///   - CacheException: If secure storage write fails
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Retrieve the access token from secure storage.
  ///
  /// Returns the stored access token for API authorization.
  /// This token is typically added to request headers as "Authorization: Bearer <token>".
  ///
  /// Returns:
  ///   - String: The access token if stored
  ///   - Throws CacheException if no token exists
  ///
  /// Throws:
  ///   - CacheException: If no access token is stored
  Future<String> getAccessToken();

  /// Retrieve the refresh token from secure storage.
  ///
  /// Returns the stored refresh token for token renewal.
  /// Used to obtain a new access token when the current one expires.
  ///
  /// Returns:
  ///   - String: The refresh token if stored
  ///   - Throws CacheException if no token exists
  ///
  /// Throws:
  ///   - CacheException: If no refresh token is stored
  Future<String> getRefreshToken();

  /// Clear both access and refresh tokens from secure storage.
  ///
  /// Called on logout to remove all authentication credentials.
  /// This ensures the user cannot access protected resources after logout.
  ///
  /// Throws:
  ///   - CacheException: If secure storage write fails
  Future<void> clearTokens();
}

/// Implementation of [AuthLocalDataSource].
///
/// Uses flutter_secure_storage for platform-native secure token persistence.
/// Tokens are encrypted and stored securely:
/// - iOS: Keychain encryption
/// - Android: Keystore encryption
///
/// All tokens persist across app restarts and device reboots.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({
    FlutterSecureStorage? secureStorage,
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage secureStorage;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        secureStorage.write(key: 'accessToken', value: accessToken),
        secureStorage.write(key: 'refreshToken', value: refreshToken),
      ]);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save tokens: $e',
      );
    }
  }

  @override
  Future<String> getAccessToken() async {
    try {
      final token = await secureStorage.read(key: 'accessToken');
      if (token == null || token.isEmpty) {
        throw CacheException(
          message: 'No access token stored. User must authenticate first.',
        );
      }
      return token;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to retrieve access token: $e',
      );
    }
  }

  @override
  Future<String> getRefreshToken() async {
    try {
      final token = await secureStorage.read(key: 'refreshToken');
      if (token == null || token.isEmpty) {
        throw CacheException(
          message: 'No refresh token stored.',
        );
      }
      return token;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to retrieve refresh token: $e',
      );
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        secureStorage.delete(key: 'accessToken'),
        secureStorage.delete(key: 'refreshToken'),
      ]);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear tokens: $e',
      );
    }
  }
}
