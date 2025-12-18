import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/meal_plan_builder_provider.dart';
import '../../domain/entities/meal.dart';

/// Meal plan builder screen - create and manage meal plans for clients
///
/// Allows trainers to:
/// - Set meal plan name and description
/// - Add meals with nutritional information
/// - Organize meals by type (breakfast, lunch, dinner, snack)
/// - View real-time calorie and macro totals
/// - Save and assign meal plan to clients
class MealPlanBuilderScreen extends ConsumerStatefulWidget {
  const MealPlanBuilderScreen({super.key});

  @override
  ConsumerState<MealPlanBuilderScreen> createState() =>
      _MealPlanBuilderScreenState();
}

class _MealPlanBuilderScreenState extends ConsumerState<MealPlanBuilderScreen> {
  late TextEditingController _mealPlanNameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _mealPlanNameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _mealPlanNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final builderState = ref.watch(mealPlanBuilderProvider);

    // Sync controllers with provider state
    if (_mealPlanNameController.text != builderState.mealPlanName) {
      _mealPlanNameController.text = builderState.mealPlanName;
    }
    if (_descriptionController.text != (builderState.description ?? '')) {
      _descriptionController.text = builderState.description ?? '';
    }

    // Group meals by type
    final mealsByType = <String, List<Meal>>{};
    final mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    for (final type in mealTypes) {
      mealsByType[type] = builderState.meals
          .where((meal) => meal.mealType == type)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Meal Plan'),
        elevation: 1,
        surfaceTintColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${builderState.totalCalories} cal',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Plan Name Input
            TextField(
              controller: _mealPlanNameController,
              decoration: InputDecoration(
                labelText: 'Meal Plan Name',
                hintText: 'e.g., Weekly Bulk, Cutting Phase',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.restaurant),
              ),
              onChanged: (name) {
                ref.read(mealPlanBuilderProvider.notifier).setMealPlanName(name);
              },
            ),
            const SizedBox(height: 16),

