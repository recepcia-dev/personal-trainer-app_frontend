import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static late String baseUrl;
  static late String stripePublishableKey;
  static late String firebaseOptionsAndroid;
  static late String firebaseOptionsIos;

  static Future<void> load() async {
    await dotenv.load(
      fileName: '.env.${const String.fromEnvironment('ENV', defaultValue: 'development')}',
    );

    baseUrl = dotenv.env['API_BASE_URL']!;
    stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
    firebaseOptionsAndroid = dotenv.env['FIREBASE_OPTIONS_ANDROID']!;
    firebaseOptionsIos = dotenv.env['FIREBASE_OPTIONS_IOS']!;
  }
}
