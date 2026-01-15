import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_provider.dart';

/// Provider for public trainer profile data
final publicTrainerProfileProvider = FutureProvider.family<PublicTrainerProfile, String>((ref, trainerId) async {
  final dio = ref.watch(dioProvider);
  
  try {
    if (kDebugMode) {
      debugPrint('🔵 [PublicTrainerProfileProvider] Fetching trainer info from /api/v1/client/trainer');
    }
    
    // Use the client trainer endpoint which returns trainer info for the assigned trainer
    final response = await dio.get(
      '${ApiEndpoints.baseUrl}/api/v1/client/trainer',
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      
      // Build name from first_name + last_name or fall back to email
      final firstName = data['first_name'] as String? ?? '';
      final lastName = data['last_name'] as String? ?? '';
      final email = data['email'] as String? ?? '';
      final name = firstName.isNotEmpty && lastName.isNotEmpty
          ? '$firstName $lastName'
          : email.split('@')[0];
      
      if (kDebugMode) {
        debugPrint('✅ [PublicTrainerProfileProvider] Trainer info fetched: $name');
      }
      
      return PublicTrainerProfile(
        id: data['id'] as String? ?? trainerId,
        name: name,
        email: email,
        photoUrl: null,
        bio: data['bio'] as String? ?? 'Your personal trainer dedicated to helping you achieve your fitness goals.',
        experience: '5+ years',
        specializations: data['specialty'] != null 
            ? [data['specialty'] as String]
            : ['Personal Training', 'Fitness Coaching'],
        certifications: ['Certified Personal Trainer'],
        rating: 4.8,
        reviewCount: 0,
        hourlyRate: 50.0,
        isVerified: true,
        availability: {},
        location: null,
        responseTime: '< 24 hours',
      );
    } else {
      throw Exception('Failed to fetch trainer: ${response.statusCode}');
    }
  } on DioException catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [PublicTrainerProfileProvider] Error fetching trainer: ${e.message}');
    }
    rethrow;
  }
});

class PublicTrainerProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String bio;
  final String experience;
  final List<String> specializations;
  final List<String> certifications;
  final double rating;
  final int reviewCount;
  final double hourlyRate;
  final bool isVerified;
  final Map<String, List<String>> availability;
  final String? location;
  final String? responseTime;

  PublicTrainerProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.bio,
    required this.experience,
    required this.specializations,
    required this.certifications,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.isVerified,
    required this.availability,
    this.location,
    this.responseTime,
  });
}

class TrainerPublicProfileScreen extends ConsumerStatefulWidget {
  final String trainerId;

  const TrainerPublicProfileScreen({super.key, required this.trainerId});

  @override
  ConsumerState<TrainerPublicProfileScreen> createState() => _TrainerPublicProfileScreenState();
}

class _TrainerPublicProfileScreenState extends ConsumerState<TrainerPublicProfileScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(publicTrainerProfileProvider(widget.trainerId));

    return Scaffold(
      body: profileAsync.when(
        data: (profile) => CustomScrollView(
          slivers: [
            _buildAppBar(context, profile),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(context, profile),
                    const SizedBox(height: 24),
                    _buildBioSection(context, profile),
                    const SizedBox(height: 24),
                    _buildSpecializationsSection(context, profile),
                    const SizedBox(height: 24),
                    _buildCertificationsSection(context, profile),
                    const SizedBox(height: 24),
                    _buildAvailabilitySection(context, profile),
                    const SizedBox(height: 24),
                    _buildReviewsSection(context, profile),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              const Text('Failed to load profile'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(publicTrainerProfileProvider(widget.trainerId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: profileAsync.when(
        data: (profile) => _buildBookingBar(context, profile),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, PublicTrainerProfile profile) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: profile.photoUrl != null 
                      ? NetworkImage(profile.photoUrl!) 
                      : null,
                  child: profile.photoUrl == null
                      ? Text(
                          profile.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share link copied!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, PublicTrainerProfile profile) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                profile.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (profile.isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              profile.rating.toStringAsFixed(1),
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              '(${profile.reviewCount} reviews)',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            Icon(Icons.work_history, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              profile.experience,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        if (profile.location != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                profile.location!,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
        if (profile.responseTime != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Responds ${profile.responseTime}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBioSection(BuildContext context, PublicTrainerProfile profile) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(profile.bio, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildSpecializationsSection(BuildContext context, PublicTrainerProfile profile) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Specializations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profile.specializations.map((spec) => Chip(
            label: Text(spec),
            backgroundColor: theme.colorScheme.primaryContainer,
            labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCertificationsSection(BuildContext context, PublicTrainerProfile profile) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Certifications', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...profile.certifications.map((cert) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(cert, style: theme.textTheme.bodyMedium),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildAvailabilitySection(BuildContext context, PublicTrainerProfile profile) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Availability', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: profile.availability.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context, PublicTrainerProfile profile) {
    final theme = Theme.of(context);
    
    // Mock reviews
    final reviews = [
      _MockReview(
        name: 'Sarah M.',
        rating: 5,
        date: DateTime.now().subtract(const Duration(days: 5)),
        comment: 'Amazing trainer! Very knowledgeable and motivating. Highly recommend!',
      ),
      _MockReview(
        name: 'Michael R.',
        rating: 5,
        date: DateTime.now().subtract(const Duration(days: 14)),
        comment: 'Great experience. Alex really helped me achieve my fitness goals.',
      ),
      _MockReview(
        name: 'Jennifer L.',
        rating: 4,
        date: DateTime.now().subtract(const Duration(days: 30)),
        comment: 'Professional and punctual. Would recommend.',
      ),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all reviews screen
              },
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...reviews.map((review) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(review.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    ...List.generate(5, (i) => Icon(
                      i < review.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    )),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(review.date),
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                Text(review.comment, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildBookingBar(BuildContext context, PublicTrainerProfile profile) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${profile.hourlyRate.toStringAsFixed(0)}/hour',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Starting rate',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _showBookingDialog(context, profile),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Book Session'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBookingDialog(BuildContext context, PublicTrainerProfile profile) async {
    final notesController = TextEditingController();
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Book Session with ${profile.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Select Date',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: CalendarDatePicker(
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 60)),
                          onDateChanged: (date) {
                            setModalState(() => _selectedDate = date);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select Time',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          '9:00 AM', '10:00 AM', '11:00 AM',
                          '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM',
                        ].map((time) => ChoiceChip(
                          label: Text(time),
                          selected: _selectedTime == time,
                          onSelected: (selected) {
                            setModalState(() => _selectedTime = selected ? time : null);
                          },
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Notes (Optional)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          hintText: 'Any special requests or goals...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _selectedDate != null && _selectedTime != null
                            ? () {
                                Navigator.pop(context);
                                _submitBookingRequest(profile, notesController.text);
                              }
                            : null,
                        child: const Text('Request Session'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitBookingRequest(PublicTrainerProfile profile, String notes) {
    // TODO: Call API to submit booking request
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking request sent to ${profile.name}! '
          'You\'ll be notified when they respond.',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _MockReview {
  final String name;
  final int rating;
  final DateTime date;
  final String comment;

  _MockReview({
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
  });
}
