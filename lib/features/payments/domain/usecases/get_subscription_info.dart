import 'package:dartz/dartz.dart';

import '../../../../core/failure.dart';
import '../entities/subscription_info.dart';
import '../repositories/payment_repository.dart';

/// Use case for getting subscription information
class GetSubscriptionInfo {
  final PaymentRepository repository;

  GetSubscriptionInfo(this.repository);

  Future<Either<Failure, SubscriptionInfo>> call() =>
      repository.getSubscriptionInfo();
}
