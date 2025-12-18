import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/providers/auth_state_provider.dart';
import 'dashboard_tabs/home_tab.dart';
import 'dashboard_tabs/workouts_tab.dart';
import 'dashboard_tabs/profile_tab.dart';
import 'dashboard_tabs/settings_tab.dart';

/// Professional Client Dashboard with card-based layout and green theme
///
/// Features:
/// - Today tab: Hero workout card + meal tracking
/// - Progress tab: Weight tracker, completed workouts, streak counter
/// - Workouts tab: Assigned workouts with filters
/// - Profile tab: Client profile and body metrics
class ClientDashboardScreen extends ConsumerStatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  ConsumerState<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends ConsumerState<ClientDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          'Welcome, ${(user?.firstName ?? user?.name) ?? 'Client'}',
          style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        elevation: 1,
        surfaceTintColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.today_outlined),
              text: 'Today',
            ),
            Tab(
              icon: Icon(Icons.trending_up_outlined),
              text: 'Progress',
            ),
            Tab(
              icon: Icon(Icons.fitness_center_outlined),
              text: 'Workouts',
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
          _ClientTodayTab(),
          _ClientProgressTab(),
          WorkoutsTab(),
          ProfileTab(),
        ],
      ),
    );
  }
}

/// Today tab - displays today's workout and meals
class _ClientTodayTab extends StatelessWidget {
  const _ClientTodayTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Workout Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[400]!, Colors.teal[600]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Workout",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chest Day',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '5 exercises • 45 min',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                      ),
                      child: const Text('Start'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Meals Section
          Text(
            "Today's Meals",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...[
            ('Breakfast', '450 cal', true),
            ('Lunch', '650 cal', false),
            ('Dinner', '550 cal', false),
            ('Snack', '150 cal', false),
          ]
              .map((meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Checkbox(
                              value: meal.$3,
                              onChanged: (_) {},
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.$1,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    meal.$2,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: meal.$3 ? Colors.green : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

/// Progress tab - displays performance metrics and charts
class _ClientProgressTab extends StatelessWidget {
  const _ClientProgressTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Summary Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProgressMetricCard(
                value: '7',
                label: 'Day Streak',
                icon: Icons.local_fire_department,
              ),
              _ProgressMetricCard(
                value: '24',
                label: 'Completed',
                icon: Icons.check_circle,
              ),
              _ProgressMetricCard(
                value: '75 kg',
                label: 'Current Weight',
                icon: Icons.scale,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...[
            ('Chest Day', 'Completed', '2 hours ago', true),
            ('Leg Day', 'Completed', 'Yesterday', true),
            ('Back Day', 'Scheduled', 'Tomorrow', false),
          ]
              .map((activity) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: activity.$4 ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              activity.$4 ? Icons.check_circle : Icons.schedule,
                              color: activity.$4 ? Colors.green : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.$1,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Text(
                                  activity.$3,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            activity.$2,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: activity.$4 ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

/// Metric card for progress display
class _ProgressMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _ProgressMetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
