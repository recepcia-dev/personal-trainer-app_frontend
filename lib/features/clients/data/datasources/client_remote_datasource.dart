import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../models/client_model.dart';

/// Remote data source for client data - handles API calls
abstract class ClientRemoteDataSource {
  /// Fetch clients from backend API for a specific trainer
  Future<List<ClientModel>> fetchClients({
    required String trainerId,
    int skip,
    int limit,
  });

  /// Get single client by ID
  Future<ClientModel> getClientById(String id);

  /// Create a new client
  Future<ClientModel> createClient({
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? fitnessLevel,
    String? goals,
    String? notes,
  });

  /// Update client
  Future<ClientModel> updateClient(
    String id, {
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? fitnessLevel,
    String? goals,
    String? notes,
  });

  /// Delete client
  Future<void> deleteClient(String id);
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final Dio dio;

  ClientRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ClientModel>> fetchClients({
    required String trainerId,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔵 [ClientRemoteDataSource] Fetching clients for trainer: $trainerId');
      }

      // Use the trainer-specific endpoint to get trainer's clients, filtered by trainerId
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/trainer/clients',
        queryParameters: {
          'trainer_id': trainerId,
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final items = response.data as List<dynamic>;
        if (kDebugMode) {
          debugPrint('✅ [ClientRemoteDataSource] Fetched ${items.length} clients');
        }
        return items
            .map((json) => ClientModel.fromApi(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch clients: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromResponse(
        responseData: e.response?.data,
        statusCode: e.response?.statusCode,
      );
      if (kDebugMode) {
        debugPrint('❌ [ClientRemoteDataSource] Fetch clients failed: ${apiError.getDetailedMessage()}');
      }
      throw Exception('Failed to fetch clients: ${apiError.getDisplayMessage()}');
    }
  }

  @override
  Future<ClientModel> getClientById(String id) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.clients}/$id',
      );

      if (response.statusCode == 200) {
        return ClientModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch client: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromResponse(
        responseData: e.response?.data,
        statusCode: e.response?.statusCode,
      );
      if (kDebugMode) {
        debugPrint('Get client by ID failed: ${apiError.getDetailedMessage()}');
      }
      throw Exception('Failed to fetch client: ${apiError.getDisplayMessage()}');
    }
  }

  @override
  Future<ClientModel> createClient({
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? fitnessLevel,
    String? goals,
    String? notes,
  }) async {
    try {
      final payload = {
        'email': email,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phone != null) 'phone': phone,
        if (age != null) 'age': age,
        if (fitnessLevel != null) 'fitness_level': fitnessLevel,
        if (goals != null) 'goals': goals,
        if (notes != null) 'notes': notes,
      };

      if (kDebugMode) {
        debugPrint('');
        debugPrint('╔════════════════════════════════════════════════════════════════╗');
        debugPrint('║              🚀 CREATING CLIENT - REQUEST DETAILS              ║');
        debugPrint('╚════════════════════════════════════════════════════════════════╝');
        debugPrint('📍 [ClientRemoteDataSource] Endpoint: ${ApiEndpoints.baseUrl}${ApiEndpoints.clients}');
        debugPrint('📦 [ClientRemoteDataSource] Payload:');
        payload.forEach((key, value) {
          debugPrint('   • $key: $value');
        });
        debugPrint('⏳ [ClientRemoteDataSource] Sending POST request...');
      }

      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.clients}',
        data: payload,
      );

      if (kDebugMode) {
        debugPrint('✅ [ClientRemoteDataSource] Response status: ${response.statusCode}');
        debugPrint('╚════════════════════════════════════════════════════════════════╝');
        debugPrint('');
      }

      if (response.statusCode == 201) {
        return ClientModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create client: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Extract detailed error from response
      final apiError = ApiError.fromResponse(
        responseData: e.response?.data,
        statusCode: e.response?.statusCode,
      );

      // Log detailed error for debugging
      if (kDebugMode) {
        debugPrint('❌ [ClientRemoteDataSource] Request failed!');
        debugPrint('   Status Code: ${e.response?.statusCode}');
        debugPrint('   Error: ${apiError.getDetailedMessage()}');
        debugPrint('╚════════════════════════════════════════════════════════════════╝');
        debugPrint('');
      }

      // Throw exception with detailed error message
      throw Exception('Failed to create client: ${apiError.getDisplayMessage()}');
    }
  }

  @override
  Future<ClientModel> updateClient(
    String id, {
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? fitnessLevel,
    String? goals,
    String? notes,
  }) async {
    try {
      final payload = {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phone != null) 'phone': phone,
        if (age != null) 'age': age,
        if (fitnessLevel != null) 'fitness_level': fitnessLevel,
        if (goals != null) 'goals': goals,
        if (notes != null) 'notes': notes,
      };

      final response = await dio.patch(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.clients}/$id',
        data: payload,
      );

      if (response.statusCode == 200) {
        return ClientModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update client: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromResponse(
        responseData: e.response?.data,
        statusCode: e.response?.statusCode,
      );
      if (kDebugMode) {
        debugPrint('Update client failed: ${apiError.getDetailedMessage()}');
      }
      throw Exception('Failed to update client: ${apiError.getDisplayMessage()}');
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      final response = await dio.delete(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.clients}/$id',
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete client: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromResponse(
        responseData: e.response?.data,
        statusCode: e.response?.statusCode,
      );
      if (kDebugMode) {
        debugPrint('Delete client failed: ${apiError.getDetailedMessage()}');
      }
      throw Exception('Failed to delete client: ${apiError.getDisplayMessage()}');
    }
  }
}
