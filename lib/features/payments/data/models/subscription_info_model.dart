import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/subscription_info.dart';

part 'subscription_info_model.freezed.dart';
part 'subscription_info_model.g.dart';

@freezed
class SubscriptionInfoModel with _$SubscriptionInfoModel {
  const factory SubscriptionInfoModel({
    required String plan,
    required String status,
    @JsonKey(name: 'stripe_id') String? stripeId,
    @JsonKey(name: 'max_clients') int? maxClients,
    @JsonKey(name: 'current_clients_count') required int currentClientsCount,
  }) = _SubscriptionInfoModel;

  factory SubscriptionInfoModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionInfoModelFromJson(json);

  const SubscriptionInfoModel._();

  /// Convert model to domain entity
  SubscriptionInfo toEntity() => SubscriptionInfo(
    plan: plan,
    status: status,
    stripeId: stripeId,
    maxClients: maxClients,
    currentClientsCount: currentClientsCount,
  );

  /// Create model from entity
  factory SubscriptionInfoModel.fromEntity(SubscriptionInfo entity) =>
      SubscriptionInfoModel(
        plan: entity.plan,
        status: entity.status,
        stripeId: entity.stripeId,
        maxClients: entity.maxClients,
        currentClientsCount: entity.currentClientsCount,
      );
}
