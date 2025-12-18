import 'package:fpdart/fpdart.dart';

import '../../../../core/failure.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

/// Use case to fetch exercises
class FetchExercisesUseCase {
  final ExerciseRepository repository;

  FetchExercisesUseCase({required this.repository});

  Future<Either<Failure, List<Exercise>>> call({
    String? category,
    String? muscleGroup,
  }) {
    return repository.fetchExercises(
      category: category,
      muscleGroup: muscleGroup,
    );
  }
}

/// Use case to get local exercises
class GetLocalExercisesUseCase {
  final ExerciseRepository repository;

  GetLocalExercisesUseCase({required this.repository});

  Future<Either<Failure, List<Exercise>>> call({
    String? category,
    String? muscleGroup,
  }) {
    return repository.getLocalExercises(
      category: category,
      muscleGroup: muscleGroup,
    );
  }
}

/// Use case to get single exercise
class GetExerciseByIdUseCase {
  final ExerciseRepository repository;

  GetExerciseByIdUseCase({required this.repository});

  Future<Either<Failure, Exercise>> call(String id) {
    return repository.getExerciseById(id);
  }
}
