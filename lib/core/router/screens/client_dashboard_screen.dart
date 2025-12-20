import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../../features/auth/data/models/client_model.dart';
import '../../../features/workouts/presentation/providers/client_workout_provider.dart';
import '../../../features/meals/presentation/providers/client_diet_provider.dart';
import '../../../features/progress/presentation/widgets/workout_completion_dialog.dart';
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
        children: [
          _ClientTodayTab(user: user),
          const _ClientProgressTab(),
          const WorkoutsTab(),
          const ProfileTab(),
        ],
      ),
    );
  }
}

/// Today tab - displays today's workout and meals
class _ClientTodayTab extends ConsumerWidget {
  final dynamic user;

  const _ClientTodayTab({this.user});

  /// Get current day name (e.g., "monday", "tuesday")
  String _getCurrentDayName() {
    final weekday = DateTime.now().weekday;
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isClient = user is ClientModel;
    final clientTrainerId = isClient ? (user as ClientModel).trainerId : null;

    final workoutsAsync = ref.watch(assignedWorkoutsProvider);
    final dietAsync = ref.watch(assignedDietProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trainer Info Card (for clients)
          if (isClient && clientTrainerId != null && clientTrainerId.isNotEmpty) ...[
            _TrainerInfoCard(trainerId: clientTrainerId),
            const SizedBox(height: 24),
          ],

          // Hero Workout Card
          workoutsAsync.when(
            data: (workouts) {
              if (workouts.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.fitness_center_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No workouts assigned yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final todayWorkout = workouts.first;
              return Container(
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
                                todayWorkout.workoutName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${todayWorkout.sets ?? 3} sets • ${todayWorkout.reps ?? 10} reps${todayWorkout.durationMinutes != null ? ' • ${todayWorkout.durationMinutes} min' : ''}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                              if (todayWorkout.notes != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  todayWorkout.notes!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => WorkoutCompletionDialog(
                                workout: todayWorkout,
                              ),
                            );

                            // Refresh workouts list if progress was logged
                            if (result == true) {
                              ref.invalidate(assignedWorkoutsProvider);
                            }
                          },
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
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Error loading workouts: $error',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ),
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
          dietAsync.when(
            data: (meals) {
              if (meals.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.restaurant_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No meal plan assigned yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Filter meals for today
              final currentDay = _getCurrentDayName();
              final todayMeals = meals.where((meal) {
                switch (currentDay) {
                  case 'monday':
                    return meal.monday == 1;
                  case 'tuesday':
                    return meal.tuesday == 1;
                  case 'wednesday':
                    return meal.wednesday == 1;
                  case 'thursday':
                    return meal.thursday == 1;
                  case 'friday':
                    return meal.friday == 1;
                  case 'saturday':
                    return meal.saturday == 1;
                  case 'sunday':
                    return meal.sunday == 1;
                  default:
                    return false;
                }
              }).toList();

              if (todayMeals.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No meals scheduled for today',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: todayMeals.map((meal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Checkbox(
                              value: false, // TODO: Track meal completion state
                              onChanged: (_) {
                                // TODO: Implement meal completion tracking
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.mealName,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  if (meal.caloriesApprox != null)
                                    Text(
                                      '${meal.caloriesApprox!.toStringAsFixed(0)} cal',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  if (meal.ingredients != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      meal.ingredients!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: Colors.grey, // TODO: Update based on completion state
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Error loading meals: $error',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ),
            ),
          ),
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

/// Trainer Info Card - displays the client's assigned trainer information
class _TrainerInfoCard extends StatelessWidget {
  final String trainerId;

  const _TrainerInfoCard({required this.trainerId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[600]!,
              Colors.teal[700]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Trainer',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Trainer ID: $trainerId',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Linked to your account',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your trainer can assign workouts and meal plans to you.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
