/// Progress log domain entity - represents a single exercise completion
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

  ProgressLog({
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

  @override
  String toString() =>
      'ProgressLog(id: $id, exerciseId: $exerciseId, setsCompleted: $setsCompleted)';
}
