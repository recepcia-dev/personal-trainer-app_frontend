import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../progress/presentation/providers/progress_provider.dart';
import '../providers/client_provider.dart';
import '../widgets/client_edit_form.dart';

/// Screen for viewing client details and progress
class ClientDetailScreen extends ConsumerStatefulWidget {
  final String clientId;

  const ClientDetailScreen({
    required this.clientId,
    super.key,
  });

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clientAsync = ref.watch(clientProvider(widget.clientId));
    final progressStatsAsync = ref.watch(progressStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
        ],
      ),
      body: clientAsync.when(
        data: (client) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 40,
                              child: Text(
                                (client.fullName.isNotEmpty
                                        ? client.fullName[0]
                                        : 'C')
                                    .toUpperCase(),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            client.fullName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(client.email),
                          if (client.phone != null) ...[
                            const SizedBox(height: 4),
                            Text(client.phone!),
                          ],
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (client.age != null)
                                Chip(label: Text('Age: ${client.age}')),
                              if (client.fitnessLevel != null)
                                Chip(label: Text('Level: ${client.fitnessLevel}')),
                            ],
                          ),
                          if (client.goals != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Goals',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(client.goals!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Edit form (if enabled)
                  if (_isEditMode)
                    ClientEditForm(
                      client: client,
                      onSaved: () => setState(() => _isEditMode = false),
                    ),

                  if (!_isEditMode) ...[
                    // Progress section
                    Text(
                      'Progress Overview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    progressStatsAsync.when(
                      data: (stats) {
                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children: [
                            _buildStatCard(
                              theme,
                              '${stats.totalExercisesLogged}',
                              'Exercises Logged',
                              Icons.fitness_center,
                            ),
                            _buildStatCard(
                              theme,
                              '${stats.uniqueExercises}',
                              'Unique Exercises',
                              Icons.list,
                            ),
                            _buildStatCard(
                              theme,
                              '${stats.totalWeightLifted.toStringAsFixed(0)} kg',
                              'Total Volume',
                              Icons.scale,
                            ),
                            _buildStatCard(
                              theme,
                              '${stats.averageRepsPerSet.toStringAsFixed(1)}',
                              'Avg Reps',
                              Icons.repeat,
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Text('Error loading stats: $error'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading client: $error'),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String value,
    String label,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
