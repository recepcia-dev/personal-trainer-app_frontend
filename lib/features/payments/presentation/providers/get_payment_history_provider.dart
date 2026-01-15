import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/get_payment_history.dart';
import 'payment_repository_provider.dart';

part 'get_payment_history_provider.g.dart';

/// Provider for GetPaymentHistory use case
@riverpod
GetPaymentHistory getPaymentHistoryUseCase(GetPaymentHistoryUseCaseRef ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetPaymentHistory(repository);
}
