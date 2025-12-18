import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/workout_model.dart';

/// Remote data source for workout data - handles API calls
abstract class WorkoutRemoteDataSource {
  /// Fetch list of workouts from API
  Future<List<WorkoutModel>> fetchWorkouts({
    int skip = 0,
    int limit = 50,
    String? category,
    String? difficulty,
  });

  /// Get single workout by ID
  Future<WorkoutModel> getWorkoutById(String id);

  /// Create new workout
  Future<WorkoutModel> createWorkout({
    required String name,
    String? description,
    String? category,
    String? difficulty,
    int? durationMinutes,
    bool isPublic = false,
  });

  /// Update existing workout
  Future<WorkoutModel> updateWorkout(
    String id, {
    String? name,
    String? description,
    String? category,
    String? difficulty,
    int? durationMinutes,
    bool? isPublic,
    bool? isActive,
  });

  /// Delete workout
  Future<void> deleteWorkout(String id);

  /// Assign workout to client
  Future<WorkoutAssignmentModel> assignWorkout({
    required String workoutId,
    required String clientId,
    DateTime? startsAt,
    DateTime? endsAt,
    String? notes,
  });

  /// Get workout assignments
  Future<List<WorkoutAssignmentModel>> getAssignments({
    int skip = 0,
    int limit = 50,
    String? workoutId,
    String? clientId,
  });

  /// Update assignment
  Future<WorkoutAssignmentModel> updateAssignment(
    String assignmentId, {
    DateTime? startsAt,
    DateTime? endsAt,
    bool? isCompleted,
    String? notes,
  });
}

class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  final Dio dio;

  WorkoutRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<WorkoutModel>> fetchWorkouts({
    int skip = 0,
    int limit = 50,
    String? category,
    String? difficulty,
  }) async {
    try {
      final params = {
        'skip': skip,
        'limit': limit,
        if (category != null) 'category': category,
        if (difficulty != null) 'difficulty': difficulty,
      };

      final response = await dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.workouts}',
        queryParameters: params,
      );

      final data = response.data?['items'] as List<dynamic>?;
      return (data ?? [])
          .map((item) => WorkoutModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<WorkoutModel> getWorkoutById(String id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.workouts}/$id',
      );

      return WorkoutModel.fromJson(response.data!);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<WorkoutModel> createWorkout({
    required String name,
    String? description,
    String? category,
    String? difficulty,
    int? durationMinutes,
    bool isPublic = false,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.workouts}',
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (category != null) 'category': category,
          if (difficulty != null) 'difficulty': difficulty,
          if (durationMinutes != null) 'duration_minutes': durationMinutes,
          'is_public': isPublic,
          'exercises': [],
        },
      );

      return WorkoutModel.fromJson(response.data!);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<WorkoutModel> updateWorkout(
    String id, {
    String? name,
    String? description,
    String? category,
    String? difficulty,
    int? durationMinutes,
    bool? isPublic,
    bool? isActive,
  }) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.workouts}/$id',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (category != null) 'category': category,
          if (difficulty != null) 'difficulty': difficulty,
          if (durationMinutes != null) 'duration_minutes': durationMinutes,
          if (isPublic != null) 'is_public': isPublic,
          if (isActive != null) 'is_active': isActive,
        },
      );

      return WorkoutModel.fromJson(response.data!);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    try {
      await dio.delete(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.workouts}/$id',
      );
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<WorkoutAssignmentModel> assignWorkout({
    required String workoutId,
    required String clientId,
    DateTime? startsAt,
    DateTime? endsAt,
    String? notes,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.workouts}/$workoutId/assign',
        data: {
          'client_id': clientId,
          if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
          if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );

      return WorkoutAssignmentModel.fromJson(response.data!);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<WorkoutAssignmentModel>> getAssignments({
    int skip = 0,
    int limit = 50,
    String? workoutId,
    String? clientId,
  }) async {
    try {
      final params = {
        'skip': skip,
        'limit': limit,
        if (workoutId != null) 'workout_id': workoutId,
        if (clientId != null) 'client_id': clientId,
      };

      final response = await dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.workouts}/assignments/list',
        queryParameters: params,
      );

      final data = response.data?['items'] as List<dynamic>?;
      return (data ?? [])
          .map((item) => WorkoutAssignmentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<WorkoutAssignmentModel> updateAssignment(
    String assignmentId, {
    DateTime? startsAt,
    DateTime? endsAt,
    bool? isCompleted,
    String? notes,
  }) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.workouts}/assignments/$assignmentId',
        data: {
          if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
          if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
          if (isCompleted != null) 'is_completed': isCompleted,
          if (notes != null) 'notes': notes,
        },
      );

      return WorkoutAssignmentModel.fromJson(response.data!);
    } on DioException {
      rethrow;
    }
  }
}
