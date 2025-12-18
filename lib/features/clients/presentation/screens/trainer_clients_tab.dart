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
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
