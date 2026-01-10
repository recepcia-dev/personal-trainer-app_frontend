import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/models/admin_model.dart';
import '../../features/auth/data/models/client_model.dart';
import '../../features/auth/data/models/trainer_model.dart';
import 'dev_config.dart';

part 'mock_providers.g.dart';

/// JWT tokens for dev mode API calls
class DevTokens {
  // Dev secret key for JWT signing (used only in development)
  static const String _devSecret = 'dev-secret-key-for-testing-only';

  // Cache generated tokens to ensure consistency across calls
  static final Map<String, String> _tokenCache = {};

  /// Generate a valid JWT token for the given role
  static String _generateJwt({required String role, required String userId}) {
    final cacheKey = '$role:access';
    if (_tokenCache.containsKey(cacheKey)) {
      return _tokenCache[cacheKey]!;
    }

    try {
      final now = DateTime.now();
      final exp = now.add(const Duration(days: 365)); // Valid for 1 year

      final jwt = JWT({
        'sub': userId,
        'role': role,
        'iat': (now.millisecondsSinceEpoch / 1000).floor(),
        'exp': (exp.millisecondsSinceEpoch / 1000).floor(),
      });

      final token = jwt.sign(SecretKey(_devSecret));
      _tokenCache[cacheKey] = token;
      return token;
    } catch (e) {
      // Fallback to simple token if JWT generation fails
      return 'dev-$role-token-invalid';
    }
  }

  /// Generate a refresh token (also JWT format)
  static String _generateRefreshJwt({required String role, required String userId}) {
    final cacheKey = '$role:refresh';
    if (_tokenCache.containsKey(cacheKey)) {
      return _tokenCache[cacheKey]!;
    }

    try {
      final now = DateTime.now();
      final exp = now.add(const Duration(days: 30)); // Refresh valid for 30 days

      final jwt = JWT({
        'sub': userId,
        'role': role,
        'type': 'refresh',
        'iat': (now.millisecondsSinceEpoch / 1000).floor(),
        'exp': (exp.millisecondsSinceEpoch / 1000).floor(),
      });

      final token = jwt.sign(SecretKey(_devSecret));
      _tokenCache[cacheKey] = token;
      return token;
    } catch (e) {
      // Fallback to simple token if JWT generation fails
      return 'dev-$role-refresh-token-invalid';
    }
  }

  // Trainer tokens
  static late final String trainerAccessToken =
      _generateJwt(role: 'trainer', userId: 'dev-trainer-001');
  static late final String trainerRefreshToken =
      _generateRefreshJwt(role: 'trainer', userId: 'dev-trainer-001');

  // Client tokens
  static late final String clientAccessToken =
      _generateJwt(role: 'client', userId: 'dev-client-001');
  static late final String clientRefreshToken =
      _generateRefreshJwt(role: 'client', userId: 'dev-client-001');

  // Admin tokens
  static late final String adminAccessToken =
      _generateJwt(role: 'admin', userId: 'dev-admin-001');
  static late final String adminRefreshToken =
      _generateRefreshJwt(role: 'admin', userId: 'dev-admin-001');
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
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('🔐 TRAINER BEARER TOKEN FOR CURL REQUESTS');
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('Token: ${DevTokens.trainerAccessToken}');
    debugPrint('');
    debugPrint('Use in curl:');
    debugPrint('curl -H "Authorization: Bearer ${DevTokens.trainerAccessToken}" \\');
    debugPrint('  https://api.personaltrainer.com/api/v1/trainer/profile');
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('');
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
        await storage.write(key: 'accessToken', value: DevTokens.trainerAccessToken);
        await storage.write(key: 'refreshToken', value: DevTokens.trainerRefreshToken);
        break;
      case DevRoleEnum.client:
        await storage.write(key: 'accessToken', value: DevTokens.clientAccessToken);
        await storage.write(key: 'refreshToken', value: DevTokens.clientRefreshToken);
        break;
      case DevRoleEnum.admin:
        await storage.write(key: 'accessToken', value: DevTokens.adminAccessToken);
        await storage.write(key: 'refreshToken', value: DevTokens.adminRefreshToken);
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
