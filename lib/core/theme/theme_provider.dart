import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing the app's theme mode.
///
/// Supports switching between light and dark themes with persistence.
/// Theme selection is saved to shared_preferences and restored on app restart.
/// Later enhanced in F010 to support system mode.
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
      state = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
  }

  /// Save theme mode to shared preferences.
  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  /// Toggle between light and dark theme.
  Future<void> toggleTheme() async {
    final newMode =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
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
}
