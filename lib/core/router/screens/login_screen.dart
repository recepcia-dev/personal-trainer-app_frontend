import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('Login'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Login Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Call login on auth provider
              ref.read(authProvider.notifier).login();
              // After login, router redirect will automatically navigate to dashboard
            },
            child: const Text('Login'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/splash'),
            child: const Text('Back to Splash'),
          ),
        ],
      ),
    ),
  );
}
