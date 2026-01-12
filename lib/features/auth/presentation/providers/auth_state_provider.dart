import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/crashlytics/crashlytics_service_provider.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/admin_model.dart';
import 'auth_repository_provider.dart';
import '../../../clients/presentation/providers/client_provider.dart';

part 'auth_state_provider.g.dart';

/// Simple authentication state provider.
///
/// State is the authenticated user (Trainer, Client, or Admin), or null if not logged in.
/// Navigation is handled directly by screens, not by router redirects.
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  dynamic build() {
    // Initialize by attempting to restore user from storage
    _initializeAuth();

    // Start with no authenticated user
    // User will be set after successful magic link verification or restoration
    return null;
  }

  /// Initialize authentication by restoring user from stored tokens
  void _initializeAuth() {
    // Schedule the restoration to happen after the provider is fully initialized
    Future.microtask(() => _restoreUser());
  }

  /// Restore user from stored tokens
  Future<void> _restoreUser() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.getCurrentUser();

      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('⚠️ [AuthState] Failed to restore user: $failure');
          }
        },
        (user) {
          if (kDebugMode) {
            debugPrint('✅ [AuthState] Restored user from storage: ${user.runtimeType}');
          }
          // Set the authenticated user
          state = user;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AuthState] Exception restoring user: $e');
      }
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state != null;

  /// Send magic link to email
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> sendMagicLink(String email, String userType) async {
    final useCase = ref.read(sendMagicLinkUseCaseProvider);
    final result = await useCase.call(email: email, userType: userType);

    return result.fold(
      (failure) {
        print('❌ sendMagicLink failed: ${failure.message}');
        return false;
      },
      (_) {
        print('✅ Magic link sent to $email as $userType');
        return true;
      },
    );
  }

  /// Verify magic link code and authenticate user
  ///
  /// Returns the authenticated user on success, null on failure.
  Future<dynamic> verifyMagicLink({
    required String email,
    required String code,
  }) async {
    final useCase = ref.read(verifyMagicLinkUseCaseProvider);
    final result = await useCase.call(email: email, code: code);

    return result.fold(
      (failure) {
        print('❌ verifyMagicLink failed: ${failure.message}');
        return null;
      },
      (user) {
        print('✅ Magic link verified, user: $user');

        // Check if admin email
        dynamic finalUser = user;
        if (email.endsWith('@thegamechangers.es')) {
          finalUser = AdminModel(email: email, name: 'Admin');
        }

        // Set authenticated user
        state = finalUser;

        // Set crashlytics user ID (best effort)
        _setCrashlyticsUser(email);

        return finalUser;
      },
    );
  }

  /// Logout - clear authenticated user and invalidate cached data
  Future<void> logout() async {
    final useCase = ref.read(logoutUseCaseProvider);
    await useCase.call();
    state = null;

    // Clear all cached providers (best effort)
    try {
      // Invalidate clients providers
      ref.invalidate(clientsProvider);
      ref.invalidate(allClientsProvider);

      if (kDebugMode) {
        debugPrint('✅ [AuthState] Invalidated cached client data on logout');
      }
    } catch (_) {}

    // Clear crashlytics user (best effort)
    try {
      final crashlytics = ref.read(crashlyticsProvider);
      await crashlytics.clearUserId();
    } catch (_) {}
  }

  void _setCrashlyticsUser(String email) {
    try {
      final crashlytics = ref.read(crashlyticsProvider);
      crashlytics.setUserId(email);
    } catch (_) {}
  }
}
