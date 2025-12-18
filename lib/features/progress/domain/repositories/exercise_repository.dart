import 'package:fpdart/fpdart.dart';

import '../../../../core/failure.dart';
import '../entities/exercise.dart';

/// Exercise repository interface - defines contract for exercise data operations
abstract class ExerciseRepository {
  /// Fetch all exercises from remote, cache locally
  Future<Either<Failure, List<Exercise>>> fetchExercises({
    String? category,
    String? muscleGroup,
  });

  /// Get exercises from local cache
  Future<Either<Failure, List<Exercise>>> getLocalExercises({
    String? category,
    String? muscleGroup,
  });

  /// Get single exercise by ID
  Future<Either<Failure, Exercise>> getExerciseById(String id);

  /// Save exercises to local cache
  Future<Either<Failure, void>> cacheExercises(List<Exercise> exercises);
}
