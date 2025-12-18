import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/exercise_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/exercise_log_form.dart';

/// Screen for logging exercise progress
class ExerciseLogScreen extends ConsumerStatefulWidget {
  const ExerciseLogScreen({super.key});

  @override
  ConsumerState<ExerciseLogScreen> createState() => _ExerciseLogScreenState();
}

class _ExerciseLogScreenState extends ConsumerState<ExerciseLogScreen> {
  String? _selectedExerciseId;
  String? _selectedCategory;

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
                'Log Your Exercise',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Category filter
              Text(
                'Select Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildCategoryFilter(context, theme),
              const SizedBox(height: 24),

              // Exercises list
              Text(
                'Select Exercise',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildExercisesList(context, theme),
              const SizedBox(height: 24),

              // Exercise form
              if (_selectedExerciseId != null)
                ExerciseLogForm(exerciseId: _selectedExerciseId!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, ThemeData theme) {
    return ref.watch(exercisesProvider(
      (category: null, muscleGroup: null),
    )).when(
      data: (exercises) {
        final categories = exercises.map((e) => e.category).toSet().toList();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedCategory == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                ),
              )),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Center(
        child: Text('Error loading categories: $error'),
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context, ThemeData theme) {
    return ref.watch(exercisesProvider(
      (category: _selectedCategory, muscleGroup: null),
    )).when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No exercises found',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            final isSelected = _selectedExerciseId == exercise.id;

            return Card(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : null,
              child: ListTile(
                onTap: () {
                  setState(() {
                    _selectedExerciseId = isSelected ? null : exercise.id;
                  });
                },
                title: Text(exercise.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    if (exercise.muscleGroup != null)
                      Text('Muscle: ${exercise.muscleGroup}'),
                    if (exercise.equipment != null)
                      Text('Equipment: ${exercise.equipment}'),
                  ],
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle,
                        color: theme.colorScheme.primary)
                    : Icon(Icons.radio_button_unchecked,
                        color: theme.colorScheme.outline),
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
}
