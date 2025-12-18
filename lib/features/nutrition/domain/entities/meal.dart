/// Domain entity representing a single meal
///
/// Contains nutritional information and meal type classification
class Meal {
  final String id;
  final String name;
  final String? description;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatsG;
  final String mealType; // breakfast, lunch, dinner, snack
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Meal({
    required this.id,
    required this.name,
    this.description,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatsG,
    required this.mealType,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get macro summary string
  String get macroSummary {
    final parts = <String>[];
    if (proteinG != null) parts.add('${proteinG}g P');
    if (carbsG != null) parts.add('${carbsG}g C');
    if (fatsG != null) parts.add('${fatsG}g F');
    return parts.join(' • ');
  }

  /// Copy with method
  Meal copyWith({
    String? id,
    String? name,
    String? description,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatsG,
    String? mealType,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatsG: fatsG ?? this.fatsG,
      mealType: mealType ?? this.mealType,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Meal(id: $id, name: $name, type: $mealType, cal: $calories)';
}
