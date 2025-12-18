/// Client domain entity - represents a client assigned to a trainer
class Client {
  final String id;
  final String trainerId;
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final int? age;
  final String? fitnessLevel; // beginner, intermediate, advanced
  final String? goals;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.trainerId,
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.age,
    this.fitnessLevel,
    this.goals,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get full name or email fallback
  String get fullName {
    if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    return email;
  }

  @override
  String toString() => 'Client(id: $id, email: $email, trainer: $trainerId)';
}
