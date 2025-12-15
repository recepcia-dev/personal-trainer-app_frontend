import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/biometric_auth_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/magic_link_verification_screen.dart';
import '../analytics/analytics_service_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';

// Create router provider using Riverpod with authentication-based redirects
final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Watch auth state for changes
      final isAuthenticated = ref.watch(authProvider);

      // Get the current route location
      final location = state.uri.path;

      // Handle authenticated users trying to access login
      if (isAuthenticated && location == '/login') {
        return '/dashboard';
      }

      // Handle unauthenticated users trying to access dashboard
      if (!isAuthenticated && location == '/dashboard') {
        return '/login';
      }

      // Handle splash screen navigation based on auth state
      if (location == '/splash') {
        return isAuthenticated ? '/dashboard' : '/login';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) {
          // Log screen view
          ref.read(analyticsServiceProvider).whenData((analytics) {
            analytics.logScreenView(
              screenName: 'splash',
              screenClass: 'SplashScreen',
            );
          });
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          // Log screen view
          ref.read(analyticsServiceProvider).whenData((analytics) {
            analytics.logScreenView(
              screenName: 'login',
              screenClass: 'LoginScreen',
            );
          });
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/verify-magic-link',
        name: 'verifyMagicLink',
        builder: (context, state) {
          // Log screen view
          ref.read(analyticsServiceProvider).whenData((analytics) {
            analytics.logScreenView(
              screenName: 'verify_magic_link',
              screenClass: 'MagicLinkVerificationScreen',
            );
          });
          final email = state.uri.queryParameters['email'] ?? '';
          final code = state.uri.queryParameters['code'];
          return MagicLinkVerificationScreen(email: email, code: code);
        },
      ),
      GoRoute(
        path: '/biometric-auth',
        name: 'biometricAuth',
        builder: (context, state) {
          // Log screen view
          ref.read(analyticsServiceProvider).whenData((analytics) {
            analytics.logScreenView(
              screenName: 'biometric_auth',
              screenClass: 'BiometricAuthScreen',
            );
          });
          return const BiometricAuthScreen();
        },
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) {
          // Log screen view
          ref.read(analyticsServiceProvider).whenData((analytics) {
            analytics.logScreenView(
              screenName: 'dashboard',
              screenClass: 'DashboardScreen',
            );
          });
          return const DashboardScreen();
        },
      ),
    ],
  ),
);
