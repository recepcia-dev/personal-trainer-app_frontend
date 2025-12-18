import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/client.dart';
import '../providers/client_provider.dart';

/// Form widget for editing client information
class ClientEditForm extends ConsumerStatefulWidget {
  final Client client;
  final VoidCallback onSaved;

  const ClientEditForm({
    required this.client,
    required this.onSaved,
    super.key,
  });

  @override
  ConsumerState<ClientEditForm> createState() => _ClientEditFormState();
}

class _ClientEditFormState extends ConsumerState<ClientEditForm> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _goalsController;
  late TextEditingController _notesController;

  String? _selectedFitnessLevel;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.client.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.client.lastName ?? '');
    _phoneController = TextEditingController(text: widget.client.phone ?? '');
    _ageController = TextEditingController(text: widget.client.age?.toString() ?? '');
    _goalsController = TextEditingController(text: widget.client.goals ?? '');
    _notesController = TextEditingController(text: widget.client.notes ?? '');
    _selectedFitnessLevel = widget.client.fitnessLevel;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _goalsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Client',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // First name
        TextField(
          controller: _firstNameController,
          decoration: InputDecoration(
            labelText: 'First Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 12),

        // Last name
        TextField(
          controller: _lastNameController,
          decoration: InputDecoration(
            labelText: 'Last Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 12),

        // Phone
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),

        // Age
        TextField(
          controller: _ageController,
          decoration: InputDecoration(
            labelText: 'Age',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.cake),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),

        // Fitness level
        DropdownButtonFormField<String>(
          value: _selectedFitnessLevel,
          decoration: InputDecoration(
            labelText: 'Fitness Level',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.fitness_center),
          ),
          items: const [
            DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
            DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
            DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
          ],
          onChanged: (value) => setState(() => _selectedFitnessLevel = value),
        ),
        const SizedBox(height: 12),

        // Goals
        TextField(
          controller: _goalsController,
          decoration: InputDecoration(
            labelText: 'Goals',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.flag),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),

        // Notes
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.note),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => widget.onSaved(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitForm,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSubmitting ? 'Saving...' : 'Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    try {
      await ref.read(updateClientNotifierProvider.notifier).updateClient(
        widget.client.id,
        firstName: _firstNameController.text.isNotEmpty
            ? _firstNameController.text
            : null,
        lastName: _lastNameController.text.isNotEmpty
            ? _lastNameController.text
            : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        age: _ageController.text.isNotEmpty
            ? int.tryParse(_ageController.text)
            : null,
        fitnessLevel: _selectedFitnessLevel,
        goals:
            _goalsController.text.isNotEmpty ? _goalsController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }
}
