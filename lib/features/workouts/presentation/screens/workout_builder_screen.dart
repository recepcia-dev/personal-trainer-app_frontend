import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/workout_builder_provider.dart';

/// Comprehensive workout builder screen
///
/// Allows trainers to:
/// - Enter workout name, difficulty, and duration
/// - Add exercises with sets, reps, and weight
/// - Reorder exercises
/// - Save the workout
class WorkoutBuilderScreen extends ConsumerWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final builderState = ref.watch(workoutBuilderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
        elevation: 1,
        surfaceTintColor: Colors.blue,
        actions: [
          TextButton(
            onPressed: () {
              // Save logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Workout saved!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Name Field
            TextField(
              decoration: InputDecoration(
                labelText: 'Workout Name',
                hintText: 'e.g., Chest Day',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                ref.read(workoutBuilderProvider.notifier).setWorkoutName(value);
              },
            ),
            const SizedBox(height: 16),

            // Difficulty and Duration Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Difficulty',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: builderState.difficulty,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: ['beginner', 'intermediate', 'advanced']
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d[0].toUpperCase() + d.substring(1)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(workoutBuilderProvider.notifier)
                                .setDifficulty(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Duration (min)',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '45',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          final minutes = int.tryParse(value) ?? 45;
                          ref
                              .read(workoutBuilderProvider.notifier)
                              .setEstimatedMinutes(minutes);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Exercises Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercises (${builderState.exercises.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    // Show exercise picker
                    _showExercisePicker(context, ref);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Exercise List
            if (builderState.exercises.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No exercises added',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(workoutBuilderProvider.notifier)
                      .reorderExercises(oldIndex, newIndex);
                },
                children: [
                  for (var i = 0; i < builderState.exercises.length; i++)
                    _ExerciseListItem(
                      key: ValueKey(builderState.exercises[i].id),
                      exercise: builderState.exercises[i],
                      onRemove: () {
                        ref
                            .read(workoutBuilderProvider.notifier)
                            .removeExercise(builderState.exercises[i].id);
                      },
                      onUpdate: (sets, reps, weight) {
                        ref.read(workoutBuilderProvider.notifier).updateExercise(
                              builderState.exercises[i].id,
                              sets: sets,
                              reps: reps,
                              weightKg: weight,
                            );
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showExercisePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ExercisePickerSheet(),
    );
  }
}

/// Exercise list item widget with expand/collapse for editing
class _ExerciseListItem extends StatefulWidget {
  final dynamic exercise;
  final VoidCallback onRemove;
  final Function(int, int, double?) onUpdate;

  const _ExerciseListItem({
    required Key key,
    required this.exercise,
    required this.onRemove,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<_ExerciseListItem> createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<_ExerciseListItem> {
  late int _sets;
  late int _reps;
  late double? _weight;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _sets = widget.exercise.sets;
    _reps = widget.exercise.reps;
    _weight = widget.exercise.weightKg;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ReorderableDragStartListener(
            index: 0, // Will be updated by parent
            child: ListTile(
              leading: Icon(
                Icons.drag_handle,
                color: Colors.grey,
              ),
              title: Text(widget.exercise.exerciseName),
              subtitle: Text('${_sets} sets × ${_reps} reps ${_weight != null ? '@ ${_weight}kg' : ''}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      setState(() => _expanded = !_expanded);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: widget.onRemove,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Sets',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            _sets = int.tryParse(value) ?? _sets;
                            widget.onUpdate(_sets, _reps, _weight);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Reps',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            _reps = int.tryParse(value) ?? _reps;
                            widget.onUpdate(_sets, _reps, _weight);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _weight = double.tryParse(value);
                      widget.onUpdate(_sets, _reps, _weight);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Exercise picker bottom sheet
class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet();

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  String _searchQuery = '';
  String? _selectedCategory;
  final Set<String> _selectedExercises = {};

  // Mock exercises data
  final List<Map<String, String>> _mockExercises = [
    {'id': '1', 'name': 'Bench Press', 'category': 'Strength'},
    {'id': '2', 'name': 'Dumbbell Flyes', 'category': 'Strength'},
    {'id': '3', 'name': 'Push-ups', 'category': 'Strength'},
    {'id': '4', 'name': 'Burpees', 'category': 'Cardio'},
    {'id': '5', 'name': 'Jump Rope', 'category': 'Cardio'},
    {'id': '6', 'name': 'Yoga Flow', 'category': 'Flexibility'},
  ];

  @override
  Widget build(BuildContext context) {
    var filtered = _mockExercises.where((ex) {
      final matchesSearch =
          ex['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || ex['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Scaffold(
        appBar: AppBar(
          title: const Text('Select Exercises'),
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                hintText: 'Search exercises...',
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                    const SizedBox(width: 8),
                    ...['Strength', 'Cardio', 'Flexibility']
                        .map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(cat),
                                selected: _selectedCategory == cat,
                                onSelected: (_) =>
                                    setState(() => _selectedCategory = cat),
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final exercise = filtered[index];
                  return CheckboxListTile(
                    value: _selectedExercises.contains(exercise['id']),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedExercises.add(exercise['id']!);
                        } else {
                          _selectedExercises.remove(exercise['id']);
                        }
                      });
                    },
                    title: Text(exercise['name']!),
                    subtitle: Text(exercise['category']!),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _selectedExercises.isEmpty
                    ? null
                    : () {
                        // TODO: Add selected exercises to workout builder
                        Navigator.pop(context);
                      },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text('Add ${_selectedExercises.length} Exercise${_selectedExercises.length != 1 ? 's' : ''}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
