import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/crashlytics/crashlytics_service_provider.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/admin_model.dart';
import 'auth_repository_provider.dart';

part 'auth_state_provider.g.dart';

/// Simple authentication state provider.
///
/// State is the authenticated user (Trainer, Client, or Admin), or null if not logged in.
/// Navigation is handled directly by screens, not by router redirects.
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  dynamic build() {
    // Start with no authenticated user
    // User will be set after successful magic link verification
    return null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state != null;

  /// Send magic link to email
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> sendMagicLink(String email) async {
    final useCase = ref.read(sendMagicLinkUseCaseProvider);
    final result = await useCase.call(email: email);

    return result.fold(
      (failure) {
        print('❌ sendMagicLink failed: ${failure.message}');
        return false;
      },
      (_) {
        print('✅ Magic link sent to $email');
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

  /// Logout - clear authenticated user
  Future<void> logout() async {
    final useCase = ref.read(logoutUseCaseProvider);
    await useCase.call();
    state = null;

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
