import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/client_workout_datasource.dart';
import '../../data/models/assigned_workout_model.dart';

/// Provider for client workout datasource
final clientWorkoutDataSourceProvider = Provider<ClientWorkoutDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ClientWorkoutDataSourceImpl(dio: dio);
});

/// Provider for fetching assigned workouts for the authenticated client
final assignedWorkoutsProvider = FutureProvider.autoDispose<List<AssignedWorkoutModel>>((ref) async {
  final datasource = ref.watch(clientWorkoutDataSourceProvider);
  return await datasource.getAssignedWorkouts();
});

/// Provider for fetching a specific workout detail
final workoutDetailProvider = FutureProvider.autoDispose.family<AssignedWorkoutModel, String>((ref, assignmentId) async {
  final datasource = ref.watch(clientWorkoutDataSourceProvider);
  return await datasource.getWorkoutDetail(assignmentId);
});

/// Provider for fetching completed workout history
final completedWorkoutsProvider = FutureProvider.autoDispose<List<AssignedWorkoutModel>>((ref) async {
  final datasource = ref.watch(clientWorkoutDataSourceProvider);
  return await datasource.getCompletedWorkouts();
});

/// Provider for marking a workout complete
final markWorkoutCompleteProvider = FutureProvider.autoDispose.family<AssignedWorkoutModel, String>((ref, assignmentId) async {
  final datasource = ref.watch(clientWorkoutDataSourceProvider);
  return await datasource.markWorkoutComplete(assignmentId);
});
