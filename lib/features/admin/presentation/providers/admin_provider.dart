import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/admin_remote_datasource.dart';
import '../../domain/entities/admin_stats.dart';
import '../../../../core/network/dio_provider.dart';

/// Provider for admin remote datasource
final adminDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AdminRemoteDataSourceImpl(dio: dio);
});

/// Provider for platform statistics
final adminStatsProvider = FutureProvider<AdminStats?>((ref) async {
  final dataSource = ref.watch(adminDataSourceProvider);
  try {
    final stats = await dataSource.getStats();
    final users = stats['users'] as Map<String, dynamic>;
    return AdminStats(
      totalUsers: users['total'] as int? ?? 0,
      trainers: users['trainers'] as int? ?? 0,
      clients: users['clients'] as int? ?? 0,
      admins: users['admins'] as int? ?? 0,
      clientRecords: stats['client_records'] as int? ?? 0,
      exercises: stats['exercises'] as int? ?? 0,
      progressLogs: stats['progress_logs'] as int? ?? 0,
    );
  } catch (e) {
    return null;
  }
});

/// Provider for all users
final adminUsersProvider = FutureProvider<List<AdminUser>>((ref) async {
  final dataSource = ref.watch(adminDataSourceProvider);
  try {
    final users = await dataSource.getUsers();
    return users
        .map((u) => AdminUser(
          id: u['id'] as String? ?? '',
          email: u['email'] as String? ?? '',
          fullName: u['full_name'] as String?,
          userType: u['user_type'] as String? ?? 'unknown',
          isActive: u['is_active'] as bool? ?? true,
          createdAt: u['created_at'] != null
              ? DateTime.parse(u['created_at'] as String)
              : DateTime.now(),
          lastLoginAt: u['last_login_at'] != null
              ? DateTime.parse(u['last_login_at'] as String)
              : null,
        ))
        .toList();
  } catch (e) {
    return [];
  }
});

/// Provider for paginated users
final adminUsersPaginatedProvider =
    FutureProvider.family<List<AdminUser>, int>((ref, page) async {
  final dataSource = ref.watch(adminDataSourceProvider);
  final skip = page * 50;
  try {
    final users = await dataSource.getUsers(skip: skip, limit: 50);
    return users
        .map((u) => AdminUser(
          id: u['id'] as String? ?? '',
          email: u['email'] as String? ?? '',
          fullName: u['full_name'] as String?,
          userType: u['user_type'] as String? ?? 'unknown',
          isActive: u['is_active'] as bool? ?? true,
          createdAt: u['created_at'] != null
              ? DateTime.parse(u['created_at'] as String)
              : DateTime.now(),
        ))
        .toList();
  } catch (e) {
    return [];
  }
});

/// Provider for exercises
final adminExercisesProvider = FutureProvider<List>((ref) async {
  final dataSource = ref.watch(adminDataSourceProvider);
  try {
    return await dataSource.getExercises();
  } catch (e) {
    return [];
  }
});
