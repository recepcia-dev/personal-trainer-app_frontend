import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/subscription_info_model.dart';
import '../../domain/entities/payment_intent.dart';

/// Abstract payment remote data source
abstract class PaymentRemoteDataSource {
  /// Create payment intent via backend API
  Future<PaymentIntent> createPaymentIntent({
    required int amount,
    required String currency,
    Map<String, dynamic>? metadata,
  });

  /// Get subscription information from backend
  Future<SubscriptionInfoModel> getSubscriptionInfo();

  /// Update subscription plan via backend
  Future<SubscriptionInfoModel> updateSubscriptionPlan({required String plan});
}

/// Implementation of payment remote data source
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaymentIntent> createPaymentIntent({
    required int amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createPaymentIntent,
        data: {
          'amount': amount,
          'currency': currency,
          if (metadata != null) 'metadata': metadata,
        },
      );

      final json = response.data as Map<String, dynamic>;

      return PaymentIntent(
        id: json['id'] ?? '',
        clientSecret: json['client_secret'] ?? '',
        publishableKey: json['publishable_key'] ?? '',
        amount: json['amount'] as int,
        currency: json['currency'] ?? 'usd',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? e.message ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: e.message ?? 'Network error');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to create payment intent: $e');
    }
  }

  @override
  Future<SubscriptionInfoModel> getSubscriptionInfo() async {
    try {
      final response = await dio.get(ApiEndpoints.getSubscriptionInfo);
      final json = response.data as Map<String, dynamic>;

      return SubscriptionInfoModel.fromJson(json);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: e.message ?? 'Network error');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to get subscription info: $e');
    }
  }

  @override
  Future<SubscriptionInfoModel> updateSubscriptionPlan({
    required String plan,
  }) async {
    try {
      final response = await dio.patch(
        ApiEndpoints.updateSubscriptionPlan,
        data: {'plan': plan},
      );

      final json = response.data as Map<String, dynamic>;

      return SubscriptionInfoModel.fromJson(json);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: e.message ?? 'Network error');
      }
    } catch (e) {
      throw ServerException(
        message: 'Failed to update subscription plan: $e',
      );
    }
  }
}
