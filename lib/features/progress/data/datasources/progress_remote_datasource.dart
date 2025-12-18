import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/progress_log_model.dart';

/// Remote data source for progress data - handles API calls
abstract class ProgressRemoteDataSource {
  /// Log an exercise to backend
  Future<ProgressLogModel> logExercise({
    required String exerciseId,
    required int setsCompleted,
    required int repsPerSet,
    double? weightKg,
    int? durationSeconds,
    String? notes,
  });

  /// Fetch progress logs from backend
  Future<List<ProgressLogModel>> fetchProgressLogs({
    String? exerciseId,
  });

  /// Get progress statistics
  Future<Map<String, dynamic>> getProgressStats();

  /// Get exercise history
  Future<Map<String, dynamic>> getExerciseHistory(String exerciseId);
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  final Dio dio;

  ProgressRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProgressLogModel> logExercise({
    required String exerciseId,
    required int setsCompleted,
    required int repsPerSet,
    double? weightKg,
    int? durationSeconds,
    String? notes,
  }) async {
    try {
      final payload = {
        'exercise_id': exerciseId,
        'sets_completed': setsCompleted,
        'reps_per_set': repsPerSet,
        if (weightKg != null) 'weight_kg': weightKg,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
        if (notes != null) 'notes': notes,
      };

      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.progressLogs}',
        data: payload,
      );

      if (response.statusCode == 201) {
        return ProgressLogModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to log exercise: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to log exercise: ${e.message}');
    }
  }

  @override
  Future<List<ProgressLogModel>> fetchProgressLogs({
    String? exerciseId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (exerciseId != null) queryParams['exercise_id'] = exerciseId;

      final response = await dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.progressLogs}',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ProgressLogModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch logs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch logs: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getProgressStats() async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.progressStats}',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch stats: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch stats: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getExerciseHistory(String exerciseId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.progressHistory}/$exerciseId',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch history: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch history: ${e.message}');
    }
  }
}
