import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_repository_provider.dart';
import '../providers/auth_state_provider.dart';

/// Trainer complete profile screen - collects trainer-specific information after signup
class TrainerCompleteProfileScreen extends ConsumerStatefulWidget {
  final String email;

  const TrainerCompleteProfileScreen({
    required this.email,
    super.key,
  });

  @override
  ConsumerState<TrainerCompleteProfileScreen> createState() =>
      _TrainerCompleteProfileScreenState();
}

class _TrainerCompleteProfileScreenState
    extends ConsumerState<TrainerCompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _specialtyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);

      final result = await repository.registerTrainer(
        email: widget.email,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        specialty: _specialtyController.text.trim(),
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isLoading = false);
          }
        },
        (trainer) {
          // Update auth state with the registered trainer using proper Riverpod API
          ref.read(authStateProvider.notifier).setUser(trainer);

          if (mounted) {
            // Navigate to trainer dashboard
            context.go('/trainer-dashboard');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome, Trainer!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let your clients know who you are',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Specialty
                TextFormField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(
                    labelText: 'Specialty',
                    prefixIcon: Icon(Icons.fitness_center),
                    border: OutlineInputBorder(),
                    helperText:
                        'e.g., Strength Training, Yoga, CrossFit, Nutrition',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your specialty';
                    }
                    if (value.trim().length < 3) {
                      return 'Specialty must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bio (Optional)
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio (Optional)',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                    helperText:
                        'Tell clients about your experience and approach',
                  ),
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        value.trim().length < 20) {
                      return 'Bio should be at least 20 characters or left empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                FilledButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Complete Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),

                // Info Card
                Card(
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'What happens next?',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• You\'ll receive a unique trainer code\n'
                          '• Share this code with your clients\n'
                          '• Clients use your code to connect with you\n'
                          '• Start creating personalized workouts and meal plans',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
