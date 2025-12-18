import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// Background sync task identifier
const String backgroundSyncTaskId = 'personalTrainerSync';

/// Initialize background sync with workmanager
///
/// This sets up periodic background sync tasks that run even when the app is closed.
/// On Android: Uses JobScheduler API
/// On iOS: Uses BackgroundTasks framework (limited, approximately 15 minutes apart)
///
/// Call this once during app initialization in main.dart
Future<void> initializeBackgroundSync() async {
  try {
    // Initialize workmanager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Register periodic sync task (every 1 hour)
    // iOS: Note that periodic tasks are capped at every ~15 minutes minimum
    // Android: Will run approximately every 1 hour
    await Workmanager().registerPeriodicTask(
      backgroundSyncTaskId,
      'syncData',
      frequency: const Duration(hours: 1),
      initialDelay: const Duration(minutes: 15), // Wait 15 min before first run
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );

    debugPrint(
      '[BackgroundSync] Initialized background sync (every 1 hour, requires network)',
    );
  } catch (e) {
    debugPrint('[BackgroundSync] Failed to initialize: $e');
  }
}

/// Stop background sync tasks
///
/// Call this if user disables background sync in settings
Future<void> disableBackgroundSync() async {
  try {
    await Workmanager().cancelByTag(backgroundSyncTaskId);
    debugPrint('[BackgroundSync] Disabled background sync');
  } catch (e) {
    debugPrint('[BackgroundSync] Failed to disable: $e');
  }
}

/// Callback dispatcher - runs in background isolate
///
/// This function is called by the workmanager when background task is triggered.
/// It must be a top-level function and cannot access UI state.
///
/// Note: This runs in a separate isolate with limited access to app state.
/// We cannot directly access Riverpod providers here, so we use a simple
/// dependency injection approach with the SyncService.
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      debugPrint('[BackgroundSync] Background task triggered: $taskName');

      if (taskName == 'syncData') {
        return await _performBackgroundSync();
      }

      return true;
    } catch (e) {
      debugPrint('[BackgroundSync] Task error: $e');
      return false;
    }
  });
}

/// Perform sync in background
///
/// This is called from the background isolate when sync task triggers.
/// In a real implementation, this would:
/// 1. Reconnect to the database
/// 2. Fetch unsynced data from local database
/// 3. Make API calls to backend
/// 4. Update local database with sync status
///
/// For now, this is a placeholder that logs the event.
Future<bool> _performBackgroundSync() async {
  try {
    debugPrint('[BackgroundSync] Performing background sync...');

    // TODO: Implement actual background sync logic
    // The challenge: We're in a separate isolate, so we can't use:
    // - Riverpod providers
    // - Global app state
    // - Context
    //
    // Solution: Create a minimal standalone sync service that:
    // 1. Opens its own database connection
    // 2. Makes standalone API calls via Dio
    // 3. Updates database directly
    // 4. No dependency on app state
    //
    // Example:
    // final database = await $FloorAppDatabase
    //     .databaseBuilder('personal_trainer_app.db')
    //     .build();
    // final progressLogs = await database.progressLogDao.getUnsyncedLogs();
    // if (progressLogs.isNotEmpty) {
    //   await dioClient.post('/api/v1/progress-logs/bulk-import', data: progressLogs);
    //   await database.progressLogDao.markAsSynced(progressLogs);
    // }

    debugPrint('[BackgroundSync] Background sync completed');
    return true;
  } catch (e) {
    debugPrint('[BackgroundSync] Background sync failed: $e');
    return false;
  }
}

/// Listener for background sync events
///
/// Use this callback to update UI when background sync completes
typedef BackgroundSyncCallback = void Function(bool success, String? error);

class BackgroundSyncManager {
  static final BackgroundSyncManager _instance =
      BackgroundSyncManager._internal();

  factory BackgroundSyncManager() {
    return _instance;
  }

  BackgroundSyncManager._internal();

  BackgroundSyncCallback? _onSyncComplete;

  /// Register callback for sync completion
  void registerSyncCallback(BackgroundSyncCallback? callback) {
    _onSyncComplete = callback;
  }

  /// Call when background sync completes
  void notifySyncComplete(bool success, String? error) {
    _onSyncComplete?.call(success, error);
  }
}

/// Constraints for background sync
///
/// Configurable constraints to optimize sync behavior:
/// - Network: Only sync when connected
/// - Battery: Don't sync if battery is low
/// - Device idle: Can sync while device is in use (not critical)
/// - Storage: Check if storage is available
class SyncConstraints {
  final bool requiresNetwork;
  final bool requiresBatteryNotLow;
  final bool requiresDeviceIdle;
  final bool requiresStorageNotLow;
  final Duration? minimumInterval;

  const SyncConstraints({
    this.requiresNetwork = true,
    this.requiresBatteryNotLow = true,
    this.requiresDeviceIdle = false,
    this.requiresStorageNotLow = false,
    this.minimumInterval = const Duration(hours: 1),
  });

  /// Create constraints from user preferences
  factory SyncConstraints.fromPreferences({
    required bool syncOnMetered,
    required bool syncOnBattery,
    required Duration syncInterval,
  }) {
    return SyncConstraints(
      requiresNetwork: true,
      requiresBatteryNotLow: !syncOnBattery,
      requiresDeviceIdle: false,
      requiresStorageNotLow: true,
      minimumInterval: syncInterval,
    );
  }
}
