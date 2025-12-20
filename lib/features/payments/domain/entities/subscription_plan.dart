/// Subscription plan entity
class SubscriptionPlan {
  final String id; // free, basic, pro
  final String name; // "Free Plan", "Basic Plan", "Pro Plan"
  final double price; // Monthly price in USD
  final int maxClients; // null or large number for unlimited
  final List<String> features;
  final bool recommended; // Highlight as recommended
  final bool isCurrent; // Current user's plan

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.maxClients,
    required this.features,
    this.recommended = false,
    this.isCurrent = false,
  });

  // Predefined plans
  static final free = SubscriptionPlan(
    id: 'free',
    name: 'Free Plan',
    price: 0.0,
    maxClients: 5,
    features: [
      'Up to 5 clients',
      'Basic workout plans',
      'Simple progress tracking',
    ],
  );

  static final basic = SubscriptionPlan(
    id: 'basic',
    name: 'Basic Plan',
    price: 9.99,
    maxClients: 20,
    features: [
      'Up to 20 clients',
      'Advanced workout customization',
      'Progress analytics',
      'Email support',
    ],
    recommended: true,
  );

  static final pro = SubscriptionPlan(
    id: 'pro',
    name: 'Pro Plan',
    price: 19.99,
    maxClients: 999, // unlimited
    features: [
      'Unlimited clients',
      'Premium workout AI',
      'Advanced analytics & reports',
      'Priority 24/7 support',
      'Custom branding',
    ],
  );

  // Get price in cents for Stripe
  int getPriceInCents() {
    return (price * 100).toInt();
  }

  static List<SubscriptionPlan> getAllPlans({bool highlightCurrent = true}) {
    return [free, basic, pro];
  }
}
