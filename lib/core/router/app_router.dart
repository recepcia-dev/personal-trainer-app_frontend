import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/models/admin_model.dart';
import '../../features/auth/data/models/client_model.dart';
import '../../features/auth/data/models/trainer_model.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../dev/dev_config.dart';
import '../dev/mock_providers.dart';
import '../../features/auth/presentation/screens/biometric_auth_screen.dart';
import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/magic_link_verification_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/booking/presentation/screens/trainer_public_profile_screen.dart';
import '../../features/nutrition/domain/entities/meal_plan.dart';
import '../../features/nutrition/presentation/screens/client_meal_plan_screen.dart';
import '../../features/nutrition/presentation/screens/meal_plan_builder_screen.dart';
import '../../features/workouts/presentation/screens/workout_builder_screen.dart';
import '../../features/workouts/presentation/screens/client_workout_detail_screen.dart';
import '../../features/payments/presentation/screens/subscription_plans_screen.dart';
import '../../features/payments/presentation/screens/subscription_management_screen.dart';
import '../../features/payments/presentation/screens/payment_success_screen.dart';
import '../../features/payments/presentation/screens/client_subscription_screen.dart';
import '../../features/payments/presentation/screens/workout_store_screen.dart';
import '../../features/payments/presentation/screens/workout_pack_detail_screen.dart';
import '../../features/payments/presentation/screens/client_purchases_screen.dart';
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
      // In dev mode, watch mock auth state; in prod, watch real auth state
      final user = kDebugMode && DevConfig.mockAuthEnabled
          ? ref.watch(mockAuthStateProvider)
          : ref.watch(authStateProvider);
      final location = state.uri.path;

      // Protected routes - require authentication
      final protectedRoutes = [
        '/dashboard',
        '/admin/dashboard',
        '/trainer/dashboard',
        '/client/dashboard',
        '/trainer/workout-builder',
        '/trainer/meal-plan-builder',
        '/client/meal-plan',
      ];

      // Check if it's a protected route or a dynamic client workout route
      final isProtectedRoute = protectedRoutes.contains(location) ||
          location.startsWith('/client/workout/');
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
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'client';
          return LoginScreen(userType: role);
        },
      ),
      GoRoute(
        path: '/verify',
        name: 'verify',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final userType = state.uri.queryParameters['userType'] ?? 'client';
          return MagicLinkVerificationScreen(email: email, userType: userType);
        },
      ),
      GoRoute(
        path: '/complete-profile',
        name: 'completeProfile',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final userType = state.uri.queryParameters['userType'] ?? 'client';
          return CompleteProfileScreen(email: email, userType: userType);
        },
      ),
      GoRoute(
        path: '/biometric',
        name: 'biometric',
        builder: (context, state) => const BiometricAuthScreen(),
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

      // Trainer workflow routes
      GoRoute(
        path: '/trainer/workout-builder',
        name: 'workoutBuilder',
        builder: (context, state) => const WorkoutBuilderScreen(),
      ),
      GoRoute(
        path: '/trainer/meal-plan-builder',
        name: 'mealPlanBuilder',
        builder: (context, state) => const MealPlanBuilderScreen(),
      ),

      // Client workflow routes
      GoRoute(
        path: '/client/meal-plan',
        name: 'clientMealPlan',
        builder: (context, state) {
          // For now, create a mock meal plan to display
          // In real app, this would be passed as an extra parameter or fetched from database
          final mockMealPlan = MealPlan(
            id: 'mock-1',
            trainerId: 'trainer-1',
            name: 'Sample Weekly Plan',
            description: 'A well-balanced nutrition plan',
            meals: [],
            totalCalories: 0,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          return ClientMealPlanScreen(mealPlan: mockMealPlan);
        },
      ),
      GoRoute(
        path: '/client/workout/:assignmentId',
        name: 'clientWorkoutDetail',
        builder: (context, state) {
          final assignmentId = state.pathParameters['assignmentId'] ?? '';
          return ClientWorkoutDetailScreen(assignmentId: assignmentId);
        },
      ),

      // Trainer profile route (for clients to view their trainer)
      GoRoute(
        path: '/trainer-profile/:trainerId',
        name: 'trainerProfile',
        builder: (context, state) {
          final trainerId = state.pathParameters['trainerId'] ?? '';
          return TrainerPublicProfileScreen(trainerId: trainerId);
        },
      ),

      // Payment routes
      GoRoute(
        path: '/payments/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionManagementScreen(),
      ),
      GoRoute(
        path: '/payments/plans',
        name: 'subscriptionPlans',
        builder: (context, state) => const SubscriptionPlansScreen(),
      ),
      GoRoute(
        path: '/payments/success',
        name: 'paymentSuccess',
        builder: (context, state) {
          final planName = state.uri.queryParameters['plan'] ?? 'Pro Plan';
          final amount = state.uri.queryParameters['amount'] ?? '19.99';
          return PaymentSuccessScreen(planName: planName, amount: amount);
        },
      ),

      // Client subscription & store routes
      GoRoute(
        path: '/client/subscription',
        name: 'clientSubscription',
        builder: (context, state) => const ClientSubscriptionScreen(),
      ),
      GoRoute(
        path: '/client/store',
        name: 'workoutStore',
        builder: (context, state) => const WorkoutStoreScreen(),
      ),
      GoRoute(
        path: '/client/store/:packId',
        name: 'workoutPackDetail',
        builder: (context, state) {
          final packId = state.pathParameters['packId'] ?? '';
          return WorkoutPackDetailScreen(packId: packId);
        },
      ),
      GoRoute(
        path: '/client/purchases',
        name: 'clientPurchases',
        builder: (context, state) => const ClientPurchasesScreen(),
      ),
    ],
  );
});
