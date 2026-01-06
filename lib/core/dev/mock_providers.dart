import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/models/admin_model.dart';
import '../../features/auth/data/models/client_model.dart';
import '../../features/auth/data/models/trainer_model.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../network/dio_client.dart';
import 'dev_config.dart';

part 'mock_providers.g.dart';

/// Dummy tokens for dev mode API calls
class _DevTokens {
  static const String trainerAccessToken = 'dev-trainer-token-12345';
  static const String trainerRefreshToken = 'dev-trainer-refresh-token-12345';
  static const String clientAccessToken = 'dev-client-token-67890';
  static const String clientRefreshToken = 'dev-client-refresh-token-67890';
  static const String adminAccessToken = 'dev-admin-token-11111';
  static const String adminRefreshToken = 'dev-admin-refresh-token-11111';
}

/// Secure storage provider for dev mode
@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

/// Mock authentication state provider for development
/// Returns a pre-authenticated user based on selected role
@riverpod
class MockAuthState extends _$MockAuthState {
  @override
  dynamic build() {
    // Return based on currently selected dev role
    final role = ref.watch(devRoleProvider);

    switch (role) {
      case DevRoleEnum.trainer:
        return TrainerModel(
          id: 'dev-trainer-001',
          email: 'trainer@test.local',
          name: 'John Trainer',
          firstName: 'John',
          lastName: 'Trainer',
          photoUrl: null,
          age: 35,
          weightKg: 80.0,
          heightCm: 180.0,
          gender: 'Male',
          trainerUniqueCode: 'TRAINER001',
          specialty: 'CrossFit & Strength',
          bio: 'Experienced trainer specializing in strength training and fitness.',
        );

      case DevRoleEnum.client:
        return ClientModel(
          id: 'dev-client-001',
          email: 'client@test.local',
          name: 'Jane Client',
          firstName: 'Jane',
          lastName: 'Client',
          trainerId: 'dev-trainer-001',
          age: 28,
          weightKg: 65.0,
          heightCm: 165.0,
          gender: 'Female',
          fitnessLevel: 'Intermediate',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

      case DevRoleEnum.admin:
        return AdminModel(
          email: 'admin@test.local',
          name: 'Admin User',
        );

      case DevRoleEnum.notAuthenticated:
        return null;
    }
  }

  /// Switch to trainer role
  void setTrainerRole() => state = build();

  /// Switch to client role
  void setClientRole() => state = build();

  /// Switch to admin role
  void setAdminRole() => state = build();

  /// Logout (set state to null)
  void logout() => state = null;
}

/// Track which dev role is currently selected
enum DevRoleEnum {
  trainer,
  client,
  admin,
  notAuthenticated,
}

/// Provider for tracking current dev role
@riverpod
class DevRole extends _$DevRole {
  @override
  DevRoleEnum build() => DevRoleEnum.notAuthenticated;

  Future<void> selectTrainer() async {
    state = DevRoleEnum.trainer;
    await _saveTokens(DevRoleEnum.trainer);
  }

  Future<void> selectClient() async {
    state = DevRoleEnum.client;
    await _saveTokens(DevRoleEnum.client);
  }

  Future<void> selectAdmin() async {
    state = DevRoleEnum.admin;
    await _saveTokens(DevRoleEnum.admin);
  }

  Future<void> selectNotAuthenticated() async {
    state = DevRoleEnum.notAuthenticated;
    await _clearTokens();
  }

  /// Save tokens to secure storage based on role
  Future<void> _saveTokens(DevRoleEnum role) async {
    final storage = ref.read(secureStorageProvider);
    switch (role) {
      case DevRoleEnum.trainer:
        await storage.write(key: 'accessToken', value: _DevTokens.trainerAccessToken);
        await storage.write(key: 'refreshToken', value: _DevTokens.trainerRefreshToken);
        break;
      case DevRoleEnum.client:
        await storage.write(key: 'accessToken', value: _DevTokens.clientAccessToken);
        await storage.write(key: 'refreshToken', value: _DevTokens.clientRefreshToken);
        break;
      case DevRoleEnum.admin:
        await storage.write(key: 'accessToken', value: _DevTokens.adminAccessToken);
        await storage.write(key: 'refreshToken', value: _DevTokens.adminRefreshToken);
        break;
      case DevRoleEnum.notAuthenticated:
        await _clearTokens();
        break;
    }
  }

  /// Clear tokens from secure storage
  Future<void> _clearTokens() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
  }
}

/// Get provider overrides for dev mode
///
/// Note: The router itself checks DevConfig.mockAuthEnabled and watches
/// mockAuthStateProvider directly, so no overrides are needed here.
/// The dev toolbar directly updates devRoleProvider, which drives state changes.
List<dynamic> getDevProviderOverrides() {
  if (!DevConfig.mockAuthEnabled) {
    return [];
  }
  // No overrides needed - router handles dev mode awareness
  return [];
}

/// Quick access to mock auth in dev mode
class DevAuth {
  static void loginAsTrainer() {
    // Usage: DevAuth.loginAsTrainer() in console or dev code
  }

  static void loginAsClient() {
    // Usage: DevAuth.loginAsClient() in console or dev code
  }

  static void loginAsAdmin() {
    // Usage: DevAuth.loginAsAdmin() in console or dev code
  }

  static void logout() {
    // Usage: DevAuth.logout() in console or dev code
  }
}
