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

/// Provider for progress statistics
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
  FutureOr<void> build() {
    return;
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
  }
}

/// Provider for exercise log notifier
final logExerciseNotifierProvider =
    AsyncNotifierProvider<LogExerciseNotifier, void>(() {
  return LogExerciseNotifier();
});
