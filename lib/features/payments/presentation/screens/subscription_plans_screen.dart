import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/subscription_plan.dart';
import '../providers/payment_state_provider.dart';
import '../providers/subscription_info_provider.dart';
import '../widgets/plan_card.dart';

/// Screen for selecting a subscription plan
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  bool _isProcessing = false;
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    final subscriptionInfo = ref.watch(subscriptionInfoProvider);
    final paymentState = ref.watch(paymentStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
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
        data: (currentSubscription) {
          final plans = SubscriptionPlan.getAllPlans();

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Select the plan that works best for you',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ...plans.map((plan) {
                  final isCurrent = plan.id == currentSubscription.plan;

                  return PlanCard(
                    plan: plan.copyWith(isCurrent: isCurrent),
                    isCurrentPlan: isCurrent,
                    onSelectPlan: () => _handleSelectPlan(context, plan),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSelectPlan(
    BuildContext context,
    SubscriptionPlan plan,
  ) async {
    if (plan.price == 0) {
      // Free plan doesn't require payment
      _showSuccessDialog(context, plan);
      return;
    }

    setState(() {
      _isProcessing = true;
      _selectedPlanId = plan.id;
    });

    try {
      final paymentNotifier = ref.read(paymentStateProvider.notifier);

      // Create payment intent
      final success = await paymentNotifier.createPayment(
        amount: plan.getPriceInCents(),
        currency: 'usd',
        metadata: {
          'plan': plan.id,
          'plan_name': plan.name,
          'plan_price': plan.price,
        },
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create payment. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      // Present payment sheet
      final paymentSuccess = await paymentNotifier.presentPaymentSheet();

      if (!mounted) return;

      if (paymentSuccess) {
        _showSuccessDialog(context, plan);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment was cancelled or failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog(BuildContext context, SubscriptionPlan plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Successful'),
        content: Text(
          'You are now on the ${plan.name}!',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

extension on SubscriptionPlan {
  SubscriptionPlan copyWith({
    String? id,
    String? name,
    double? price,
    int? maxClients,
    List<String>? features,
    bool? recommended,
    bool? isCurrent,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      maxClients: maxClients ?? this.maxClients,
      features: features ?? this.features,
      recommended: recommended ?? this.recommended,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}
