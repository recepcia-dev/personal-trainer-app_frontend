import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_provider.dart';

/// Signup email screen - collects email during signup flow.
///
/// Flow:
/// 1. User selects role (trainer/client) on previous screen
/// 2. User enters email
/// 3. Submit sends magic link with is_signup=true and selected role
class SignupEmailScreen extends ConsumerStatefulWidget {
  final String userType;

  const SignupEmailScreen({super.key, required this.userType});

  @override
  ConsumerState<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends ConsumerState<SignupEmailScreen> {
  final _emailController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();

    // Validate
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Email is required');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Please enter a valid email');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Send magic link - for signup flow with user_type
    final success = await ref.read(authStateProvider.notifier).sendMagicLink(
          email,
          widget.userType,
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Navigate to verification screen - includes user type from signup
      context.go(
        '/verify?email=${Uri.encodeComponent(email)}&userType=${widget.userType}&isSignup=true',
      );
    } else {
      setState(() => _errorMessage = 'Failed to create account. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/signup-role')),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Header
              Text(
                'Enter your email',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We'll send you a code to verify your email",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Role display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.userType == 'trainer'
                          ? Icons.sports
                          : Icons.person,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Signing up as ${widget.userType == 'trainer' ? 'Trainer' : 'Client'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Email field
              TextField(
                controller: _emailController,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _errorMessage,
                ),
                onSubmitted: (_) => _sendMagicLink(),
              ),
              const SizedBox(height: 24),

              // Create account button
              FilledButton(
                onPressed: _isLoading ? null : _sendMagicLink,
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Magic Link', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
