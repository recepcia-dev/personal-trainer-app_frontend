import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('Dashboard'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Dashboard Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Call logout on auth provider
              ref.read(authProvider.notifier).logout();
              // After logout, router redirect will automatically navigate to login
            },
            child: const Text('Logout'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/splash'),
            child: const Text('Go to Splash'),
          ),
        ],
      ),
    ),
  );
}
