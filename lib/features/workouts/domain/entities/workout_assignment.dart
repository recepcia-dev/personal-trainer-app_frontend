/// Domain entity representing a workout assignment to a client
class WorkoutAssignment {
  final String id;
  final String? remoteId;
  final String workoutId;
  final String clientId;
  final String assignedBy;
  final DateTime? assignedAt;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? notes;
  final bool isSynced;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkoutAssignment({
    required this.id,
    this.remoteId,
    required this.workoutId,
    required this.clientId,
    required this.assignedBy,
    this.assignedAt,
    this.startsAt,
    this.endsAt,
    this.isCompleted = false,
    this.completedAt,
    this.notes,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with modified fields
  WorkoutAssignment copyWith({
    String? id,
    String? remoteId,
    String? workoutId,
    String? clientId,
    String? assignedBy,
    DateTime? assignedAt,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? isCompleted,
    DateTime? completedAt,
    String? notes,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutAssignment(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      workoutId: workoutId ?? this.workoutId,
      clientId: clientId ?? this.clientId,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedAt: assignedAt ?? this.assignedAt,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'WorkoutAssignment(id: $id, workoutId: $workoutId, clientId: $clientId, isCompleted: $isCompleted)';
}
