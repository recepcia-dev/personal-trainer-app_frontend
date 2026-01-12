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
        title: const Text('Detalles del Cliente'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Eliminar cliente',
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
              label: const Text('Asignar Rutina'),
              backgroundColor: Colors.blue[700],
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              onPressed: () => _showAssignMealDialog(),
              heroTag: 'assign_meal',
              icon: const Icon(Icons.restaurant),
              label: const Text('Asignar Comida'),
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
                                Chip(label: Text('Edad: ${client.age}')),
                              if (client.fitnessLevel != null)
                                Chip(label: Text('Nivel: ${client.fitnessLevel}')),
                            ],
                          ),
                          if (client.goals != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Objetivos',
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
                      'Resumen de Progreso',
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
                            'Estadísticas de progreso próximamente',
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
          child: Text('Error al cargar cliente: $error'),
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
        title: const Text('Eliminar Cliente'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este cliente? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _deleteClient(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[700],
            ),
            child: const Text('Eliminar'),
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
            content: Text('Eliminando cliente...'),
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
            content: Text('Cliente eliminado exitosamente'),
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
            content: Text('Error al eliminar cliente: $e'),
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
            content: Text('¡Rutina asignada exitosamente!'),
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
      title: const Text('Asignar Rutina'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _workoutNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Rutina',
                  hintText: 'ej., Día de Pecho',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre de la rutina';
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
                      decoration: const InputDecoration(labelText: 'Series'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      decoration: const InputDecoration(labelText: 'Repeticiones'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
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
                  labelText: 'Notas (Opcional)',
                  hintText: 'Instrucciones adicionales...',
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
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _assignWorkout,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Asignar'),
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
  String? _selectedMealType;
  final _ingredientsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  // Available meal types
  static const _mealTypes = ['Desayuno', 'Almuerzo', 'Merienda', 'Cena'];

  // Days of week selection
  final Map<String, bool> _selectedDays = {
    'Lunes': true,
    'Martes': true,
    'Miércoles': true,
    'Jueves': true,
    'Viernes': true,
    'Sábado': true,
    'Domingo': true,
  };

  @override
  void dispose() {
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
        mealName: _selectedMealType!,
        ingredients: _ingredientsController.text.isNotEmpty
            ? _ingredientsController.text
            : null,
        caloriesApprox: calories,
        monday: _selectedDays['Lunes']!,
        tuesday: _selectedDays['Martes']!,
        wednesday: _selectedDays['Miércoles']!,
        thursday: _selectedDays['Jueves']!,
        friday: _selectedDays['Viernes']!,
        saturday: _selectedDays['Sábado']!,
        sunday: _selectedDays['Domingo']!,
        startDate: DateTime.now(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await ref.read(assignDietProvider(params).future);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Plan de comida asignado exitosamente!'),
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
      title: const Text('Asignar Plan de Comida'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedMealType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Comida',
                  hintText: 'Seleccionar tipo de comida',
                ),
                items: _mealTypes.map((mealType) {
                  return DropdownMenuItem(
                    value: mealType,
                    child: Text(mealType),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedMealType = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona un tipo de comida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredientes',
                  hintText: 'ej., Avena, plátano, proteína en polvo',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calorías (aprox)',
                  suffixText: 'kcal',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text('Días:', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  labelText: 'Notas (Opcional)',
                  hintText: 'Instrucciones adicionales...',
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
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _assignMeal,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Asignar'),
        ),
      ],
    );
  }
}
