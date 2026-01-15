import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity status enum
enum ConnectivityStatus {
  online,
  offline,
  connecting,
}

/// Provider for connectivity status (simplified implementation)
/// In production, use connectivity_plus package
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  Timer? _checkTimer;
  
  ConnectivityNotifier() : super(ConnectivityStatus.online) {
    // Start periodic connectivity checks
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      // In production, check actual connectivity
      // For now, we assume online
    });
  }

  void setOffline() {
    state = ConnectivityStatus.offline;
  }

  void setOnline() {
    state = ConnectivityStatus.online;
  }

  void setConnecting() {
    state = ConnectivityStatus.connecting;
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}

/// Provider for pending sync items count
final pendingSyncCountProvider = StateProvider<int>((ref) => 0);

/// Provider for sync status
final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.synced);

enum SyncStatus {
  synced,
  syncing,
  pending,
  error,
}

/// Offline indicator banner widget
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    
    if (connectivity == ConnectivityStatus.online) {
      return const SizedBox.shrink();
    }

    return MaterialBanner(
      content: Row(
        children: [
          Icon(
            connectivity == ConnectivityStatus.connecting 
                ? Icons.wifi_find 
                : Icons.wifi_off,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              connectivity == ConnectivityStatus.connecting
                  ? 'Reconnecting...'
                  : 'You\'re offline. Changes will sync when you\'re back online.',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: connectivity == ConnectivityStatus.connecting
          ? Colors.orange
          : Colors.grey[700],
      actions: [
        TextButton(
          onPressed: () {
            ref.read(connectivityProvider.notifier).setConnecting();
            // Attempt reconnection
            Future.delayed(const Duration(seconds: 2), () {
              ref.read(connectivityProvider.notifier).setOnline();
            });
          },
          child: Text(
            'Retry',
            style: TextStyle(
              color: connectivity == ConnectivityStatus.connecting
                  ? Colors.white70
                  : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Sync status indicator widget for app bar
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider);
    final connectivity = ref.watch(connectivityProvider);

    // Determine icon and color based on status
    IconData icon;
    Color color;
    String tooltip;

    if (connectivity == ConnectivityStatus.offline) {
      icon = Icons.cloud_off;
      color = Colors.grey;
      tooltip = 'Offline - $pendingCount pending changes';
    } else if (syncStatus == SyncStatus.syncing) {
      icon = Icons.sync;
      color = Colors.blue;
      tooltip = 'Syncing...';
    } else if (syncStatus == SyncStatus.pending || pendingCount > 0) {
      icon = Icons.cloud_upload;
      color = Colors.orange;
      tooltip = '$pendingCount changes pending';
    } else if (syncStatus == SyncStatus.error) {
      icon = Icons.cloud_off;
      color = Colors.red;
      tooltip = 'Sync error - tap to retry';
    } else {
      icon = Icons.cloud_done;
      color = Colors.green;
      tooltip = 'All synced';
    }

    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Stack(
          children: [
            Icon(icon, color: color),
            if (pendingCount > 0 && connectivity != ConnectivityStatus.offline)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    pendingCount > 9 ? '9+' : '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        onPressed: () {
          if (syncStatus == SyncStatus.error) {
            // Trigger manual sync
            ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
            Future.delayed(const Duration(seconds: 2), () {
              ref.read(syncStatusProvider.notifier).state = SyncStatus.synced;
              ref.read(pendingSyncCountProvider.notifier).state = 0;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tooltip)),
            );
          }
        },
      ),
    );
  }
}

/// Item sync status chip (for list items)
class ItemSyncStatusChip extends StatelessWidget {
  final bool isSynced;
  final bool hasError;

  const ItemSyncStatusChip({
    super.key,
    required this.isSynced,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSynced && !hasError) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: hasError ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: hasError ? Colors.red : Colors.orange,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasError ? Icons.error : Icons.cloud_upload,
            size: 12,
            color: hasError ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            hasError ? 'Sync failed' : 'Not synced',
            style: TextStyle(
              fontSize: 10,
              color: hasError ? Colors.red : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
