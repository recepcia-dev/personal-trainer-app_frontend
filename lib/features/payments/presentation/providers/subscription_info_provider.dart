import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/subscription_info.dart';
import './payment_repository_provider.dart';

/// FutureProvider for subscription information
/// Provides async loading, error, and data states
final subscriptionInfoProvider =
    FutureProvider<SubscriptionInfo>((ref) async {
  final useCase = ref.watch(getSubscriptionInfoUseCaseProvider);
  final result = await useCase.call();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (info) => info,
  );
});
