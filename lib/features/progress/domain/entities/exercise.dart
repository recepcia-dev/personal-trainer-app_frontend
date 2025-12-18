/// Exercise domain entity - represents an exercise in the catalog
class Exercise {
  final String id;
  final String name;
  final String category; // strength, cardio, flexibility, plyometrics, etc.
  final String? description;
  final String? muscleGroup; // chest, back, legs, arms, core, full_body, etc.
  final String? equipment; // barbell, dumbbells, kettlebell, machine, etc.
  final String? videoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.muscleGroup,
    this.equipment,
    this.videoUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String toString() => 'Exercise(id: $id, name: $name, category: $category)';
}
