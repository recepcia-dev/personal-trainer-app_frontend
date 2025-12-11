import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
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
            onPressed: () => context.go('/dashboard'),
            child: const Text('Go to Dashboard'),
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
