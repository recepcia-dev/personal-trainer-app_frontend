import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/progress_local_datasource.dart';
import '../../data/datasources/progress_remote_datasource.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/entities/progress_log.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/usecases/progress_usecases.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import 'exercise_provider.dart';

/// Progress remote data source provider
final progressRemoteDataSourceProvider =
    Provider<ProgressRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProgressRemoteDataSourceImpl(dio: dio);
});

/// Progress local data source provider
final progressLocalDataSourceProvider = Provider<ProgressLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return ProgressLocalDataSourceImpl(database: database);
});

/// Progress repository provider
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl(
    remoteDataSource: ref.watch(progressRemoteDataSourceProvider),
    localDataSource: ref.watch(progressLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

/// Log exercise use case provider
final logExerciseUseCaseProvider = Provider<LogExerciseUseCase>((ref) {
  return LogExerciseUseCase(repository: ref.watch(progressRepositoryProvider));
});

/// Get progress logs use case provider
final getProgressLogsUseCaseProvider = Provider<GetProgressLogsUseCase>((ref) {
  return GetProgressLogsUseCase(repository: ref.watch(progressRepositoryProvider));
});

/// Get progress stats use case provider
final getProgressStatsUseCaseProvider =
    Provider<GetProgressStatsUseCase>((ref) {
  return GetProgressStatsUseCase(repository: ref.watch(progressRepositoryProvider));
});

/// Get exercise history use case provider
final getExerciseHistoryUseCaseProvider =
    Provider<GetExerciseHistoryUseCase>((ref) {
  return GetExerciseHistoryUseCase(
      repository: ref.watch(progressRepositoryProvider));
});

/// Sync progress logs use case provider
final syncProgressLogsUseCaseProvider =
    Provider<SyncProgressLogsUseCase>((ref) {
  return SyncProgressLogsUseCase(
      repository: ref.watch(progressRepositoryProvider));
});

/// Log exercise state notifier
class LogExerciseNotifier
    extends StateNotifier<AsyncValue<ProgressLog>> {
  final LogExerciseUseCase _useCase;

  LogExerciseNotifier({required LogExerciseUseCase useCase})
      : _useCase = useCase,
        super(AsyncValue.data(
          ProgressLog(
            id: '',
            clientId: '',
            exerciseId: '',
            setsCompleted: 0,
            repsPerSet: 0,
            isSynced: false,
            createdAt: DateTime(2000),
            updatedAt: DateTime(2000),
          ),
        ));

  Future<void> logExercise({
    required String exerciseId,
    required int setsCompleted,
    required int repsPerSet,
    double? weightKg,
    int? durationSeconds,
    String? notes,
  }) async {
    state = const AsyncValue.loading();

    final result = await _useCase.call(
      exerciseId: exerciseId,
      setsCompleted: setsCompleted,
      repsPerSet: repsPerSet,
      weightKg: weightKg,
      durationSeconds: durationSeconds,
      notes: notes,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (log) => AsyncValue.data(log),
    );
  }
}

/// Log exercise notifier provider
final logExerciseNotifierProvider =
    StateNotifierProvider<LogExerciseNotifier, AsyncValue<ProgressLog>>(
  (ref) {
    return LogExerciseNotifier(useCase: ref.watch(logExerciseUseCaseProvider));
  },
);

/// Progress logs provider
final progressLogsProvider = FutureProvider.family<List<ProgressLog>, String?>(
  (ref, exerciseId) async {
    return ref
        .watch(getProgressLogsUseCaseProvider)
        .call(exerciseId: exerciseId)
        .then((result) => result.fold(
          (failure) => throw Exception(failure),
          (logs) => logs,
        ));
  },
);

/// All progress logs provider
final allProgressLogsProvider = FutureProvider<List<ProgressLog>>((ref) async {
  return ref
      .watch(progressLogsProvider(null))
      .maybeWhen(
        data: (logs) => logs,
        orElse: () => throw Exception('Failed to load progress logs'),
      );
});

/// Progress stats provider
final progressStatsProvider = FutureProvider<ProgressStats>((ref) async {
  return ref
      .watch(getProgressStatsUseCaseProvider)
      .call()
      .then((result) => result.fold(
        (failure) => throw Exception(failure),
        (stats) => stats,
      ));
});

/// Exercise history provider
final exerciseHistoryProvider =
    FutureProvider.family<ExerciseHistory, String>((ref, exerciseId) async {
  return ref
      .watch(getExerciseHistoryUseCaseProvider)
      .call(exerciseId)
      .then((result) => result.fold(
        (failure) => throw Exception(failure),
        (history) => history,
      ));
});

/// Sync progress logs provider
final syncProgressLogsProvider = FutureProvider<int>((ref) async {
  return ref
      .watch(syncProgressLogsUseCaseProvider)
      .call()
      .then((result) => result.fold(
        (failure) => throw Exception(failure),
        (count) => count,
      ));
});
