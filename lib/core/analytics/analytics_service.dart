import 'package:firebase_analytics/firebase_analytics.dart';

/// Service for managing Firebase Analytics events and screen tracking
class AnalyticsService {
  final FirebaseAnalytics _firebaseAnalytics;

  AnalyticsService({
    required FirebaseAnalytics firebaseAnalytics,
  }) : _firebaseAnalytics = firebaseAnalytics;

  /// Initialize Firebase Analytics
  Future<void> initialize() async {
    // FirebaseAnalytics is already initialized by Firebase Core
    // This method is here for consistency with other services
    // Additional configuration can be added here as needed
  }

  /// Log a screen view event
  /// [screenName]: Name of the screen being viewed (e.g., 'login_screen', 'dashboard')
  /// [screenClass]: Optional class name for the screen (e.g., 'LoginScreen')
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _firebaseAnalytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      // Silently fail - analytics errors shouldn't crash the app
    }
  }

  /// Log a custom event
  /// [name]: Event name (e.g., 'workout_created', 'client_added')
  /// [parameters]: Optional map of event parameters
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _firebaseAnalytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Silently fail - analytics errors shouldn't crash the app
    }
  }

  /// Log user property
  /// [name]: Property name (e.g., 'user_type', 'trainer_or_client')
  /// [value]: Property value
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _firebaseAnalytics.setUserProperty(
        name: name,
        value: value,
      );
    } catch (e) {
      // Silently fail - analytics errors shouldn't crash the app
    }
  }

  /// Set user ID for analytics
  /// [userId]: Unique identifier for the user
  Future<void> setUserId(String userId) async {
    try {
      await _firebaseAnalytics.setUserId(id: userId);
    } catch (e) {
      // Silently fail - analytics errors shouldn't crash the app
    }
  }

  /// Clear user ID (on logout)
  Future<void> clearUserId() async {
    try {
      await _firebaseAnalytics.setUserId(id: null);
    } catch (e) {
      // Silently fail - analytics errors shouldn't crash the app
    }
  }

  /// Log authentication event
  /// [method]: Authentication method (e.g., 'magic_link', 'biometric')
  /// [success]: Whether authentication was successful
  Future<void> logLogin({
    required String method,
    required bool success,
  }) async {
    try {
      await _firebaseAnalytics.logEvent(
        name: 'login',
        parameters: {
          'method': method,
          'success': success,
        },
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log workout creation
  /// [workoutId]: ID of the created workout
  /// [workoutName]: Name of the workout
  Future<void> logWorkoutCreated({
    required String workoutId,
    required String workoutName,
  }) async {
    try {
      await _firebaseAnalytics.logEvent(
        name: 'workout_created',
        parameters: {
          'workout_id': workoutId,
          'workout_name': workoutName,
        },
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log payment event
  /// [amount]: Payment amount in cents
  /// [currency]: Currency code (e.g., 'USD')
  /// [success]: Whether payment was successful
  Future<void> logPayment({
    required int amount,
    required String currency,
    required bool success,
  }) async {
    try {
      await _firebaseAnalytics.logEvent(
        name: 'payment',
        parameters: {
          'amount': amount,
          'currency': currency,
          'success': success,
        },
      );
    } catch (e) {
      // Silently fail
    }
  }
}
