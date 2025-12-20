import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/progress_request_model.dart';

/// Remote data source for progress tracking operations
abstract class ProgressRemoteDataSource {
  /// Register workout progress
  Future<ProgressEntryModel> registerProgress(ProgressRequestModel request);

  /// Get progress history for the authenticated client
  Future<List<ProgressEntryModel>> getProgressHistory({int limit = 50});
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
}
