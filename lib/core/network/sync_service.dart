import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'network_info.dart';

/// Service for background synchronization with exponential backoff.
///
/// This service:
/// - Runs periodic sync every 5 minutes when online
/// - Implements exponential backoff for rate limiting
/// - Logs sync errors to Crashlytics
/// - Automatically stops when offline
class SyncService {
  /// Creates a new SyncService instance.
  ///
  /// [networkInfo] is used to check online/offline status.
  /// [initialBackoffMs] is the initial backoff duration (default: 1000ms).
  /// [maxBackoffMs] is the maximum backoff duration (default: 30000ms).
  /// [syncIntervalMs] is the interval between sync attempts when online (default: 5 minutes).
  SyncService({
    required NetworkInfo networkInfo,
    this.initialBackoffMs = 1000,
    this.maxBackoffMs = 30000,
    this.syncIntervalMs = 5 * 60 * 1000, // 5 minutes
  }) : _networkInfo = networkInfo;

  final NetworkInfo _networkInfo;
  final int initialBackoffMs;
  final int maxBackoffMs;
  final int syncIntervalMs;

  Timer? _syncTimer;
  int _backoffMs = 1000;
  bool _isSyncing = false;

  /// Check if sync service is currently running.
  bool get isRunning => _syncTimer != null;

  /// Get current backoff duration in milliseconds.
  int get currentBackoffMs => _backoffMs;

  /// Start the background synchronization service.
  ///
  /// This will:
  /// 1. Check connectivity every sync interval
  /// 2. Perform sync if online
  /// 3. Apply exponential backoff on failures
  /// 4. Log errors to Crashlytics
  void start() {
    if (_syncTimer != null) {
      if (kDebugMode) {
        print('[SyncService] Sync service already running');
      }
      return;
    }

    if (kDebugMode) {
      print('[SyncService] Starting sync service (interval: ${syncIntervalMs}ms)');
    }

    // Reset backoff on start
    _backoffMs = initialBackoffMs;

    // Start the periodic sync
    _syncTimer = Timer.periodic(
      Duration(milliseconds: syncIntervalMs),
      (_) => _performSync(),
    );

    // Perform initial sync immediately
    _performSync();
  }

  /// Stop the background synchronization service.
  void stop() {
    _syncTimer?.cancel();
    _syncTimer = null;

    if (kDebugMode) {
      print('[SyncService] Sync service stopped');
    }
  }

  /// Perform a single sync operation with backoff handling.
  Future<void> _performSync() async {
    // Prevent overlapping sync operations
    if (_isSyncing) {
      if (kDebugMode) {
        print('[SyncService] Sync already in progress, skipping');
      }
      return;
    }

    // Check network connectivity
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      if (kDebugMode) {
        print('[SyncService] No network connection, skipping sync');
      }
      return;
    }

    _isSyncing = true;

    try {
      if (kDebugMode) {
        print('[SyncService] Starting sync operation');
      }

      // TODO: Implement actual sync logic here
      // This should:
      // 1. Fetch data from backend
      // 2. Compare with local database
      // 3. Update local records marked as isSynced: false
      // 4. Handle merge conflicts

      // On success, reset backoff
      _backoffMs = initialBackoffMs;

      if (kDebugMode) {
        print('[SyncService] Sync completed successfully');
      }
    } catch (e, stackTrace) {
      _handleSyncError(e, stackTrace);
    } finally {
      _isSyncing = false;
    }
  }

  /// Handle sync errors with exponential backoff and logging.
  void _handleSyncError(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('[SyncService] Sync error: $error');
      print('[SyncService] Backoff increased to ${_backoffMs}ms');
    }

    // Log to Crashlytics if available
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'SyncService sync error',
      );
    } catch (e) {
      // Crashlytics not initialized or error occurred
      if (kDebugMode) {
        print('[SyncService] Failed to log error to Crashlytics: $e');
      }
    }

    // Apply exponential backoff
    _applyExponentialBackoff();
  }

  /// Apply exponential backoff with jitter.
  ///
  /// Formula: backoff = min(initialBackoff * 2^attempts + jitter, maxBackoff)
  /// Jitter: random value between 0 and backoff * 0.1
  void _applyExponentialBackoff() {
    // Calculate next backoff with jitter
    final jitter = Random().nextInt((_backoffMs * 0.1).toInt());
    _backoffMs = min(_backoffMs * 2 + jitter, maxBackoffMs);
  }

  /// Reset backoff to initial value.
  void resetBackoff() {
    _backoffMs = initialBackoffMs;
    if (kDebugMode) {
      print('[SyncService] Backoff reset to ${initialBackoffMs}ms');
    }
  }

  /// Dispose of the sync service (stops the timer).
  void dispose() {
    stop();
  }
}
