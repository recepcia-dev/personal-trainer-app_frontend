import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/create_payment_intent.dart';
import '../../domain/usecases/get_subscription_info.dart';

/// Remote data source provider
final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((ref) {
  final dio = DioClient().dio;
  return PaymentRemoteDataSourceImpl(dio: dio);
});

/// Network info provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

/// Payment repository provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    remoteDataSource: ref.watch(paymentRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

/// Create payment intent use case provider
final createPaymentIntentUseCaseProvider = Provider<CreatePaymentIntent>((ref) {
  return CreatePaymentIntent(ref.watch(paymentRepositoryProvider));
});

/// Get subscription info use case provider
final getSubscriptionInfoUseCaseProvider = Provider<GetSubscriptionInfo>((ref) {
  return GetSubscriptionInfo(ref.watch(paymentRepositoryProvider));
});
