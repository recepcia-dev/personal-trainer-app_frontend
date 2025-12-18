import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/workout_execution_provider.dart';

/// Client workout detail screen - execute and log workout
///
/// Allows clients to:
/// - View workout details and timer
/// - For each exercise: see prescribed and enter actual sets/reps/weight
/// - Mark exercises complete
/// - Log workout progress
class ClientWorkoutDetailScreen extends ConsumerStatefulWidget {
  final String workoutId;
  final String workoutName;
  final int estimatedMinutes;
  final List<Map<String, dynamic>> exercises;

  const ClientWorkoutDetailScreen({
    required this.workoutId,
    required this.workoutName,
    required this.estimatedMinutes,
    required this.exercises,
    super.key,
  });

  @override
  ConsumerState<ClientWorkoutDetailScreen> createState() =>
      _ClientWorkoutDetailScreenState();
}

class _ClientWorkoutDetailScreenState
    extends ConsumerState<ClientWorkoutDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final executionState = ref.watch(
      workoutExecutionProvider(
        (
          workoutId: widget.workoutId,
          workoutName: widget.workoutName,
          estimatedMinutes: widget.estimatedMinutes,
          exercises: widget.exercises,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutName),
        elevation: 1,
        surfaceTintColor: Colors.green,
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            color: Colors.green.withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Timer and progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Elapsed Time',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${executionState.elapsedMinutes}m',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Completed',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${executionState.completedCount}/${executionState.exercises.length}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: executionState.completionPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Exercise List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: executionState.exercises.length,
              itemBuilder: (context, index) {
                final exercise = executionState.exercises[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ExerciseCompletionCard(
                    exercise: exercise,
                    onUpdate: (sets, reps, weight, isCompleted) {
                      ref
                          .read(
                            workoutExecutionProvider(
                              (
                                workoutId: widget.workoutId,
                                workoutName: widget.workoutName,
                                estimatedMinutes: widget.estimatedMinutes,
                                exercises: widget.exercises,
                              ),
                            ).notifier,
                          )
                          .updateExercise(
                            exercise.id,
                            sets: sets,
                            reps: reps,
                            weightKg: weight,
                            isCompleted: isCompleted,
                          );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: executionState.allCompleted
              ? () {
                  // Show completion dialog
                  _showCompletionDialog(context, ref, executionState);
                }
              : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: Text(
            executionState.allCompleted
                ? '✓ Complete Workout'
                : 'Complete ${executionState.completedCount}/${executionState.exercises.length}',
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog(
    BuildContext context,
    WidgetRef ref,
    WorkoutExecutionState state,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout Complete! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Great job completing ${state.workoutName}!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Completed: ${state.elapsedMinutes} minutes\nExercises: ${state.completedCount}/${state.exercises.length}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Details'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Save progress logs to database
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

/// Individual exercise card for logging
class _ExerciseCompletionCard extends StatefulWidget {
  final dynamic exercise;
  final Function(int, int, double?, bool) onUpdate;

  const _ExerciseCompletionCard({
    required this.exercise,
    required this.onUpdate,
  });

  @override
  State<_ExerciseCompletionCard> createState() =>
      _ExerciseCompletionCardState();
}

class _ExerciseCompletionCardState extends State<_ExerciseCompletionCard> {
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _setsController =
        TextEditingController(text: widget.exercise.completedSets.toString());
    _repsController =
        TextEditingController(text: widget.exercise.completedReps.toString());
    _weightController = TextEditingController(
      text: widget.exercise.completedWeightKg?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _updateExercise() {
    final sets = int.tryParse(_setsController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    final weight = double.tryParse(_weightController.text);
    widget.onUpdate(sets, reps, weight, widget.exercise.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Checkbox(
              value: widget.exercise.isCompleted,
              onChanged: (value) {
                final sets = int.tryParse(_setsController.text) ?? 0;
                final reps = int.tryParse(_repsController.text) ?? 0;
                final weight = double.tryParse(_weightController.text);
                widget.onUpdate(sets, reps, weight, value ?? false);
                setState(() {});
              },
            ),
            title: Text(
              widget.exercise.exerciseName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Prescribed: ${widget.exercise.prescribedSets}×${widget.exercise.prescribedReps}${widget.exercise.prescribedWeightKg != null ? ' @ ${widget.exercise.prescribedWeightKg}kg' : ''}',
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() => _expanded = !_expanded);
              },
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Log Your Performance',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _setsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Sets',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (_) => _updateExercise(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _repsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Reps',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (_) => _updateExercise(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (_) => _updateExercise(),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      onPressed: () {
                        setState(() => _expanded = false);
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
