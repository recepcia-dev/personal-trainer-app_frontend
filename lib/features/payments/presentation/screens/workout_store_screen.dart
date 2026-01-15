import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/workout_pack_model.dart';
import '../providers/client_store_provider.dart';

/// Workout store screen for browsing and purchasing premium workout packs (TC007.2)
class WorkoutStoreScreen extends ConsumerStatefulWidget {
  const WorkoutStoreScreen({super.key});

  @override
  ConsumerState<WorkoutStoreScreen> createState() => _WorkoutStoreScreenState();
}

class _WorkoutStoreScreenState extends ConsumerState<WorkoutStoreScreen> {
  String? _selectedCategory;
  String? _selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    final packsAsync = ref.watch(allWorkoutPacksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Store'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: packsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load workout packs', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: theme.textTheme.bodySmall),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.invalidate(allWorkoutPacksProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (response) {
          if (response.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No workout packs available',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new premium workouts!',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          // Apply filters
          var filteredPacks = response.items;
          if (_selectedCategory != null) {
            filteredPacks = filteredPacks
                .where((p) => p.category == _selectedCategory)
                .toList();
          }
          if (_selectedDifficulty != null) {
            filteredPacks = filteredPacks
                .where((p) => p.difficulty == _selectedDifficulty)
                .toList();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredPacks.length,
            itemBuilder: (context, index) {
              final pack = filteredPacks[index];
              return _WorkoutPackCard(
                pack: pack,
                onTap: () => context.push('/client/store/${pack.id}'),
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter Packs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text('Category', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedCategory == null,
                  onSelected: () => setState(() => _selectedCategory = null),
                ),
                _FilterChip(
                  label: 'Strength',
                  selected: _selectedCategory == 'strength',
                  onSelected: () => setState(() => _selectedCategory = 'strength'),
                ),
                _FilterChip(
                  label: 'Cardio',
                  selected: _selectedCategory == 'cardio',
                  onSelected: () => setState(() => _selectedCategory = 'cardio'),
                ),
                _FilterChip(
                  label: 'HIIT',
                  selected: _selectedCategory == 'hiit',
                  onSelected: () => setState(() => _selectedCategory = 'hiit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Difficulty', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedDifficulty == null,
                  onSelected: () => setState(() => _selectedDifficulty = null),
                ),
                _FilterChip(
                  label: 'Beginner',
                  selected: _selectedDifficulty == 'beginner',
                  onSelected: () => setState(() => _selectedDifficulty = 'beginner'),
                ),
                _FilterChip(
                  label: 'Intermediate',
                  selected: _selectedDifficulty == 'intermediate',
                  onSelected: () => setState(() => _selectedDifficulty = 'intermediate'),
                ),
                _FilterChip(
                  label: 'Advanced',
                  selected: _selectedDifficulty == 'advanced',
                  onSelected: () => setState(() => _selectedDifficulty = 'advanced'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ref.invalidate(allWorkoutPacksProvider);
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        onSelected();
        Navigator.pop(context);
      },
    );
  }
}

class _WorkoutPackCard extends StatelessWidget {
  final WorkoutPackModel pack;
  final VoidCallback onTap;

  const _WorkoutPackCard({
    required this.pack,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with gradient
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(pack.category),
                    _getCategoryColor(pack.category).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Icon(
                      _getCategoryIcon(pack.category),
                      size: 48,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pack.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (pack.trainerName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'by ${pack.trainerName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Tags row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(pack.categoryDisplayName, Colors.blue),
                      _buildChip(pack.difficultyDisplayName, Colors.orange),
                      _buildChip('${pack.workoutCount} workouts', Colors.purple),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price and action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pack.formattedPrice,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (pack.isPurchased)
                        Chip(
                          avatar: const Icon(Icons.check, size: 16, color: Colors.white),
                          label: const Text('Purchased'),
                          backgroundColor: Colors.green,
                          labelStyle: const TextStyle(color: Colors.white),
                        )
                      else
                        FilledButton(
                          onPressed: onTap,
                          child: const Text('View Details'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Colors.red.shade600;
      case 'cardio':
        return Colors.blue.shade600;
      case 'flexibility':
        return Colors.purple.shade600;
      case 'hiit':
        return Colors.orange.shade600;
      case 'yoga':
        return Colors.teal.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      case 'hiit':
        return Icons.local_fire_department;
      case 'yoga':
        return Icons.spa;
      default:
        return Icons.sports_gymnastics;
    }
  }
}
