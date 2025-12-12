import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'analytics_service.dart';

part 'analytics_service_provider.g.dart';

/// Provides a singleton instance of FirebaseAnalytics
@riverpod
FirebaseAnalytics firebaseAnalytics(FirebaseAnalyticsRef ref) =>
    FirebaseAnalytics.instance;

/// Provides a singleton instance of AnalyticsService
/// Initializes analytics on first access
@riverpod
Future<AnalyticsService> analyticsService(AnalyticsServiceRef ref) async {
  final firebaseAnalytics = ref.watch(firebaseAnalyticsProvider);
  final service = AnalyticsService(firebaseAnalytics: firebaseAnalytics);
  await service.initialize();
  return service;
}
