import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.load();

  runApp(
    const ProviderScope(
      child: PersonalTrainerApp(),
    ),
  );
}

class PersonalTrainerApp extends ConsumerWidget {
  const PersonalTrainerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Personal Trainer App',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends ConsumerWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Personal Trainer App - Coming Soon'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
                child: const Text('Toggle Theme'),
              ),
            ],
          ),
        ),
      );
}
