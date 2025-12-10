import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing the app's theme mode.
///
/// Supports switching between light and dark themes.
/// Later enhanced in F010 to support system mode and persistence.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
        (ref) => ThemeModeNotifier());

/// Notifier for managing theme mode state.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  /// Toggle between light and dark theme.
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  /// Set theme to light mode.
  void setLightMode() {
    state = ThemeMode.light;
  }

  /// Set theme to dark mode.
  void setDarkMode() {
    state = ThemeMode.dark;
  }
}
