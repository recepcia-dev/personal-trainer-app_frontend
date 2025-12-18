import 'package:flutter/foundation.dart';

/// Offline-first sync service for managing data synchronization
///
/// Handles syncing of local changes to backend when device is online.
/// Implements the following sync flows:
/// - Sync workouts and exercise logs
/// - Sync meal plans and meal logs
/// - Sync progress logs and metrics
/// - Sync user profile updates
class SyncService extends ChangeNotifier {
  bool _isSyncing = false;
  String? _lastSyncError;
  DateTime? _lastSyncTime;

  bool get isSyncing => _isSyncing;
  String? get lastSyncError => _lastSyncError;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Perform a complete sync of all unsynced data
  ///
  /// This method:
  /// 1. Checks if device is online
  /// 2. Syncs each data type in order
  /// 3. Updates sync timestamps
  /// 4. Notifies listeners of sync completion
  /// 5. Clears sync errors on success
  Future<void> syncAll() async {
    if (_isSyncing) {
      debugPrint('[SyncService] Sync already in progress, skipping');
      return;
    }

    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      debugPrint('[SyncService] Starting sync...');

      // Sync exercises (read-only, pull from backend)
      await _syncExercises();

      // Sync workouts and workout assignments
      await _syncWorkoutAssignments();

      // Sync progress logs (exercise completion logs)
      await _syncProgressLogs();

      // Sync meal plans and assignments
      await _syncMealAssignments();

      // Sync user profile updates
      await _syncUserProfile();

      // Update last sync time
      _lastSyncTime = DateTime.now();
      _lastSyncError = null;

      debugPrint('[SyncService] Sync completed successfully');
    } catch (e) {
      _lastSyncError = e.toString();
      debugPrint('[SyncService] Sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync exercises from backend (pull-only)
  ///
  /// Fetches latest exercise catalog from backend and updates local cache.
  /// This includes:
  /// - New exercises added by admin
  /// - Updated exercise descriptions/details
  /// - Deactivated exercises
  Future<void> _syncExercises() async {
    try {
      debugPrint('[SyncService] Syncing exercises...');
      // TODO: Implement exercise sync
      // 1. Fetch exercises from /api/v1/exercises
      // 2. Compare with local database
      // 3. Update local cache with latest exercises
      // 4. Mark as synced
    } catch (e) {
      debugPrint('[SyncService] Exercise sync error: $e');
      rethrow;
    }
  }

  /// Sync workout assignments between local and backend
  ///
  /// Handles bidirectional sync:
  /// - Push: New workouts created locally
  /// - Push: Workout modifications (name, exercises, difficulty)
  /// - Pull: Workouts assigned to client by trainer
  /// - Sync timestamps for conflict resolution
  Future<void> _syncWorkoutAssignments() async {
    try {
      debugPrint('[SyncService] Syncing workout assignments...');
      // TODO: Implement workout sync
      // 1. Push unsynced workouts to /api/v1/workouts/create
      // 2. Pull assigned workouts from /api/v1/workouts/assigned
      // 3. Mark as synced when successful
      // 4. Store remote IDs for future updates
    } catch (e) {
      debugPrint('[SyncService] Workout sync error: $e');
      rethrow;
    }
  }

  /// Sync progress logs (exercise completion records)
  ///
  /// Pushes exercise completion logs to backend:
  /// - Exercise ID, sets/reps/weight completed
  /// - Duration of exercise
  /// - Timestamp of completion
  /// - Device ID for multi-device sync
  ///
  /// After successful sync, updates local record with remote ID
  /// and synced timestamp.
  Future<void> _syncProgressLogs() async {
    try {
      debugPrint('[SyncService] Syncing progress logs...');
      // TODO: Implement progress log sync
      // 1. Query local database for unsynced progress logs (isSynced = false)
      // 2. For each batch (50 at a time):
      //    a. POST to /api/v1/progress-logs/bulk-import
      //    b. Receive remote IDs from backend
      //    c. Update local records with remoteId and isSynced=true
      // 3. Handle partial failures (mark successfully synced items)
    } catch (e) {
      debugPrint('[SyncService] Progress log sync error: $e');
      rethrow;
    }
  }

  /// Sync meal plan assignments between local and backend
  ///
  /// Handles bidirectional sync:
  /// - Push: New meal plans created locally
  /// - Push: Meal plan modifications (meals, calories, macros)
  /// - Pull: Meal plans assigned to client by trainer
  /// - Sync meal completion logs
  Future<void> _syncMealAssignments() async {
    try {
      debugPrint('[SyncService] Syncing meal plan assignments...');
      // TODO: Implement meal plan sync
      // 1. Push unsynced meal plans to /api/v1/meal-plans/create
      // 2. Pull assigned meal plans from /api/v1/meal-plans/assigned
      // 3. Push meal completion logs to /api/v1/meal-logs/bulk-import
      // 4. Mark as synced when successful
    } catch (e) {
      debugPrint('[SyncService] Meal plan sync error: $e');
      rethrow;
    }
  }

  /// Sync user profile updates
  ///
  /// Pushes user profile changes to backend:
  /// - Weight updates
  /// - Height updates
  /// - Age/DOB updates
  /// - Name/email updates (if allowed)
  ///
  /// These are applied immediately and only synced if offline.
  Future<void> _syncUserProfile() async {
    try {
      debugPrint('[SyncService] Syncing user profile...');
      // TODO: Implement user profile sync
      // 1. Check if any profile fields have been updated locally
      // 2. Push changes to /api/v1/users/{id}/profile
      // 3. Merge remote changes (if device was offline)
      // 4. Handle conflicts with timestamp-based resolution
    } catch (e) {
      debugPrint('[SyncService] User profile sync error: $e');
      rethrow;
    }
  }

  /// Sync a specific workout by ID (on-demand sync)
  ///
  /// Used when user explicitly wants to push a workout immediately
  /// after creation.
  Future<void> syncWorkoutById(String workoutId) async {
    try {
      debugPrint('[SyncService] Syncing workout $workoutId...');
      // TODO: Implement single workout sync
      // 1. Query local database for workout with ID
      // 2. POST to /api/v1/workouts/{id}/update
      // 3. Update local record with remote ID
    } catch (e) {
      debugPrint('[SyncService] Workout sync error: $e');
      rethrow;
    }
  }

  /// Sync a specific meal plan by ID (on-demand sync)
  ///
  /// Used when user explicitly wants to push a meal plan immediately
  /// after creation.
  Future<void> syncMealPlanById(String mealPlanId) async {
    try {
      debugPrint('[SyncService] Syncing meal plan $mealPlanId...');
      // TODO: Implement single meal plan sync
      // 1. Query local database for meal plan with ID
      // 2. POST to /api/v1/meal-plans/{id}/update
      // 3. Update local record with remote ID
    } catch (e) {
      debugPrint('[SyncService] Meal plan sync error: $e');
      rethrow;
    }
  }

  /// Clear all sync errors and reset sync state
  void clearSyncErrors() {
    _lastSyncError = null;
    notifyListeners();
  }

  /// Get sync status summary
  String getSyncStatus() {
    if (_isSyncing) {
      return 'Syncing...';
    }
    if (_lastSyncError != null) {
      return 'Sync failed: $_lastSyncError';
    }
    if (_lastSyncTime != null) {
      final minutesAgo =
          DateTime.now().difference(_lastSyncTime!).inMinutes;
      if (minutesAgo < 1) {
        return 'Synced just now';
      } else if (minutesAgo < 60) {
        return 'Synced $minutesAgo min ago';
      } else {
        final hoursAgo = minutesAgo ~/ 60;
        return 'Synced $hoursAgo h ago';
      }
    }
    return 'Not synced yet';
  }
}
