import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.load();

  // Initialize theme persistence
  final container = ProviderContainer();
  await container.read(themeModeProvider.notifier).initialize();

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith(
          (ref) => ThemeModeNotifier(),
        ),
      ],
      child: const PersonalTrainerApp(),
    ),
  );
}

class PersonalTrainerApp extends ConsumerWidget {
  const PersonalTrainerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp(
        title: 'Personal Trainer App',
        theme: AppTheme.light(colorScheme: lightDynamic),
        darkTheme: AppTheme.dark(colorScheme: darkDynamic),
        themeMode: themeMode,
        home: const _HomeScreen(),
      ),
    );
  }
}

class _HomeScreen extends ConsumerWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Personal Trainer App - Coming Soon'),
            const SizedBox(height: 16),
            Text('Current Theme: ${_getThemeModeName(themeMode)}'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await ref.read(themeModeProvider.notifier).setLightMode();
              },
              child: const Text('Light Mode'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await ref.read(themeModeProvider.notifier).setDarkMode();
              },
              child: const Text('Dark Mode'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await ref.read(themeModeProvider.notifier).setSystemMode();
              },
              child: const Text('System Mode'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await ref.read(themeModeProvider.notifier).toggleTheme();
              },
              child: const Text('Toggle Theme'),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System',
  };
}
