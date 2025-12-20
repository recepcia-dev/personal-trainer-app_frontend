import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../workouts/data/models/assigned_workout_model.dart';
import '../../data/models/progress_request_model.dart';
import '../providers/progress_provider.dart';

/// Dialog for logging workout completion
class WorkoutCompletionDialog extends ConsumerStatefulWidget {
  final AssignedWorkoutModel workout;

  const WorkoutCompletionDialog({
    required this.workout,
    super.key,
  });

  @override
  ConsumerState<WorkoutCompletionDialog> createState() =>
      _WorkoutCompletionDialogState();
}

class _WorkoutCompletionDialogState
    extends ConsumerState<WorkoutCompletionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  int _difficultyRating = 5;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with assigned values
    _setsController.text = widget.workout.sets?.toString() ?? '';
    _repsController.text = widget.workout.reps?.toString() ?? '';
    _weightController.text = widget.workout.weightKg?.toString() ?? '';
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _logProgress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = ProgressRequestModel(
        workoutAssignmentId: widget.workout.id,
        setsCompleted: int.tryParse(_setsController.text),
        repsCompleted: int.tryParse(_repsController.text),
        weightKgUsed: double.tryParse(_weightController.text),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        difficultyRating: _difficultyRating,
      );

      await ref.read(registerProgressProvider(request).future);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging progress: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Log Workout: ${widget.workout.workoutName}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sets and Reps
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _setsController,
                      decoration: const InputDecoration(
                        labelText: 'Sets Completed',
                        hintText: '3',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      decoration: const InputDecoration(
                        labelText: 'Reps Completed',
                        hintText: '10',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight Used (kg)',
                  hintText: '50.0',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),

              // Difficulty Rating
              Text(
                'Difficulty Rating: $_difficultyRating/10',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _difficultyRating.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _difficultyRating.toString(),
                onChanged: (value) {
                  setState(() => _difficultyRating = value.toInt());
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'How did it feel?',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _logProgress,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Log Progress'),
        ),
      ],
    );
  }
}
