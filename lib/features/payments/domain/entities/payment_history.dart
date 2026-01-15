/// Represents a single payment transaction in the user's history
class PaymentHistory {
  final String id;
  final String description;
  final int amount; // Amount in cents
  final String currency;
  final String status; // succeeded, pending, failed
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? invoiceUrl;
  final Map<String, dynamic>? metadata;

  PaymentHistory({
    required this.id,
    required this.description,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.invoiceUrl,
    this.metadata,
  });

  /// Get formatted amount (e.g., "$10.00")
  String get formattedAmount {
    final dollars = (amount / 100).toStringAsFixed(2);
    return '$currency $dollars'.toUpperCase();
  }

  /// Check if payment is successful
  bool get isSuccessful => status == 'succeeded';

  @override
  String toString() => 'PaymentHistory(id: $id, amount: $amount, status: $status)';
}
