import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'trainer_public_profile_screen.dart';

/// Provider for searching trainers
final trainerSearchProvider = FutureProvider.family<List<TrainerSearchResult>, String>((ref, query) async {
  await Future.delayed(const Duration(milliseconds: 300));
  
  // Mock data - all trainers if empty query, otherwise filter
  final allTrainers = [
    TrainerSearchResult(
      id: 'trainer-1',
      name: 'Alex Johnson',
      photoUrl: null,
      specializations: ['Weight Loss', 'Muscle Building'],
      rating: 4.8,
      reviewCount: 124,
      hourlyRate: 75.0,
      isVerified: true,
      location: 'San Francisco, CA',
    ),
    TrainerSearchResult(
      id: 'trainer-2',
      name: 'Maria Garcia',
      photoUrl: null,
      specializations: ['Yoga', 'Flexibility', 'Meditation'],
      rating: 4.9,
      reviewCount: 89,
      hourlyRate: 60.0,
      isVerified: true,
      location: 'Los Angeles, CA',
    ),
    TrainerSearchResult(
      id: 'trainer-3',
      name: 'James Wilson',
      photoUrl: null,
      specializations: ['CrossFit', 'HIIT', 'Strength Training'],
      rating: 4.6,
      reviewCount: 56,
      hourlyRate: 80.0,
      isVerified: false,
      location: 'San Francisco, CA',
    ),
    TrainerSearchResult(
      id: 'trainer-4',
      name: 'Emily Chen',
      photoUrl: null,
      specializations: ['Nutrition', 'Weight Loss', 'Wellness'],
      rating: 4.7,
      reviewCount: 201,
      hourlyRate: 65.0,
      isVerified: true,
      location: 'San Jose, CA',
    ),
    TrainerSearchResult(
      id: 'trainer-5',
      name: 'David Brown',
      photoUrl: null,
      specializations: ['Sports Performance', 'Athletic Training'],
      rating: 4.5,
      reviewCount: 42,
      hourlyRate: 90.0,
      isVerified: false,
      location: 'Oakland, CA',
    ),
  ];
  
  if (query.isEmpty) return allTrainers;
  
  final lowerQuery = query.toLowerCase();
  return allTrainers.where((t) =>
    t.name.toLowerCase().contains(lowerQuery) ||
    t.specializations.any((s) => s.toLowerCase().contains(lowerQuery)) ||
    (t.location?.toLowerCase().contains(lowerQuery) ?? false)
  ).toList();
});

class TrainerSearchResult {
  final String id;
  final String name;
  final String? photoUrl;
  final List<String> specializations;
  final double rating;
  final int reviewCount;
  final double hourlyRate;
  final bool isVerified;
  final String? location;

  TrainerSearchResult({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.specializations,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.isVerified,
    this.location,
  });
}

class TrainerSearchScreen extends ConsumerStatefulWidget {
  const TrainerSearchScreen({super.key});

  @override
  ConsumerState<TrainerSearchScreen> createState() => _TrainerSearchScreenState();
}

class _TrainerSearchScreenState extends ConsumerState<TrainerSearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'rating';
  List<String> _selectedSpecializations = [];

  final _allSpecializations = [
    'Weight Loss',
    'Muscle Building',
    'Yoga',
    'HIIT',
    'CrossFit',
    'Nutrition',
    'Sports Performance',
    'Flexibility',
    'Strength Training',
    'Wellness',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trainersAsync = ref.watch(trainerSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Trainer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, specialty, or location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          if (_selectedSpecializations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: _selectedSpecializations.map((spec) => Chip(
                  label: Text(spec, style: const TextStyle(fontSize: 12)),
                  onDeleted: () {
                    setState(() => _selectedSpecializations.remove(spec));
                  },
                )).toList(),
              ),
            ),
          Expanded(
            child: trainersAsync.when(
              data: (trainers) {
                // Apply filters
                var filtered = trainers;
                if (_selectedSpecializations.isNotEmpty) {
                  filtered = filtered.where((t) =>
                    t.specializations.any((s) => _selectedSpecializations.contains(s))
                  ).toList();
                }
                
                // Apply sorting
                switch (_sortBy) {
                  case 'rating':
                    filtered.sort((a, b) => b.rating.compareTo(a.rating));
                    break;
                  case 'price_low':
                    filtered.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
                    break;
                  case 'price_high':
                    filtered.sort((a, b) => b.hourlyRate.compareTo(a.hourlyRate));
                    break;
                  case 'reviews':
                    filtered.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
                    break;
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No trainers found',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _TrainerCard(
                    trainer: filtered[index],
                    onTap: () => _navigateToProfile(filtered[index]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    const Text('Failed to load trainers'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(trainerSearchProvider(_searchQuery)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedSpecializations.clear();
                        _sortBy = 'rating';
                      });
                      setState(() {});
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Sort By',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Rating'),
                    selected: _sortBy == 'rating',
                    onSelected: (_) => setModalState(() => _sortBy = 'rating'),
                  ),
                  ChoiceChip(
                    label: const Text('Price: Low to High'),
                    selected: _sortBy == 'price_low',
                    onSelected: (_) => setModalState(() => _sortBy = 'price_low'),
                  ),
                  ChoiceChip(
                    label: const Text('Price: High to Low'),
                    selected: _sortBy == 'price_high',
                    onSelected: (_) => setModalState(() => _sortBy = 'price_high'),
                  ),
                  ChoiceChip(
                    label: const Text('Most Reviews'),
                    selected: _sortBy == 'reviews',
                    onSelected: (_) => setModalState(() => _sortBy = 'reviews'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Specializations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allSpecializations.map((spec) => FilterChip(
                  label: Text(spec),
                  selected: _selectedSpecializations.contains(spec),
                  onSelected: (selected) {
                    setModalState(() {
                      if (selected) {
                        _selectedSpecializations.add(spec);
                      } else {
                        _selectedSpecializations.remove(spec);
                      }
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProfile(TrainerSearchResult trainer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainerPublicProfileScreen(trainerId: trainer.id),
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  final TrainerSearchResult trainer;
  final VoidCallback onTap;

  const _TrainerCard({
    required this.trainer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: trainer.photoUrl != null
                    ? NetworkImage(trainer.photoUrl!)
                    : null,
                child: trainer.photoUrl == null
                    ? Text(
                        trainer.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trainer.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (trainer.isVerified)
                          const Icon(Icons.verified, color: Colors.blue, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trainer.specializations.take(2).join(' • '),
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          trainer.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' (${trainer.reviewCount})',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        Text(
                          '\$${trainer.hourlyRate.toStringAsFixed(0)}/hr',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    if (trainer.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            trainer.location!,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
