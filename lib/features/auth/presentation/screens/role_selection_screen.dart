import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/role_selection_provider.dart';

/// Screen for user to select their role (Trainer or Client)
class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const SizedBox(height: 32),
              Text(
                'Are you a trainer or client?',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Select your role to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),

              // Trainer Button
              ElevatedButton.icon(
                onPressed: () {
                  print('🔐 Trainer button pressed');
                  // Defer the ref operations to after frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(authProvider.notifier).logout();
                    ref.read(roleSelectionProvider.notifier).state = 'trainer';
                    print('🔐 Role set to trainer');
                  });
                  // Navigate immediately (don't await)
                  print('🔐 Navigating to login');
                  context.goNamed('login');
                },
                icon: const Icon(Icons.person),
                label: const Text('I\'m a Trainer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 60),
                ),
              ),
              const SizedBox(height: 16),

              // Client Button
              ElevatedButton.icon(
                onPressed: () {
                  print('🔐 Client button pressed');
                  // Defer the ref operations to after frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(authProvider.notifier).logout();
                    ref.read(roleSelectionProvider.notifier).state = 'client';
                    print('🔐 Role set to client');
                  });
                  // Navigate immediately (don't await)
                  print('🔐 Navigating to login');
                  context.goNamed('login');
                },
                icon: const Icon(Icons.person),
                label: const Text('I\'m a Client'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
