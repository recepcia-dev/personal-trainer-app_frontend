import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

import '../crashlytics/crashlytics_service.dart';

/// Service for handling deep links from URLs
/// Supports both cold start (initial app link) and warm start (incoming link)
class DeepLinkService {
  final AppLinks _appLinks;
  final GoRouter _router;
  final CrashlyticsService? _crashlytics;

  StreamSubscription<Uri>? _linkSubscription;

  DeepLinkService({
    required AppLinks appLinks,
    required GoRouter router,
    CrashlyticsService? crashlytics,
  })  : _appLinks = appLinks,
        _router = router,
        _crashlytics = crashlytics;

  /// Initialize the deep link service
  /// Handles initial link on app startup and listens for incoming links
  Future<void> initialize() async {
    try {
      // Handle initial link (cold start - app not running when link clicked)
      // app_links.getInitialLink() requires checking if the app was launched from a link
      try {
        final initialLink = await _appLinks.getInitialAppLink();
        if (initialLink != null) {
          handleDeepLink(initialLink);
        }
      } catch (e) {
        // getInitialAppLink might not be available on all versions
        // Try alternative approach
        _crashlytics?.logMessage('Note: getInitialAppLink not available');
      }

      // Listen for links while app is running (warm start)
      _linkSubscription = _appLinks.uriLinkStream.listen(
        handleDeepLink,
        onError: (error) {
          _crashlytics?.recordError(
            error as Exception,
            StackTrace.current,
            reason: 'Error in deep link stream listener',
          );
        },
      );
    } catch (error, stackTrace) {
      _crashlytics?.recordError(
        error as Exception,
        stackTrace,
        reason: 'Error initializing deep link service',
      );
    }
  }

  /// Handle incoming deep link URI (public for testing)
  void handleDeepLink(Uri uri) {
    try {
      _routeFromUri(uri);
    } catch (error, stackTrace) {
      _crashlytics?.recordError(
        error as Exception,
        stackTrace,
        reason: 'Error handling deep link: $uri',
      );
    }
  }

  /// Parse URI and route to appropriate screen
  void _routeFromUri(Uri uri) {
    // Handle magic link verification: /auth/verify?email=X&code=Y
    if (uri.path == '/auth/verify') {
      final email = uri.queryParameters['email'];
      final code = uri.queryParameters['code'];

      if (email != null && code != null) {
        // Navigate to verify magic link screen with email and code
        _router.go(
          '/verify-magic-link?email=$email&code=$code',
        );
      } else if (email != null) {
        // If code is missing, just navigate to verify screen
        _router.go(
          '/verify-magic-link?email=$email',
        );
      } else {
        // Invalid: no email provided
        _logInvalidLink(uri);
      }
    }
    // Handle workout sharing: /workouts/share?id=X
    else if (uri.path == '/workouts/share') {
      final workoutId = uri.queryParameters['id'];
      if (workoutId != null) {
        // Route to workout detail screen (feature for later)
        // For now, just navigate to dashboard
        _router.go('/dashboard');
      } else {
        _logInvalidLink(uri);
      }
    }
    // Unknown path - log and ignore
    else {
      _logInvalidLink(uri);
    }
  }

  /// Log invalid link for debugging
  void _logInvalidLink(Uri uri) {
    _crashlytics?.logMessage(
      'Invalid deep link: $uri - missing required parameters',
    );
  }

  /// Cleanup resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}
