/// App Theme Configuration
///
/// Material Design 3 theme implementation based on design system.
/// Reference: doc/design-system.md
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/design_tokens.dart';

/// App theme configuration with Material Design 3
abstract class AppTheme {
  // ============================================================================
  // COLOR PALETTE
  // ============================================================================

  // Primary Colors
  static const Color _primaryOrange = Color(0xFFFF6B35);
  static const Color _primaryOrangeVariant = Color(0xFFFF8555);
  static const Color _primaryOrangeDark = Color(0xFFE55A28);

  // Background Colors (Dark Theme)
  static const Color _backgroundDark = Color(0xFF0D0D0D);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _surfaceVariantDark = Color(0xFF2A2A2A);

  // Background Colors (Light Theme - future)
  static const Color _backgroundLight = Color(0xFFFAFAFA);
  static const Color _surfaceLight = Color(0xFFFFFFFF);

  // Text Colors
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF9E9E9E);
  static const Color _textTertiary = Color(0xFF757575);
  static const Color _textPrimaryLight = Color(0xFF1A1A1A);

  // Semantic Colors
  static const Color _successGreen = Color(0xFF4CAF50);
  static const Color _warningAmber = Color(0xFFFFC107);
  static const Color _errorRed = Color(0xFFF44336);
  static const Color _infoBlue = Color(0xFF2196F3);

  // Border Colors
  static const Color _borderLight = Color(0xFF2A2A2A);
  static const Color _borderMedium = Color(0xFF424242);

  // ============================================================================
  // DARK THEME (Primary)
  // ============================================================================

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      // Primary brand color
      primary: _primaryOrange,
      onPrimary: _textPrimary,
      primaryContainer: _primaryOrangeDark,
      onPrimaryContainer: _textPrimary,

      // Secondary color (muted orange)
      secondary: _primaryOrangeVariant,
      onSecondary: _textPrimary,
      secondaryContainer: _surfaceVariantDark,
      onSecondaryContainer: _textSecondary,

      // Background colors
      surface: _backgroundDark,
      onSurface: _textPrimary,
      surfaceContainerHighest: _surfaceDark,
      surfaceContainerHigh: _surfaceVariantDark,

      // Error colors
      error: _errorRed,
      onError: _textPrimary,

      // Additional colors
      outline: _borderLight,
      outlineVariant: _borderMedium,
      shadow: Colors.black,
      scrim: Colors.black.withValues(alpha: 0.6),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundDark,

      // ========================================================================
      // TYPOGRAPHY
      // ========================================================================
      textTheme: _buildTextTheme(colorScheme),

      // ========================================================================
      // APP BAR THEME
      // ========================================================================
      appBarTheme: AppBarTheme(
        backgroundColor: _backgroundDark,
        foregroundColor: _textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          letterSpacing: 0.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(
          color: _textPrimary,
          size: DesignTokens.iconMd,
        ),
      ),

      // ========================================================================
      // CARD THEME
      // ========================================================================
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: DesignTokens.elevationSm,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      // ========================================================================
      // BUTTON THEMES
      // ========================================================================

      // Elevated Button (Primary CTA)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryOrange,
          foregroundColor: _textPrimary,
          elevation: DesignTokens.elevationMd,
          shadowColor: _primaryOrange.withValues(alpha: 0.4),
          padding: DesignTokens.buttonPadding,
          minimumSize: const Size(
            double.minPositive,
            DesignTokens.buttonHeightStandard,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: DesignTokens.letterSpacingButton,
          ),
        ),
      ),

      // Outlined Button (Secondary)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textPrimary,
          side: const BorderSide(
            color: _borderMedium,
            width: DesignTokens.borderStandard,
          ),
          padding: DesignTokens.buttonPadding,
          minimumSize: const Size(
            double.minPositive,
            DesignTokens.buttonHeightStandard,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: DesignTokens.letterSpacingButton,
          ),
        ),
      ),

      // Text Button (Tertiary)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryOrange,
          padding: DesignTokens.buttonPadding,
          minimumSize: const Size(
            double.minPositive,
            DesignTokens.buttonHeightStandard,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: DesignTokens.letterSpacingButton,
          ),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _textPrimary,
          backgroundColor: Colors.white.withValues(alpha: DesignTokens.opacitySubtle),
          minimumSize: const Size(
            DesignTokens.buttonIconSize,
            DesignTokens.buttonIconSize,
          ),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryOrange,
        foregroundColor: _textPrimary,
        elevation: DesignTokens.elevationLg,
        shape: const CircleBorder(),
        sizeConstraints: const BoxConstraints.tightFor(
          width: DesignTokens.buttonCtaSize,
          height: DesignTokens.buttonCtaSize,
        ),
      ),

      // ========================================================================
      // INPUT DECORATION THEME
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: _borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: _borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: _primaryOrange,
            width: DesignTokens.borderThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: _errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: _errorRed,
            width: DesignTokens.borderThick,
          ),
        ),
        hintStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 14,
        ),
      ),

      // ========================================================================
      // CHIP THEME (Badges)
      // ========================================================================
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: _primaryOrange,
        disabledColor: _surfaceVariantDark,
        padding: DesignTokens.badgePadding,
        labelPadding: EdgeInsets.zero,
        side: const BorderSide(
          color: _borderMedium,
          width: DesignTokens.borderStandard,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        labelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: DesignTokens.letterSpacingBadge,
          color: _textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: DesignTokens.letterSpacingBadge,
          color: _textPrimary,
        ),
      ),

      // ========================================================================
      // DIVIDER THEME
      // ========================================================================
      dividerTheme: const DividerThemeData(
        color: _borderLight,
        thickness: DesignTokens.borderThin,
        space: DesignTokens.spaceMd,
      ),

      // ========================================================================
      // DIALOG THEME
      // ========================================================================
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceDark,
        elevation: DesignTokens.elevationXl,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
      ),

      // ========================================================================
      // BOTTOM SHEET THEME
      // ========================================================================
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surfaceDark,
        elevation: DesignTokens.elevationXl,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusXl),
          ),
        ),
      ),

      // ========================================================================
      // LIST TILE THEME
      // ========================================================================
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
        ),
        minVerticalPadding: DesignTokens.spaceSm,
        iconColor: _textSecondary,
        textColor: _textPrimary,
      ),

      // ========================================================================
      // ICON THEME
      // ========================================================================
      iconTheme: const IconThemeData(
        color: _textPrimary,
        size: DesignTokens.iconMd,
      ),

      // ========================================================================
      // BADGE THEME
      // ========================================================================
      badgeTheme: const BadgeThemeData(
        backgroundColor: _errorRed,
        textColor: _textPrimary,
        smallSize: 6,
        largeSize: 16,
      ),

      // ========================================================================
      // PROGRESS INDICATOR THEME
      // ========================================================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryOrange,
        linearTrackColor: _surfaceVariantDark,
        circularTrackColor: _surfaceVariantDark,
      ),

      // ========================================================================
      // SNACKBAR THEME
      // ========================================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceDark,
        contentTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
      ),
    );
  }

  // ============================================================================
  // LIGHT THEME (Future Implementation)
  // ============================================================================

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: _primaryOrange,
      onPrimary: _textPrimary,
      secondary: _primaryOrangeVariant,
      onSecondary: _textPrimary,
      surface: _backgroundLight,
      onSurface: _textPrimaryLight,
      error: _errorRed,
      onError: _textPrimary,
    );

    // TODO: Implement full light theme when design is finalized
    // For now, return dark theme as fallback
    return darkTheme.copyWith(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundLight,
    );
  }

  // ============================================================================
  // TEXT THEME
  // ============================================================================

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25, // 40px line height
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29, // 36px line height
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33, // 32px line height
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33, // 32px line height
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4, // 28px line height
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.33, // 24px line height
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4, // 28px line height
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5, // 24px line height
        color: colorScheme.onSurface,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43, // 20px line height
        color: colorScheme.onSurface,
        letterSpacing: 0.1,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5, // 24px line height
        color: colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43, // 20px line height
        color: colorScheme.onSurface,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33, // 16px line height
        color: _textSecondary,
        letterSpacing: 0.4,
      ),

      // Label styles
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43, // 20px line height
        color: _textSecondary,
        letterSpacing: 0.1,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33, // 16px line height
        color: _textSecondary,
        letterSpacing: 0.5,
      ),
      labelSmall: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.4, // 14px line height
        color: _textSecondary,
        letterSpacing: DesignTokens.letterSpacingBadge,
      ),
    );
  }

  // ============================================================================
  // SEMANTIC COLOR GETTERS
  // ============================================================================

  static Color get successColor => _successGreen;
  static Color get warningColor => _warningAmber;
  static Color get errorColor => _errorRed;
  static Color get infoColor => _infoBlue;

  static Color get textPrimary => _textPrimary;
  static Color get textSecondary => _textSecondary;
  static Color get textTertiary => _textTertiary;

  static Color get borderLight => _borderLight;
  static Color get borderMedium => _borderMedium;
}
