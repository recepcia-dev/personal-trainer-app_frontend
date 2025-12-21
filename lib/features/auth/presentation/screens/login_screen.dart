import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_provider.dart';

/// Login screen - user enters email to receive magic link.
///
/// Simple flow:
/// 1. User enters email
/// 2. Click "Send Magic Link"
/// 3. Navigate directly to verification screen
class LoginScreen extends ConsumerStatefulWidget {
  final String userType;

  const LoginScreen({super.key, required this.userType});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

    // Send magic link
    final success = await ref.read(authStateProvider.notifier).sendMagicLink(email, widget.userType);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Navigate directly to verification screen
      context.go('/verify?email=${Uri.encodeComponent(email)}&userType=${widget.userType}');
    } else {
      setState(() => _errorMessage = 'Failed to send magic link. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/role-selection')),
        title: const Text('Sign In'),
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
                "We'll send you a code to verify your identity",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

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

              // Send button
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
