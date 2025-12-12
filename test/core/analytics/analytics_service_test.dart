import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/analytics/analytics_service.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  group('AnalyticsService', () {
    late MockFirebaseAnalytics mockFirebaseAnalytics;
    late AnalyticsService analyticsService;

    setUp(() {
      mockFirebaseAnalytics = MockFirebaseAnalytics();
      analyticsService = AnalyticsService(
        firebaseAnalytics: mockFirebaseAnalytics,
      );
    });

    test('initialize completes successfully', () async {
      expect(
        analyticsService.initialize(),
        completes,
      );
    });

    group('logScreenView', () {
      test('logs screen view with screen name only', () async {
        when(
          () => mockFirebaseAnalytics.logScreenView(
            screenName: 'dashboard',
            screenClass: null,
          ),
        ).thenAnswer((_) async {});

        await analyticsService.logScreenView(screenName: 'dashboard');

        verify(
          () => mockFirebaseAnalytics.logScreenView(
            screenName: 'dashboard',
            screenClass: null,
          ),
        ).called(1);
      });

      test('logs screen view with screen name and class', () async {
        when(
          () => mockFirebaseAnalytics.logScreenView(
            screenName: 'dashboard',
            screenClass: 'DashboardScreen',
          ),
        ).thenAnswer((_) async {});

        await analyticsService.logScreenView(
          screenName: 'dashboard',
          screenClass: 'DashboardScreen',
        );

        verify(
          () => mockFirebaseAnalytics.logScreenView(
            screenName: 'dashboard',
            screenClass: 'DashboardScreen',
          ),
        ).called(1);
      });

      test('handles exceptions gracefully', () async {
        when(
          () => mockFirebaseAnalytics.logScreenView(
            screenName: any(named: 'screenName'),
            screenClass: any(named: 'screenClass'),
          ),
        ).thenThrow(Exception('Firebase error'));

        // Should not throw even if Firebase throws
        expect(
          analyticsService.logScreenView(screenName: 'dashboard'),
          completes,
        );
      });
    });

    group('logEvent', () {
      test('logs custom event without parameters', () async {
        when(
          () => mockFirebaseAnalytics.logEvent(
            name: 'workout_created',
            parameters: null,
          ),
        ).thenAnswer((_) async {});

        await analyticsService.logEvent(name: 'workout_created');

        verify(
          () => mockFirebaseAnalytics.logEvent(
            name: 'workout_created',
            parameters: null,
          ),
        ).called(1);
      });

      test('logs custom event with parameters', () async {
        final parameters = {
          'workout_id': 'w123',
          'workout_name': 'Morning Run',
        };

        when(
          () => mockFirebaseAnalytics.logEvent(
            name: 'workout_created',
            parameters: parameters,
          ),
        ).thenAnswer((_) async {});

        await analyticsService.logEvent(
          name: 'workout_created',
          parameters: parameters,
        );

        verify(
          () => mockFirebaseAnalytics.logEvent(
            name: 'workout_created',
            parameters: parameters,
          ),
        ).called(1);
      });

      test('handles exceptions gracefully', () async {
        when(
          () => mockFirebaseAnalytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          ),
        ).thenThrow(Exception('Firebase error'));

        expect(
          analyticsService.logEvent(name: 'event'),
          completes,
        );
      });
    });

    group('setUserProperty', () {
      test('sets user property successfully', () async {
        when(
          () => mockFirebaseAnalytics.setUserProperty(
            name: 'user_type',
            value: 'trainer',
          ),
        ).thenAnswer((_) async {});

        await analyticsService.setUserProperty(
          name: 'user_type',
          value: 'trainer',
        );

        verify(
          () => mockFirebaseAnalytics.setUserProperty(
            name: 'user_type',
            value: 'trainer',
          ),
        ).called(1);
      });

      test('handles exceptions gracefully', () async {
        when(
          () => mockFirebaseAnalytics.setUserProperty(
            name: any(named: 'name'),
            value: any(named: 'value'),
          ),
        ).thenThrow(Exception('Firebase error'));

        expect(
          analyticsService.setUserProperty(
            name: 'user_type',
            value: 'trainer',
          ),
          completes,
        );
      });
    });

    group('setUserId', () {
      test('sets user ID successfully', () async {
        when(
          () => mockFirebaseAnalytics.setUserId(id: 'user123'),
        ).thenAnswer((_) async {});

        await analyticsService.setUserId('user123');

        verify(
          () => mockFirebaseAnalytics.setUserId(id: 'user123'),
        ).called(1);
      });

      test('handles exceptions gracefully', () async {
        when(
          () => mockFirebaseAnalytics.setUserId(id: any(named: 'id')),
        ).thenThrow(Exception('Firebase error'));

        expect(
          analyticsService.setUserId('user123'),
          completes,
        );
      });
    });

    group('clearUserId', () {
      test('clears user ID successfully', () async {
        when(
          () => mockFirebaseAnalytics.setUserId(id: null),
        ).thenAnswer((_) async {});

        await analyticsService.clearUserId();

        verify(
          () => mockFirebaseAnalytics.setUserId(id: null),
        ).called(1);
      });

      test('handles exceptions gracefully', () async {
        when(
          () => mockFirebaseAnalytics.setUserId(id: any(named: 'id')),
        ).thenThrow(Exception('Firebase error'));

        expect(
          analyticsService.clearUserId(),
          completes,
        );
      });
    });

    group('logLogin', () {
      test('logs successful login', () async {
        when(
          () => mockFirebaseAnalytics.logEvent(
            name: 'login',
            parameters: {
              'method': 'magic_link',
              'success': true,
            },
          ),
        ).thenAnswer((_) async {});

        await analyticsService.logLogin(
          method: 'magic_link',
          success: true,
        );

        verify(
          () => mockFirebaseAnalytics.logEvent(
            name: 'login',
            parameters: {
              'method': 'magic_link',
              'success': true,
            },
          ),
        ).called(1);
      });

      test('logs failed login', () async {
        when(
          () => mockFirebaseAnalytics.logEvent(
            name: 'login',
            parameters: {
              'method': 'biometric',
              'success': false,
            },
          ),
        ).thenAnswer((_) async {});

        await analyticsService.logLogin(
          method: 'biometric',
          success: false,
        );

        verify(
          () => mockFirebaseAnalytics.logEvent(
            name: 'login',
            parameters: {
              'method': 'biometric',
              'success': false,
            },
          ),
        ).called(1);
      });
    });

    group('logWorkoutCreated', () {
      test('logs workout creation', () async {
        when(
          () => mockFirebaseAnalytics.logEvent(
            name: 'workout_created',
            parameters: {
              'workout_id': 'w123',
              'workout_name': 'Morning Run',
            },
          ),
        ).thenAnswer((_) async {});

        await analyticsService.logWorkoutCreated(
          workoutId: 'w123',
          workoutName: 'Morning Run',
        );

        verify(
          () => mockFirebaseAnalytics.logEvent(
            name: 'workout_created',
            parameters: {
              'workout_id': 'w123',
              'workout_name': 'Morning Run',
            },
          ),
        ).called(1);
      });
    });

    group('logPayment', () {
      test('logs successful payment', () async {
        when(
          () => mockFirebaseAnalytics.logEvent(
            name: 'payment',
            parameters: {
              'amount': 9999,
              'currency': 'USD',
              'success': true,
            },
          ),
        ).thenAnswer((_) async {});

        await analyticsService.logPayment(
          amount: 9999,
          currency: 'USD',
          success: true,
        );

        verify(
          () => mockFirebaseAnalytics.logEvent(
            name: 'payment',
            parameters: {
              'amount': 9999,
              'currency': 'USD',
              'success': true,
            },
          ),
        ).called(1);
      });

      test('logs failed payment', () async {
        when(
          () => mockFirebaseAnalytics.logEvent(
            name: 'payment',
            parameters: {
              'amount': 9999,
              'currency': 'USD',
              'success': false,
            },
          ),
        ).thenAnswer((_) async {});

        await analyticsService.logPayment(
          amount: 9999,
          currency: 'USD',
          success: false,
        );

        verify(
          () => mockFirebaseAnalytics.logEvent(
            name: 'payment',
            parameters: {
              'amount': 9999,
              'currency': 'USD',
              'success': false,
            },
          ),
        ).called(1);
      });
    });
  });
}
