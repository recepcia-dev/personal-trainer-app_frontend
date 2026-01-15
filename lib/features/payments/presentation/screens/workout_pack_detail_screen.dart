import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/workout_pack_model.dart';
import '../providers/client_store_provider.dart';

/// Workout pack detail screen with Stripe payment (TC007.2, TC007.3, TC007.4)
class WorkoutPackDetailScreen extends ConsumerStatefulWidget {
  final String packId;

  const WorkoutPackDetailScreen({super.key, required this.packId});

  @override
  ConsumerState<WorkoutPackDetailScreen> createState() => _WorkoutPackDetailScreenState();
}

class _WorkoutPackDetailScreenState extends ConsumerState<WorkoutPackDetailScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final packAsync = ref.watch(workoutPackDetailProvider(widget.packId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pack Details'),
        centerTitle: true,
      ),
      body: packAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load pack details', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: theme.textTheme.bodySmall),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.invalidate(workoutPackDetailProvider(widget.packId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (pack) => _buildPackDetail(context, pack),
      ),
    );
  }

  Widget _buildPackDetail(BuildContext context, WorkoutPackModel pack) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero header
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getCategoryColor(pack.category),
                  _getCategoryColor(pack.category).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    _getCategoryIcon(pack.category),
                    size: 150,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        pack.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (pack.trainerName != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              child: Text(
                                pack.trainerName![0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'by ${pack.trainerName}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip(pack.categoryDisplayName, Colors.blue),
                    _buildChip(pack.difficultyDisplayName, Colors.orange),
                    _buildChip('${pack.workoutCount} workouts', Colors.purple),
                  ],
                ),

                const SizedBox(height: 24),

                // Description
                Text(
                  'About this pack',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pack.description,
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 24),

                // What's included
                Text(
                  "What's included",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFeatureRow(Icons.fitness_center, '${pack.workoutCount} premium workouts'),
                _buildFeatureRow(Icons.timer, 'Detailed instructions'),
                _buildFeatureRow(Icons.video_library, 'Video demonstrations'),
                _buildFeatureRow(Icons.all_inclusive, 'Lifetime access'),

                const SizedBox(height: 32),

                // Price card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          pack.formattedPrice,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'One-time purchase',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (pack.isPurchased)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Already Purchased',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isProcessing ? null : () => _handlePurchase(pack),
                              icon: _isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.shopping_cart),
                              label: Text(_isProcessing ? 'Processing...' : 'Buy Now'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Test card info (for TC007.3)
                if (!pack.isPurchased)
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Test Payment',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use test card: 4242 4242 4242 4242\n'
                            'Expiry: 12/34, CVC: 123',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(WorkoutPackModel pack) async {
    setState(() => _isProcessing = true);

    try {
      final purchaseNotifier = ref.read(purchasePackProvider.notifier);
      final success = await purchaseNotifier.purchasePack(pack);

      if (!mounted) return;

      if (success) {
        _showSuccessDialog(pack);
      }
    } catch (e) {
      if (!mounted) return;

      // TC007.4 - Handle payment failure gracefully
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog(WorkoutPackModel pack) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Purchase Successful!'),
        content: Text(
          'You now have access to ${pack.name}. '
          'The workouts have been added to your library.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/client/dashboard');
            },
            child: const Text('Go to Workouts'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 64),
        title: const Text('Payment Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your payment could not be processed. Please try again.',
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Allow retry
            },
            child: const Text('Retry'),
          ),
        ],
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
      case 'yoga':
        return Colors.teal.shade600;
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
      case 'yoga':
        return Icons.spa;
      default:
        return Icons.sports_gymnastics;
    }
  }
}
