import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../auth/data/models/client_model.dart';

part 'client_trainer_provider.g.dart';

/// Trainer info model for client view
class TrainerInfo {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? specialty;
  final String? bio;

  TrainerInfo({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.specialty,
    this.bio,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return email.split('@')[0];
  }

  factory TrainerInfo.fromJson(Map<String, dynamic> json) {
    return TrainerInfo(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      specialty: json['specialty'] as String?,
      bio: json['bio'] as String?,
    );
  }
}

/// Provider for fetching the client's assigned trainer info
@riverpod
Future<TrainerInfo?> clientTrainer(ClientTrainerRef ref) async {
  final user = ref.watch(authStateProvider);
  
  // Only clients can fetch their trainer
  if (user is! ClientModel) {
    if (kDebugMode) {
      debugPrint('🔵 [ClientTrainerProvider] User is not a client');
    }
    return null;
  }

  // If no trainer assigned
  if (user.trainerId == null || user.trainerId!.isEmpty) {
    if (kDebugMode) {
      debugPrint('🔵 [ClientTrainerProvider] No trainer assigned to client');
    }
    return null;
  }

  final dio = ref.watch(dioProvider);
  
  try {
    if (kDebugMode) {
      debugPrint('🔵 [ClientTrainerProvider] Fetching trainer info from /api/v1/client/trainer');
    }
    
    final response = await dio.get(
      '${ApiEndpoints.baseUrl}/api/v1/client/trainer',
    );

    if (response.statusCode == 200) {
      final trainerInfo = TrainerInfo.fromJson(response.data as Map<String, dynamic>);
      if (kDebugMode) {
        debugPrint('✅ [ClientTrainerProvider] Trainer info fetched: ${trainerInfo.fullName}');
      }
      return trainerInfo;
    } else {
      throw Exception('Failed to fetch trainer: ${response.statusCode}');
    }
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      // No trainer assigned
      if (kDebugMode) {
        debugPrint('🔵 [ClientTrainerProvider] No trainer found (404)');
      }
      return null;
    }
    if (kDebugMode) {
      debugPrint('❌ [ClientTrainerProvider] Error fetching trainer: ${e.message}');
    }
    rethrow;
  }
}
