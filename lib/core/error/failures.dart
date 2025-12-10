import 'package:equatable/equatable.dart';

/// Base failure class for all error types in the application.
///
/// Following Clean Architecture principles, all repository methods return
/// Either<Failure, T> to handle errors in a type-safe manner.
abstract class Failure extends Equatable {
  final String message;

  const Failure({
    this.message = 'An unexpected error occurred',
  });

  @override
  List<Object?> get props => [message];
}

/// Failure returned when the server returns an error response.
///
/// This includes HTTP errors (4xx, 5xx) and server-side business logic errors.
class ServerFailure extends Failure {
  /// Optional HTTP status code (e.g., 401, 403, 500)
  final int? statusCode;

  const ServerFailure({
    String message = 'Server error occurred',
    this.statusCode,
  }) : super(message: message);

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure returned when local cache/database operations fail.
///
/// This includes errors reading from or writing to SQLite database (Drift).
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Cache error occurred',
  }) : super(message: message);
}

/// Failure returned when network connectivity is unavailable or network operations fail.
///
/// This is distinct from ServerFailure - it indicates the request couldn't be sent,
/// not that the server returned an error.
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Network error occurred',
  }) : super(message: message);
}

/// Failure returned when authentication/authorization fails.
///
/// This includes invalid credentials, expired tokens, and insufficient permissions.
class AuthFailure extends Failure {
  const AuthFailure({
    String message = 'Authentication failed',
  }) : super(message: message);
}

/// Failure returned when input validation fails.
///
/// This includes invalid email formats, missing required fields, etc.
class ValidationFailure extends Failure {
  const ValidationFailure({
    String message = 'Validation error',
  }) : super(message: message);
}
