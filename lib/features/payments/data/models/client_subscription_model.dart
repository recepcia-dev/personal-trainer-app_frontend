/// Client subscription info model
class ClientSubscriptionInfo {
  final String plan;
  final String status;
  final DateTime? renewalDate;
  final double pricePerMonth;
  final List<String> features;

  ClientSubscriptionInfo({
    required this.plan,
    required this.status,
    this.renewalDate,
    required this.pricePerMonth,
    required this.features,
  });

  factory ClientSubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return ClientSubscriptionInfo(
      plan: json['plan'] as String,
      status: json['status'] as String,
      renewalDate: json['renewal_date'] != null
          ? DateTime.parse(json['renewal_date'] as String)
          : null,
      pricePerMonth: (json['price_per_month'] as num).toDouble(),
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  String get planDisplayName {
    switch (plan.toLowerCase()) {
      case 'free':
        return 'Free Plan';
      case 'basic':
        return 'Basic Plan';
      case 'premium':
        return 'Premium Plan';
      default:
        return plan;
    }
  }

  bool get isActive => status.toLowerCase() == 'active';
  bool get isFree => plan.toLowerCase() == 'free';
}
