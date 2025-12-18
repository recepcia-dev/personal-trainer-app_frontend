import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/exercise_model.dart';

/// Remote data source for exercise data - handles API calls
abstract class ExerciseRemoteDataSource {
  /// Fetch exercises from backend API
  Future<List<ExerciseModel>> fetchExercises({
    String? category,
    String? muscleGroup,
  });

  /// Get single exercise by ID
  Future<ExerciseModel> getExerciseById(String id);
}

class ExerciseRemoteDataSourceImpl implements ExerciseRemoteDataSource {
  final Dio dio;

  ExerciseRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ExerciseModel>> fetchExercises({
    String? category,
    String? muscleGroup,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (muscleGroup != null) queryParams['muscle_group'] = muscleGroup;

      final response = await dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.exercises}',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ExerciseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch exercises: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch exercises: ${e.message}');
    }
  }

  @override
  Future<ExerciseModel> getExerciseById(String id) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.exercises}/$id',
      );

      if (response.statusCode == 200) {
        return ExerciseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch exercise: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch exercise: ${e.message}');
    }
  }
}
