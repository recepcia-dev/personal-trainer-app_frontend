import 'meal.dart';

/// Domain entity representing a complete meal plan
///
/// A meal plan contains multiple meals and is assigned to clients by trainers
class MealPlan {
  final String id;
  final String trainerId;
  final String name;
  final String? description;
  final List<Meal> meals;
  final int totalCalories;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealPlan({
    required this.id,
    required this.trainerId,
    required this.name,
    this.description,
    required this.meals,
    required this.totalCalories,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get meal count
  int get mealCount => meals.length;

  /// Get total macros
  (double protein, double carbs, double fats) get totalMacros {
    double protein = 0;
    double carbs = 0;
    double fats = 0;
    for (final meal in meals) {
      protein += meal.proteinG ?? 0;
      carbs += meal.carbsG ?? 0;
      fats += meal.fatsG ?? 0;
    }
    return (protein, carbs, fats);
  }

  /// Copy with method
  MealPlan copyWith({
    String? id,
    String? trainerId,
    String? name,
    String? description,
    List<Meal>? meals,
    int? totalCalories,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      name: name ?? this.name,
      description: description ?? this.description,
      meals: meals ?? this.meals,
      totalCalories: totalCalories ?? this.totalCalories,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'MealPlan(id: $id, name: $name, meals: ${meals.length}, calories: $totalCalories)';
}
