import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';

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
}

/// Implementation of [AuthRemoteDataSource].
///
/// Uses Dio HTTP client to communicate with the backend API.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

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
}
