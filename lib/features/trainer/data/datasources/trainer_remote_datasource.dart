import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';

/// Remote data source for trainer operations - handles API calls
abstract class TrainerRemoteDataSource {
  /// Get trainer profile
  Future<Map<String, dynamic>> getTrainerProfile();

  /// Get trainer statistics
  Future<Map<String, dynamic>> getTrainerStats();

  /// Assign workout to a client
  Future<void> assignWorkout({
    required String clientId,
    required String workoutId,
    int? sets,
    int? reps,
    double? weightKg,
    int? durationMinutes,
    int? restSeconds,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  });

  /// Assign diet/meal plan to a client
  Future<void> assignDiet({
    required String clientId,
    required String mealName,
    String? ingredients,
    double? caloriesApprox,
    String? macrosJson,
    int servings = 1,
    bool monday = true,
    bool tuesday = true,
    bool wednesday = true,
    bool thursday = true,
    bool friday = true,
    bool saturday = true,
    bool sunday = true,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  });
}

class TrainerRemoteDataSourceImpl implements TrainerRemoteDataSource {
  final Dio dio;

  TrainerRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getTrainerProfile() async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/trainer/profile',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch trainer profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch trainer profile: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getTrainerStats() async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/trainer/stats',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch trainer stats: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch trainer stats: ${e.message}');
    }
  }

  @override
  Future<void> assignWorkout({
    required String clientId,
    required String workoutId,
    int? sets,
    int? reps,
    double? weightKg,
    int? durationMinutes,
    int? restSeconds,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/api/v1/trainer/clients/$clientId/assign-workout',
        data: {
          'workout_id': workoutId,
          if (sets != null) 'sets': sets,
          if (reps != null) 'reps': reps,
          if (weightKg != null) 'weight_kg': weightKg,
          if (durationMinutes != null) 'duration_minutes': durationMinutes,
          if (restSeconds != null) 'rest_seconds': restSeconds,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to assign workout: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to assign workout: ${e.message}');
    }
  }

  @override
  Future<void> assignDiet({
    required String clientId,
    required String mealName,
    String? ingredients,
    double? caloriesApprox,
    String? macrosJson,
    int servings = 1,
    bool monday = true,
    bool tuesday = true,
    bool wednesday = true,
    bool thursday = true,
    bool friday = true,
    bool saturday = true,
    bool sunday = true,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/api/v1/trainer/clients/$clientId/assign-diet',
        data: {
          'meal_name': mealName,
          if (ingredients != null) 'ingredients': ingredients,
          if (caloriesApprox != null) 'calories_approx': caloriesApprox,
          if (macrosJson != null) 'macros_json': macrosJson,
          'servings': servings,
          'monday': monday ? 1 : 0,
          'tuesday': tuesday ? 1 : 0,
          'wednesday': wednesday ? 1 : 0,
          'thursday': thursday ? 1 : 0,
          'friday': friday ? 1 : 0,
          'saturday': saturday ? 1 : 0,
          'sunday': sunday ? 1 : 0,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to assign diet: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to assign diet: ${e.message}');
    }
  }
}
