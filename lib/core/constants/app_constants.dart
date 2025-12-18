import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Initialize with sensible defaults
  static String baseUrl = 'http://localhost:8000';
  static String stripePublishableKey = 'pk_test_51234567890abcdefghijklmnop';
  static String firebaseOptionsAndroid = '{}';
  static String firebaseOptionsIos = '{}';

  static Future<void> load() async {
    if (kIsWeb) {
      // Skip .env loading on web, use defaults
      return;
    }

    try {
      await dotenv.load(
        fileName: '.env.${const String.fromEnvironment('ENV', defaultValue: 'development')}',
      );

      baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
      stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 'pk_test_51234567890abcdefghijklmnop';
      firebaseOptionsAndroid = dotenv.env['FIREBASE_OPTIONS_ANDROID'] ?? '{}';
      firebaseOptionsIos = dotenv.env['FIREBASE_OPTIONS_IOS'] ?? '{}';
    } catch (e) {
      // Fallback to development defaults if .env file not found
      baseUrl = 'http://localhost:8000';
      stripePublishableKey = 'pk_test_51234567890abcdefghijklmnop';
      firebaseOptionsAndroid = '{}';
      firebaseOptionsIos = '{}';
    }
  }
}
