import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/analytics/analytics_service_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/crashlytics/crashlytics_service_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.load();

  // Initialize theme persistence
  final container = ProviderContainer();
  await container.read(themeModeProvider.notifier).initialize();

  // Initialize analytics service
  await container.read(analyticsServiceProvider.future);

  // Initialize Crashlytics service
  await container.read(crashlyticsServiceProvider.future);

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

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp.router(
        title: 'Personal Trainer App',
        theme: AppTheme.light(colorScheme: lightDynamic),
        darkTheme: AppTheme.dark(colorScheme: darkDynamic),
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
