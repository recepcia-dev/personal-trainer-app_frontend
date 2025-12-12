import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/payment_intent.dart';

part 'payment_intent_model.freezed.dart';

/// Data model for PaymentIntent - matches API response structure
///
/// Implements immutability via @freezed annotation
/// Provides JSON serialization via json_serializable
/// Extends domain PaymentIntent entity for use throughout application
@Freezed(toJson: false)
class PaymentIntentModel with _$PaymentIntentModel implements PaymentIntent {
  const factory PaymentIntentModel({
    required String clientSecret,
    required String publishableKey,
    required String id,
    required int amount,
    required String currency,
  }) = _PaymentIntentModel;

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) =>
      PaymentIntentModel(
        clientSecret:
            json['client_secret'] as String? ?? json['clientSecret'] as String,
        publishableKey:
            json['publishable_key'] as String? ?? json['publishableKey'] as String,
        id: json['id'] as String,
        amount: json['amount'] as int,
        currency: json['currency'] as String,
      );
}
