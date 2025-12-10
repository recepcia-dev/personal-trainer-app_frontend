import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/app_constants.dart';

/// Interface for providing authentication tokens to the HTTP client.
///
/// Implementations will be provided by the auth layer (e.g., AuthLocalDataSource)
/// to retrieve stored access and refresh tokens.
abstract class TokenProvider {
  /// Get the current access token
  Future<String?> getAccessToken();

  /// Get the current refresh token
  Future<String?> getRefreshToken();

  /// Save new tokens after refresh
  Future<void> saveTokens(String accessToken, String refreshToken);
}

/// Dio HTTP client instance configured for the application.
///
/// This client handles:
/// - Base URL configuration from environment
/// - Bearer token authentication via AuthInterceptor
/// - Request/response logging in debug mode
/// - Error handling for network operations
class DioClient {
  static final DioClient _instance = DioClient._internal();

  late final Dio _dio;
  static TokenProvider? _tokenProvider;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());

    // Add pretty logger only in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: false,
          maxWidth: 90,
        ),
      );
    }
  }

  /// Get the singleton instance of DioClient
  factory DioClient() {
    return _instance;
  }

  /// Set the token provider for authentication
  ///
  /// This should be called once the auth layer is initialized
  /// (typically in main() after AppConstants.load())
  static void setTokenProvider(TokenProvider provider) {
    _tokenProvider = provider;
  }

  /// Get the underlying Dio instance
  Dio get dio => _dio;
}

/// Interceptor that adds Bearer token to requests.
///
/// This interceptor reads the access token from the token provider
/// and adds it to the Authorization header of every request.
/// If no token is available, the request proceeds without auth.
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add Bearer token to Authorization header if available
    if (DioClient._tokenProvider != null) {
      final token = await DioClient._tokenProvider!.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 errors (unauthorized - token expired)
    // This can be extended later to implement token refresh logic
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh:
      // 1. Get refresh token from token provider
      // 2. Call /api/v1/auth/refresh endpoint
      // 3. Save new tokens
      // 4. Retry original request
    }

    handler.next(err);
  }
}
