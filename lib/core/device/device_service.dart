import 'package:device_info_plus/device_info_plus.dart';

/// Service for retrieving device information.
///
/// Used for device-bound authentication to ensure tokens are tied to specific devices.
/// Provides device ID and other device information for binding authentication sessions.
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();

  factory DeviceService() {
    return _instance;
  }

  DeviceService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get unique device identifier for device binding
  ///
  /// Returns a unique device ID that remains consistent across app reinstalls.
  /// This is used to bind authentication tokens to specific devices.
  ///
  /// On Android: Uses hardware-based identifiers (ANDROID_ID)
  /// On iOS: Uses hardware UUID
  ///
  /// Returns the device ID as a string
  /// Throws an exception if device info cannot be retrieved
  Future<String> getDeviceId() async {
    try {
      final deviceInfo = _deviceInfo;

      // Platform-specific device ID retrieval
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.id.isNotEmpty) {
        return androidInfo.id; // Android device ID
      }

      final iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.identifierForVendor != null) {
        return iosInfo.identifierForVendor!; // iOS identifier for vendor
      }

      throw Exception('Unable to retrieve device identifier');
    } catch (e) {
      throw DeviceException('Failed to get device ID: $e');
    }
  }

  /// Get device name for display purposes
  ///
  /// Returns a human-readable name for the device
  /// Useful for showing users which devices their account is signed into
  Future<String> getDeviceName() async {
    try {
      final deviceInfo = _deviceInfo;

      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.model.isNotEmpty) {
        return androidInfo.model; // Android device model
      }

      final iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.utsname.machine.isNotEmpty) {
        return iosInfo.utsname.machine; // iOS device model
      }

      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Get device platform information
  ///
  /// Returns a map containing device information:
  /// - platform: 'android' or 'ios'
  /// - osVersion: Operating system version
  /// - model: Device model name
  Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = _deviceInfo;

    try {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'android',
        'osVersion': androidInfo.version.release,
        'model': androidInfo.model,
      };
    } catch (_) {
      try {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'osVersion': iosInfo.systemVersion,
          'model': iosInfo.utsname.machine,
        };
      } catch (e) {
        throw DeviceException('Failed to get device info: $e');
      }
    }
  }
}

/// Exception thrown when device information cannot be retrieved
class DeviceException implements Exception {
  final String message;

  DeviceException(this.message);

  @override
  String toString() => message;
}
