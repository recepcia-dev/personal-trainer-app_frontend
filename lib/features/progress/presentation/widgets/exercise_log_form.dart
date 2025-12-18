import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/exercise_provider.dart';
import '../providers/progress_provider.dart';

/// Form widget for logging exercise completion
class ExerciseLogForm extends ConsumerStatefulWidget {
  final String exerciseId;

  const ExerciseLogForm({
    required this.exerciseId,
    super.key,
  });

  @override
  ConsumerState<ExerciseLogForm> createState() => _ExerciseLogFormState();
}

class _ExerciseLogFormState extends ConsumerState<ExerciseLogForm> {
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController();
    _repsController = TextEditingController();
    _weightController = TextEditingController();
    _durationController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ref.watch(exerciseProvider(widget.exerciseId)).when(
      data: (exercise) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (exercise.description != null)
                      Text(
                        exercise.description!,
                        style: theme.textTheme.bodySmall,
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        if (exercise.muscleGroup != null)
                          Chip(
                            label: Text(exercise.muscleGroup!),
                            side: BorderSide(color: theme.colorScheme.outline),
                          ),
                        if (exercise.equipment != null)
                          Chip(
                            label: Text(exercise.equipment!),
                            side: BorderSide(color: theme.colorScheme.outline),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form fields
            Text(
              'Log Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Sets field
            TextField(
              controller: _setsController,
              decoration: InputDecoration(
                labelText: 'Sets',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.repeat),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Reps field
            TextField(
              controller: _repsController,
              decoration: InputDecoration(
                labelText: 'Reps per Set',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.fitness_center),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Weight field (optional)
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg) - Optional',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.scale),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),

            // Duration field (optional)
            TextField(
              controller: _durationController,
              decoration: InputDecoration(
                labelText: 'Duration (seconds) - Optional',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Notes field
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes - Optional',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitForm,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSubmitting ? 'Logging...' : 'Log Exercise'),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading exercise: $error'),
      ),
    );
  }

  Future<void> _submitForm() async {
    // Validate inputs
    if (_setsController.text.isEmpty || _repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sets and Reps are required')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(logExerciseNotifierProvider.notifier).logExercise(
        exerciseId: widget.exerciseId,
        setsCompleted: int.parse(_setsController.text),
        repsPerSet: int.parse(_repsController.text),
        weightKg: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        durationSeconds: _durationController.text.isNotEmpty
            ? int.tryParse(_durationController.text)
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _setsController.clear();
        _repsController.clear();
        _weightController.clear();
        _durationController.clear();
        _notesController.clear();

        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }
}
