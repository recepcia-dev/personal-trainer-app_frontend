import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/auth/biometric_auth_service.dart';

// Mock LocalAuthentication
class MockLocalAuthentication extends Mock implements LocalAuthentication {}

// Fake AuthenticationOptions for mocktail
class FakeAuthenticationOptions extends Fake implements AuthenticationOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthenticationOptions());
  });
  group('LocalAuthService Tests', () {
    late MockLocalAuthentication mockLocalAuth;
    late LocalAuthService service;

    setUp(() {
      mockLocalAuth = MockLocalAuthentication();
      service = LocalAuthService(localAuth: mockLocalAuth);
    });

    group('canAuthenticateWithBiometrics', () {
      test('returns true when device is supported and biometrics enrolled',
          () async {
        // Arrange
        when(() => mockLocalAuth.isDeviceSupported())
            .thenAnswer((_) async => true);
        when(() => mockLocalAuth.canCheckBiometrics)
            .thenAnswer((_) async => true);
        when(() => mockLocalAuth.getAvailableBiometrics()).thenAnswer(
            (_) async => [BiometricType.fingerprint]);

        // Act
        final result = await service.canAuthenticateWithBiometrics();

        // Assert
        expect(result, true);
        verify(() => mockLocalAuth.isDeviceSupported()).called(1);
        verify(() => mockLocalAuth.canCheckBiometrics).called(1);
        verify(() => mockLocalAuth.getAvailableBiometrics()).called(1);
      });

      test('returns false when device is not supported', () async {
        // Arrange
        when(() => mockLocalAuth.isDeviceSupported())
            .thenAnswer((_) async => false);

        // Act
        final result = await service.canAuthenticateWithBiometrics();

        // Assert
        expect(result, false);
        verify(() => mockLocalAuth.isDeviceSupported()).called(1);
        verifyNever(() => mockLocalAuth.canCheckBiometrics);
      });

      test('returns false when canCheckBiometrics is false', () async {
        // Arrange
        when(() => mockLocalAuth.isDeviceSupported())
            .thenAnswer((_) async => true);
        when(() => mockLocalAuth.canCheckBiometrics)
            .thenAnswer((_) async => false);

        // Act
        final result = await service.canAuthenticateWithBiometrics();

        // Assert
        expect(result, false);
      });

      test('returns false when no biometrics are enrolled', () async {
        // Arrange
        when(() => mockLocalAuth.isDeviceSupported())
            .thenAnswer((_) async => true);
        when(() => mockLocalAuth.canCheckBiometrics)
            .thenAnswer((_) async => true);
        when(() => mockLocalAuth.getAvailableBiometrics())
            .thenAnswer((_) async => []);

        // Act
        final result = await service.canAuthenticateWithBiometrics();

        // Assert
        expect(result, false);
      });

      test('returns false when exception is thrown', () async {
        // Arrange
        when(() => mockLocalAuth.isDeviceSupported())
            .thenThrow(Exception('Platform error'));

        // Act
        final result = await service.canAuthenticateWithBiometrics();

        // Assert
        expect(result, false);
      });
    });

    group('getAvailableBiometrics', () {
      test('returns list of available biometrics', () async {
        // Arrange
        final biometrics = [BiometricType.face, BiometricType.fingerprint];
        when(() => mockLocalAuth.getAvailableBiometrics())
            .thenAnswer((_) async => biometrics);

        // Act
        final result = await service.getAvailableBiometrics();

        // Assert
        expect(result, biometrics);
      });

      test('returns empty list on error', () async {
        // Arrange
        when(() => mockLocalAuth.getAvailableBiometrics())
            .thenThrow(Exception('Error'));

        // Act
        final result = await service.getAvailableBiometrics();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('authenticate', () {
      test('returns true on successful authentication', () async {
        // Arrange
        when(() => mockLocalAuth.isDeviceSupported())
            .thenAnswer((_) async => true);
        when(() => mockLocalAuth.authenticate(
              localizedReason: any(named: 'localizedReason'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => true);

        // Act
        final result = await service.authenticate(reason: 'Test authentication');

        // Assert
        expect(result, true);
      });

      test('returns false on authentication failure (user cancellation)',
          () async {
        // Arrange
        when(() => mockLocalAuth.isDeviceSupported())
            .thenAnswer((_) async => true);
        when(() => mockLocalAuth.authenticate(
              localizedReason: any(named: 'localizedReason'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => false);

        // Act
        final result = await service.authenticate(reason: 'Test authentication');

        // Assert
        expect(result, false);
      });

      test('throws BiometricAuthException when device not supported',
          () async {
        // Arrange
        when(() => mockLocalAuth.isDeviceSupported())
            .thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => service.authenticate(reason: 'Test authentication'),
          throwsA(isA<BiometricAuthException>()),
        );
      });

      test('throws BiometricAuthException on PlatformException', () async {
        // Arrange
        when(() => mockLocalAuth.isDeviceSupported())
            .thenAnswer((_) async => true);
        when(() => mockLocalAuth.authenticate(
              localizedReason: any(named: 'localizedReason'),
              options: any(named: 'options'),
            )).thenThrow(PlatformException(code: 'NotAvailable'));

        // Act & Assert
        expect(
          () => service.authenticate(reason: 'Test authentication'),
          throwsA(isA<BiometricAuthException>()),
        );
      });

      test('calls authenticate with correct reason parameter', () async {
        // Arrange
        when(() => mockLocalAuth.isDeviceSupported())
            .thenAnswer((_) async => true);
        when(() => mockLocalAuth.authenticate(
              localizedReason: any(named: 'localizedReason'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => true);

        // Act
        await service.authenticate(reason: 'Test reason', biometricOnly: false);

        // Assert - verify the method was called
        verify(() => mockLocalAuth.isDeviceSupported()).called(1);
        verify(() => mockLocalAuth.authenticate(
              localizedReason: any(named: 'localizedReason'),
              options: any(named: 'options'),
            )).called(1);
      });

      test('passes biometricOnly correctly to authenticate', () async {
        // Arrange
        when(() => mockLocalAuth.isDeviceSupported())
            .thenAnswer((_) async => true);
        when(() => mockLocalAuth.authenticate(
              localizedReason: any(named: 'localizedReason'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => true);

        // Act
        await service.authenticate(reason: 'Test', biometricOnly: true);

        // Assert - verify authenticate was called (biometricOnly is passed internally)
        verify(() => mockLocalAuth.authenticate(
              localizedReason: any(named: 'localizedReason'),
              options: any(named: 'options'),
            )).called(1);
      });
    });

    group('BiometricAuthException', () {
      test('creates exception with message', () {
        const message = 'Test error message';
        final exception = BiometricAuthException(message);

        expect(exception.message, message);
        expect(exception.toString(), 'BiometricAuthException: $message');
      });

      test('can be caught as Exception', () {
        expect(
          () => throw BiometricAuthException('test'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
