import 'package:fpdart/fpdart.dart';

import '../../../../core/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../datasources/exercise_local_datasource.dart';
import '../datasources/exercise_remote_datasource.dart';
import '../models/exercise_model.dart';

/// Exercise repository implementation with offline-first pattern
class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseRemoteDataSource remoteDataSource;
  final ExerciseLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ExerciseRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Exercise>>> fetchExercises({
    String? category,
    String? muscleGroup,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Fetch from remote
        final remoteExercises = await remoteDataSource.fetchExercises(
          category: category,
          muscleGroup: muscleGroup,
        );

        // Cache locally
        await localDataSource.cacheExercises(remoteExercises);

        // Return domain entities
        return Right(remoteExercises.map((m) => m.toEntity()).toList());
      } catch (e) {
        // On error, fallback to local cache
        return _getLocalData(category: category, muscleGroup: muscleGroup);
      }
    } else {
      // Offline: use local cache
      return _getLocalData(category: category, muscleGroup: muscleGroup);
    }
  }

  @override
  Future<Either<Failure, List<Exercise>>> getLocalExercises({
    String? category,
    String? muscleGroup,
  }) async {
    try {
      final localExercises = await localDataSource.getExercises(
        category: category,
        muscleGroup: muscleGroup,
      );
      return Right(localExercises.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get local exercises: $e'));
    }
  }

  @override
  Future<Either<Failure, Exercise>> getExerciseById(String id) async {
    try {
      final exercise = await localDataSource.getExerciseById(id);

      if (exercise != null) {
        return Right(exercise.toEntity());
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteExercise = await remoteDataSource.getExerciseById(id);
          // Cache it
          await localDataSource.cacheExercises([remoteExercise]);
          return Right(remoteExercise.toEntity());
        } catch (e) {
          return Left(ServerFailure('Failed to fetch exercise: $e'));
        }
      }

      return Left(CacheFailure('Exercise not found'));
    } catch (e) {
      return Left(CacheFailure('Failed to get exercise: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheExercises(List<Exercise> exercises) async {
    try {
      final models = exercises.map((e) => ExerciseModel.fromEntity(e)).toList();
      await localDataSource.cacheExercises(models);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to cache exercises: $e'));
    }
  }

  Future<Either<Failure, List<Exercise>>> _getLocalData({
    String? category,
    String? muscleGroup,
  }) async {
    try {
      final localExercises = await localDataSource.getExercises(
        category: category,
        muscleGroup: muscleGroup,
      );
      return Right(localExercises.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get cached exercises: $e'));
    }
  }
}
