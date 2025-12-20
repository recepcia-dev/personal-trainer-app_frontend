import 'package:dartz/dartz.dart';

import '../../../../core/failure.dart';
import '../entities/subscription_info.dart';
import '../entities/payment_intent.dart';

/// Abstract repository for payment operations
abstract class PaymentRepository {
  /// Create a payment intent for Stripe
  /// [amount]: Amount in cents
  /// [currency]: Currency code (e.g., 'usd')
  /// [metadata]: Additional metadata to attach to the payment
  Future<Either<Failure, PaymentIntent>> createPaymentIntent({
    required int amount,
    required String currency,
    Map<String, dynamic>? metadata,
  });

  /// Get current user's subscription information
  Future<Either<Failure, SubscriptionInfo>> getSubscriptionInfo();

  /// Update user's subscription plan (backend will do this via webhook)
  /// [plan]: Plan ID (free, basic, pro)
  Future<Either<Failure, SubscriptionInfo>> updateSubscriptionPlan({
    required String plan,
  });
}
