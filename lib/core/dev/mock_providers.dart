import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/models/admin_model.dart';
import '../../features/auth/data/models/client_model.dart';
import '../../features/auth/data/models/trainer_model.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import 'dev_config.dart';

part 'mock_providers.g.dart';

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

  void selectTrainer() => state = DevRoleEnum.trainer;

  void selectClient() => state = DevRoleEnum.client;

  void selectAdmin() => state = DevRoleEnum.admin;

  void selectNotAuthenticated() => state = DevRoleEnum.notAuthenticated;
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
