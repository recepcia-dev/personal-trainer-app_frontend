import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/providers/auth_state_provider.dart';
import 'dashboard_tabs/home_tab.dart';
import 'dashboard_tabs/clients_tab.dart';
import 'dashboard_tabs/workouts_tab.dart';
import 'dashboard_tabs/profile_tab.dart';
import 'dashboard_tabs/settings_tab.dart';

/// Professional Trainer Dashboard with workflow-oriented layout and blue theme
///
/// Features:
/// - Home tab: Quick actions and recent activity
/// - Clients tab: Grid view of assigned clients
/// - Workouts tab: List of created workouts
/// - Nutrition tab: Meal plans management
/// - Profile tab: Trainer profile settings
class TrainerDashboardScreen extends ConsumerStatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  ConsumerState<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends ConsumerState<TrainerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${(user?.firstName ?? user?.name) ?? 'Trainer'}',
          style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        elevation: 1,
        surfaceTintColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          isScrollable: false,
          tabs: const [
            Tab(
              icon: Icon(Icons.home_outlined),
              text: 'Home',
            ),
            Tab(
              icon: Icon(Icons.people_outline),
              text: 'Clients',
            ),
            Tab(
              icon: Icon(Icons.fitness_center_outlined),
              text: 'Workouts',
            ),
            Tab(
              icon: Icon(Icons.restaurant_outlined),
              text: 'Nutrition',
            ),
            Tab(
              icon: Icon(Icons.person_outline),
              text: 'Profile',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomeTab(),
          ClientsTab(),
          WorkoutsTab(),
          _TrainerNutritionTab(),
          ProfileTab(),
        ],
      ),
    );
  }
}

/// Placeholder for Nutrition tab - displays trainer's meal plans
class _TrainerNutritionTab extends StatelessWidget {
  const _TrainerNutritionTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 64,
            color: Colors.blue.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nutrition & Meal Plans',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create and manage meal plans for your clients',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}
