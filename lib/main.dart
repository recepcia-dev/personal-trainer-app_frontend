import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';

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
  Widget build(BuildContext context) =>
    MaterialApp(
      title: 'Personal Trainer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Personal Trainer App - Coming Soon'),
        ),
      ),
    );
}
