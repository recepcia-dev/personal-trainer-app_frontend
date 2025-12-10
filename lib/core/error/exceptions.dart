/// Base exception class for all custom exceptions in the application.
///
/// These exceptions are thrown in data sources and caught by repositories,
/// which convert them to Failure objects for type-safe error handling.
abstract class AppException implements Exception {
  final String message;

  AppException({required this.message});

  @override
  String toString() => message;
}

/// Exception thrown when the server returns an error response.
///
/// This includes HTTP errors (4xx, 5xx) and server-side business logic errors.
/// Repositories convert this to ServerFailure.
class ServerException extends AppException {
  /// HTTP status code (e.g., 401, 403, 500)
  final int? statusCode;

  /// Response body from the server (for debugging)
  final String? responseBody;

  ServerException({
    required String message,
    this.statusCode,
    this.responseBody,
  }) : super(message: message);
}

/// Exception thrown when local cache/database operations fail.
///
/// This includes errors reading from or writing to SQLite database (Drift).
/// Repositories convert this to CacheFailure.
class CacheException extends AppException {
  CacheException({required String message}) : super(message: message);
}

/// Exception thrown when network connectivity is unavailable or network operations fail.
///
/// This is distinct from ServerException - it indicates the request couldn't be sent,
/// not that the server returned an error.
/// Repositories convert this to NetworkFailure.
class NetworkException extends AppException {
  NetworkException({required String message}) : super(message: message);
}

/// Exception thrown when authentication/authorization fails.
///
/// This includes invalid credentials, expired tokens, and insufficient permissions.
/// Repositories convert this to AuthFailure.
class AuthException extends AppException {
  AuthException({required String message}) : super(message: message);
}

/// Exception thrown when input validation fails.
///
/// This includes invalid email formats, missing required fields, etc.
/// Repositories convert this to ValidationFailure.
class ValidationException extends AppException {
  ValidationException({required String message}) : super(message: message);
}
