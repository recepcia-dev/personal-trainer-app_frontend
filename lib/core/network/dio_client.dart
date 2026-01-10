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
  /// Get the singleton instance of DioClient
  factory DioClient() => _instance;

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

  static final DioClient _instance = DioClient._internal();

  late final Dio _dio;
  static TokenProvider? _tokenProvider;

  /// Set the token provider for authentication
  ///
  /// This should be called once the auth layer is initialized
  /// (typically in main() after AppConstants.load())
  static set tokenProvider(TokenProvider provider) => _tokenProvider = provider;

  /// Check if token provider has been initialized
  static bool get isTokenProviderInitialized => _tokenProvider != null;

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
    debugPrint('');
    debugPrint('╔════════════════════════════════════════════════════════════════╗');
    debugPrint('║                 🔐 AUTH INTERCEPTOR - REQUEST                  ║');
    debugPrint('╚════════════════════════════════════════════════════════════════╝');
    debugPrint('🔐 [AuthInterceptor] Method: ${options.method}');
    debugPrint('🔐 [AuthInterceptor] Full URL: ${options.baseUrl}${options.path}');

    // Add Bearer token to Authorization header if available
    if (DioClient._tokenProvider == null) {
      debugPrint('⚠️ [AuthInterceptor] *** TOKEN PROVIDER IS NOT INITIALIZED ***');
      debugPrint('⚠️ Request will be sent WITHOUT Authorization header');
      debugPrint('📋 [AuthInterceptor] Headers (NO AUTH):');
      _logRequestHeaders(options);
      debugPrint('╚════════════════════════════════════════════════════════════════╝');
      handler.next(options);
      return;
    }

    debugPrint('✅ [AuthInterceptor] Token provider is initialized');
    debugPrint('🔐 [AuthInterceptor] Attempting to retrieve access token...');

    try {
      final token = await DioClient._tokenProvider!.getAccessToken();

      debugPrint('🔐 [AuthInterceptor] Token retrieval completed');

      if (token != null && token.isNotEmpty) {
        debugPrint('✅ [AuthInterceptor] Token IS present (not null, not empty)');
        debugPrint('   Token length: ${token.length} characters');
        debugPrint('   Token preview: ${token.substring(0, 30)}...');
        debugPrint('🔐 [AuthInterceptor] Adding Authorization header to request...');
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('✅ [AuthInterceptor] Authorization header successfully added');
      } else {
        debugPrint('❌ [AuthInterceptor] TOKEN IS NULL OR EMPTY!');
        if (token == null) {
          debugPrint('   Token is: NULL');
        } else {
          debugPrint('   Token is: EMPTY STRING');
        }
        debugPrint('❌ Request will be sent WITHOUT Authorization header');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthInterceptor] EXCEPTION while retrieving token!');
      debugPrint('   Exception: $e');
      debugPrint('   Stack: $stackTrace');
    }

    // Log all headers and body before sending request
    debugPrint('📋 [AuthInterceptor] Final headers being sent:');
    _logRequestHeaders(options);

    debugPrint('╚════════════════════════════════════════════════════════════════╝');
    debugPrint('');

    handler.next(options);
  }

  /// Helper method to log all request headers
  void _logRequestHeaders(RequestOptions options) {
    debugPrint('📋 [AuthInterceptor] Headers being sent:');
    options.headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        // Mask most of the token for security
        final maskedValue = (value as String?)?.replaceRange(10, null, '***') ?? 'null';
        debugPrint('   ✅ $key: $maskedValue (PRESENT)');
      } else {
        debugPrint('   • $key: $value');
      }
    });

    // Log request body for POST/PUT requests
    if ((options.method == 'POST' || options.method == 'PUT') && options.data != null) {
      debugPrint('📝 [AuthInterceptor] Request body:');
      if (options.data is Map) {
        final data = options.data as Map;
        data.forEach((key, value) {
          debugPrint('   • $key: $value');
        });
      } else {
        debugPrint('   • ${options.data}');
      }
    }
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
