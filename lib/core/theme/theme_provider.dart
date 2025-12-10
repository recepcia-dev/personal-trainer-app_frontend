import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing the app's theme mode.
///
/// Supports switching between light, dark, and system themes with persistence.
/// Theme selection is saved to shared_preferences and restored on app restart.
/// System mode follows device settings automatically.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
        (ref) => ThemeModeNotifier());

/// Notifier for managing theme mode state with persistence.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  static const _themeKey = 'theme_mode';

  /// Initialize theme from shared preferences.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      state = switch (savedTheme) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };
    }
  }

  /// Save theme mode to shared preferences.
  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    await prefs.setString(_themeKey, themeString);
  }

  /// Toggle between light, dark, and system themes (cycles in that order).
  Future<void> toggleTheme() async {
    final newMode = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    state = newMode;
    await _saveTheme(newMode);
  }

  /// Set theme to light mode.
  Future<void> setLightMode() async {
    state = ThemeMode.light;
    await _saveTheme(ThemeMode.light);
  }

  /// Set theme to dark mode.
  Future<void> setDarkMode() async {
    state = ThemeMode.dark;
    await _saveTheme(ThemeMode.dark);
  }

  /// Set theme to system mode (follows device settings).
  Future<void> setSystemMode() async {
    state = ThemeMode.system;
    await _saveTheme(ThemeMode.system);
  }
}
