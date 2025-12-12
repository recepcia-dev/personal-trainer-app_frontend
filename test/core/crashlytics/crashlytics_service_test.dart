import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/crashlytics/crashlytics_service.dart';

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  group('CrashlyticsService', () {
    late MockFirebaseCrashlytics mockFirebaseCrashlytics;
    late CrashlyticsService crashlyticsService;

    setUp(() {
      mockFirebaseCrashlytics = MockFirebaseCrashlytics();
      crashlyticsService = CrashlyticsService(
        firebaseCrashlytics: mockFirebaseCrashlytics,
      );
    });

    group('initialize', () {
      test('should enable Crashlytics collection on init', () async {
        when(
          () => mockFirebaseCrashlytics.setCrashlyticsCollectionEnabled(true),
        ).thenAnswer((_) async => {});

        await crashlyticsService.initialize();

        verify(
          () => mockFirebaseCrashlytics.setCrashlyticsCollectionEnabled(true),
        ).called(1);
      });

      test('should silently fail if setCrashlyticsCollectionEnabled throws',
          () async {
        when(
          () => mockFirebaseCrashlytics.setCrashlyticsCollectionEnabled(true),
        ).thenThrow(Exception('Failed to enable'));

        // Should not throw
        await crashlyticsService.initialize();

        verify(
          () => mockFirebaseCrashlytics.setCrashlyticsCollectionEnabled(true),
        ).called(1);
      });
    });

    group('recordError', () {
      test('should record error with stack trace', () async {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        when(
          () => mockFirebaseCrashlytics.recordError(
            error,
            stackTrace,
            reason: null,
            fatal: false,
          ),
        ).thenAnswer((_) async => {});

        await crashlyticsService.recordError(error, stackTrace);

        verify(
          () => mockFirebaseCrashlytics.recordError(
            error,
            stackTrace,
            reason: null,
            fatal: false,
          ),
        ).called(1);
      });

      test('should record error with reason', () async {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;
        const reason = 'Payment processing failed';

        when(
          () => mockFirebaseCrashlytics.recordError(
            error,
            stackTrace,
            reason: reason,
            fatal: false,
          ),
        ).thenAnswer((_) async => {});

        await crashlyticsService.recordError(
          error,
          stackTrace,
          reason: reason,
        );

        verify(
          () => mockFirebaseCrashlytics.recordError(
            error,
            stackTrace,
            reason: reason,
            fatal: false,
          ),
        ).called(1);
      });

      test('should silently fail if recordError throws', () async {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        when(
          () => mockFirebaseCrashlytics.recordError(
            any(),
            any(),
            reason: any(named: 'reason'),
            fatal: any(named: 'fatal'),
          ),
        ).thenThrow(Exception('Failed to record'));

        // Should not throw
        await crashlyticsService.recordError(error, stackTrace);
      });
    });

    group('recordFatalError', () {
      test('should record fatal error', () async {
        final error = Exception('Fatal error');
        final stackTrace = StackTrace.current;

        when(
          () => mockFirebaseCrashlytics.recordError(
            error,
            stackTrace,
            reason: null,
            fatal: true,
          ),
        ).thenAnswer((_) async => {});

        await crashlyticsService.recordFatalError(error, stackTrace);

        verify(
          () => mockFirebaseCrashlytics.recordError(
            error,
            stackTrace,
            reason: null,
            fatal: true,
          ),
        ).called(1);
      });

      test('should record fatal error with reason', () async {
        final error = Exception('Fatal error');
        final stackTrace = StackTrace.current;
        const reason = 'App crash';

        when(
          () => mockFirebaseCrashlytics.recordError(
            error,
            stackTrace,
            reason: reason,
            fatal: true,
          ),
        ).thenAnswer((_) async => {});

        await crashlyticsService.recordFatalError(
          error,
          stackTrace,
          reason: reason,
        );

        verify(
          () => mockFirebaseCrashlytics.recordError(
            error,
            stackTrace,
            reason: reason,
            fatal: true,
          ),
        ).called(1);
      });
    });

    group('setUserId', () {
      test('should set user identifier', () async {
        const userId = 'user@example.com';

        when(
          () => mockFirebaseCrashlytics.setUserIdentifier(userId),
        ).thenAnswer((_) async => {});

        await crashlyticsService.setUserId(userId);

        verify(
          () => mockFirebaseCrashlytics.setUserIdentifier(userId),
        ).called(1);
      });

      test('should silently fail if setUserIdentifier throws', () async {
        const userId = 'user@example.com';

        when(
          () => mockFirebaseCrashlytics.setUserIdentifier(userId),
        ).thenThrow(Exception('Failed to set user ID'));

        // Should not throw
        await crashlyticsService.setUserId(userId);
      });
    });

    group('clearUserId', () {
      test('should clear user identifier', () async {
        when(
          () => mockFirebaseCrashlytics.setUserIdentifier(''),
        ).thenAnswer((_) async => {});

        await crashlyticsService.clearUserId();

        verify(
          () => mockFirebaseCrashlytics.setUserIdentifier(''),
        ).called(1);
      });

      test('should silently fail if setUserIdentifier throws', () async {
        when(
          () => mockFirebaseCrashlytics.setUserIdentifier(''),
        ).thenThrow(Exception('Failed to clear user ID'));

        // Should not throw
        await crashlyticsService.clearUserId();
      });
    });

    group('setUserProperty', () {
      test('should set custom key-value property', () async {
        const key = 'user_type';
        const value = 'trainer';

        when(
          () => mockFirebaseCrashlytics.setCustomKey(key, value),
        ).thenAnswer((_) async => {});

        await crashlyticsService.setUserProperty(key: key, value: value);

        verify(
          () => mockFirebaseCrashlytics.setCustomKey(key, value),
        ).called(1);
      });

      test('should silently fail if setCustomKey throws', () async {
        const key = 'user_type';
        const value = 'trainer';

        when(
          () => mockFirebaseCrashlytics.setCustomKey(key, value),
        ).thenThrow(Exception('Failed to set property'));

        // Should not throw
        await crashlyticsService.setUserProperty(key: key, value: value);
      });
    });

    group('logMessage', () {
      test('should call log on firebaseCrashlytics', () {
        const message = 'User logged in successfully';

        crashlyticsService.logMessage(message);

        verify(
          () => mockFirebaseCrashlytics.log(message),
        ).called(1);
      });

      test('should silently fail if log throws', () {
        const message = 'User logged in successfully';

        when(
          () => mockFirebaseCrashlytics.log(message),
        ).thenThrow(Exception('Failed to log'));

        // Should not throw
        crashlyticsService.logMessage(message);
      });
    });
  });
}
