import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/progress_request_model.dart';

/// Remote data source for progress tracking operations
abstract class ProgressRemoteDataSource {
  /// Register workout progress
  Future<ProgressEntryModel> registerProgress(ProgressRequestModel request);

  /// Get progress history for the authenticated client
  Future<List<ProgressEntryModel>> getProgressHistory({int limit = 50});

  /// Log exercise completion
  Future<dynamic> logExercise({
    required String exerciseId,
    required int setsCompleted,
    required int repsPerSet,
    double? weightKg,
    int? durationSeconds,
    String? notes,
  });

  /// Fetch progress logs
  Future<List<dynamic>> fetchProgressLogs({String? exerciseId});

  /// Get progress statistics
  Future<Map<String, dynamic>> getProgressStats();

  /// Get exercise history
  Future<Map<String, dynamic>> getExerciseHistory(String exerciseId);
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  final Dio dio;

  ProgressRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProgressEntryModel> registerProgress(ProgressRequestModel request) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/api/v1/client/progress',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return ProgressEntryModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to register progress: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to register progress: ${e.message}');
    }
  }

  @override
  Future<List<ProgressEntryModel>> getProgressHistory({int limit = 50}) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/client/progress',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final items = response.data as List<dynamic>;
        return items
            .map((json) => ProgressEntryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch progress history: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch progress history: ${e.message}');
    }
  }

  @override
  Future<dynamic> logExercise({
    required String exerciseId,
    required int setsCompleted,
    required int repsPerSet,
    double? weightKg,
    int? durationSeconds,
    String? notes,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/api/v1/client/exercises/log',
        data: {
          'exercise_id': exerciseId,
          'sets_completed': setsCompleted,
          'reps_per_set': repsPerSet,
          'weight_kg': weightKg,
          'duration_seconds': durationSeconds,
          'notes': notes,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to log exercise: ${e.message}');
    }
  }

  @override
  Future<List<dynamic>> fetchProgressLogs({String? exerciseId}) async {
    try {
      final queryParams = <String, dynamic>{
        if (exerciseId != null) 'exercise_id': exerciseId,
      };
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/client/progress/logs',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to fetch progress logs: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getProgressStats() async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/client/progress/stats',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to get progress stats: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getExerciseHistory(String exerciseId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/client/exercises/$exerciseId/history',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to get exercise history: ${e.message}');
    }
  }
}
