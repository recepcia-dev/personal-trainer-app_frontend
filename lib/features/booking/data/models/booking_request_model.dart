import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_request_model.freezed.dart';
part 'booking_request_model.g.dart';

enum BookingStatus {
  pending,
  accepted,
  declined,
  cancelled,
  completed,
}

@freezed
class BookingRequestModel with _$BookingRequestModel {
  const factory BookingRequestModel({
    required String id,
    required String trainerId,
    required String clientId,
    required String clientName,
    String? clientEmail,
    String? clientPhotoUrl,
    required DateTime requestedDate,
    required String requestedTime,
    int? durationMinutes,
    String? notes,
    @Default(BookingStatus.pending) BookingStatus status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) = _BookingRequestModel;

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestModelFromJson(json);
}
