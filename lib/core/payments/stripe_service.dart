import 'package:dartz/dartz.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/payments/domain/entities/payment_intent.dart'
    as payment_intent;
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
}
