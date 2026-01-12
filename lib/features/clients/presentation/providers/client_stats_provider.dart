import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../auth/data/models/client_model.dart';
import '../../../progress/presentation/providers/progress_provider.dart';

part 'client_stats_provider.g.dart';

/// Client statistics aggregated from progress data
class ClientStats {
  final int totalWorkouts;
  final int uniqueExercises;
  final double totalWeightLifted;
  final double? currentWeight;

  const ClientStats({
    required this.totalWorkouts,
    required this.uniqueExercises,
    required this.totalWeightLifted,
    this.currentWeight,
  });
}

/// Provider for client statistics
/// Aggregates workout history and progress data
@riverpod
Future<ClientStats> clientStats(ClientStatsRef ref) async {
  final user = ref.watch(authStateProvider);
  if (user is! ClientModel) {
    throw Exception('User is not a client');
  }

  // Fetch progress history to calculate stats
  final progressHistoryAsync = await ref.watch(progressHistoryProvider.future);

  // Calculate stats from progress history
  double totalWeight = 0;

  for (final entry in progressHistoryAsync) {
    // Calculate total weight: sets × reps × weight
    if (entry.weightKgUsed != null) {
      final sets = entry.setsCompleted ?? 1;
      final reps = entry.repsCompleted ?? 1;
      totalWeight += entry.weightKgUsed! * sets * reps;
    }
  }

  return ClientStats(
    totalWorkouts: progressHistoryAsync.length,
    uniqueExercises: progressHistoryAsync.length, // Placeholder: each entry as unique
    totalWeightLifted: totalWeight,
    currentWeight: user.weightKg, // From auth state (if available)
  );
}
