import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/workout_pack_model.dart';
import '../providers/client_store_provider.dart';

/// Screen showing purchased workout packs
class ClientPurchasesScreen extends ConsumerWidget {
  const ClientPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchasedPacksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Purchases'),
        centerTitle: true,
      ),
      body: purchasesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load purchases', style: theme.textTheme.titleMedium),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.invalidate(purchasedPacksProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (response) {
          if (response.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No purchases yet',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse our workout store to find premium packs!',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/client/store'),
                    icon: const Icon(Icons.store),
                    label: const Text('Browse Store'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: response.items.length,
            itemBuilder: (context, index) {
              final pack = response.items[index];
              return _PurchasedPackCard(pack: pack);
            },
          );
        },
      ),
    );
  }
}

class _PurchasedPackCard extends StatelessWidget {
  final WorkoutPackModel pack;

  const _PurchasedPackCard({required this.pack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _getCategoryColor(pack.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(pack.category),
            color: _getCategoryColor(pack.category),
            size: 28,
          ),
        ),
        title: Text(
          pack.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${pack.workoutCount} workouts'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Purchased',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            // Navigate to view pack workouts
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Colors.red.shade600;
      case 'cardio':
        return Colors.blue.shade600;
      case 'flexibility':
        return Colors.purple.shade600;
      case 'hiit':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      case 'hiit':
        return Icons.local_fire_department;
      default:
        return Icons.sports_gymnastics;
    }
  }
}
