import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/payments/domain/entities/payment_intent.dart'
    as payment_intent;
import '../../features/payments/domain/entities/payment_result.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';

/// Service for initializing and managing Stripe SDK.
///
/// Handles Stripe SDK initialization with publishable key from environment.
/// Keys differ between development and production via AppConstants.
/// Also manages payment intent creation and payment sheet operations.
class StripeService {
  /// Create StripeService instance with required dependencies.
  const StripeService({
    required this.authRemoteDataSource,
  });

  /// Remote data source for API calls
  final AuthRemoteDataSource authRemoteDataSource;

  /// Initialize Stripe SDK with publishable key and settings.
  ///
  /// This must be called once during app startup before any payment operations.
  /// The publishable key is loaded from environment variables (.env.development or .env.production).
  static Future<void> init() async {
    Stripe.publishableKey = AppConstants.stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  /// Validate payment sheet parameters before initialization
  ///
  /// Ensures client secret and merchant name are valid before passing to Stripe SDK.
  void _validatePaymentSheetParameters({
    required String clientSecret,
    required String merchantDisplayName,
  }) {
    if (clientSecret.isEmpty) {
      throw ArgumentError('Client secret cannot be empty');
    }
    if (merchantDisplayName.isEmpty) {
      throw ArgumentError('Merchant display name cannot be empty');
    }
  }

  /// Create a payment intent for processing payments.
  ///
  /// Calls the backend API to create a Stripe payment intent with the client secret.
  /// The client secret is used to initialize the payment sheet for payment processing.
  ///
  /// Parameters:
  ///   - amount: Payment amount in cents (e.g., 1000 = $10.00)
  ///   - currency: Currency code (e.g., 'USD')
  ///   - metadata: Optional metadata to attach to the payment intent
  ///
  /// Returns:
  ///   - Right(PaymentIntent) on success containing client secret for payment sheet
  ///   - Left(ServerFailure) if backend API fails
  ///   - Left(CacheFailure) if no access token available
  Future<Either<Failure, payment_intent.PaymentIntent>> createPaymentIntent({
    required int amount,
    required String currency,
    Map<String, String>? metadata,
  }) async {
    try {
      // Call backend API to create payment intent
      final paymentIntentModel = await authRemoteDataSource.createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );

      // Return the payment intent with client secret
      // Client secret is used to initialize payment sheet in presentation layer (F040)
      return Right(paymentIntentModel);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    } on CacheException catch (e) {
      return Left(
        CacheFailure(message: e.message),
      );
    } catch (e) {
      return Left(
        CacheFailure(message: 'Unexpected error: $e'),
      );
    }
  }

  /// Present the Stripe payment sheet to process a payment.
  ///
  /// Initializes and displays the Stripe payment sheet for the user to enter
  /// payment details and complete payment processing. The payment intent must be
  /// created first via [createPaymentIntent] to obtain the client secret.
  ///
  /// Parameters:
  ///   - clientSecret: Client secret from PaymentIntent (from createPaymentIntent)
  ///   - merchantDisplayName: Display name of the merchant in payment sheet
  ///   - theme: Optional theme (light, dark, system) for payment sheet UI
  ///
  /// Returns:
  ///   - Right(PaymentResult) on successful payment containing payment intent ID
  ///   - Left(ServerFailure) if payment is cancelled or fails
  ///
  /// Flow:
  ///   1. Validates client secret format
  ///   2. Initializes Stripe payment sheet with merchant details
  ///   3. Presents payment sheet UI to user
  ///   4. Handles successful payment and returns PaymentResult
  ///   5. Catches cancellation (FailureCode.Canceled) and other errors
  ///
  /// Note: Full Stripe UI presentation and payment processing requires integration
  /// testing on actual device/emulator. Unit tests verify error handling logic.
  Future<Either<Failure, PaymentResult>> presentPaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
    ThemeMode theme = ThemeMode.system,
  }) async {
    try {
      // Validate client secret format - should be "pi_<id>_secret_<secret>"
      if (!clientSecret.contains('_secret_')) {
        return Left(
          ServerFailure(
            message: 'Invalid client secret format',
            statusCode: 400,
          ),
        );
      }

      // Extract payment intent ID from client secret
      final paymentIntentId = clientSecret.split('_secret_').first;

      // Initialize and present Stripe payment sheet
      try {
        // Validate parameters before Stripe SDK call
        _validatePaymentSheetParameters(
          clientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
        );

        // Initialize payment sheet with payment intent details
        // SetupPaymentSheetParameters configures the payment sheet UI
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: merchantDisplayName,
            style: theme,
          ),
        );

        // Present the payment sheet UI to the user
        // The user enters payment details and completes payment here
        await Stripe.instance.presentPaymentSheet();
      } on StripeException catch (e) {
        // Handle Stripe-specific exceptions
        if (e.error.code == FailureCode.Canceled) {
          // User cancelled the payment sheet
          return Left(
            ServerFailure(
              message: 'Payment cancelled by user',
              statusCode: 0,
            ),
          );
        }

        // Other Stripe errors (card declined, validation error, etc.)
        return Left(
          ServerFailure(
            message: e.error.message ?? 'Payment failed',
            statusCode: 0,
          ),
        );
      }

      // Payment successful - return result with payment intent ID
      return Right(PaymentResult(paymentIntentId: paymentIntentId));
    } catch (e) {
      // Unexpected errors
      return Left(
        ServerFailure(
          message: 'Unexpected payment error: $e',
          statusCode: 0,
        ),
      );
    }
  }
}
