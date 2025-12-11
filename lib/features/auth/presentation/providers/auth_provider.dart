import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple auth state provider
/// Tracks whether a user is authenticated
/// This is a placeholder until full auth system is implemented (F018+)
final authProvider = StateNotifierProvider<AuthNotifier, bool>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  /// Login user
  void login() => state = true;

  /// Logout user
  void logout() => state = false;

  /// Check if user is authenticated
  bool get isAuthenticated => state;
}
