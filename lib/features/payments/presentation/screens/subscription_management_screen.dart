import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/subscription_info_provider.dart';

/// Screen for managing user subscription
class SubscriptionManagementScreen extends ConsumerWidget {
  const SubscriptionManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionInfo = ref.watch(subscriptionInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        centerTitle: true,
      ),
      body: subscriptionInfo.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(subscriptionInfoProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (subscription) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current plan card
                _buildCurrentPlanCard(context, subscription),
                const SizedBox(height: 24),

                // Client limits card
                _buildClientLimitsCard(context, subscription),
                const SizedBox(height: 24),

                // Action buttons
                _buildActionButtons(context, subscription),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentPlanCard(
    BuildContext context,
    dynamic subscription,
  ) {
    final planName = subscription.plan.toUpperCase();
    final planPrice = _getPlanPrice(subscription.plan);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Plan',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              planName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              planPrice == 0 ? 'Free' : '\$${planPrice.toStringAsFixed(2)}/month',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Status: ${subscription.status}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientLimitsCard(
    BuildContext context,
    dynamic subscription,
  ) {
    final maxClients = subscription.maxClients;
    final currentClients = subscription.currentClientsCount;
    final percentage = maxClients != null && maxClients > 0
        ? (currentClients / maxClients * 100).toInt()
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client Limits',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentClients / ${maxClients ?? "Unlimited"} clients',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (maxClients != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: currentClients / maxClients,
                  minHeight: 8,
                ),
              ),
            if (maxClients == null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✓ Unlimited clients',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    dynamic subscription,
  ) {
    return Column(
      children: [
        // Upgrade button (only if not on Pro)
        if (subscription.plan != 'pro')
          FilledButton(
            onPressed: () => context.push('/payments/plans'),
            child: const Text('Upgrade Plan'),
          ),
        if (subscription.plan != 'pro') const SizedBox(height: 12),

        // Update payment method button
        OutlinedButton(
          onPressed: () => _showPaymentMethodDialog(context),
          child: const Text('Update Payment Method'),
        ),
        const SizedBox(height: 12),

        // Cancel subscription button
        TextButton(
          onPressed: () => _showCancelDialog(context),
          child: const Text(
            'Cancel Subscription',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  void _showPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Payment Method'),
        content: const Text(
          'Payment method management is coming soon. You can manage your payment methods directly in your account settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? You will lose access to premium features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subscription cancellation is being processed...'),
                ),
              );
            },
            child: const Text(
              'Cancel Subscription',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  double _getPlanPrice(String plan) {
    switch (plan.toLowerCase()) {
      case 'basic':
        return 9.99;
      case 'pro':
        return 19.99;
      default:
        return 0.0;
    }
  }
}
