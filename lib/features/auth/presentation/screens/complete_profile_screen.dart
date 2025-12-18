import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_provider.dart';

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

  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _ageController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
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
      // TODO: Call API to update user profile
      // For now, just navigate to dashboard
      print('✅ Profile saved: $firstName $lastName');

      if (mounted) {
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
        _showError('Failed to save profile: $e');
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

              // Age
              TextField(
                controller: _ageController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  hintText: '25',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffix: const Text('years'),
                ),
              ),
              const SizedBox(height: 16),

              // Weight
              TextField(
                controller: _weightController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Weight',
                  hintText: '75',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffix: const Text('kg'),
                ),
              ),
              const SizedBox(height: 16),

              // Height
              TextField(
                controller: _heightController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Height',
                  hintText: '180',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffix: const Text('cm'),
                ),
              ),
              const SizedBox(height: 16),

              // Gender dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                  DropdownMenuItem(value: 'prefer_not', child: Text('Prefer not to say')),
                ],
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _selectedGender = value);
                      },
              ),
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
