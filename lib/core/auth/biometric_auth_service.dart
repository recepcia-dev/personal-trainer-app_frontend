import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Abstract service for device-bound biometric authentication.
///
/// Provides methods to check biometric availability and authenticate users
/// with Face ID, Touch ID, Fingerprint, or device PIN/Pattern.
abstract class BiometricAuthService {
  /// Check if biometric authentication is available on this device.
  ///
  /// Returns true if:
  /// - Device has biometric hardware (fingerprint sensor, Face ID, etc.)
  /// - At least one biometric is enrolled
  /// - Device is supported by local_auth
  Future<bool> canAuthenticateWithBiometrics();

  /// Get list of available biometric types on this device.
  ///
  /// Returns list of [BiometricType]: face, fingerprint, iris, weak, strong
  Future<List<BiometricType>> getAvailableBiometrics();

  /// Prompt user for biometric authentication.
  ///
  /// [reason]: Localized message shown to user during authentication
  /// [biometricOnly]: If true, only allow biometric (no PIN fallback)
  ///
  /// Returns true on successful authentication, false on failure/cancellation
  ///
  /// Throws [BiometricAuthException] for critical errors
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
  });
}

/// Implementation using local_auth package.
class LocalAuthService implements BiometricAuthService {
  /// Creates a new instance of [LocalAuthService].
  ///
  /// [localAuth] can be provided for testing with mocks.
  /// If not provided, a new [LocalAuthentication] instance is created.
  LocalAuthService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<bool> canAuthenticateWithBiometrics() async {
    try {
      // Check if device is supported
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;

      // Check if biometrics can be checked (hardware exists)
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      // Check if at least one biometric is enrolled
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      // Platform error or unsupported device
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      // Check if device supports authentication
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        throw BiometricAuthException(
          'Device does not support biometric authentication',
        );
      }

      // Attempt authentication
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true, // Require user interaction to dismiss
          biometricOnly: biometricOnly,
          sensitiveTransaction: true, // Extra security for sensitive ops
          useErrorDialogs: true, // Show system error dialogs
        ),
      );
    } on PlatformException catch (e) {
      // Handle platform-specific errors
      // Common error codes: NotAvailable, NotEnrolled, LockedOut, etc.
      throw BiometricAuthException(
        'Biometric authentication failed: ${e.message ?? e.code}',
      );
    } catch (e) {
      // Unexpected error
      throw BiometricAuthException('Unexpected error: $e');
    }
  }
}

/// Custom exception for biometric authentication errors.
class BiometricAuthException implements Exception {
  /// Creates a new [BiometricAuthException].
  BiometricAuthException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'BiometricAuthException: $message';
}

/// Riverpod provider for [BiometricAuthService].
///
/// Provides a singleton instance of [LocalAuthService] for use throughout
/// the application. Can be mocked in tests by using Riverpod's mocking
/// capabilities.
final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return LocalAuthService();
});
