import 'package:flutter/foundation.dart';

import 'dev_config.dart';

/// Development data seeding utilities
/// Pre-populates app with dummy data for testing UI/UX
abstract class DevDataSeeder {
  /// Seed all dummy data on app startup
  static Future<void> seedAll() async {
    if (!DevConfig.seedDummyDataEnabled) {
      return;
    }

    try {
      DevLogger.info('Seeding development data...');

      // Add seeding operations here as you build features
      // Example:
      // await seedTrainers();
      // await seedClients();
      // await seedWorkouts();
      // await seedExercises();

      DevLogger.success('Development data seeded successfully');
    } catch (e) {
      DevLogger.error('Failed to seed dev data: $e');
    }
  }

  /// Clear all seeded data
  static Future<void> clearAll() async {
    try {
      DevLogger.info('Clearing development data...');

      // Add clearing operations here
      // Example:
      // await clearTrainers();
      // await clearClients();
      // await clearWorkouts();

      DevLogger.success('Development data cleared successfully');
    } catch (e) {
      DevLogger.error('Failed to clear dev data: $e');
    }
  }

  /// Reseed all data (clear then seed)
  static Future<void> reseedAll() async {
    await clearAll();
    await seedAll();
  }
}

// Example seeding functions (uncomment as you build features)

/// Seed dummy trainers
// Future<void> seedTrainers() async {
//   final db = await AppDatabase.open();
//
//   const trainers = [
//     TrainerCompanion.insert(
//       id: 'dev-trainer-001',
//       name: 'John Trainer',
//       email: 'trainer@test.local',
//       uniqueCode: 'TRAINER001',
//       specialty: 'CrossFit & Strength',
//     ),
//     TrainerCompanion.insert(
//       id: 'dev-trainer-002',
//       name: 'Sarah Coach',
//       email: 'coach@test.local',
//       uniqueCode: 'TRAINER002',
//       specialty: 'Yoga & Flexibility',
//     ),
//   ];
//
//   await db.batch((batch) {
//     batch.insertAll(db.trainers, trainers);
//   });
//
//   DevLogger.info('Seeded ${trainers.length} trainers');
// }

/// Seed dummy clients
// Future<void> seedClients() async {
//   final db = await AppDatabase.open();
//
//   const clients = [
//     ClientCompanion.insert(
//       id: 'dev-client-001',
//       name: 'Jane Client',
//       email: 'client@test.local',
//       trainerId: 'dev-trainer-001',
//       fitnessLevel: 'Intermediate',
//     ),
//     ClientCompanion.insert(
//       id: 'dev-client-002',
//       name: 'Mike Fitness',
//       email: 'mike@test.local',
//       trainerId: 'dev-trainer-001',
//       fitnessLevel: 'Beginner',
//     ),
//   ];
//
//   await db.batch((batch) {
//     batch.insertAll(db.clients, clients);
//   });
//
//   DevLogger.info('Seeded ${clients.length} clients');
// }

/// Seed dummy workouts
// Future<void> seedWorkouts() async {
//   final db = await AppDatabase.open();
//
//   // Create sample workouts with exercises
//   // Example structure:
//   // Workout 1: "Upper Body Strength"
//   //   - Bench Press (4 sets x 6 reps)
//   //   - Bent Over Rows (4 sets x 6 reps)
//   //   - Pull-ups (3 sets x 8 reps)
//
//   DevLogger.info('Seeded sample workouts');
// }

/// Seed dummy exercises
// Future<void> seedExercises() async {
//   final db = await AppDatabase.open();
//
//   // Create exercise library with common exercises
//   // Strength exercises, cardio, stretching, etc.
//
//   DevLogger.info('Seeded exercise library');
// }

/// Print development data seeding guide
void printDevDataGuide() {
  if (!kDebugMode) return;

  debugPrint('');
  debugPrint('╔════════════════════════════════════════════╗');
  debugPrint('║     DEVELOPMENT DATA SEEDING GUIDE          ║');
  debugPrint('╚════════════════════════════════════════════╝');
  debugPrint('');
  debugPrint('To enable automatic data seeding:');
  debugPrint('  1. Edit lib/core/dev/dev_config.dart');
  debugPrint('  2. Set seedDummyDataEnabled = true');
  debugPrint('  3. Uncomment seeding functions below');
  debugPrint('  4. Run: flutter pub run build_runner build');
  debugPrint('  5. Launch app with flutter run -t lib/main_dev.dart');
  debugPrint('');
  debugPrint('To reseed data while app is running:');
  debugPrint('  DevDataSeeder.reseedAll()');
  debugPrint('');
  debugPrint('To clear all dev data:');
  debugPrint('  DevDataSeeder.clearAll()');
  debugPrint('');
}
