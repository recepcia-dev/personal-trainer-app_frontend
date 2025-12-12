/// Domain entity for PaymentIntent
///
/// Represents a Stripe payment intent with the client secret needed for payment sheet
class PaymentIntent {
  const PaymentIntent({
    required this.clientSecret,
    required this.publishableKey,
    required this.id,
    required this.amount,
    required this.currency,
  });

  /// Stripe client secret for initializing payment sheet
  final String clientSecret;

  /// Stripe publishable key (redundant but can be useful)
  final String publishableKey;

  /// Payment intent ID from Stripe
  final String id;

  /// Amount in cents (e.g., 1000 = $10.00)
  final int amount;

  /// Currency code (e.g., 'USD')
  final String currency;
}
