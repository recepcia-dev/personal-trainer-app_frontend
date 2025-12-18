import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Only load .env on native platforms (mobile/desktop)
  // Web uses hardcoded localhost:8000
  if (!kIsWeb) {
    try {
      await AppConstants.load();
    } catch (e) {
      debugPrint('Failed to load app constants: $e');
    }
  }

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
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Personal Trainer App',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
