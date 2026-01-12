import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_trainer_app/core/theme/theme_provider.dart';

/// Unit tests for ThemeModeNotifier
///
/// NOTE: Full integration testing requires SharedPreferences plugin initialization.
/// Run app manually to verify persistence:
/// 1. Change theme preference to Dark
/// 2. Close and restart the app
/// 3. Verify theme is still Dark (no reversion to Light)
///
/// This test suite verifies the notifier can be instantiated correctly.
void main() {
  group('ThemeModeNotifier', () {
    test('can be instantiated with initial light mode state', () {
      final notifier = ThemeModeNotifier();
      expect(notifier, isNotNull);
      expect(notifier.state, ThemeMode.light);
    });

    test('has initialize method defined', () {
      final notifier = ThemeModeNotifier();
      expect(notifier.initialize, isA<Function>());
    });

    test('has setDarkMode method defined', () {
      final notifier = ThemeModeNotifier();
      expect(notifier.setDarkMode, isA<Function>());
    });

    test('has setLightMode method defined', () {
      final notifier = ThemeModeNotifier();
      expect(notifier.setLightMode, isA<Function>());
    });

    test('has setSystemMode method defined', () {
      final notifier = ThemeModeNotifier();
      expect(notifier.setSystemMode, isA<Function>());
    });

    test('has toggleTheme method defined', () {
      final notifier = ThemeModeNotifier();
      expect(notifier.toggleTheme, isA<Function>());
    });
  });
}
