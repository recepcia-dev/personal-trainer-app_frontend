import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_provider.dart';

/// Login screen with passwordless authentication via magic link.
///
/// Users enter their email, receive a magic link, and verify the code
/// in the next screen. This unified screen works for both trainers and clients.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  bool _emailSubmitted = false;
  String? _emailErrorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Handle sending magic link
  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();

    // Clear previous error
    setState(() {
      _emailErrorMessage = null;
    });

    // Validate email
    if (email.isEmpty) {
      setState(() {
        _emailErrorMessage = 'Email is required';
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _emailErrorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _emailSubmitted = true;
    });

    // Call sendMagicLink on auth state provider
    await ref.read(authStateProvider.notifier).sendMagicLink(email: email);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Watch for state changes to navigate or show error messages
    ref.listen<AsyncValue<dynamic>>(
      authStateProvider,
      (previous, next) {
        next.whenData((_) {
          // Magic link sent successfully - navigate to verification screen
          if (_emailSubmitted) {
            final email = _emailController.text.trim();
            context.push('/verify-magic-link?email=${Uri.encodeComponent(email)}');
          }
        });
        next.maybeWhen(
          error: (error, stack) {
            // Error sending magic link
            setState(() {
              _emailSubmitted = false;
              _emailErrorMessage = error.toString();
            });
            _showErrorMessage(context, error.toString());
          },
          orElse: () {},
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: 32),
                Text(
                  'Sign In',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your email to receive a magic link',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 48),

                // Email input field
                TextField(
                  controller: _emailController,
                  enabled: !authState.isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                    errorText: _emailErrorMessage,
                    errorMaxLines: 2,
                  ),
                  onSubmitted: (_) {
                    if (!authState.isLoading) {
                      _sendMagicLink();
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Send Magic Link button or loading indicator
                if (authState.isLoading)
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Sending magic link...',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _sendMagicLink,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Send Magic Link',
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

  /// Show success message to user
  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Check your email for the magic link'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show error message to user
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
