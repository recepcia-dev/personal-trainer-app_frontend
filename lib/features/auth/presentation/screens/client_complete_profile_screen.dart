import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_repository_provider.dart';
import '../providers/auth_state_provider.dart';

/// Client complete profile screen - collects client-specific information after signup
class ClientCompleteProfileScreen extends ConsumerStatefulWidget {
  final String email;

  const ClientCompleteProfileScreen({
    required this.email,
    super.key,
  });

  @override
  ConsumerState<ClientCompleteProfileScreen> createState() =>
      _ClientCompleteProfileScreenState();
}

class _ClientCompleteProfileScreenState
    extends ConsumerState<ClientCompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _trainerCodeController = TextEditingController();

  String _selectedFitnessLevel = 'beginner';
  bool _isLoading = false;

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

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);

      final result = await repository.registerClient(
        email: widget.email,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        weightKg: double.parse(_weightController.text.trim()),
        heightCm: double.parse(_heightController.text.trim()),
        fitnessLevel: _selectedFitnessLevel,
        trainerCode: _trainerCodeController.text.trim(),
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
        (client) {
          // Update auth state with the registered client using proper Riverpod API
          ref.read(authStateProvider.notifier).setUser(client);

          if (mounted) {
            // Navigate to client dashboard
            context.go('/client-dashboard');
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
                  'Tell us about yourself',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This helps your trainer create personalized workouts',
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Age
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                    suffixText: 'years',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value.trim());
                    if (age == null || age < 13 || age > 120) {
                      return 'Please enter a valid age (13-120)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Weight
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    prefixIcon: Icon(Icons.monitor_weight),
                    border: OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your weight';
                    }
                    final weight = double.tryParse(value.trim());
                    if (weight == null || weight < 20 || weight > 300) {
                      return 'Please enter a valid weight (20-300 kg)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Height
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    prefixIcon: Icon(Icons.height),
                    border: OutlineInputBorder(),
                    suffixText: 'cm',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your height';
                    }
                    final height = double.tryParse(value.trim());
                    if (height == null || height < 100 || height > 250) {
                      return 'Please enter a valid height (100-250 cm)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Fitness Level
                DropdownButtonFormField<String>(
                  value: _selectedFitnessLevel,
                  decoration: const InputDecoration(
                    labelText: 'Fitness Level',
                    prefixIcon: Icon(Icons.fitness_center),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'beginner',
                      child: Text('Beginner - New to fitness'),
                    ),
                    DropdownMenuItem(
                      value: 'intermediate',
                      child: Text('Intermediate - Some experience'),
                    ),
                    DropdownMenuItem(
                      value: 'advanced',
                      child: Text('Advanced - Very experienced'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFitnessLevel = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Trainer Code
                TextFormField(
                  controller: _trainerCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Trainer Code',
                    prefixIcon: Icon(Icons.qr_code),
                    border: OutlineInputBorder(),
                    helperText: 'Enter the code provided by your trainer',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your trainer code';
                    }
                    if (value.trim().length < 4) {
                      return 'Trainer code must be at least 4 characters';
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
