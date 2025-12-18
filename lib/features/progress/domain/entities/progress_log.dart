/// Domain entity representing logged exercise progress
///
/// Tracks actual performance when a client completes an exercise
class ProgressLog {
  final String id;
  final String? remoteId;
  final String clientId;
  final String exerciseId;
  final int setsCompleted;
  final int repsPerSet;
  final double? weightKg;
  final int? durationSeconds;
  final String? notes;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProgressLog({
    required this.id,
    this.remoteId,
    required this.clientId,
    required this.exerciseId,
    required this.setsCompleted,
    required this.repsPerSet,
    this.weightKg,
    this.durationSeconds,
    this.notes,
    required this.isSynced,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get summary string
  String get summary =>
      '$setsCompleted sets × $repsPerSet reps${weightKg != null ? ' @ ${weightKg}kg' : ''}';

  /// Copy with method
  ProgressLog copyWith({
    String? id,
    String? remoteId,
    String? clientId,
    String? exerciseId,
    int? setsCompleted,
    int? repsPerSet,
    double? weightKg,
    int? durationSeconds,
    String? notes,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgressLog(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      clientId: clientId ?? this.clientId,
      exerciseId: exerciseId ?? this.exerciseId,
      setsCompleted: setsCompleted ?? this.setsCompleted,
      repsPerSet: repsPerSet ?? this.repsPerSet,
      weightKg: weightKg ?? this.weightKg,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'ProgressLog(exercise: $exerciseId, sets: $setsCompleted, reps: $repsPerSet, weight: $weightKg kg)';
}
