import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_service.dart';

/// Singleton provider for the sync service
///
/// Provides the SyncService instance throughout the app.
/// Usage:
/// ```dart
/// // In a screen
/// final syncService = ref.watch(syncServiceProvider);
/// await syncService.syncAll();
///
/// // Listen for sync state changes
/// ref.listen(syncServiceProvider, (previous, next) {
///   if (next.isSyncing) {
///     print('Sync started');
///   }
/// });
/// ```
final syncServiceProvider = ChangeNotifierProvider<SyncService>((ref) {
  return SyncService();
});

/// Watch the sync status as a string
///
/// Returns a readable sync status like:
/// - "Syncing..."
/// - "Synced just now"
/// - "Synced 5 min ago"
/// - "Sync failed: ..."
final syncStatusProvider = Provider<String>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.getSyncStatus();
});

/// Watch if sync is currently in progress
final isSyncingProvider = Provider<bool>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.isSyncing;
});

/// Watch the last sync error (if any)
final syncErrorProvider = Provider<String?>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.lastSyncError;
});

/// Watch the last sync timestamp
final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.lastSyncTime;
});

/// Trigger a sync manually
///
/// Usage:
/// ```dart
/// ref.read(syncServiceProvider.notifier).syncAll();
/// ```
extension SyncServiceExtension on SyncService {
  Future<void> syncWorkoutById(String workoutId) => syncWorkoutById(workoutId);
  Future<void> syncMealPlanById(String mealPlanId) =>
      syncMealPlanById(mealPlanId);
}
