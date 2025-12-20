import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/assigned_workout_model.dart';

/// Remote data source for client workout operations
abstract class ClientWorkoutDataSource {
  /// Get workouts assigned to the authenticated client
  Future<List<AssignedWorkoutModel>> getAssignedWorkouts();
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
}
