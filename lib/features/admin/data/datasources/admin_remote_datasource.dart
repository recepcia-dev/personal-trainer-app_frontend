import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';

/// Remote data source for admin operations
abstract class AdminRemoteDataSource {
  /// Get platform statistics
  Future<Map<String, dynamic>> getStats();

  /// Get all users with pagination
  Future<List<Map<String, dynamic>>> getUsers({
    int skip = 0,
    int limit = 50,
    String? userType,
    bool? isActive,
  });

  /// Get user details
  Future<Map<String, dynamic>> getUser(String userId);

  /// Toggle user active status
  Future<Map<String, dynamic>> toggleUserActive(String userId, bool isActive);

  /// Delete user (soft delete)
  Future<Map<String, dynamic>> deleteUser(String userId);

  /// Get all exercises
  Future<List<Map<String, dynamic>>> getExercises({
    int skip = 0,
    int limit = 50,
  });

  /// Send broadcast notification
  Future<Map<String, dynamic>> sendBroadcast(String title, String message);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio dio;

  AdminRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.adminStats}',
      );
      return response.data!;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUsers({
    int skip = 0,
    int limit = 50,
    String? userType,
    bool? isActive,
  }) async {
    try {
      final params = {
        'skip': skip,
        'limit': limit,
        if (userType != null) 'user_type': userType,
        if (isActive != null) 'is_active': isActive,
      };

      final response = await dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.adminUsers}',
        queryParameters: params,
      );

      final data = response.data?['items'] as List<dynamic>?;
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.adminUsers}/$userId',
      );
      return response.data!;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> toggleUserActive(String userId, bool isActive) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.adminUsers}/$userId/activate',
        data: {'is_active': isActive},
      );
      return response.data!;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await dio.delete<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.adminUsers}/$userId',
      );
      return response.data!;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getExercises({
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final params = {'skip': skip, 'limit': limit};

      final response = await dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.adminExercises}',
        queryParameters: params,
      );

      final data = response.data?['items'] as List<dynamic>?;
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> sendBroadcast(String title, String message) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.adminStats.replaceFirst('/stats', '/broadcast')}',
        data: {'title': title, 'message': message},
      );
      return response.data!;
    } on DioException {
      rethrow;
    }
  }
}
