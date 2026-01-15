import 'package:dartz/dartz.dart';

import '../../../../core/failure.dart';
import '../entities/payment_history.dart';
import '../repositories/payment_repository.dart';

/// Use case to retrieve user's payment history
class GetPaymentHistory {
  final PaymentRepository repository;

  GetPaymentHistory(this.repository);

  Future<Either<Failure, List<PaymentHistory>>> call({
    int limit = 50,
    int offset = 0,
  }) async {
    return repository.getPaymentHistory(limit: limit, offset: offset);
  }
}
