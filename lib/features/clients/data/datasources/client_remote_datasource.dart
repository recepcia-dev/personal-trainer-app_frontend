import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/client_model.dart';

/// Remote data source for client data - handles API calls
abstract class ClientRemoteDataSource {
  /// Fetch clients from backend API
  Future<List<ClientModel>> fetchClients({
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
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      // Use the trainer-specific endpoint to get trainer's clients
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/v1/trainer/clients',
      );

      if (response.statusCode == 200) {
        final items = response.data as List<dynamic>;
        return items
            .map((json) => ClientModel.fromApi(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch clients: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch clients: ${e.message}');
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
      throw Exception('Failed to fetch client: ${e.message}');
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

      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.clients}',
        data: payload,
      );

      if (response.statusCode == 201) {
        return ClientModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create client: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create client: ${e.message}');
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
      throw Exception('Failed to update client: ${e.message}');
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
      throw Exception('Failed to delete client: ${e.message}');
    }
  }
}
