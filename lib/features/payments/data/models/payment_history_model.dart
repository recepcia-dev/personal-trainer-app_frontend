import '../../../payments/domain/entities/payment_history.dart';

/// Model for payment history data from API
class PaymentHistoryModel extends PaymentHistory {
  PaymentHistoryModel({
    required super.id,
    required super.description,
    required super.amount,
    required super.currency,
    required super.status,
    required super.createdAt,
    super.paidAt,
    super.invoiceUrl,
    super.metadata,
  });

  /// Create from JSON response
  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryModel(
      id: json['id'] as String,
      description: json['description'] as String? ?? 'Payment',
      amount: json['amount'] as int,
      currency: (json['currency'] as String? ?? 'usd').toLowerCase(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      invoiceUrl: json['invoice_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'currency': currency,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'invoice_url': invoiceUrl,
      'metadata': metadata,
    };
  }
}
