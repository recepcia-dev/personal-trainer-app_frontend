import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'crashlytics_service.dart';

part 'crashlytics_service_provider.g.dart';

/// Provides a singleton instance of FirebaseCrashlytics
@riverpod
FirebaseCrashlytics firebaseCrashlytics(FirebaseCrashlyticsRef ref) =>
    FirebaseCrashlytics.instance;

/// Provides a singleton instance of CrashlyticsService
/// Initializes Crashlytics on first access
@riverpod
Future<CrashlyticsService> crashlyticsService(CrashlyticsServiceRef ref) async {
  final firebaseCrashlytics = ref.watch(firebaseCrashlyticsProvider);
  final service = CrashlyticsService(
    firebaseCrashlytics: firebaseCrashlytics,
  );
  await service.initialize();
  return service;
}

/// Provides easy access to CrashlyticsService for logging crashes
/// This is a convenience provider that assumes Crashlytics has been initialized
@riverpod
CrashlyticsService crashlytics(CrashlyticsRef ref) {
  final firebaseCrashlytics = ref.watch(firebaseCrashlyticsProvider);
  return CrashlyticsService(firebaseCrashlytics: firebaseCrashlytics);
}
