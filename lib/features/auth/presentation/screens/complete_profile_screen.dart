import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/client_model.dart';
import '../../data/models/trainer_model.dart';
import '../providers/auth_state_provider.dart';
import '../providers/auth_repository_provider.dart';

/// Complete profile screen - user enters extended info after magic link verification.
///
/// Collects:
/// - First Name, Last Name
/// - Age / Date of Birth
/// - Weight (kg), Height (cm)
/// - Gender (optional)
///
/// User can skip and complete later.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  final String email;
  final String userType;

  const CompleteProfileScreen({
    required this.email,
    required this.userType,
    super.key,
  });

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _trainerCodeController;

  String? _selectedFitnessLevel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _ageController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _trainerCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _trainerCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      _showError('Please enter your first and last name');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      dynamic user;

      if (widget.userType == 'trainer') {
        // Validate trainer fields
        final specialty = _ageController.text.trim(); // Reusing age field for specialty
        if (specialty.isEmpty) {
          _showError('Please enter your specialty');
          setState(() => _isLoading = false);
          return;
        }

        final bio = _weightController.text.trim(); // Reusing weight field for bio

        // Register trainer
        final result = await authRepository.registerTrainer(
          email: widget.email,
          firstName: firstName,
          lastName: lastName,
          specialty: specialty,
          bio: bio.isNotEmpty ? bio : null,
        );

        result.fold(
          (failure) => throw Exception(failure.message),
          (trainer) => user = trainer,
        );
      } else if (widget.userType == 'client') {
        // Validate client fields
        final age = int.tryParse(_ageController.text.trim());
        if (age == null || age <= 0) {
          _showError('Please enter a valid age');
          setState(() => _isLoading = false);
          return;
        }

        final weightKg = double.tryParse(_weightController.text.trim());
        if (weightKg == null || weightKg <= 0) {
          _showError('Please enter a valid weight');
          setState(() => _isLoading = false);
          return;
        }

        final heightCm = double.tryParse(_heightController.text.trim());
        if (heightCm == null || heightCm <= 0) {
          _showError('Please enter a valid height');
          setState(() => _isLoading = false);
          return;
        }

        final fitnessLevel = _selectedFitnessLevel ?? 'beginner';
        final trainerCode = _trainerCodeController.text.trim();

        if (trainerCode.isEmpty) {
          _showError('Please enter your trainer code');
          setState(() => _isLoading = false);
          return;
        }

        // Register client
        final result = await authRepository.registerClient(
          email: widget.email,
          firstName: firstName,
          lastName: lastName,
          age: age,
          weightKg: weightKg,
          heightCm: heightCm,
          fitnessLevel: fitnessLevel,
          trainerCode: trainerCode,
        );

        result.fold(
          (failure) => throw Exception(failure.message),
          (client) => user = client,
        );
      }

      if (mounted) {
        print('✅ Profile saved: $firstName $lastName');

        // Update auth state with the new user
        ref.read(authStateProvider.notifier).state = user;

        // For trainers, show their unique code before navigating
        if (widget.userType == 'trainer' && user is TrainerModel) {
          await _showTrainerCodeDialog(user.trainerUniqueCode ?? 'N/A');
        }

        // Navigate to appropriate dashboard based on user type
        if (widget.userType == 'trainer') {
          context.go('/trainer/dashboard');
        } else if (widget.userType == 'client') {
          context.go('/client/dashboard');
        } else {
          context.go('/admin/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to save profile: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skipProfile() {
    // Navigate directly to dashboard without saving profile
    if (widget.userType == 'trainer') {
      context.go('/trainer/dashboard');
    } else if (widget.userType == 'client') {
      context.go('/client/dashboard');
    } else {
      context.go('/admin/dashboard');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _showTrainerCodeDialog(String trainerCode) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.celebration, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Welcome, Trainer!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your account has been created successfully!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Unique Trainer Code:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: SelectableText(
                  trainerCode,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share this code with your clients so they can link to you during registration.',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Tell us about yourself',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll use this info to personalize your experience',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Form fields
              // First Name
              TextField(
                controller: _firstNameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'First Name *',
                  hintText: 'John',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Last Name
              TextField(
                controller: _lastNameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Last Name *',
                  hintText: 'Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Role-specific fields
              if (widget.userType == 'trainer') ...[
                // Trainer: Specialty field
                TextField(
                  controller: _ageController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Specialization *',
                    hintText: 'e.g., Strength Training, Cardio, Flexibility',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Trainer: Bio field
                TextField(
                  controller: _weightController,
                  enabled: !_isLoading,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Bio (Optional)',
                    hintText: 'Tell clients about your experience and approach...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else if (widget.userType == 'client') ...[
                // Client: Age field
                TextField(
                  controller: _ageController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age *',
                    hintText: '25',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Client: Weight field
                TextField(
                  controller: _weightController,
                  enabled: !_isLoading,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Weight (kg) *',
                    hintText: '75',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Client: Height field
                TextField(
                  controller: _heightController,
                  enabled: !_isLoading,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Height (cm) *',
                    hintText: '180',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Client: Fitness level dropdown
                DropdownButtonFormField<String>(
                  value: _selectedFitnessLevel,
                  decoration: InputDecoration(
                    labelText: 'Fitness Level *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                    DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                    DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() => _selectedFitnessLevel = value);
                        },
                ),
                const SizedBox(height: 16),

                // Client: Trainer Code field
                TextField(
                  controller: _trainerCodeController,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Trainer Code *',
                    hintText: 'TRAINER-ABC123',
                    helperText: 'Enter the unique code provided by your trainer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Save button
              FilledButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Continue', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),

              // Skip button
              TextButton(
                onPressed: _isLoading ? null : _skipProfile,
                child: const Text('Skip for now'),
              ),
              const SizedBox(height: 16),

              // Info text
              Text(
                '* Required fields. You can update this later in your profile settings.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
