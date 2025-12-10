import 'package:flutter/material.dart';

/// Application theme configuration for Material Design 3.
///
/// This file provides methods to create light and dark themes with
/// support for dynamic colors on Android 12+.
abstract class AppTheme {
  /// Create a light theme with Material Design 3.
  ///
  /// [colorScheme] is optional and can be provided for dynamic color support
  /// (e.g., from Android 12+ system colors or custom seed-based colors).
  /// If not provided, defaults to a blue seed color.
  static ThemeData light({ColorScheme? colorScheme}) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: colorScheme ??
            ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
      );

  /// Create a dark theme with Material Design 3.
  ///
  /// [colorScheme] is optional and can be provided for dynamic color support
  /// (e.g., from Android 12+ system colors or custom seed-based colors).
  /// If not provided, defaults to a blue seed color.
  static ThemeData dark({ColorScheme? colorScheme}) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: colorScheme ??
            ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
      );
}
