import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/client_workout_provider.dart';
import '../../data/models/assigned_workout_model.dart';
import '../../../progress/presentation/widgets/workout_completion_dialog.dart';

/// Screen displaying workout details for clients
class ClientWorkoutDetailScreen extends ConsumerWidget {
  final String assignmentId;

  const ClientWorkoutDetailScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(workoutDetailProvider(assignmentId));

    return Scaffold(
      body: workoutAsync.when(
        data: (workout) => _WorkoutDetailContent(workout: workout),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorContent(
          error: error.toString(),
          onRetry: () => ref.invalidate(workoutDetailProvider(assignmentId)),
          onBack: () => context.pop(),
        ),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ErrorContent({
    required this.error,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Workout'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Error Loading Workout',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutDetailContent extends ConsumerStatefulWidget {
  final AssignedWorkoutModel workout;

  const _WorkoutDetailContent({required this.workout});

  @override
  ConsumerState<_WorkoutDetailContent> createState() =>
      _WorkoutDetailContentState();
}

class _WorkoutDetailContentState extends ConsumerState<_WorkoutDetailContent> {
  bool _isCompleting = false;

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      case 'hiit':
        return Icons.flash_on;
      default:
        return Icons.sports_gymnastics;
    }
  }

  Future<void> _markComplete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WorkoutCompletionDialog(
        workout: widget.workout,
      ),
    );

    if (result == true && mounted) {
      // Refresh data
      ref.invalidate(assignedWorkoutsProvider);
      ref.invalidate(workoutDetailProvider(widget.workout.id));
      ref.invalidate(completedWorkoutsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Workout completed! Great job! 💪'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to workouts list
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workout = widget.workout;

    return CustomScrollView(
      slivers: [
        // App Bar with gradient background
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              workout.workoutName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[400]!, Colors.teal[600]!],
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(workout.workoutCategory),
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meta badges row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (workout.workoutDifficulty != null)
                      _Badge(
                        label: workout.workoutDifficulty!,
                        color: _getDifficultyColor(workout.workoutDifficulty),
                        icon: Icons.signal_cellular_alt,
                      ),
                    if (workout.workoutCategory != null)
                      _Badge(
                        label: workout.workoutCategory!,
                        color: Colors.blue,
                        icon: _getCategoryIcon(workout.workoutCategory),
                      ),
                    if (workout.durationMinutes != null)
                      _Badge(
                        label: '${workout.durationMinutes} min',
                        color: Colors.purple,
                        icon: Icons.timer_outlined,
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description section
                if (workout.workoutDescription != null) ...[
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.workoutDescription!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Trainer info
                if (workout.trainerName != null) ...[
                  Text(
                    'Assigned By',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: Colors.green,
                        ),
                      ),
                      title: Text(workout.trainerName!),
                      subtitle: const Text('Personal Trainer'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Notes from trainer
                if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                  Text(
                    'Trainer Notes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            workout.notes!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.amber[900],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Workout details placeholder
                Text(
                  'Exercises',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.format_list_bulleted,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Exercise details coming soon',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your trainer will add specific exercises and instructions here.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Complete workout button
                if (!workout.isCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isCompleting ? null : _markComplete,
                      icon: _isCompleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _isCompleting ? 'Completing...' : 'Mark as Complete',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                // Already completed message
                if (workout.isCompleted) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workout Completed!',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (workout.completedAt != null)
                              Text(
                                'Completed on ${_formatDate(workout.completedAt!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green[700],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
