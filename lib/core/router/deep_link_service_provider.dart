import 'package:app_links/app_links.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../crashlytics/crashlytics_service_provider.dart';
import 'app_router.dart';
import 'deep_link_service.dart';

part 'deep_link_service_provider.g.dart';

/// Riverpod provider for DeepLinkService
/// Keeps the service alive for the app lifetime
@Riverpod(keepAlive: true)
Future<DeepLinkService> deepLinkService(DeepLinkServiceRef ref) async {
  // Get dependencies
  final router = ref.watch(routerProvider);
  final crashlytics = await ref.watch(crashlyticsServiceProvider.future);

  // Create service
  final service = DeepLinkService(
    appLinks: AppLinks(),
    router: router,
    crashlytics: crashlytics,
  );

  // Initialize on first access
  await service.initialize();

  // Cleanup on disposal
  ref.onDispose(() => service.dispose());

  return service;
}
