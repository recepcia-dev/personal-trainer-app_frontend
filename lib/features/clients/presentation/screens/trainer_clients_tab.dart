import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/client_provider.dart';
import 'client_detail_screen.dart';
import 'client_create_screen.dart';

/// Screen for trainers to manage their clients
class TrainerClientsTab extends ConsumerWidget {
  const TrainerClientsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final clientsAsync = ref.watch(allClientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Clients'),
        elevation: 0,
        centerTitle: true,
      ),
      body: clientsAsync.when(
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No clients yet',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToCreateClient(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Client'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return ClientListTile(
                client: client,
                onTap: () => _navigateToClientDetail(context, client.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error loading clients: $error'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.refresh(allClientsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateClient(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToCreateClient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClientCreateScreen()),
    );
  }

  void _navigateToClientDetail(BuildContext context, String clientId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClientDetailScreen(clientId: clientId)),
    );
  }
}

/// List tile widget for displaying a client
class ClientListTile extends ConsumerWidget {
  final dynamic client;
  final VoidCallback onTap;

  const ClientListTile({
    required this.client,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(
            (client.fullName.isNotEmpty ? client.fullName[0] : 'C').toUpperCase(),
          ),
        ),
        title: Text(
          client.fullName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(client.email),
        trailing: Wrap(
          spacing: 8,
          children: [
            if (client.fitnessLevel != null)
              Chip(
                label: Text(
                  client.fitnessLevel!,
                  style: theme.textTheme.bodySmall,
                ),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
            IconButton(
              icon: Icon(Icons.more_vert, color: theme.colorScheme.outline),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: () => _showClientMenu(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showClientMenu(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Client Options'),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onTap();
            },
            child: const Text('View Details'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showDeleteConfirmation(context, ref);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[700],
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text(
          'Are you sure you want to delete ${client.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteClient(context, ref),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[700],
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClient(BuildContext context, WidgetRef ref) async {
    try {
      Navigator.of(context).pop(); // Close the confirmation dialog

      // Only show SnackBar if context is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleting client...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Delete the client
      await ref.read(deleteClientProvider(client.id).future);

      // Invalidate providers to refresh the client list
      ref.invalidate(clientsProvider((skip: 0, limit: 100)));
      ref.invalidate(allClientsProvider);

      // Only show success SnackBar if context is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Only show error SnackBar if context is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting client: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
