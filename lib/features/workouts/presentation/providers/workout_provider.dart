import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/workout_repository.dart';
import '../../data/datasources/workout_local_datasource.dart';
import '../../data/datasources/workout_remote_datasource.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../../progress/presentation/providers/exercise_provider.dart';

/// Provider for workout repository
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final database = ref.watch(databaseProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  return WorkoutRepositoryImpl(
    remoteDataSource: WorkoutRemoteDataSourceImpl(dio: dio),
    localDataSource: WorkoutLocalDataSourceImpl(database: database),
    networkInfo: networkInfo,
  );
});

/// Provider for fetching all workouts
final workoutsProvider =
    FutureProvider.family<List, int>((ref, page) async {
  final skip = page * 50;
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.fetchWorkouts(skip: skip, limit: 50);
});

/// Provider for all workouts (no pagination)
final allWorkoutsProvider = FutureProvider<List>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.fetchWorkouts();
});

/// Provider for single workout
final workoutProvider = FutureProvider.family<dynamic, String>((ref, workoutId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkoutById(workoutId);
});

/// State notifier for creating workouts
class CreateWorkoutNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  Future<void> createWorkout({
    required String name,
    String? description,
    String? category,
    String? difficulty,
    int? durationMinutes,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(workoutRepositoryProvider);

    state = await AsyncValue.guard(() => repository.createWorkout(
      name: name,
      description: description,
      category: category,
      difficulty: difficulty,
      durationMinutes: durationMinutes,
    ));

    // Refresh the list
    state.whenData((_) {
      ref.refresh(allWorkoutsProvider);
    });
  }
}

final createWorkoutNotifierProvider =
    AsyncNotifierProvider<CreateWorkoutNotifier, void>(() {
  return CreateWorkoutNotifier();
});

/// Provider for workout assignments
final workoutAssignmentsProvider =
    FutureProvider.family<List, String>((ref, clientId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getClientAssignments(clientId);
});
