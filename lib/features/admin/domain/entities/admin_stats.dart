/// Admin platform statistics
class AdminStats {
  final int totalUsers;
  final int trainers;
  final int clients;
  final int admins;
  final int clientRecords;
  final int exercises;
  final int progressLogs;

  AdminStats({
    required this.totalUsers,
    required this.trainers,
    required this.clients,
    required this.admins,
    required this.clientRecords,
    required this.exercises,
    required this.progressLogs,
  });

  /// Get user breakdown percentage
  double getTrainerPercentage() => totalUsers > 0 ? (trainers / totalUsers) * 100 : 0;
  double getClientPercentage() => totalUsers > 0 ? (clients / totalUsers) * 100 : 0;
  double getAdminPercentage() => totalUsers > 0 ? (admins / totalUsers) * 100 : 0;
}

/// User information for admin management
class AdminUser {
  final String id;
  final String email;
  final String? fullName;
  final String userType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  AdminUser({
    required this.id,
    required this.email,
    this.fullName,
    required this.userType,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Get user display status
  String get statusText => isActive ? 'Active' : 'Inactive';

  /// Get user type display name
  String get userTypeDisplay {
    return switch (userType.toLowerCase()) {
      'admin' => 'Administrator',
      'trainer' => 'Trainer',
      'client' => 'Client',
      _ => userType,
    };
  }
}
