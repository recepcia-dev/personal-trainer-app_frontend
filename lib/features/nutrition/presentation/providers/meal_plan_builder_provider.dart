import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_plan.dart';

/// State for meal plan builder
class MealPlanBuilderState {
  final String mealPlanId;
  final String mealPlanName;
  final String? description;
  final List<Meal> meals;
  final int totalCalories;

  MealPlanBuilderState({
    String? mealPlanId,
    this.mealPlanName = '',
    this.description,
    this.meals = const [],
    this.totalCalories = 0,
  }) : mealPlanId = mealPlanId ?? const Uuid().v4();

  MealPlanBuilderState copyWith({
    String? mealPlanId,
    String? mealPlanName,
    String? description,
    List<Meal>? meals,
    int? totalCalories,
  }) {
    return MealPlanBuilderState(
      mealPlanId: mealPlanId ?? this.mealPlanId,
      mealPlanName: mealPlanName ?? this.mealPlanName,
      description: description ?? this.description,
      meals: meals ?? this.meals,
      totalCalories: totalCalories ?? this.totalCalories,
    );
  }
}

/// Provider for managing meal plan builder state
class MealPlanBuilderNotifier extends StateNotifier<MealPlanBuilderState> {
  MealPlanBuilderNotifier() : super(MealPlanBuilderState());

  /// Update meal plan name
  void setMealPlanName(String name) {
    state = state.copyWith(mealPlanName: name);
  }

  /// Update description
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Add meal to the plan
  void addMeal({
    required String name,
    required String mealType, // breakfast, lunch, dinner, snack
    String? description,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatsG,
  }) {
    final newMeal = Meal(
      id: const Uuid().v4(),
      name: name,
      description: description,
      calories: calories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatsG: fatsG,
      mealType: mealType,
      orderIndex: state.meals.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final updatedMeals = [...state.meals, newMeal];
    final newTotalCalories = updatedMeals.fold(0, (sum, meal) => sum + (meal.calories ?? 0));

    state = state.copyWith(
      meals: updatedMeals,
      totalCalories: newTotalCalories,
    );
  }

  /// Update meal
  void updateMeal(String mealId, {
    required String name,
    required String mealType,
    String? description,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatsG,
  }) {
    final updated = state.meals.map((meal) {
      if (meal.id == mealId) {
        return meal.copyWith(
          name: name,
          mealType: mealType,
          description: description,
          calories: calories,
          proteinG: proteinG,
          carbsG: carbsG,
          fatsG: fatsG,
        );
      }
      return meal;
    }).toList();

    final newTotalCalories = updated.fold(0, (sum, meal) => sum + (meal.calories ?? 0));
    state = state.copyWith(meals: updated, totalCalories: newTotalCalories);
  }

  /// Remove meal from the plan
  void removeMeal(String mealId) {
    final filtered = state.meals.where((meal) => meal.id != mealId).toList();

    // Re-order meals
    final reordered = [
      for (var i = 0; i < filtered.length; i++)
        filtered[i].copyWith(orderIndex: i),
    ];

    final newTotalCalories = reordered.fold(0, (sum, meal) => sum + (meal.calories ?? 0));
    state = state.copyWith(meals: reordered, totalCalories: newTotalCalories);
  }

  /// Get meals by type
  List<Meal> getMealsByType(String mealType) {
    return state.meals.where((meal) => meal.mealType == mealType).toList();
  }

  /// Reset builder
  void reset() {
    state = MealPlanBuilderState();
  }

  /// Load existing meal plan
  void loadMealPlan(MealPlan mealPlan) {
    state = state.copyWith(
      mealPlanId: mealPlan.id,
      mealPlanName: mealPlan.name,
      description: mealPlan.description,
      meals: mealPlan.meals,
      totalCalories: mealPlan.totalCalories,
    );
  }
}

/// Riverpod provider for meal plan builder
final mealPlanBuilderProvider = StateNotifierProvider<MealPlanBuilderNotifier, MealPlanBuilderState>((ref) {
  return MealPlanBuilderNotifier();
});

/// Provider to get complete meal plan object
final mealPlanFromBuilderProvider = Provider<MealPlan?>((ref) {
  final builderState = ref.watch(mealPlanBuilderProvider);
  final user = ref.watch(authStateProvider);

  if (user == null || builderState.mealPlanName.isEmpty) {
    return null;
  }

  return MealPlan(
    id: builderState.mealPlanId,
    trainerId: user.email,
    name: builderState.mealPlanName,
    description: builderState.description,
    meals: builderState.meals,
    totalCalories: builderState.totalCalories,
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
});
