import 'package:flutter/material.dart';

/// Application theme configuration for Material Design 3.
///
/// Custom color palette:
/// - Light theme: #F97316 (orange), #FB923C (light orange), #D1FAE5 (mint green)
/// - Dark theme: #1F2937 (dark gray), #FB923C (orange), #F97316 (bright orange)
abstract class AppTheme {
  // Custom colors
  static const Color _lightOrange = Color(0xFFF97316);
  static const Color _lightOrangeVariant = Color(0xFFFB923C);
  static const Color _lightMint = Color(0xFFD1FAE5);
  static const Color _darkBackground = Color(0xFF1F2937);
  static const Color _darkOrange = Color(0xFFFB923C);
  static const Color _darkOrangeBright = Color(0xFFF97316);

  /// Create a light theme with Material Design 3 using custom orange/mint palette.
  static ThemeData light({ColorScheme? colorScheme}) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: colorScheme ??
            ColorScheme.fromSeed(
              seedColor: _lightOrange,
              brightness: Brightness.light,
              surface: const Color(0xFFFAFAFA),
              primaryContainer: const Color(0xFFFFEDD5),
              secondaryContainer: _lightMint,
            ),
        // Enhanced typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );

  /// Create a dark theme with Material Design 3 using custom dark gray/orange palette.
  static ThemeData dark({ColorScheme? colorScheme}) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: colorScheme ??
            ColorScheme.fromSeed(
              seedColor: _darkOrange,
              brightness: Brightness.dark,
              surface: const Color(0xFF111827),
              primaryContainer: const Color(0xFF7C2D12),
              secondaryContainer: const Color(0xFF5F4E37),
            ),
        scaffoldBackgroundColor: _darkBackground,
        // Enhanced typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
}
