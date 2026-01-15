import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../../features/auth/data/models/client_model.dart';
import '../../../features/workouts/presentation/providers/client_workout_provider.dart';
import '../../../features/meals/presentation/providers/client_diet_provider.dart';
import '../../../features/progress/presentation/widgets/workout_completion_dialog.dart';
import '../../../features/progress/presentation/providers/progress_provider.dart';
import 'dashboard_tabs/workouts_tab.dart';
import 'dashboard_tabs/profile_tab.dart';

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

/// Progress tab - displays performance metrics, charts, and completed workout history
class _ClientProgressTab extends ConsumerWidget {
  const _ClientProgressTab();

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressStatsAsync = ref.watch(clientProgressStatsProvider);
    final completedWorkoutsAsync = ref.watch(completedWorkoutsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Summary Cards from API
          progressStatsAsync.when(
            data: (stats) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _ProgressMetricCard(
                          value: '${stats.currentStreak}',
                          label: 'Day Streak',
                          icon: Icons.local_fire_department,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ProgressMetricCard(
                          value: '${stats.totalWorkoutsCompleted}',
                          label: 'Completed',
                          icon: Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ProgressMetricCard(
                          value: stats.currentWeightKg != null
                              ? '${stats.currentWeightKg!.toStringAsFixed(1)}'
                              : '-',
                          label: 'Weight (kg)',
                          icon: Icons.scale,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _ProgressMetricCard(
                          value: '${stats.completionRate.toStringAsFixed(0)}%',
                          label: 'Completion',
                          icon: Icons.pie_chart,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ProgressMetricCard(
                          value: stats.weightChangeKg != null
                              ? '${stats.weightChangeKg! >= 0 ? '+' : ''}${stats.weightChangeKg!.toStringAsFixed(1)}'
                              : '-',
                          label: 'Weight Δ',
                          icon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ProgressMetricCard(
                          value: '${stats.totalWorkoutsAssigned}',
                          label: 'Assigned',
                          icon: Icons.fitness_center,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Expanded(child: _ProgressMetricCard(value: '-', label: 'Day Streak', icon: Icons.local_fire_department)),
                SizedBox(width: 8),
                Expanded(child: _ProgressMetricCard(value: '-', label: 'Completed', icon: Icons.check_circle)),
                SizedBox(width: 8),
                Expanded(child: _ProgressMetricCard(value: '-', label: 'Weight (kg)', icon: Icons.scale)),
              ],
            ),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          // Log Measurement Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogMeasurementDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Log Measurement'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Workout Frequency Chart
          Text(
            'Weekly Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          progressStatsAsync.when(
            data: (stats) {
              if (stats.weeklyWorkoutData.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No workout data yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                  ),
                );
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: _WorkoutFrequencyChart(data: stats.weeklyWorkoutData),
                  ),
                ),
              );
            },
            loading: () => Card(
              child: SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          // Completion Rate Chart
          Text(
            'Completion Rate',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          progressStatsAsync.when(
            data: (stats) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 180,
                  child: _CompletionRateChart(
                    completed: stats.totalWorkoutsCompleted,
                    remaining: stats.totalWorkoutsAssigned - stats.totalWorkoutsCompleted,
                    rate: stats.completionRate,
                  ),
                ),
              ),
            ),
            loading: () => Card(
              child: SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          // Workout History
          Text(
            'Workout History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          completedWorkoutsAsync.when(
            data: (completed) {
              if (completed.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No completed workouts yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete your first workout to see it here!',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: completed.take(5).map((workout) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.workoutName,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              if (workout.completedAt != null)
                                Text(
                                  _formatTimeAgo(workout.completedAt!),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          'Completed',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[400]),
                      const SizedBox(height: 8),
                      Text('Error loading history', style: TextStyle(color: Colors.red[700])),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogMeasurementDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _LogMeasurementSheet(),
    );
  }
}

/// Workout frequency bar chart widget
class _WorkoutFrequencyChart extends StatelessWidget {
  final List<WeeklyWorkoutData> data;

  const _WorkoutFrequencyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} workouts',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index].weekLabel,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == value.roundToDouble()) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final weekData = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weekData.workoutsCompleted.toDouble(),
                color: Colors.green,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: weekData.workoutsAssigned.toDouble(),
                  color: Colors.green.withOpacity(0.2),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _getMaxY() {
    double max = 1;
    for (final week in data) {
      if (week.workoutsAssigned > max) max = week.workoutsAssigned.toDouble();
      if (week.workoutsCompleted > max) max = week.workoutsCompleted.toDouble();
    }
    return max + 1;
  }
}

/// Completion rate pie chart widget
class _CompletionRateChart extends StatelessWidget {
  final int completed;
  final int remaining;
  final double rate;

  const _CompletionRateChart({
    required this.completed,
    required this.remaining,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: completed.toDouble(),
                  title: '$completed',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.grey[300],
                  value: remaining > 0 ? remaining.toDouble() : 0.1,
                  title: remaining > 0 ? '$remaining' : '',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${rate.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Completion Rate',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(width: 12, height: 12, color: Colors.green),
                const SizedBox(width: 8),
                Text('Completed ($completed)', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(width: 12, height: 12, color: Colors.grey[300]),
                const SizedBox(width: 8),
                Text('Remaining ($remaining)', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Bottom sheet for logging measurements
class _LogMeasurementSheet extends ConsumerStatefulWidget {
  const _LogMeasurementSheet();

  @override
  ConsumerState<_LogMeasurementSheet> createState() => _LogMeasurementSheetState();
}

class _LogMeasurementSheetState extends ConsumerState<_LogMeasurementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log Measurement',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.height),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bodyFatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Body Fat %',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.percent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _waistController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Waist (cm)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chestController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Chest (cm)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _saveMeasurement,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Measurement'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMeasurement() async {
    if (_weightController.text.isEmpty &&
        _heightController.text.isEmpty &&
        _bodyFatController.text.isEmpty &&
        _waistController.text.isEmpty &&
        _chestController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one measurement')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(logMeasurementNotifierProvider.notifier).logMeasurement(
        weightKg: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
        heightCm: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
        bodyFatPercentage: _bodyFatController.text.isNotEmpty ? double.tryParse(_bodyFatController.text) : null,
        waistCm: _waistController.text.isNotEmpty ? double.tryParse(_waistController.text) : null,
        chestCm: _chestController.text.isNotEmpty ? double.tryParse(_chestController.text) : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Measurement saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh stats
        ref.invalidate(clientProgressStatsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving measurement: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
