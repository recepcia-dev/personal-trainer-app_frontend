import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../progress/presentation/providers/progress_provider.dart';
import '../../../trainer/presentation/providers/trainer_provider.dart';
import '../providers/client_provider.dart';
import '../widgets/client_edit_form.dart';

/// Screen for viewing client details and progress
class ClientDetailScreen extends ConsumerStatefulWidget {
  final String clientId;

  const ClientDetailScreen({
    required this.clientId,
    super.key,
  });

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clientAsync = ref.watch(clientProvider(widget.clientId));
    // TODO: Implement progressStatsProvider for client statistics
    // final progressStatsAsync = ref.watch(progressStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Delete client',
          ),
        ],
      ),
      floatingActionButton: clientAsync.when(
        data: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              onPressed: () => _showAssignWorkoutDialog(),
              heroTag: 'assign_workout',
              icon: const Icon(Icons.fitness_center),
              label: const Text('Assign Workout'),
              backgroundColor: Colors.blue[700],
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              onPressed: () => _showAssignMealDialog(),
              heroTag: 'assign_meal',
              icon: const Icon(Icons.restaurant),
              label: const Text('Assign Meal'),
              backgroundColor: Colors.green[700],
            ),
          ],
        ),
        loading: () => null,
        error: (_, __) => null,
      ),
      body: clientAsync.when(
        data: (client) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 40,
                              child: Text(
                                (client.fullName.isNotEmpty
                                        ? client.fullName[0]
                                        : 'C')
                                    .toUpperCase(),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            client.fullName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(client.email),
                          if (client.phone != null) ...[
                            const SizedBox(height: 4),
                            Text(client.phone!),
                          ],
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (client.age != null)
                                Chip(label: Text('Age: ${client.age}')),
                              if (client.fitnessLevel != null)
                                Chip(label: Text('Level: ${client.fitnessLevel}')),
                            ],
                          ),
                          if (client.goals != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Goals',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(client.goals!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Edit form (if enabled)
                  if (_isEditMode)
                    ClientEditForm(
                      client: client,
                      onSaved: () => setState(() => _isEditMode = false),
                    ),

                  if (!_isEditMode) ...[
                    // Progress section
                    Text(
                      'Progress Overview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // TODO: Implement progress statistics display
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Progress statistics coming soon',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
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
          child: Text('Error loading client: $error'),
        ),
      ),
    );
  }

  void _showAssignWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => _AssignWorkoutDialog(clientId: widget.clientId),
    );
  }

  void _showAssignMealDialog() {
    showDialog(
      context: context,
      builder: (context) => _AssignMealDialog(clientId: widget.clientId),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: const Text(
          'Are you sure you want to delete this client? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteClient(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[700],
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClient(BuildContext context) async {
    try {
      Navigator.of(context).pop(); // Close the confirmation dialog

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleting client...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Delete the client
      await ref.read(deleteClientProvider(widget.clientId).future);

      // Invalidate providers to refresh the client list
      if (mounted) {
        ref.invalidate(clientsProvider((skip: 0, limit: 100)));
        ref.invalidate(allClientsProvider);
        ref.invalidate(clientProvider(widget.clientId));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to clients list
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting client: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatCard(
    ThemeData theme,
    String value,
    String label,
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
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
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
}

/// Dialog for assigning workout to client
class _AssignWorkoutDialog extends ConsumerStatefulWidget {
  final String clientId;

  const _AssignWorkoutDialog({required this.clientId});

  @override
  ConsumerState<_AssignWorkoutDialog> createState() => _AssignWorkoutDialogState();
}

class _AssignWorkoutDialogState extends ConsumerState<_AssignWorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _workoutNameController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _workoutNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _assignWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Generate a workout ID (in production, this would come from selecting an existing workout)
      final workoutId = const Uuid().v4();
      final sets = int.tryParse(_setsController.text);
      final reps = int.tryParse(_repsController.text);

      // Call backend API to assign workout
      final params = AssignWorkoutParams(
        clientId: widget.clientId,
        workoutId: workoutId,
        sets: sets,
        reps: reps,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        startDate: DateTime.now(),
      );

      await ref.read(assignWorkoutProvider(params).future);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
    return AlertDialog(
      title: const Text('Assign Workout'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _workoutNameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  hintText: 'e.g., Chest Day',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter workout name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _setsController,
                      decoration: const InputDecoration(labelText: 'Sets'),
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
                      decoration: const InputDecoration(labelText: 'Reps'),
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
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional instructions...',
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
          onPressed: _isLoading ? null : _assignWorkout,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Assign'),
        ),
      ],
    );
  }
}

/// Dialog for assigning meal to client
class _AssignMealDialog extends ConsumerStatefulWidget {
  final String clientId;

  const _AssignMealDialog({required this.clientId});

  @override
  ConsumerState<_AssignMealDialog> createState() => _AssignMealDialogState();
}

class _AssignMealDialogState extends ConsumerState<_AssignMealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _mealNameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  // Days of week selection
  final Map<String, bool> _selectedDays = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': true,
    'Sunday': true,
  };

  @override
  void dispose() {
    _mealNameController.dispose();
    _ingredientsController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _assignMeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Parse calories
      final calories = _caloriesController.text.isNotEmpty
          ? double.tryParse(_caloriesController.text)
          : null;

      // Call backend API to assign meal
      final params = AssignDietParams(
        clientId: widget.clientId,
        mealName: _mealNameController.text,
        ingredients: _ingredientsController.text.isNotEmpty
            ? _ingredientsController.text
            : null,
        caloriesApprox: calories,
        monday: _selectedDays['Monday']!,
        tuesday: _selectedDays['Tuesday']!,
        wednesday: _selectedDays['Wednesday']!,
        thursday: _selectedDays['Thursday']!,
        friday: _selectedDays['Friday']!,
        saturday: _selectedDays['Saturday']!,
        sunday: _selectedDays['Sunday']!,
        startDate: DateTime.now(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await ref.read(assignDietProvider(params).future);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal plan assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
    return AlertDialog(
      title: const Text('Assign Meal Plan'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _mealNameController,
                decoration: const InputDecoration(
                  labelText: 'Meal Name',
                  hintText: 'e.g., Breakfast',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter meal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredients',
                  hintText: 'e.g., Oats, banana, protein powder',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories (approx)',
                  suffixText: 'kcal',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text('Days:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _selectedDays.keys.map((day) {
                  return FilterChip(
                    label: Text(day.substring(0, 3)),
                    selected: _selectedDays[day]!,
                    onSelected: (selected) {
                      setState(() => _selectedDays[day] = selected);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional instructions...',
                ),
                maxLines: 2,
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
          onPressed: _isLoading ? null : _assignMeal,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Assign'),
        ),
      ],
    );
  }
}
