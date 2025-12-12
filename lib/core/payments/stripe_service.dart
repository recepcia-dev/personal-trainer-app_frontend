import 'package:flutter_stripe/flutter_stripe.dart';

import '../constants/app_constants.dart';

/// Service for initializing and managing Stripe SDK.
///
/// Handles Stripe SDK initialization with publishable key from environment.
/// Keys differ between development and production via AppConstants.
class StripeService {
  /// Initialize Stripe SDK with publishable key and settings.
  ///
  /// This must be called once during app startup before any payment operations.
  /// The publishable key is loaded from environment variables (.env.development or .env.production).
  static Future<void> init() async {
    Stripe.publishableKey = AppConstants.stripePublishableKey;
    await Stripe.instance.applySettings();
  }
}
