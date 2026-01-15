import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/progress_remote_datasource.dart';
import '../../data/models/progress_request_model.dart';

/// Provider for progress datasource
final progressDataSourceProvider = Provider<ProgressRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProgressRemoteDataSourceImpl(dio: dio);
});

/// Provider for registering workout progress
final registerProgressProvider =
    FutureProvider.family.autoDispose<ProgressEntryModel, ProgressRequestModel>(
  (ref, request) async {
    final datasource = ref.watch(progressDataSourceProvider);
    return await datasource.registerProgress(request);
  },
);

/// Provider for fetching progress history
final progressHistoryProvider =
    FutureProvider.autoDispose<List<ProgressEntryModel>>((ref) async {
  final datasource = ref.watch(progressDataSourceProvider);
  return await datasource.getProgressHistory();
});

/// Model for progress statistics
class ProgressStats {
  final int totalWorkoutsCompleted;
  final int totalWorkoutsAssigned;
  final double completionRate;
  final int currentStreak;
  final double? currentWeightKg;
  final double? weightChangeKg;
  final List<WeeklyWorkoutData> weeklyWorkoutData;

  ProgressStats({
    required this.totalWorkoutsCompleted,
    required this.totalWorkoutsAssigned,
    required this.completionRate,
    required this.currentStreak,
    this.currentWeightKg,
    this.weightChangeKg,
    required this.weeklyWorkoutData,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      totalWorkoutsCompleted: json['total_workouts_completed'] as int? ?? 0,
      totalWorkoutsAssigned: json['total_workouts_assigned'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      currentStreak: json['current_streak'] as int? ?? 0,
      currentWeightKg: (json['current_weight_kg'] as num?)?.toDouble(),
      weightChangeKg: (json['weight_change_kg'] as num?)?.toDouble(),
      weeklyWorkoutData: (json['weekly_workout_data'] as List<dynamic>?)
              ?.map((e) => WeeklyWorkoutData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Model for weekly workout data
class WeeklyWorkoutData {
  final String weekStart;
  final String weekLabel;
  final int workoutsCompleted;
  final int workoutsAssigned;

  WeeklyWorkoutData({
    required this.weekStart,
    required this.weekLabel,
    required this.workoutsCompleted,
    required this.workoutsAssigned,
  });

  factory WeeklyWorkoutData.fromJson(Map<String, dynamic> json) {
    return WeeklyWorkoutData(
      weekStart: json['week_start'] as String,
      weekLabel: json['week_label'] as String,
      workoutsCompleted: json['workouts_completed'] as int? ?? 0,
      workoutsAssigned: json['workouts_assigned'] as int? ?? 0,
    );
  }
}

/// Model for body measurement
class BodyMeasurement {
  final String id;
  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPercentage;
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;
  final double? bicepCm;
  final double? thighCm;
  final String? frontPhotoUrl;
  final String? sidePhotoUrl;
  final String? backPhotoUrl;
  final String? notes;
  final DateTime createdAt;

  BodyMeasurement({
    required this.id,
    this.weightKg,
    this.heightCm,
    this.bodyFatPercentage,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.bicepCm,
    this.thighCm,
    this.frontPhotoUrl,
    this.sidePhotoUrl,
    this.backPhotoUrl,
    this.notes,
    required this.createdAt,
  });

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'] as String,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      bodyFatPercentage: (json['body_fat_percentage'] as num?)?.toDouble(),
      chestCm: (json['chest_cm'] as num?)?.toDouble(),
      waistCm: (json['waist_cm'] as num?)?.toDouble(),
      hipsCm: (json['hips_cm'] as num?)?.toDouble(),
      bicepCm: (json['bicep_cm'] as num?)?.toDouble(),
      thighCm: (json['thigh_cm'] as num?)?.toDouble(),
      frontPhotoUrl: json['front_photo_url'] as String?,
      sidePhotoUrl: json['side_photo_url'] as String?,
      backPhotoUrl: json['back_photo_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Provider for progress statistics (new comprehensive stats)
final clientProgressStatsProvider = FutureProvider.autoDispose<ProgressStats>((ref) async {
  final datasource = ref.watch(progressDataSourceProvider);
  final stats = await datasource.getProgressStats();
  return ProgressStats.fromJson(stats);
});

/// Provider for body measurements list
final bodyMeasurementsProvider = FutureProvider.autoDispose<List<BodyMeasurement>>((ref) async {
  final datasource = ref.watch(progressDataSourceProvider);
  final measurements = await datasource.getMeasurements();
  return measurements.map((m) => BodyMeasurement.fromJson(m)).toList();
});

/// Provider for latest body measurement
final latestMeasurementProvider = FutureProvider.autoDispose<BodyMeasurement?>((ref) async {
  final datasource = ref.watch(progressDataSourceProvider);
  final measurement = await datasource.getLatestMeasurement();
  if (measurement == null) return null;
  return BodyMeasurement.fromJson(measurement);
});

/// Provider for progress statistics (legacy - kept for backward compatibility)
final progressStatsProvider = FutureProvider.autoDispose((ref) async {
  final datasource = ref.watch(progressDataSourceProvider);
  final stats = await datasource.getProgressStats();
  return (
    totalExercisesLogged: stats['total_exercises_logged'] as int? ?? 0,
    uniqueExercises: stats['unique_exercises'] as int? ?? 0,
    totalWeightLifted: (stats['total_weight_lifted'] as num?)?.toDouble() ?? 0.0,
    averageRepsPerSet: (stats['average_reps_per_set'] as num?)?.toDouble() ?? 0.0,
    lastLoggedAt:
        stats['last_logged_at'] != null ? DateTime.parse(stats['last_logged_at']) : null,
  );
});

/// Provider for all progress logs
final allProgressLogsProvider = FutureProvider.autoDispose((ref) async {
  final datasource = ref.watch(progressDataSourceProvider);
  return await datasource.fetchProgressLogs();
});

/// Provider for exercise history
final exerciseHistoryProvider =
    FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, exerciseId) async {
  final datasource = ref.watch(progressDataSourceProvider);
  return await datasource.getExerciseHistory(exerciseId);
});

/// State notifier for logging exercises
class LogExerciseNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state - nothing to load
  }

  Future<void> logExercise({
    required String exerciseId,
    required int setsCompleted,
    required int repsPerSet,
    double? weightKg,
    int? durationSeconds,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final datasource = ref.read(progressDataSourceProvider);

    state = await AsyncValue.guard(() => datasource.logExercise(
      exerciseId: exerciseId,
      setsCompleted: setsCompleted,
      repsPerSet: repsPerSet,
      weightKg: weightKg,
      durationSeconds: durationSeconds,
      notes: notes,
    ));

    // Refresh progress logs and stats
    ref.invalidate(allProgressLogsProvider);
    ref.invalidate(progressStatsProvider);
    ref.invalidate(clientProgressStatsProvider);
  }
}

/// Provider for exercise log notifier
final logExerciseNotifierProvider =
    AsyncNotifierProvider<LogExerciseNotifier, void>(() {
  return LogExerciseNotifier();
});

/// State notifier for logging body measurements
class LogMeasurementNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state - nothing to load
  }

  Future<void> logMeasurement({
    double? weightKg,
    double? heightCm,
    double? bodyFatPercentage,
    double? chestCm,
    double? waistCm,
    double? hipsCm,
    double? bicepCm,
    double? thighCm,
    String? frontPhotoUrl,
    String? sidePhotoUrl,
    String? backPhotoUrl,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final datasource = ref.read(progressDataSourceProvider);

    state = await AsyncValue.guard(() => datasource.logMeasurement(
      weightKg: weightKg,
      heightCm: heightCm,
      bodyFatPercentage: bodyFatPercentage,
      chestCm: chestCm,
      waistCm: waistCm,
      hipsCm: hipsCm,
      bicepCm: bicepCm,
      thighCm: thighCm,
      frontPhotoUrl: frontPhotoUrl,
      sidePhotoUrl: sidePhotoUrl,
      backPhotoUrl: backPhotoUrl,
      notes: notes,
    ));

    // Refresh measurements
    ref.invalidate(bodyMeasurementsProvider);
    ref.invalidate(latestMeasurementProvider);
    ref.invalidate(clientProgressStatsProvider);
  }
}

/// Provider for measurement log notifier
final logMeasurementNotifierProvider =
    AsyncNotifierProvider<LogMeasurementNotifier, void>(() {
  return LogMeasurementNotifier();
});
