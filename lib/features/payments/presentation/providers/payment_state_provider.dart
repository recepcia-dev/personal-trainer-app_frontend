import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentIntent;

import '../../domain/entities/payment_intent.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/entities/subscription_info.dart';
import '../providers/payment_repository_provider.dart';
import '../providers/subscription_info_provider.dart';

/// Payment state provider for handling payment operations
final paymentStateProvider =
    StateNotifierProvider<PaymentStateNotifier, AsyncValue<PaymentIntent?>>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentStateNotifier(repository: repository, ref: ref);
});

/// State notifier for managing payment state
class PaymentStateNotifier extends StateNotifier<AsyncValue<PaymentIntent?>> {
  final PaymentRepository repository;
  final Ref ref;

  PaymentStateNotifier({
    required this.repository,
    required this.ref,
  }) : super(const AsyncValue.data(null));

  /// Create payment intent for given amount
  Future<bool> createPayment({
    required int amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    state = const AsyncValue.loading();

    final result = await repository.createPaymentIntent(
      amount: amount,
      currency: currency,
      metadata: metadata,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (intent) {
        state = AsyncValue.data(intent);
        return true;
      },
    );
  }

  /// Present payment sheet and process payment
  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      // Refresh subscription info after successful payment
      // This will trigger the webhook update from backend
      ref.refresh(subscriptionInfoProvider);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Reset payment state
  void reset() {
    state = const AsyncValue.data(null);
  }
}