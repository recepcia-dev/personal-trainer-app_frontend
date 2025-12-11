import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/verify_magic_link_response_model.dart';

/// Abstract interface for remote authentication data operations.
///
/// Implementations communicate with the backend API for authentication flows.
/// All methods throw exceptions on failure (exceptions are caught by repositories).
///
/// Despite having a single method initially, this interface enables:
/// - Dependency inversion: repository depends on interface, not implementation
/// - Testability: mock implementations for unit tests
/// - Extensibility: future methods will follow this interface
/// - Loose coupling: implementations can change without affecting repository
// ignore: one_member_abstracts
abstract class AuthRemoteDataSource {
  /// Send a magic link to the provided email.
  ///
  /// The backend will send an email containing a code that the user can use
  /// for passwordless authentication.
  ///
  /// Parameters:
  ///   - email: The user's email address
  ///
  /// Throws:
  ///   - ServerException: If the server returns an error response
  ///   - NetworkException: If network connectivity issues prevent the request
  Future<void> sendMagicLink(String email);

  /// Verify the magic link code and authenticate the user.
  ///
  /// Called after user receives the magic link email and enters the verification code.
  /// Returns the authenticated user (Trainer or Client) and stores tokens securely.
  ///
  /// Parameters:
  ///   - email: The user's email address
  ///   - code: The verification code from the email
  ///
  /// Returns:
  ///   - Trainer or Client model depending on user role
  ///   - Tokens are automatically stored to flutter_secure_storage
  ///
  /// Throws:
  ///   - ServerException: If code is invalid, expired, or server error occurs
  ///   - NetworkException: If network connectivity issues prevent the request
  Future<dynamic> verifyMagicLink({
    required String email,
    required String code,
  });

  /// Get the current authenticated user from the server.
  ///
  /// Retrieves the authenticated user (Trainer or Client) from the backend using
  /// the stored access token. This method is called to check if a user is still
  /// authenticated and to refresh their user data from the server.
  ///
  /// No parameters required - uses the access token stored in flutter_secure_storage.
  ///
  /// Returns:
  ///   - Trainer or Client model depending on user role
  ///
  /// Throws:
  ///   - CacheException: If no access token is stored in flutter_secure_storage
  ///   - ServerException: If token is invalid, expired, or server error occurs
  ///   - NetworkException: If network connectivity issues prevent the request
  Future<dynamic> getCurrentUser();
}

/// Implementation of [AuthRemoteDataSource].
///
/// Uses Dio HTTP client to communicate with the backend API.
/// Handles secure token storage to flutter_secure_storage.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required this.dioClient,
    FlutterSecureStorage? secureStorage,
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage();

  final DioClient dioClient;
  final FlutterSecureStorage secureStorage;

  @override
  Future<void> sendMagicLink(String email) async {
    try {
      await dioClient.dio.post(
        '/api/v1/auth/magic-link',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to send magic link: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.toString(),
      );
    }
  }

  @override
  Future<dynamic> verifyMagicLink({
    required String email,
    required String code,
  }) async {
    try {
      final response = await dioClient.dio.post(
        '/api/v1/auth/verify-magic-link',
        data: {'email': email, 'code': code},
      );

      // Parse the response
      final responseModel = VerifyMagicLinkResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Store tokens securely
      await secureStorage.write(
        key: 'accessToken',
        value: responseModel.accessToken,
      );
      await secureStorage.write(
        key: 'refreshToken',
        value: responseModel.refreshToken,
      );

      // Return the parsed user model (Trainer or Client)
      return responseModel.parseUser();
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to verify magic link: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.toString(),
      );
    }
  }

  @override
  Future<dynamic> getCurrentUser() async {
    try {
      // Retrieve access token from secure storage
      final accessToken = await secureStorage.read(key: 'accessToken');

      // Throw CacheException if no token is stored
      if (accessToken == null || accessToken.isEmpty) {
        throw CacheException(
          message: 'No access token stored. User must authenticate first.',
        );
      }

      // Make request to /api/v1/auth/me endpoint
      final response = await dioClient.dio.post(
        '/api/v1/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      // Parse the response
      final responseModel = VerifyMagicLinkResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Return the parsed user model (Trainer or Client)
      return responseModel.parseUser();
    } on CacheException {
      rethrow;
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to get current user: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.toString(),
      );
    }
  }
}
