import 'package:flutter/material.dart';

import '../../domain/entities/meal_plan.dart';

/// Client meal plan view screen - display assigned meal plan
///
/// Allows clients to:
/// - View current meal plan with all meals
/// - See nutritional breakdown (calories, macros)
/// - Mark meals as eaten
/// - Track daily nutrition progress
class ClientMealPlanScreen extends StatefulWidget {
  final MealPlan mealPlan;

  const ClientMealPlanScreen({
    required this.mealPlan,
    super.key,
  });

  @override
  State<ClientMealPlanScreen> createState() => _ClientMealPlanScreenState();
}

class _ClientMealPlanScreenState extends State<ClientMealPlanScreen> {
  late Map<String, bool> _mealCompletion;

  @override
  void initState() {
    super.initState();
    // Initialize meal completion tracking
    _mealCompletion = {
      for (final meal in widget.mealPlan.meals) meal.id: false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final (protein, carbs, fats) = widget.mealPlan.totalMacros;

    // Group meals by type
    final mealsByType = <String, dynamic>{};
    final mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    for (final type in mealTypes) {
      mealsByType[type] = widget.mealPlan.meals
          .where((meal) => meal.mealType == type)
          .toList();
    }

    // Calculate completed meals
    final completedMeals = _mealCompletion.values.where((v) => v).length;
    final completionPercentage =
        widget.mealPlan.meals.isEmpty ? 0 : (completedMeals / widget.mealPlan.meals.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealPlan.name),
        elevation: 1,
        surfaceTintColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.mealPlan.totalCalories} cal',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
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
            // Daily progress card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Progress',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completedMeals / ${widget.mealPlan.meals.length} meals',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                            '${completionPercentage.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                          ),
                          const Text('Complete'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completionPercentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nutrition summary
            Row(
              children: [
                Expanded(
                  child: _MacroCard(
                    label: 'Protein',
                    value: protein.toStringAsFixed(1),
                    unit: 'g',
                    color: Colors.red,
                    icon: Icons.favorite,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MacroCard(
                    label: 'Carbs',
                    value: carbs.toStringAsFixed(1),
                    unit: 'g',
                    color: Colors.blue,
                    icon: Icons.bolt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MacroCard(
                    label: 'Fats',
                    value: fats.toStringAsFixed(1),
                    unit: 'g',
                    color: Colors.orange,
                    icon: Icons.local_fire_department,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description (if available)
            if (widget.mealPlan.description != null &&
                widget.mealPlan.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About this plan',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.mealPlan.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Meals by type
            for (final type in mealTypes)
              if ((mealsByType[type] as List).isNotEmpty)
                _MealTypeSectionWidget(
                  mealType: type,
                  meals: mealsByType[type] as List,
                  mealCompletion: _mealCompletion,
                  onToggleMeal: (mealId) {
                    setState(() {
                      _mealCompletion[mealId] = !(_mealCompletion[mealId] ?? false);
                    });
                  },
                ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Macro nutrients card
class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
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

/// Meal type section (breakfast, lunch, dinner, snack)
class _MealTypeSectionWidget extends StatelessWidget {
  final String mealType;
  final List<dynamic> meals;
  final Map<String, bool> mealCompletion;
  final Function(String) onToggleMeal;

  const _MealTypeSectionWidget({
    required this.mealType,
    required this.meals,
    required this.mealCompletion,
    required this.onToggleMeal,
  });

  String _getMealTypeLabel(String type) {
    switch (type) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snacks';
      default:
        return type;
    }
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
        for (final meal in meals)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MealItemCard(
              meal: meal,
              isCompleted: mealCompletion[meal.id] ?? false,
              onToggle: () => onToggleMeal(meal.id),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Individual meal item card
class _MealItemCard extends StatelessWidget {
  final dynamic meal;
  final bool isCompleted;
  final VoidCallback onToggle;

  const _MealItemCard({
    required this.meal,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isCompleted ? Colors.green.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isCompleted,
                    onChanged: (_) => onToggle(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                        ),
                        if (meal.description != null &&
                            meal.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              meal.description,
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
                  if (meal.calories != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${meal.calories} cal',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Macro badges
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (meal.proteinG != null)
                    _MacroBadge('${meal.proteinG}g P', Colors.red),
                  if (meal.carbsG != null)
                    _MacroBadge('${meal.carbsG}g C', Colors.blue),
                  if (meal.fatsG != null)
                    _MacroBadge('${meal.fatsG}g F', Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Macro badge widget
class _MacroBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
