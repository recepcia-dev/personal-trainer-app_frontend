import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentIntent;

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/client_store_datasource.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/models/client_subscription_model.dart';
import '../../data/models/workout_pack_model.dart';

/// Client store data source provider
final clientStoreDataSourceProvider = Provider<ClientStoreDataSource>((ref) {
  return ClientStoreDataSource(dio: DioClient().dio);
});

/// Client subscription provider
final clientSubscriptionProvider = FutureProvider<ClientSubscriptionInfo>((ref) async {
  final dataSource = ref.watch(clientStoreDataSourceProvider);
  return await dataSource.getSubscription();
});

/// Workout packs provider (available for purchase)
final workoutPacksProvider = FutureProvider.family<WorkoutPackListResponse, Map<String, String?>>(
  (ref, filters) async {
    final dataSource = ref.watch(clientStoreDataSourceProvider);
    return await dataSource.getWorkoutPacks(
      category: filters['category'],
      difficulty: filters['difficulty'],
    );
  },
);

/// All workout packs provider (no filters)
final allWorkoutPacksProvider = FutureProvider<WorkoutPackListResponse>((ref) async {
  final dataSource = ref.watch(clientStoreDataSourceProvider);
  return await dataSource.getWorkoutPacks();
});

/// Purchased workout packs provider
final purchasedPacksProvider = FutureProvider<WorkoutPackListResponse>((ref) async {
  final dataSource = ref.watch(clientStoreDataSourceProvider);
  return await dataSource.getPurchasedPacks();
});

/// Workout pack detail provider
final workoutPackDetailProvider = FutureProvider.family<WorkoutPackModel, String>(
  (ref, packId) async {
    final dataSource = ref.watch(clientStoreDataSourceProvider);
    return await dataSource.getWorkoutPackDetail(packId);
  },
);

/// Purchase workout pack state notifier
class PurchasePackNotifier extends StateNotifier<AsyncValue<bool>> {
  final ClientStoreDataSource storeDataSource;
  final PaymentRemoteDataSource paymentDataSource;
  final Ref ref;

  PurchasePackNotifier({
    required this.storeDataSource,
    required this.paymentDataSource,
    required this.ref,
  }) : super(const AsyncValue.data(false));

  /// Purchase a workout pack
  /// Returns true if purchase was successful
  Future<bool> purchasePack(WorkoutPackModel pack) async {
    state = const AsyncValue.loading();

    try {
      // 1. Create payment intent
      final paymentIntent = await paymentDataSource.createPaymentIntent(
        amount: pack.priceCents,
        currency: pack.currency,
        metadata: {
          'type': 'workout_pack',
          'pack_id': pack.id,
          'pack_name': pack.name,
        },
      );

      // 2. Initialize Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          merchantDisplayName: 'Personal Trainer App',
          style: ThemeMode.system,
        ),
      );

      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Record purchase in backend
      await storeDataSource.recordPurchase(pack.id);

      // 5. Refresh purchased packs
      ref.invalidate(purchasedPacksProvider);
      ref.invalidate(allWorkoutPacksProvider);

      state = const AsyncValue.data(true);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data(false);
  }
}

/// Purchase pack provider
final purchasePackProvider = StateNotifierProvider<PurchasePackNotifier, AsyncValue<bool>>((ref) {
  return PurchasePackNotifier(
    storeDataSource: ref.watch(clientStoreDataSourceProvider),
    paymentDataSource: PaymentRemoteDataSourceImpl(dio: DioClient().dio),
    ref: ref,
  );
});
