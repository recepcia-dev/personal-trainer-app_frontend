/// Subscription information entity
class SubscriptionInfo {
  final String plan; // free, basic, pro
  final String status; // active, cancelled, expired
  final String? stripeId;
  final int? maxClients; // null for unlimited
  final int currentClientsCount;

  SubscriptionInfo({
    required this.plan,
    required this.status,
    this.stripeId,
    this.maxClients,
    required this.currentClientsCount,
  });
}
