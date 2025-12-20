import 'package:freezed_annotation/freezed_annotation.dart';

part 'assigned_diet_model.freezed.dart';
part 'assigned_diet_model.g.dart';

/// Model for diet/meal assigned to a client
@freezed
class AssignedDietModel with _$AssignedDietModel {
  const factory AssignedDietModel({
    required String id,
    @JsonKey(name: 'meal_name') required String mealName,
    String? ingredients,
    @JsonKey(name: 'calories_approx') double? caloriesApprox,
    @JsonKey(name: 'macros_json') String? macrosJson,
    required int servings,
    required int monday,
    required int tuesday,
    required int wednesday,
    required int thursday,
    required int friday,
    required int saturday,
    required int sunday,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    String? notes,
    @JsonKey(name: 'is_active') required int isActive,
  }) = _AssignedDietModel;

  factory AssignedDietModel.fromJson(Map<String, dynamic> json) =>
      _$AssignedDietModelFromJson(json);
}
