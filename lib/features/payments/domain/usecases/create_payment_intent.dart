import 'package:dartz/dartz.dart';

import '../../../../core/failure.dart';
import '../entities/payment_intent.dart';
import '../repositories/payment_repository.dart';

/// Use case for creating a payment intent
class CreatePaymentIntent {
  final PaymentRepository repository;

  CreatePaymentIntent(this.repository);

  Future<Either<Failure, PaymentIntent>> call({
    required int amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) =>
      repository.createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );
}
