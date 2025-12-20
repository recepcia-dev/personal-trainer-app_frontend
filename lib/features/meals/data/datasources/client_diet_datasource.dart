import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/assigned_diet_model.dart';

/// Remote data source for client diet/meal operations
abstract class ClientDietDataSource {
  /// Get diet/meals assigned to the authenticated client
  Future<List<AssignedDietModel>> getAssignedDiet();
}

class ClientDietDataSourceImpl implements ClientDietDataSource {
  final Dio dio;

  ClientDietDataSourceImpl({required this.dio});

  @override
  Future<List<AssignedDietModel>> getAssignedDiet() async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/client/diet',
      );

      if (response.statusCode == 200) {
        final items = response.data as List<dynamic>;
        return items
            .map((json) => AssignedDietModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch assigned diet: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch assigned diet: ${e.message}');
    }
  }
}
