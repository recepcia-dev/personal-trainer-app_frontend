import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/subscription_info.dart';
import '../../domain/entities/payment_intent.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

/// Implementation of payment repository
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaymentIntent>> createPaymentIntent({
    required int amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    // Payments require network connection
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(
        'No internet connection. Cannot process payment.',
      ));
    }

    try {
      final intent = await remoteDataSource.createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );
      return Right(intent);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, originalError: e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, originalError: e));
    } catch (e) {
      return Left(ServerFailure('Failed to create payment intent: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionInfo>> getSubscriptionInfo() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(
        'No internet connection.',
      ));
    }

    try {
      final model = await remoteDataSource.getSubscriptionInfo();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, originalError: e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, originalError: e));
    } catch (e) {
      return Left(ServerFailure('Failed to get subscription info: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionInfo>> updateSubscriptionPlan({
    required String plan,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(
        'No internet connection.',
      ));
    }

    try {
      final model = await remoteDataSource.updateSubscriptionPlan(plan: plan);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, originalError: e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, originalError: e));
    } catch (e) {
      return Left(ServerFailure('Failed to update subscription plan: $e'));
    }
  }
}
