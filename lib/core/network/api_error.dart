/// Represents a structured error response from the API
/// Most backend endpoints return JSON with error details
class ApiError {
  final String? error;
  final String? message;
  final dynamic detail;
  final int? statusCode;

  ApiError({
    this.error,
    this.message,
    this.detail,
    this.statusCode,
  });

  /// Parse API error from response data (JSON)
  /// Handles both structured error responses and plain text responses
  factory ApiError.fromResponse({
    required dynamic responseData,
    required int? statusCode,
  }) {
    // Handle JSON responses with error structure
    if (responseData is Map<String, dynamic>) {
      return ApiError(
        error: responseData['error'] as String?,
        message: responseData['message'] as String?,
        detail: responseData['detail'],
        statusCode: statusCode,
      );
    }

    // Handle plain text responses
    if (responseData is String) {
      return ApiError(
        message: responseData,
        statusCode: statusCode,
      );
    }

    // Fallback for other response types
    return ApiError(
      message: responseData?.toString() ?? 'Unknown error',
      statusCode: statusCode,
    );
  }

  /// Get human-readable error message for display
  /// Prefers structured error message, falls back to HTTP status
  String getDisplayMessage() {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }

    if (error != null && error!.isNotEmpty) {
      return error!;
    }

    if (statusCode != null) {
      return 'HTTP ${statusCode} error';
    }

    return 'An unknown error occurred';
  }

  /// Get detailed error for logging/debugging
  String getDetailedMessage() {
    final parts = <String>[];

    if (error != null && error!.isNotEmpty) {
      parts.add('Error: $error');
    }

    if (message != null && message!.isNotEmpty) {
      parts.add('Message: $message');
    }

    if (detail != null) {
      parts.add('Detail: $detail');
    }

    if (statusCode != null) {
      parts.add('Status: $statusCode');
    }

    return parts.isEmpty ? 'Unknown error' : parts.join(' | ');
  }

  @override
  String toString() => getDetailedMessage();
}
