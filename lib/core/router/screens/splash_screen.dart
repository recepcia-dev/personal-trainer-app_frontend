import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Personal Trainer App',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    ),
  );
}
