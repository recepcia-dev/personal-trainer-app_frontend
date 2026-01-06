import 'package:flutter/foundation.dart';

import 'dev_config.dart';

/// Development utilities for quick testing and debugging
abstract class DevUtils {
  /// Print all available dev shortcuts to console
  static void printDevShortcuts() {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('╔════════════════════════════════════════════╗');
    debugPrint('║        DEV SHORTCUTS & UTILITIES            ║');
    debugPrint('╚════════════════════════════════════════════╝');
    debugPrint('');
    debugPrint('Quick authentication shortcuts:');
    debugPrint('  • DevUtils.loginAsTrainer()');
    debugPrint('  • DevUtils.loginAsClient()');
    debugPrint('  • DevUtils.loginAsAdmin()');
    debugPrint('  • DevUtils.logout()');
    debugPrint('');
    debugPrint('Data utilities:');
    debugPrint('  • DevUtils.reseedData()');
    debugPrint('  • DevUtils.clearData()');
    debugPrint('');
    debugPrint('Logging utilities:');
    debugPrint('  • DevLogger.log(\'message\')');
    debugPrint('  • DevLogger.success(\'message\')');
    debugPrint('  • DevLogger.error(\'message\')');
    debugPrint('');
    debugPrint('Configuration:');
    debugPrint('  • Edit lib/core/dev/dev_config.dart');
    debugPrint('  • Run: flutter pub run build_runner build');
    debugPrint('');
  }

  /// Quick login as trainer (requires Riverpod context)
  static void loginAsTrainer() {
    DevLogger.success('Trainer login triggered');
    // Actual login happens via DevRole provider in UI
  }

  /// Quick login as client (requires Riverpod context)
  static void loginAsClient() {
    DevLogger.success('Client login triggered');
    // Actual login happens via DevRole provider in UI
  }

  /// Quick login as admin (requires Riverpod context)
  static void loginAsAdmin() {
    DevLogger.success('Admin login triggered');
    // Actual login happens via DevRole provider in UI
  }

  /// Quick logout (requires Riverpod context)
  static void logout() {
    DevLogger.info('Logout triggered');
    // Actual logout happens via DevRole provider in UI
  }

  /// Reseed all development data
  static Future<void> reseedData() async {
    DevLogger.info('Reseeding data...');
    // Implementation will be added as features are built
  }

  /// Clear all development data
  static Future<void> clearData() async {
    DevLogger.info('Clearing data...');
    // Implementation will be added as features are built
  }

  /// Print device information (useful for testing)
  static void printDeviceInfo() {
    debugPrint('');
    debugPrint('╔════════════════════════════════════════════╗');
    debugPrint('║        DEVICE INFORMATION                  ║');
    debugPrint('╚════════════════════════════════════════════╝');
    debugPrint('Platform: ${defaultTargetPlatform.name}');
    debugPrint('Debug Mode: $kDebugMode');
    debugPrint('Release Mode: $kReleaseMode');
    debugPrint('Profile Mode: $kProfileMode');
    debugPrint('');
  }
}

/// Extension methods for easier dev access
extension DevExtension on String {
  /// Print as dev log
  void toDev() {
    DevLogger.log(this);
  }

  /// Print as success
  void toSuccess() {
    DevLogger.success(this);
  }

  /// Print as error
  void toError() {
    DevLogger.error(this);
  }
}
