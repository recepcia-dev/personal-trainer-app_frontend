import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/assigned_workout_model.dart';

/// Remote data source for client workout operations
abstract class ClientWorkoutDataSource {
  /// Get workouts assigned to the authenticated client
  Future<List<AssignedWorkoutModel>> getAssignedWorkouts();

  /// Get workout detail by assignment ID
  Future<AssignedWorkoutModel> getWorkoutDetail(String assignmentId);

  /// Mark a workout assignment as complete
  Future<AssignedWorkoutModel> markWorkoutComplete(String assignmentId);

  /// Get completed workout history
  Future<List<AssignedWorkoutModel>> getCompletedWorkouts();
}

class ClientWorkoutDataSourceImpl implements ClientWorkoutDataSource {
  final Dio dio;

  ClientWorkoutDataSourceImpl({required this.dio});

  @override
  Future<List<AssignedWorkoutModel>> getAssignedWorkouts() async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/client/workouts',
      );

      if (response.statusCode == 200) {
        final items = response.data as List<dynamic>;
        return items
            .map((json) => AssignedWorkoutModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch assigned workouts: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch assigned workouts: ${e.message}');
    }
  }

  @override
  Future<AssignedWorkoutModel> getWorkoutDetail(String assignmentId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/client/workouts/$assignmentId',
      );

      if (response.statusCode == 200) {
        return AssignedWorkoutModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch workout detail: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch workout detail: ${e.message}');
    }
  }

  @override
  Future<AssignedWorkoutModel> markWorkoutComplete(String assignmentId) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/api/v1/client/workouts/$assignmentId/complete',
      );

      if (response.statusCode == 200) {
        return AssignedWorkoutModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to mark workout complete: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to mark workout complete: ${e.message}');
    }
  }

  @override
  Future<List<AssignedWorkoutModel>> getCompletedWorkouts() async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/client/workouts/history/completed',
      );

      if (response.statusCode == 200) {
        final items = response.data as List<dynamic>;
        return items
            .map((json) => AssignedWorkoutModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch completed workouts: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch completed workouts: ${e.message}');
    }
  }
}
