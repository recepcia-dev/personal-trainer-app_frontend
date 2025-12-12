import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Service for managing Firebase Crashlytics error reporting and crash tracking
class CrashlyticsService {
  CrashlyticsService({
    required FirebaseCrashlytics firebaseCrashlytics,
  }) : _firebaseCrashlytics = firebaseCrashlytics;

  final FirebaseCrashlytics _firebaseCrashlytics;

  /// Initialize Firebase Crashlytics
  ///
  /// Sets up crash reporting and enables automated crash collection.
  /// Called during app startup before running the main app.
  Future<void> initialize() async {
    try {
      // Enable collection of crash reports
      // This is essential for Crashlytics to start collecting crashes
      await _firebaseCrashlytics.setCrashlyticsCollectionEnabled(true);
    } catch (e) {
      // Silently fail - Crashlytics initialization errors shouldn't crash the app
    }
  }

  /// Record an error with optional reason and stack trace
  ///
  /// Use this to manually record errors that may not crash the app
  /// but should be logged for debugging and monitoring.
  ///
  /// Parameters:
  ///   - error: The error object (Exception, Error, or any object)
  ///   - stackTrace: The stack trace associated with the error
  ///   - reason: Optional human-readable description of the error context
  Future<void> recordError(
    dynamic error,
    StackTrace stackTrace, {
    dynamic reason,
  }) async {
    try {
      await _firebaseCrashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: false,
      );
    } catch (e) {
      // Silently fail - error recording shouldn't crash the app
    }
  }

  /// Record a fatal error that crashes the app
  ///
  /// Use this for unrecoverable errors that terminate the app execution.
  ///
  /// Parameters:
  ///   - error: The error object
  ///   - stackTrace: The stack trace
  ///   - reason: Optional description of the fatal error
  Future<void> recordFatalError(
    dynamic error,
    StackTrace stackTrace, {
    dynamic reason,
  }) async {
    try {
      await _firebaseCrashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: true,
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Set user identifier for crash reporting
  ///
  /// Associates crash reports with a specific user ID.
  /// Called after successful authentication to track user-specific crashes.
  ///
  /// Parameters:
  ///   - userId: Unique identifier for the user (email, UUID, etc.)
  Future<void> setUserId(String userId) async {
    try {
      await _firebaseCrashlytics.setUserIdentifier(userId);
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear user identifier on logout
  ///
  /// Removes user association from future crash reports.
  /// Call this when the user logs out to prevent crash reports being
  /// attributed to the wrong user.
  Future<void> clearUserId() async {
    try {
      await _firebaseCrashlytics.setUserIdentifier('');
    } catch (e) {
      // Silently fail
    }
  }

  /// Set custom user properties for crash context
  ///
  /// Attach additional metadata to crash reports for better debugging.
  /// Common properties: user_type (trainer/client), subscription_tier, etc.
  ///
  /// Parameters:
  ///   - key: Property name
  ///   - value: Property value
  Future<void> setUserProperty({
    required String key,
    required String value,
  }) async {
    try {
      await _firebaseCrashlytics.setCustomKey(key, value);
    } catch (e) {
      // Silently fail
    }
  }

  /// Log a custom message for debugging context
  ///
  /// Adds a debug message to the crash log that will be visible
  /// in the Crashlytics console when a crash is reported.
  ///
  /// Parameters:
  ///   - message: Debug message to log
  void logMessage(String message) {
    try {
      _firebaseCrashlytics.log(message);
    } catch (e) {
      // Silently fail
    }
  }
}
