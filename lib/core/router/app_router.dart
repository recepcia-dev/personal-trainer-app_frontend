import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/models/admin_model.dart';
import '../../features/auth/data/models/client_model.dart';
import '../../features/auth/data/models/trainer_model.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/providers/pending_email_provider.dart';
import '../../features/auth/presentation/screens/biometric_auth_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/magic_link_verification_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../analytics/analytics_service_provider.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/client_dashboard_screen.dart';
import 'screens/main_dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/trainer_dashboard_screen.dart';

// Create router provider using Riverpod with authentication-based redirects
final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Watch auth state for changes
      final isAuthenticated = ref.watch(authProvider);
      final authState = ref.watch(authStateProvider);
      final user = authState.value;

      // Get the current route location
      final location = state.uri.path;

      print('🔍 Router redirect: location=$location, isAuthenticated=$isAuthenticated, authState=$authState, user=$user');

      // CRITICAL: If auth state is still loading, don't redirect - wait for it to complete
      // This prevents infinite redirect loops during app startup
      if (authState.isLoading) {
        print('🔄 Router: Auth state is still loading, not redirecting');
        return null;
      }

      // Check if there's a pending email verification (magic link sent)
      final pendingEmail = ref.watch(pendingEmailProvider);
      if (pendingEmail.isNotEmpty && location != '/verify-magic-link') {
        print('🔄 Router: Redirecting to verify-magic-link for $pendingEmail');
        return '/verify-magic-link?email=${Uri.encodeComponent(pendingEmail)}';
      }

      // Handle authenticated users trying to access login
      if (isAuthenticated && location == '/login') {
        // Redirect to appropriate dashboard based on user role
        if (user is AdminModel) {
          return '/admin/dashboard';
        } else if (user is TrainerModel) {
          return '/trainer/dashboard';
        } else if (user is ClientModel) {
          return '/client/dashboard';
        }
        // Fallback to old dashboard route
        return '/dashboard';
      }

      // Handle unauthenticated users trying to access dashboards
      if (!isAuthenticated &&
          (location == '/dashboard' ||
           location == '/admin/dashboard' ||
           location == '/trainer/dashboard' ||
           location == '/client/dashboard')) {
        return '/role-selection';
      }

      // Handle splash screen navigation based on auth state
      if (location == '/splash') {
        if (!isAuthenticated) {
          return '/role-selection';
        }
        // Redirect to appropriate dashboard based on user role
        if (user is AdminModel) {
          return '/admin/dashboard';
        } else if (user is TrainerModel) {
          return '/trainer/dashboard';
        } else if (user is ClientModel) {
          return '/client/dashboard';
        }
        // Fallback to old dashboard route
        return '/dashboard';
      }

      // No redirect needed
      print('🔍 Router: no redirect needed for $location');
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
        path: '/role-selection',
        name: 'roleSelection',
        builder: (context, state) {
          // Log screen view
          ref.read(analyticsServiceProvider).whenData((analytics) {
            analytics.logScreenView(
              screenName: 'role_selection',
              screenClass: 'RoleSelectionScreen',
            );
          });
          return const RoleSelectionScreen();
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
              screenClass: 'MainDashboardScreen',
            );
          });
          return const MainDashboardScreen();
        },
      ),
      GoRoute(
        path: '/admin/dashboard',
        name: 'adminDashboard',
        builder: (context, state) {
          // Log screen view
          ref.read(analyticsServiceProvider).whenData((analytics) {
            analytics.logScreenView(
              screenName: 'admin_dashboard',
              screenClass: 'AdminDashboardScreen',
            );
          });
          return const AdminDashboardScreen();
        },
      ),
      GoRoute(
        path: '/trainer/dashboard',
        name: 'trainerDashboard',
        builder: (context, state) {
          // Log screen view
          ref.read(analyticsServiceProvider).whenData((analytics) {
            analytics.logScreenView(
              screenName: 'trainer_dashboard',
              screenClass: 'TrainerDashboardScreen',
            );
          });
          return const TrainerDashboardScreen();
        },
      ),
      GoRoute(
        path: '/client/dashboard',
        name: 'clientDashboard',
        builder: (context, state) {
          // Log screen view
          ref.read(analyticsServiceProvider).whenData((analytics) {
            analytics.logScreenView(
              screenName: 'client_dashboard',
              screenClass: 'ClientDashboardScreen',
            );
          });
          return const ClientDashboardScreen();
        },
      ),
    ],
  ),
);
