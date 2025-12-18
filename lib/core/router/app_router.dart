import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/models/admin_model.dart';
import '../../features/auth/data/models/client_model.dart';
import '../../features/auth/data/models/trainer_model.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/magic_link_verification_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/client_dashboard_screen.dart';
import 'screens/trainer_dashboard_screen.dart';

/// Simple router with minimal redirect logic.
///
/// Navigation flow:
/// 1. /role-selection → User picks Trainer or Client
/// 2. /login → User enters email, sends magic link
/// 3. /verify → User enters code from email
/// 4. /dashboard → User sees their dashboard (protected)
///
/// Only dashboard routes are protected. Auth screens allow free navigation.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/role-selection',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final user = ref.watch(authStateProvider);
      final location = state.uri.path;

      // Protected routes - require authentication
      final protectedRoutes = [
        '/dashboard',
        '/admin/dashboard',
        '/trainer/dashboard',
        '/client/dashboard',
      ];

      final isProtectedRoute = protectedRoutes.contains(location);
      final isAuthenticated = user != null;

      // If trying to access protected route without auth, go to role selection
      if (isProtectedRoute && !isAuthenticated) {
        return '/role-selection';
      }

      // If authenticated and on auth screens, go to appropriate dashboard
      if (isAuthenticated && (location == '/role-selection' || location == '/login')) {
        if (user is AdminModel) return '/admin/dashboard';
        if (user is TrainerModel) return '/trainer/dashboard';
        if (user is ClientModel) return '/client/dashboard';
        return '/trainer/dashboard'; // fallback
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Auth flow routes (not protected)
      GoRoute(
        path: '/role-selection',
        name: 'roleSelection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/verify',
        name: 'verify',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return MagicLinkVerificationScreen(email: email);
        },
      ),

      // Dashboard routes (protected)
      GoRoute(
        path: '/admin/dashboard',
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/trainer/dashboard',
        name: 'trainerDashboard',
        builder: (context, state) => const TrainerDashboardScreen(),
      ),
      GoRoute(
        path: '/client/dashboard',
        name: 'clientDashboard',
        builder: (context, state) => const ClientDashboardScreen(),
      ),
    ],
  );
});
