import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../database/app_database.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/exercise_local_datasource.dart';
import '../../data/datasources/exercise_remote_datasource.dart';
import '../../data/repositories/exercise_repository_impl.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/usecases/fetch_exercises_usecase.dart';

/// Database provider
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// Connectivity provider
final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

/// Network info provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

/// Exercise remote data source provider
final exerciseRemoteDataSourceProvider =
    Provider<ExerciseRemoteDataSource>((ref) {
  return ExerciseRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

/// Exercise local data source provider
final exerciseLocalDataSourceProvider = Provider<ExerciseLocalDataSource>((ref) {
  return ExerciseLocalDataSourceImpl(database: ref.watch(databaseProvider));
});

/// Exercise repository provider
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl(
    remoteDataSource: ref.watch(exerciseRemoteDataSourceProvider),
    localDataSource: ref.watch(exerciseLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

/// Fetch exercises use case provider
final fetchExercisesUseCaseProvider = Provider<FetchExercisesUseCase>((ref) {
  return FetchExercisesUseCase(repository: ref.watch(exerciseRepositoryProvider));
});

/// Get local exercises use case provider
final getLocalExercisesUseCaseProvider =
    Provider<GetLocalExercisesUseCase>((ref) {
  return GetLocalExercisesUseCase(
      repository: ref.watch(exerciseRepositoryProvider));
});

/// Get exercise by ID use case provider
final getExerciseByIdUseCaseProvider =
    Provider<GetExerciseByIdUseCase>((ref) {
  return GetExerciseByIdUseCase(repository: ref.watch(exerciseRepositoryProvider));
});

/// Exercises state provider - fetches exercises on demand
final exercisesProvider = FutureProvider.family<List<Exercise>, ({String? category, String? muscleGroup})>((
  ref,
  params,
) async {
  return ref.watch(fetchExercisesUseCaseProvider).call(
    category: params.category,
    muscleGroup: params.muscleGroup,
  ).then((result) => result.fold(
    (failure) => throw Exception(failure),
    (exercises) => exercises,
  ));
});

/// Exercises by category provider
final exercisesByCategoryProvider = FutureProvider.family<List<Exercise>, String>(
  (ref, category) async {
    return ref
        .watch(exercisesProvider(
          (category: category, muscleGroup: null),
        ))
        .maybeWhen(
          data: (exercises) => exercises,
          orElse: () => throw Exception('Failed to load exercises'),
        );
  },
);

/// All exercises provider
final allExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  return ref
      .watch(exercisesProvider(
        (category: null, muscleGroup: null),
      ))
      .maybeWhen(
        data: (exercises) => exercises,
        orElse: () => throw Exception('Failed to load exercises'),
      );
});

/// Single exercise provider
final exerciseProvider =
    FutureProvider.family<Exercise, String>((ref, exerciseId) async {
  return ref
      .watch(getExerciseByIdUseCaseProvider)
      .call(exerciseId)
      .then((result) => result.fold(
        (failure) => throw Exception(failure),
        (exercise) => exercise,
      ));
});
