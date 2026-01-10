import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dev_config.dart';
import 'mock_providers.dart';

/// Development data seeding utilities
/// Pre-populates app with dummy data for testing UI/UX
abstract class DevDataSeeder {
  /// Seed all dummy data on app startup
  /// Accepts FlutterSecureStorage instance to ensure consistent storage access
  static Future<void> seedAll(FlutterSecureStorage storage) async {
    if (!DevConfig.seedDummyDataEnabled) {
      return;
    }

    try {
      DevLogger.info('Seeding development data...');

      // In dev mode, auto-select trainer role and save tokens for immediate API calls
      // This ensures the Authorization header is present on first API request
      // before the user interacts with the dev toolbar
      if (DevConfig.mockAuthEnabled) {
        await _initializeDevAuthTokens(storage);
      }

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

  /// Initialize dev auth tokens by auto-selecting trainer role
  /// This ensures tokens are available for API calls without user interaction
  /// before the user interacts with the dev toolbar
  ///
  /// CRITICAL: Use the same FlutterSecureStorage instance as TokenProvider
  /// to avoid sync issues between writes and reads
  static Future<void> _initializeDevAuthTokens(FlutterSecureStorage storage) async {
    try {
      DevLogger.info('');
      DevLogger.info('═══════════════════════════════════════════════════════════════');
      DevLogger.info('🔐 [DevDataSeeder] INITIALIZING DEV AUTH TOKENS');
      DevLogger.info('═══════════════════════════════════════════════════════════════');

      // Save trainer tokens as default for dev mode
      // Use the generated dev JWT tokens from DevTokens
      final accessTokenLength = DevTokens.trainerAccessToken.length;
      final refreshTokenLength = DevTokens.trainerRefreshToken.length;

      DevLogger.info('📝 [DevDataSeeder] Access token to save: $accessTokenLength characters');
      DevLogger.info('   Preview: ${DevTokens.trainerAccessToken.substring(0, 30)}...');
      DevLogger.info('🔐 [DevDataSeeder] Writing accessToken to secure storage...');

      await storage.write(
        key: 'accessToken',
        value: DevTokens.trainerAccessToken,
      );
      DevLogger.success('✅ [DevDataSeeder] accessToken written successfully');

      DevLogger.info('📝 [DevDataSeeder] Refresh token to save: $refreshTokenLength characters');
      DevLogger.info('🔐 [DevDataSeeder] Writing refreshToken to secure storage...');

      await storage.write(
        key: 'refreshToken',
        value: DevTokens.trainerRefreshToken,
      );
      DevLogger.success('✅ [DevDataSeeder] refreshToken written successfully');

      // Verify tokens were saved
      DevLogger.info('🔍 [DevDataSeeder] Verifying tokens were persisted...');
      final savedAccessToken = await storage.read(key: 'accessToken');
      final savedRefreshToken = await storage.read(key: 'refreshToken');

      if (savedAccessToken != null && savedAccessToken.isNotEmpty) {
        DevLogger.success(
          '✅ [DevDataSeeder] accessToken verified (${savedAccessToken.length} chars)',
        );
      } else {
        DevLogger.warning(
          '❌ [DevDataSeeder] accessToken NOT found after write! This is a critical issue.',
        );
      }

      if (savedRefreshToken != null && savedRefreshToken.isNotEmpty) {
        DevLogger.success(
          '✅ [DevDataSeeder] refreshToken verified (${savedRefreshToken.length} chars)',
        );
      } else {
        DevLogger.warning(
          '❌ [DevDataSeeder] refreshToken NOT found after write! This is a critical issue.',
        );
      }

      if (savedAccessToken != null &&
          savedAccessToken.isNotEmpty &&
          savedRefreshToken != null &&
          savedRefreshToken.isNotEmpty) {
        DevLogger.success(
          '✅ [DevDataSeeder] All dev auth tokens initialized successfully!',
        );
      } else {
        DevLogger.error(
          '❌ [DevDataSeeder] Token persistence failed - tokens cannot be read back!',
        );
      }

      DevLogger.info('═══════════════════════════════════════════════════════════════');
      DevLogger.info('');
    } catch (e, stackTrace) {
      DevLogger.error('❌ [DevDataSeeder] Exception during token initialization: $e');
      DevLogger.error('   Stack trace: $stackTrace');
      // Non-critical, app can still run without tokens
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
  /// Uses properly configured storage instance to avoid keychain issues
  static Future<void> reseedAll() async {
    await clearAll();
    // Use properly configured storage instance (same as main_dev.dart)
    const storage = FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    await seedAll(storage);
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
