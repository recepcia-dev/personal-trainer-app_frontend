import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/trainer_remote_datasource.dart';

/// Trainer remote data source provider
final trainerRemoteDataSourceProvider = Provider<TrainerRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return TrainerRemoteDataSourceImpl(dio: dio);
});

/// Provider for assigning workout to client
final assignWorkoutProvider = FutureProvider.family.autoDispose<void, AssignWorkoutParams>(
  (ref, params) async {
    final datasource = ref.watch(trainerRemoteDataSourceProvider);
    await datasource.assignWorkout(
      clientId: params.clientId,
      workoutId: params.workoutId,
      sets: params.sets,
      reps: params.reps,
      weightKg: params.weightKg,
      durationMinutes: params.durationMinutes,
      restSeconds: params.restSeconds,
      startDate: params.startDate,
      endDate: params.endDate,
      notes: params.notes,
    );
  },
);

/// Provider for assigning diet to client
final assignDietProvider = FutureProvider.family.autoDispose<void, AssignDietParams>(
  (ref, params) async {
    final datasource = ref.watch(trainerRemoteDataSourceProvider);
    await datasource.assignDiet(
      clientId: params.clientId,
      mealName: params.mealName,
      ingredients: params.ingredients,
      caloriesApprox: params.caloriesApprox,
      macrosJson: params.macrosJson,
      servings: params.servings,
      monday: params.monday,
      tuesday: params.tuesday,
      wednesday: params.wednesday,
      thursday: params.thursday,
      friday: params.friday,
      saturday: params.saturday,
      sunday: params.sunday,
      startDate: params.startDate,
      endDate: params.endDate,
      notes: params.notes,
    );
  },
);

/// Parameters for assigning workout
class AssignWorkoutParams {
  final String clientId;
  final String workoutId;
  final int? sets;
  final int? reps;
  final double? weightKg;
  final int? durationMinutes;
  final int? restSeconds;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;

  AssignWorkoutParams({
    required this.clientId,
    required this.workoutId,
    this.sets,
    this.reps,
    this.weightKg,
    this.durationMinutes,
    this.restSeconds,
    this.startDate,
    this.endDate,
    this.notes,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignWorkoutParams &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          workoutId == other.workoutId &&
          sets == other.sets &&
          reps == other.reps &&
          weightKg == other.weightKg &&
          durationMinutes == other.durationMinutes &&
          restSeconds == other.restSeconds &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          notes == other.notes;

  @override
  int get hashCode =>
      clientId.hashCode ^
      workoutId.hashCode ^
      sets.hashCode ^
      reps.hashCode ^
      weightKg.hashCode ^
      durationMinutes.hashCode ^
      restSeconds.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      notes.hashCode;
}

/// Parameters for assigning diet
class AssignDietParams {
  final String clientId;
  final String mealName;
  final String? ingredients;
  final double? caloriesApprox;
  final String? macrosJson;
  final int servings;
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;

  AssignDietParams({
    required this.clientId,
    required this.mealName,
    this.ingredients,
    this.caloriesApprox,
    this.macrosJson,
    this.servings = 1,
    this.monday = true,
    this.tuesday = true,
    this.wednesday = true,
    this.thursday = true,
    this.friday = true,
    this.saturday = true,
    this.sunday = true,
    this.startDate,
    this.endDate,
    this.notes,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignDietParams &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          mealName == other.mealName &&
          ingredients == other.ingredients &&
          caloriesApprox == other.caloriesApprox &&
          macrosJson == other.macrosJson &&
          servings == other.servings &&
          monday == other.monday &&
          tuesday == other.tuesday &&
          wednesday == other.wednesday &&
          thursday == other.thursday &&
          friday == other.friday &&
          saturday == other.saturday &&
          sunday == other.sunday &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          notes == other.notes;

  @override
  int get hashCode =>
      clientId.hashCode ^
      mealName.hashCode ^
      ingredients.hashCode ^
      caloriesApprox.hashCode ^
      macrosJson.hashCode ^
      servings.hashCode ^
      monday.hashCode ^
      tuesday.hashCode ^
      wednesday.hashCode ^
      thursday.hashCode ^
      friday.hashCode ^
      saturday.hashCode ^
      sunday.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      notes.hashCode;
}

/// Trainer statistics model
class TrainerStats {
  final int activeClients;
  final int totalWorkoutsAssigned;
  final int totalDietsAssigned;

  TrainerStats({
    required this.activeClients,
    required this.totalWorkoutsAssigned,
    required this.totalDietsAssigned,
  });

  factory TrainerStats.fromJson(Map<String, dynamic> json) {
    return TrainerStats(
      activeClients: json['active_clients'] as int? ?? 0,
      totalWorkoutsAssigned: json['total_workouts_assigned'] as int? ?? 0,
      totalDietsAssigned: json['total_diets_assigned'] as int? ?? 0,
    );
  }
}

/// Provider for fetching trainer statistics
final trainerStatsProvider = FutureProvider<TrainerStats>((ref) async {
  final datasource = ref.watch(trainerRemoteDataSourceProvider);
  final data = await datasource.getTrainerStats();
  return TrainerStats.fromJson(data);
});

/// Trainer profile model
class TrainerProfile {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String uniqueCode;
  final DateTime createdAt;
  final int clientsCount;

  TrainerProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.uniqueCode,
    required this.createdAt,
    required this.clientsCount,
  });

  factory TrainerProfile.fromJson(Map<String, dynamic> json) {
    return TrainerProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      uniqueCode: json['unique_code'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      clientsCount: json['clients_count'] as int? ?? 0,
    );
  }
}

/// Provider for fetching trainer profile
final trainerProfileProvider = FutureProvider<TrainerProfile>((ref) async {
  final datasource = ref.watch(trainerRemoteDataSourceProvider);
  final data = await datasource.getTrainerProfile();
  return TrainerProfile.fromJson(data);
});
