/// Result of a successful payment transaction
///
/// Returned after successful payment processing through Stripe payment sheet.
/// Contains the payment intent ID and confirmation of successful payment.
class PaymentResult {
  const PaymentResult({
    required this.paymentIntentId,
  });

  /// The Stripe payment intent ID of the completed payment
  final String paymentIntentId;
}
