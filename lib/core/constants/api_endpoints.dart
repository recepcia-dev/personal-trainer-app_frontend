/// API endpoints constants
class ApiEndpoints {
  // Base URL for API (configured via environment)
  static const String baseUrl = 'http://localhost:8000';

  // API version prefix
  static const String apiV1 = '/api/v1';

  // Authentication endpoints
  static const String magicLink = '$apiV1/auth/magic-link';
  static const String verifyMagicLink = '$apiV1/auth/verify-magic-link';
  static const String bindDevice = '$apiV1/auth/bind-device';
  static const String getCurrentUser = '$apiV1/auth/me';
  static const String logout = '$apiV1/auth/logout';

  // Exercise endpoints
  static const String exercises = '$apiV1/exercises';

  // Clients endpoints
  static const String clients = '$apiV1/clients';

  // Workouts endpoints
  static const String workouts = '$apiV1/workouts';

  // Progress endpoints
  static const String progressLogs = '$apiV1/progress/logs';
  static const String progressStats = '$apiV1/progress/stats';
  static const String progressHistory = '$apiV1/progress/history';

  // Payment endpoints
  static const String createPaymentIntent = '$apiV1/payments/create-intent';
  static const String paymentWebhook = '$apiV1/payments/webhook';

  // Subscription endpoints
  static const String getSubscriptionInfo = '$apiV1/auth/me/subscription';
  static const String updateSubscriptionPlan = '$apiV1/auth/me/subscription';

  // Notification endpoints
  static const String registerFcmToken = '$apiV1/notifications/register-token';

  // Admin endpoints
  static const String adminStats = '$apiV1/admin/stats';
  static const String adminUsers = '$apiV1/admin/users';
  static const String adminExercises = '$apiV1/admin/exercises';
}
