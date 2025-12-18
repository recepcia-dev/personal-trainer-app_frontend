import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/exercise_provider.dart';
import '../providers/progress_provider.dart';

/// Screen for viewing progress statistics and charts
class ProgressChartScreen extends ConsumerStatefulWidget {
  const ProgressChartScreen({super.key});

  @override
  ConsumerState<ProgressChartScreen> createState() =>
      _ProgressChartScreenState();
}

class _ProgressChartScreenState extends ConsumerState<ProgressChartScreen> {
  String? _selectedExerciseId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Your Progress',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Overall stats
              _buildOverallStats(context, theme),
              const SizedBox(height: 24),

              // Exercise selection
              Text(
                'View Exercise History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildExerciseSelector(context, theme),
              const SizedBox(height: 24),

              // Exercise history if selected
              if (_selectedExerciseId != null)
                _buildExerciseHistory(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context, ThemeData theme) {
    return ref.watch(progressStatsProvider).when(
      data: (stats) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Statistics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildStatCard(
                      theme,
                      'Total Exercises',
                      '${stats.totalExercisesLogged}',
                      Icons.fitness_center,
                    ),
                    _buildStatCard(
                      theme,
                      'Unique Exercises',
                      '${stats.uniqueExercises}',
                      Icons.list,
                    ),
                    _buildStatCard(
                      theme,
                      'Total Weight (kg)',
                      '${stats.totalWeightLifted.toStringAsFixed(1)}',
                      Icons.scale,
                    ),
                    _buildStatCard(
                      theme,
                      'Avg Reps/Set',
                      '${stats.averageRepsPerSet.toStringAsFixed(1)}',
                      Icons.repeat,
                    ),
                  ],
                ),
                if (stats.lastLoggedAt != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Last Logged: ${stats.lastLoggedAt!.toString().split('.')[0]}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading stats: $error'),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSelector(BuildContext context, ThemeData theme) {
    return ref.watch(allProgressLogsProvider).when(
      data: (logs) {
        final exerciseIds = logs.map((l) => l.exerciseId).toSet().toList();

        if (exerciseIds.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No exercises logged yet',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: exerciseIds.length,
          itemBuilder: (context, index) {
            final exerciseId = exerciseIds[index];
            final isSelected = _selectedExerciseId == exerciseId;

            return ref.watch(exerciseProvider(exerciseId)).when(
              data: (exercise) {
                return Card(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : null,
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _selectedExerciseId = isSelected ? null : exerciseId;
                      });
                    },
                    title: Text(exercise.name),
                    trailing: isSelected
                        ? Icon(Icons.expand_less,
                            color: theme.colorScheme.primary)
                        : Icon(Icons.expand_more,
                            color: theme.colorScheme.outline),
                  ),
                );
              },
              loading: () => const ListTile(
                title: CircularProgressIndicator(),
              ),
              error: (error, stack) => ListTile(
                title: Text('Error: $error'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading exercises: $error'),
      ),
    );
  }

  Widget _buildExerciseHistory(BuildContext context, ThemeData theme) {
    return ref.watch(exerciseHistoryProvider(_selectedExerciseId!)).when(
      data: (history) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.exerciseName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildStatCard(
                      theme,
                      'Total Logs',
                      '${history.totalLogs}',
                      Icons.list,
                    ),
                    _buildStatCard(
                      theme,
                      'Total Volume',
                      '${history.totalVolume.toStringAsFixed(1)} kg',
                      Icons.scale,
                    ),
                    if (history.maxWeight != null)
                      _buildStatCard(
                        theme,
                        'Max Weight',
                        '${history.maxWeight!.toStringAsFixed(1)} kg',
                        Icons.trending_up,
                      ),
                    if (history.averageWeight != null)
                      _buildStatCard(
                        theme,
                        'Avg Weight',
                        '${history.averageWeight!.toStringAsFixed(1)} kg',
                        Icons.show_chart,
                      ),
                    _buildStatCard(
                      theme,
                      'Avg Reps',
                      '${history.averageReps.toStringAsFixed(1)}',
                      Icons.repeat,
                    ),
                  ],
                ),
                if (history.lastLoggedAt != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Last Logged: ${history.lastLoggedAt!.toString().split('.')[0]}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading history: $error'),
      ),
    );
  }
}
