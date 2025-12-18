/// Domain entity for Workout
class Workout {
  final String id;
  final String trainerId;
  final String name;
  final String? description;
  final String? category;
  final String? difficulty;
  final int? durationMinutes;
  final bool isPublic;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workout({
    required this.id,
    required this.trainerId,
    required this.name,
    this.description,
    this.category,
    this.difficulty,
    this.durationMinutes,
    this.isPublic = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get display difficulty color
  String getDifficultyColor() {
    return switch (difficulty?.toLowerCase()) {
      'beginner' => '#4CAF50', // green
      'intermediate' => '#FF9800', // orange
      'advanced' => '#F44336', // red
      _ => '#9E9E9E', // grey
    };
  }

  /// Check if workout is available for assignment
  bool get isAvailable => isActive;
}

/// Domain entity for Workout Assignment
class WorkoutAssignment {
  final String id;
  final String workoutId;
  final String clientId;
  final String assignedBy;
  final DateTime assignedAt;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutAssignment({
    required this.id,
    required this.workoutId,
    required this.clientId,
    required this.assignedBy,
    required this.assignedAt,
    this.startsAt,
    this.endsAt,
    this.isCompleted = false,
    this.completedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if assignment is overdue
  bool get isOverdue {
    if (endsAt == null || isCompleted) return false;
    return DateTime.now().isAfter(endsAt!);
  }

  /// Get remaining days until due date
  int? getRemainingDays() {
    if (endsAt == null) return null;
    if (isCompleted) return 0;
    final difference = endsAt!.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }

  /// Check if can be started
  bool get canStart {
    if (isCompleted) return false;
    if (startsAt == null) return true;
    return !DateTime.now().isBefore(startsAt!);
  }
}