            // Description Input
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Meal plan goals and notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 2,
              onChanged: (description) {
                ref.read(mealPlanBuilderProvider.notifier).setDescription(description);
              },
            ),
            const SizedBox(height: 24),

            // Nutrition Summary Cards
            Row(
              children: [
                Expanded(
                  child: _NutritionCard(
                    label: 'Calories',
                    value: '${builderState.totalCalories}',
                    color: Colors.green,
                    unit: 'kcal',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NutritionCard(
                    label: 'Protein',
                    value: _getTotalProtein(builderState.meals).toStringAsFixed(1),
                    color: Colors.red,
                    unit: 'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NutritionCard(
                    label: 'Carbs',
                    value: _getTotalCarbs(builderState.meals).toStringAsFixed(1),
                    color: Colors.blue,
                    unit: 'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NutritionCard(
                    label: 'Fats',
                    value: _getTotalFats(builderState.meals).toStringAsFixed(1),
                    color: Colors.orange,
                    unit: 'g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Meals by Type
            for (final type in mealTypes)
              _MealSectionWidget(
                mealType: type,
                meals: mealsByType[type] ?? [],
                onAddMeal: () => _showAddMealDialog(context, ref, type),
                onUpdateMeal: (mealId, name, description, calories, protein, carbs, fats) {
                  ref.read(mealPlanBuilderProvider.notifier).updateMeal(
                        mealId,
                        name: name,
                        mealType: type,
                        description: description ?? '',
                        calories: calories,
                        proteinG: protein,
                        carbsG: carbs,
                        fatsG: fats,
                      );
                },
                onRemoveMeal: (mealId) {
                  ref.read(mealPlanBuilderProvider.notifier).removeMeal(mealId);
                },
              ),
            const SizedBox(height: 24),

            // Add Meal Button (floating)
            if (builderState.meals.isEmpty)
              Center(
                child: FilledButton.tonal(
                  onPressed: () => _showAddMealDialog(context, ref, 'breakfast'),
                  child: const Text('+ Add First Meal'),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(mealPlanBuilderProvider.notifier).reset();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meal plan reset')),
                    );
                  }
                },
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: builderState.mealPlanName.isNotEmpty
                    ? () {
                        // Compile meal plan
                        final mealPlan = ref.read(mealPlanFromBuilderProvider);
                        if (mealPlan != null) {
                          // TODO: Save meal plan to database
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✓ Meal plan "${mealPlan.name}" created with ${mealPlan.meals.length} meals',
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      }
                    : null,
                child: const Text('Save Meal Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMealDialog(
    BuildContext context,
    WidgetRef ref,
    String mealType,
  ) {
    showDialog(
      context: context,
      builder: (context) => _AddMealDialog(
        mealType: mealType,
        onAdd: (name, description, calories, protein, carbs, fats) {
          ref.read(mealPlanBuilderProvider.notifier).addMeal(
                name: name,
                mealType: mealType,
                description: description,
                calories: calories,
                proteinG: protein,
                carbsG: carbs,
                fatsG: fats,
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  double _getTotalProtein(List<Meal> meals) {
    return meals.fold<double>(0, (sum, meal) => sum + (meal.proteinG ?? 0));
  }

  double _getTotalCarbs(List<Meal> meals) {
    return meals.fold<double>(0, (sum, meal) => sum + (meal.carbsG ?? 0));
  }

  double _getTotalFats(List<Meal> meals) {
    return meals.fold<double>(0, (sum, meal) => sum + (meal.fatsG ?? 0));
  }
}

/// Nutrition metric card
class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String unit;

  const _NutritionCard({
    required this.label,
    required this.value,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                unit,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Meal section widget (grouped by meal type)
class _MealSectionWidget extends StatelessWidget {
  final String mealType;
  final List<Meal> meals;
  final VoidCallback onAddMeal;
  final Function(String, String, String?, int?, double?, double?, double?) onUpdateMeal;
  final Function(String) onRemoveMeal;

  const _MealSectionWidget({
    required this.mealType,
    required this.meals,
    required this.onAddMeal,
    required this.onUpdateMeal,
    required this.onRemoveMeal,
  });

  String _getMealTypeLabel(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }

  IconData _getMealTypeIcon(String type) {
    switch (type) {
      case 'breakfast':
        return Icons.light_mode;
      case 'lunch':
        return Icons.wb_sunny;
      case 'dinner':
        return Icons.dark_mode;
      case 'snack':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getMealTypeIcon(mealType),
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _getMealTypeLabel(mealType),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            Text(
              '${meals.length} meal${meals.length != 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (meals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextButton.icon(
                onPressed: onAddMeal,
                icon: const Icon(Icons.add),
                label: Text('Add ${mealType.toLowerCase()}'),
              ),
            ),
          )
        else
          Column(
            children: [
              for (final meal in meals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MealCard(
                    meal: meal,
                    onEdit: () => _editMeal(context, meal),
                    onDelete: () => onRemoveMeal(meal.id),
                    onUpdate: onUpdateMeal,
                  ),
                ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: onAddMeal,
                  icon: const Icon(Icons.add),
                  label: Text('Add another ${mealType}'),
                ),
              ),
            ],
          ),
        const Divider(height: 32),
      ],
    );
  }

  void _editMeal(BuildContext context, Meal meal) {
    showDialog(
      context: context,
      builder: (context) => _EditMealDialog(
        meal: meal,
        onUpdate: (name, description, calories, protein, carbs, fats) {
          onUpdateMeal(meal.id, name, description, calories, protein, carbs, fats);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Individual meal card
class _MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(String, String, String?, int?, double?, double?, double?) onUpdate;

  const _MealCard({
    required this.meal,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (meal.description != null && meal.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            meal.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Meal?'),
                          content: Text('Remove "${meal.name}" from plan?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () {
                                onDelete();
                                Navigator.pop(context);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Nutrition breakdown
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (meal.calories != null)
                  _NutritionBadge('${meal.calories} cal', Colors.green),
                if (meal.proteinG != null)
                  _NutritionBadge('${meal.proteinG}g P', Colors.red),
                if (meal.carbsG != null)
                  _NutritionBadge('${meal.carbsG}g C', Colors.blue),
                if (meal.fatsG != null)
                  _NutritionBadge('${meal.fatsG}g F', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Nutrition badge widget
class _NutritionBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _NutritionBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Dialog for adding a new meal
class _AddMealDialog extends StatefulWidget {
  final String mealType;
  final Function(String, String?, int?, double?, double?, double?) onAdd;

  const _AddMealDialog({
    required this.mealType,
    required this.onAdd,
  });

  @override
  State<_AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<_AddMealDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _caloriesController = TextEditingController();
    _proteinController = TextEditingController();
    _carbsController = TextEditingController();
    _fatsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.mealType[0].toUpperCase()}${widget.mealType.substring(1)}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Meal Name',
                hintText: 'e.g., Grilled Chicken with Rice',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., 200g chicken, 150g rice',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proteinController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Protein (g)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _carbsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Carbs (g)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fatsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Fats (g)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter meal name')),
              );
              return;
            }
            widget.onAdd(
              _nameController.text,
              _descriptionController.text.isEmpty ? null : _descriptionController.text,
              int.tryParse(_caloriesController.text),
              double.tryParse(_proteinController.text),
              double.tryParse(_carbsController.text),
              double.tryParse(_fatsController.text),
            );
          },
          child: const Text('Add Meal'),
        ),
      ],
    );
  }
}

/// Dialog for editing an existing meal
class _EditMealDialog extends StatefulWidget {
  final Meal meal;
  final Function(String, String?, int?, double?, double?, double?) onUpdate;

  const _EditMealDialog({
    required this.meal,
    required this.onUpdate,
  });

  @override
  State<_EditMealDialog> createState() => _EditMealDialogState();
}

class _EditMealDialogState extends State<_EditMealDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meal.name);
    _descriptionController = TextEditingController(text: widget.meal.description ?? '');
    _caloriesController = TextEditingController(text: widget.meal.calories?.toString() ?? '');
    _proteinController = TextEditingController(text: widget.meal.proteinG?.toString() ?? '');
    _carbsController = TextEditingController(text: widget.meal.carbsG?.toString() ?? '');
    _fatsController = TextEditingController(text: widget.meal.fatsG?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Meal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proteinController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Protein (g)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _carbsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Carbs (g)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fatsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Fats (g)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter meal name')),
              );
              return;
            }
            widget.onUpdate(
              _nameController.text,
              _descriptionController.text.isEmpty ? null : _descriptionController.text,
              int.tryParse(_caloriesController.text),
              double.tryParse(_proteinController.text),
              double.tryParse(_carbsController.text),
              double.tryParse(_fatsController.text),
            );
          },
          child: const Text('Update Meal'),
        ),
      ],
    );
  }
}
