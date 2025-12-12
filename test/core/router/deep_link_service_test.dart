import 'package:app_links/app_links.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/crashlytics/crashlytics_service.dart';
import 'package:personal_trainer_app/core/router/deep_link_service.dart';

// Mock classes
class MockGoRouter extends Mock implements GoRouter {}

class MockCrashlyticsService extends Mock implements CrashlyticsService {}

class MockAppLinks extends Mock implements AppLinks {
  @override
  Future<Uri?> getInitialAppLink() async => null;

  @override
  Stream<Uri> get uriLinkStream => Stream.empty();
}

void main() {
  group('DeepLinkService', () {
    late MockGoRouter mockRouter;
    late MockCrashlyticsService mockCrashlytics;
    late MockAppLinks mockAppLinks;
    late DeepLinkService deepLinkService;

    setUp(() {
      mockRouter = MockGoRouter();
      mockCrashlytics = MockCrashlyticsService();
      mockAppLinks = MockAppLinks();
    });

    group('Magic Link Verification Routes', () {
      test('routes to verify-magic-link with email and code', () {
        deepLinkService = DeepLinkService(
          appLinks: mockAppLinks,
          router: mockRouter,
          crashlytics: mockCrashlytics,
        );

        final uri = Uri.parse('https://example.com/auth/verify?email=test@example.com&code=123456');
        deepLinkService.handleDeepLink(uri);

        verify(
          () => mockRouter.go('/verify-magic-link?email=test@example.com&code=123456'),
        ).called(1);
      });

      test('routes to verify-magic-link with email only', () {
        deepLinkService = DeepLinkService(
          appLinks: mockAppLinks,
          router: mockRouter,
          crashlytics: mockCrashlytics,
        );

        final uri = Uri.parse('https://example.com/auth/verify?email=test@example.com');
        deepLinkService.handleDeepLink(uri);

        verify(
          () => mockRouter.go('/verify-magic-link?email=test@example.com'),
        ).called(1);
      });

      test('logs invalid link when email is missing', () {
        deepLinkService = DeepLinkService(
          appLinks: mockAppLinks,
          router: mockRouter,
          crashlytics: mockCrashlytics,
        );

        final uri = Uri.parse('https://example.com/auth/verify?code=123456');
        deepLinkService.handleDeepLink(uri);

        verify(
          () => mockCrashlytics.logMessage(any()),
        ).called(1);
      });
    });

    group('Workout Sharing Routes', () {
      test('routes to dashboard for workout sharing links', () {
        deepLinkService = DeepLinkService(
          appLinks: mockAppLinks,
          router: mockRouter,
          crashlytics: mockCrashlytics,
        );

        final uri = Uri.parse('https://example.com/workouts/share?id=workout123');
        deepLinkService.handleDeepLink(uri);

        verify(
          () => mockRouter.go('/dashboard'),
        ).called(1);
      });
    });

    group('Error Handling', () {
      test('handles unknown paths gracefully', () {
        deepLinkService = DeepLinkService(
          appLinks: mockAppLinks,
          router: mockRouter,
          crashlytics: mockCrashlytics,
        );

        final uri = Uri.parse('https://example.com/unknown/path');
        deepLinkService.handleDeepLink(uri);

        verify(
          () => mockCrashlytics.logMessage(any()),
        ).called(1);
      });

      test('handles null crashlytics service', () {
        deepLinkService = DeepLinkService(
          appLinks: mockAppLinks,
          router: mockRouter,
          crashlytics: null,
        );

        final uri = Uri.parse('https://example.com/unknown');

        expect(() => deepLinkService.handleDeepLink(uri), returnsNormally);
      });
    });

    group('Service Lifecycle', () {
      test('disposes resources on cleanup', () {
        deepLinkService = DeepLinkService(
          appLinks: mockAppLinks,
          router: mockRouter,
          crashlytics: mockCrashlytics,
        );

        expect(() => deepLinkService.dispose(), returnsNormally);
      });

      test('initializes without errors', () async {
        deepLinkService = DeepLinkService(
          appLinks: mockAppLinks,
          router: mockRouter,
          crashlytics: mockCrashlytics,
        );

        expect(() async => await deepLinkService.initialize(), returnsNormally);
      });
    });
  });
}
