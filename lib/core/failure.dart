/// Base failure class for error handling
abstract class Failure {
  final String message;
  final dynamic originalError;

  Failure({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Server/API failure
class ServerFailure extends Failure {
  ServerFailure(String message, {dynamic originalError})
      : super(message: message, originalError: originalError);
}

/// Network failure
class NetworkFailure extends Failure {
  NetworkFailure(String message, {dynamic originalError})
      : super(message: message, originalError: originalError);
}

/// Cache/Local storage failure
class CacheFailure extends Failure {
  CacheFailure(String message, {dynamic originalError})
      : super(message: message, originalError: originalError);
}

/// Validation failure
class ValidationFailure extends Failure {
  ValidationFailure(String message, {dynamic originalError})
      : super(message: message, originalError: originalError);
}

/// Authentication failure
class AuthenticationFailure extends Failure {
  AuthenticationFailure(String message, {dynamic originalError})
      : super(message: message, originalError: originalError);
}
