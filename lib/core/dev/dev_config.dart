import 'package:flutter/foundation.dart';

/// Development configuration flags and utilities
/// Use these to conditionally enable features in dev mode
abstract class DevConfig {
  /// Enable mock authentication (skips real login flow)
  static const bool mockAuthEnabled = kDebugMode;

  /// Seed dummy data on app startup
  static const bool seedDummyDataEnabled = kDebugMode;

  /// Enable verbose logging for dev
  static const bool verboseLoggingEnabled = kDebugMode;

  /// Skip authentication entirely (auto-login on startup)
  static const bool autoLoginEnabled = kDebugMode;

  /// Print all navigation events to console
  static const bool debugNavigationEnabled = kDebugMode;

  /// Print all state changes to console
  static const bool debugStateChangesEnabled = kDebugMode;

  /// Enable dev toolbar overlay (for quick page navigation)
  static const bool devToolbarEnabled = kDebugMode; // Disabled by default

  /// Enable debug API response printing
  static const bool debugApiResponsesEnabled = kDebugMode && false; // Disabled by default

  static void printDevConfig() {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('╔════════════════════════════════════════════╗');
    debugPrint('║          DEV CONFIGURATION                 ║');
    debugPrint('╚════════════════════════════════════════════╝');
    debugPrint('Mock Auth:       $mockAuthEnabled');
    debugPrint('Seed Data:       $seedDummyDataEnabled');
    debugPrint('Verbose Logging: $verboseLoggingEnabled');
    debugPrint('Auto Login:      $autoLoginEnabled');
    debugPrint('Debug Nav:       $debugNavigationEnabled');
    debugPrint('Debug State:     $debugStateChangesEnabled');
    debugPrint('Dev Toolbar:     $devToolbarEnabled');
    debugPrint('Debug API:       $debugApiResponsesEnabled');
    debugPrint('');
  }
}

/// Dev logger utility
class DevLogger {
  static void log(String message) {
    if (DevConfig.verboseLoggingEnabled) {
      debugPrint('🔍 DEV: $message');
    }
  }

  static void info(String message) {
    if (DevConfig.verboseLoggingEnabled) {
      debugPrint('ℹ️ INFO: $message');
    }
  }

  static void warning(String message) {
    if (DevConfig.verboseLoggingEnabled) {
      debugPrint('⚠️ WARN: $message');
    }
  }

  static void error(String message) {
    if (DevConfig.verboseLoggingEnabled) {
      debugPrint('❌ ERROR: $message');
    }
  }

  static void success(String message) {
    if (DevConfig.verboseLoggingEnabled) {
      debugPrint('✅ SUCCESS: $message');
    }
  }
}
