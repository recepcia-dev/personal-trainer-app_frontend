import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/trainer/presentation/providers/trainer_provider.dart';
import '../../../../features/clients/presentation/providers/client_profile_provider.dart';
import '../../../../features/clients/presentation/providers/client_stats_provider.dart';
import '../../../../features/clients/presentation/providers/client_trainer_provider.dart';
import '../../../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../../../features/auth/data/models/client_model.dart';
import '../../../../features/auth/data/models/trainer_model.dart';

/// Profile tab - Role-based information display (Trainer or Client)
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    if (user is TrainerModel) {
      return _TrainerProfileView();
    } else if (user is ClientModel) {
      return _ClientProfileView();
    } else {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Text(
            'Unknown user type',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }
  }
}

/// Trainer profile view - displays trainer info and statistics
class _TrainerProfileView extends ConsumerWidget {
  const _TrainerProfileView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(trainerStatsProvider);
    final profileAsync = ref.watch(trainerProfileProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Trainer Basic Info
            profileAsync.when(
              data: (profile) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          profile.email.isNotEmpty
                              ? profile.email[0].toUpperCase()
                              : 'T',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.firstName != null && profile.lastName != null
                            ? '${profile.firstName} ${profile.lastName}'
                            : profile.email,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (profile.uniqueCode.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.qr_code,
                                size: 20,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Code: ${profile.uniqueCode}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error loading profile: $error'),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Section
            Text(
              'Statistics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            statsAsync.when(
              data: (stats) => Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Clients',
                      value: '${stats.activeClients}',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Workouts',
                      value: '${stats.totalWorkoutsAssigned}',
                      icon: Icons.fitness_center,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Meals',
                      value: '${stats.totalDietsAssigned}',
                      icon: Icons.restaurant,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Clients',
                      value: '0',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Workouts',
                      value: '0',
                      icon: Icons.fitness_center,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Meals',
                      value: '0',
                      icon: Icons.restaurant,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Client profile view - displays client profile and progress statistics
class _ClientProfileView extends ConsumerWidget {
  const _ClientProfileView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider);
    final profileAsync = ref.watch(clientProfileProvider);
    final statsAsync = ref.watch(clientStatsProvider);
    final trainerAsync = ref.watch(clientTrainerProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Client Basic Info Card
            profileAsync.when(
              data: (profile) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          profile.email.isNotEmpty
                              ? profile.email[0].toUpperCase()
                              : 'C',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.firstName != null && profile.lastName != null
                            ? '${profile.firstName} ${profile.lastName}'
                            : profile.email,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (profile.age != null)
                            Chip(
                              label: Text('Age: ${profile.age}'),
                              avatar: Icon(Icons.cake, size: 20),
                            ),
                          if (profile.fitnessLevel != null)
                            Chip(
                              label: Text(profile.fitnessLevel!),
                              avatar: Icon(Icons.fitness_center, size: 20),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error loading profile: $error'),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Body Metrics Card
            if (user is ClientModel && (user.weightKg != null || user.heightCm != null)) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Body Metrics',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (user.weightKg != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Weight',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '${user.weightKg!.toStringAsFixed(1)} kg',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (user.heightCm != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Height',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '${user.heightCm!.toStringAsFixed(1)} cm',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (user.weightKg != null && user.heightCm != null) ...[
                        const SizedBox(height: 12),
                        Divider(),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'BMI',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _calculateBMI(user.weightKg!, user.heightCm!)
                                    .toStringAsFixed(1),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // My Trainer Section
            Text(
              'My Trainer',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            trainerAsync.when(
              data: (trainer) {
                if (trainer == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 40,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'No trainer assigned yet',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  child: InkWell(
                    onTap: () {
                      context.push('/trainer-profile/${trainer.id}');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            child: Text(
                              trainer.fullName.isNotEmpty
                                  ? trainer.fullName[0].toUpperCase()
                                  : 'T',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trainer.fullName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  trainer.email,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (trainer.specialty != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      trainer.specialty!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Error loading trainer info',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Progress Statistics Section
            Text(
              'Progress Statistics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            statsAsync.when(
              data: (stats) => Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Workouts',
                      value: '${stats.totalWorkouts}',
                      icon: Icons.fitness_center,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Exercises',
                      value: '${stats.uniqueExercises}',
                      icon: Icons.repeat,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Weight Lifted',
                      value: '${stats.totalWeightLifted.toStringAsFixed(0)} kg',
                      icon: Icons.straighten,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Workouts',
                      value: '0',
                      icon: Icons.fitness_center,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Exercises',
                      value: '0',
                      icon: Icons.repeat,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Weight Lifted',
                      value: '0 kg',
                      icon: Icons.straighten,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Goals Section
            Text(
              'Goals',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            profileAsync.when(
              data: (profile) {
                final goals = profile.goals;
                if (goals == null || goals.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No goals set yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      goals,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading goals: $error'),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Subscription & Billing Section
            Text(
              'Subscription & Billing',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.card_membership),
                    title: const Text('My Subscription'),
                    subtitle: const Text('View plan status and features'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/client/subscription'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text('Workout Store'),
                    subtitle: const Text('Browse premium workout packs'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/client/store'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('My Purchases'),
                    subtitle: const Text('View purchased workout packs'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/client/purchases'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Calculate BMI given weight in kg and height in cm
  double _calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
