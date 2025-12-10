import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.load();

  runApp(
    const ProviderScope(
      child: PersonalTrainerApp(),
    ),
  );
}

class PersonalTrainerApp extends StatelessWidget {
  const PersonalTrainerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Personal Trainer App',
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(
            child: Text('Personal Trainer App - Coming Soon'),
          ),
        ),
      );
}
