import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'network_info.dart';
import 'sync_service.dart';

part 'sync_service_provider.g.dart';

/// Provider for SyncService
///
/// This provider creates a singleton instance of SyncService that runs
/// periodic background synchronization every 5 minutes when online.
/// The service automatically:
/// - Starts when first requested
/// - Stops when all references are released
/// - Applies exponential backoff on failures
/// - Logs errors to Crashlytics
@riverpod
SyncService syncService(SyncServiceRef ref) {
  // Create network info instance
  final networkInfo = NetworkInfoImpl(Connectivity());

  // Create the sync service
  final service = SyncService(
    networkInfo: networkInfo,
    initialBackoffMs: 1000,
    maxBackoffMs: 30000,
    syncIntervalMs: 5 * 60 * 1000, // 5 minutes
  );

  // Start the service when provider is requested
  service.start();

  // Stop the service when the provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
