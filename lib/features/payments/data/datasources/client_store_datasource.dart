import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/client_subscription_model.dart';
import '../models/workout_pack_model.dart';

/// Data source for client store and subscription operations
class ClientStoreDataSource {
  final Dio dio;

  ClientStoreDataSource({required this.dio});

  /// Get client subscription status
  Future<ClientSubscriptionInfo> getSubscription() async {
    try {
      final response = await dio.get(ApiEndpoints.clientSubscription);
      return ClientSubscriptionInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['detail'] ?? 'Failed to get subscription',
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    }
  }

  /// Get available workout packs
  Future<WorkoutPackListResponse> getWorkoutPacks({
    String? category,
    String? difficulty,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (difficulty != null) queryParams['difficulty'] = difficulty;

      final response = await dio.get(
        ApiEndpoints.workoutStore,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return WorkoutPackListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['detail'] ?? 'Failed to get workout packs',
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    }
  }

  /// Get workout pack details
  Future<WorkoutPackModel> getWorkoutPackDetail(String packId) async {
    try {
      final response = await dio.get('${ApiEndpoints.workoutStore}/$packId');
      return WorkoutPackModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['detail'] ?? 'Failed to get pack details',
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    }
  }

  /// Record workout pack purchase (after successful Stripe payment)
  Future<void> recordPurchase(String packId) async {
    try {
      await dio.post('${ApiEndpoints.workoutStore}/$packId/purchase');
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['detail'] ?? 'Failed to record purchase',
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    }
  }

  /// Get purchased workout packs
  Future<WorkoutPackListResponse> getPurchasedPacks() async {
    try {
      final response = await dio.get(ApiEndpoints.clientPurchases);
      return WorkoutPackListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['detail'] ?? 'Failed to get purchases',
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException(message: e.message ?? 'Network error');
    }
  }
}
