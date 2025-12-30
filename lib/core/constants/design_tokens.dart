/// Design Tokens
///
/// Centralized design constants extracted from design system.
/// Reference: doc/design-system.md
///
/// Usage:
/// ```dart
/// Container(
///   padding: EdgeInsets.all(DesignTokens.spaceMd),
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
///   ),
/// )
/// ```
library;

import 'package:flutter/material.dart';

/// Design tokens for spacing, sizing, and layout constants
abstract class DesignTokens {
  // ============================================================================
  // SPACING (8px base unit grid system)
  // ============================================================================

  /// Extra small spacing: 4px
  /// Usage: Icon padding, tight gaps
  static const double spaceXs = 4.0;

  /// Small spacing: 8px
  /// Usage: Badge spacing, compact lists
  static const double spaceSm = 8.0;

  /// Medium spacing: 16px
  /// Usage: Card padding, default gaps (most common)
  static const double spaceMd = 16.0;

  /// Large spacing: 24px
  /// Usage: Section spacing, page padding
  static const double spaceLg = 24.0;

  /// Extra large spacing: 32px
  /// Usage: Major section breaks
  static const double spaceXl = 32.0;

  /// 2X large spacing: 48px
  /// Usage: Hero sections, large whitespace
  static const double space2xl = 48.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  /// Small radius: 8px
  /// Usage: Small chips, tags
  static const double radiusSm = 8.0;

  /// Medium radius: 12px
  /// Usage: Buttons, input fields
  static const double radiusMd = 12.0;

  /// Large radius: 16px
  /// Usage: Cards, containers (most common)
  static const double radiusLg = 16.0;

  /// Extra large radius: 24px
  /// Usage: Large modals, bottom sheets
  static const double radiusXl = 24.0;

  /// Full radius: 9999px
  /// Usage: Pills, circular avatars, icon buttons
  static const double radiusFull = 9999.0;

  // ============================================================================
  // AVATAR SIZES
  // ============================================================================

  /// Small avatar: 32px
  /// Usage: Inline mentions, compact lists
  static const double avatarSm = 32.0;

  /// Medium avatar: 40px
  /// Usage: Review cards, chat lists
  static const double avatarMd = 40.0;

  /// Large avatar: 64px
  /// Usage: Profile cards, user settings
  static const double avatarLg = 64.0;

  /// Extra large avatar: 120px
  /// Usage: Profile headers, detailed views
  static const double avatarXl = 120.0;

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  /// Small icon: 16px
  /// Usage: Inline icons, badges
  static const double iconSm = 16.0;

  /// Medium icon: 24px
  /// Usage: Standard UI icons (most common)
  static const double iconMd = 24.0;

  /// Large icon: 32px
  /// Usage: Feature icons, empty states
  static const double iconLg = 32.0;

  /// Extra large icon: 48px
  /// Usage: Hero icons, landing pages
  static const double iconXl = 48.0;

  // ============================================================================
  // BUTTON SIZES
  // ============================================================================

  /// Icon button size: 48px
  /// Usage: Secondary action buttons (camera, menu)
  static const double buttonIconSize = 48.0;

  /// Primary CTA button size: 64px
  /// Usage: Main call-to-action button (call, start workout)
  static const double buttonCtaSize = 64.0;

  /// Standard button height: 48px
  /// Usage: Regular buttons, form actions
  static const double buttonHeightStandard = 48.0;

  /// Small button height: 36px
  /// Usage: Compact buttons, inline actions
  static const double buttonHeightSmall = 36.0;

  // ============================================================================
  // ELEVATION (z-index)
  // ============================================================================

  /// Subtle elevation: 1
  /// Usage: Subtle lift for interactive elements
  static const double elevationSm = 1.0;

  /// Card elevation: 2
  /// Usage: Standard cards, containers
  static const double elevationMd = 2.0;

  /// Floating elevation: 4
  /// Usage: FABs, floating elements
  static const double elevationLg = 4.0;

  /// Modal elevation: 8
  /// Usage: Dialogs, bottom sheets
  static const double elevationXl = 8.0;

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  /// Fast animation: 150ms
  /// Usage: Button press, ripples
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Standard animation: 250ms
  /// Usage: Page transitions, most animations
  static const Duration animationStandard = Duration(milliseconds: 250);

  /// Slow animation: 400ms
  /// Usage: Complex transitions, reveals
  static const Duration animationSlow = Duration(milliseconds: 400);

  // ============================================================================
  // OPACITY VALUES
  // ============================================================================

  /// Subtle overlay: 10%
  /// Usage: Hover states, subtle backgrounds
  static const double opacitySubtle = 0.1;

  /// Light overlay: 20%
  /// Usage: Disabled backgrounds
  static const double opacityLight = 0.2;

  /// Medium overlay: 40%
  /// Usage: Disabled text
  static const double opacityMedium = 0.4;

  /// Strong overlay: 60%
  /// Usage: Modal overlays
  static const double opacityStrong = 0.6;

  /// Heavy overlay: 80%
  /// Usage: Dark overlays, focus backgrounds
  static const double opacityHeavy = 0.8;

  // ============================================================================
  // BORDER WIDTHS
  // ============================================================================

  /// Thin border: 1px
  /// Usage: Subtle dividers
  static const double borderThin = 1.0;

  /// Standard border: 1.5px
  /// Usage: Badges, outlined buttons
  static const double borderStandard = 1.5;

  /// Thick border: 2px
  /// Usage: Focus rings, emphasized borders
  static const double borderThick = 2.0;

  /// Extra thick border: 4px
  /// Usage: Avatar borders, prominent outlines
  static const double borderXThick = 4.0;

  // ============================================================================
  // LAYOUT CONSTRAINTS
  // ============================================================================

  /// Minimum touch target: 48px
  /// Usage: Accessibility minimum for interactive elements
  static const double minTouchTarget = 48.0;

  /// Maximum content width: 600px
  /// Usage: Constrain content on tablets/desktop
  static const double maxContentWidth = 600.0;

  /// Screen horizontal padding: 24px
  /// Usage: Default screen edge insets
  static const double screenPaddingHorizontal = 24.0;

  /// Screen vertical padding: 16px
  /// Usage: Default screen top/bottom insets
  static const double screenPaddingVertical = 16.0;

  // ============================================================================
  // TYPOGRAPHY CONSTANTS
  // ============================================================================

  /// Letter spacing for badges: 1px
  /// Usage: Uppercase badge text
  static const double letterSpacingBadge = 1.0;

  /// Letter spacing for buttons: 0.5px
  /// Usage: Button text
  static const double letterSpacingButton = 0.5;

  /// Line height multiplier: 1.5
  /// Usage: Body text readability
  static const double lineHeightMultiplier = 1.5;

  // ============================================================================
  // SHADOWS
  // ============================================================================

  /// Small shadow (Elevation 1)
  /// Usage: Subtle lift for cards
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x4D000000), // rgba(0, 0, 0, 0.3)
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow (Elevation 2)
  /// Usage: Standard cards, buttons
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x66000000), // rgba(0, 0, 0, 0.4)
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Large shadow (Elevation 3)
  /// Usage: Floating action buttons
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x80000000), // rgba(0, 0, 0, 0.5)
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Extra large shadow (Elevation 4)
  /// Usage: Modals, dialogs
  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x99000000), // rgba(0, 0, 0, 0.6)
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  /// Orange glow shadow for CTA button
  /// Usage: Primary call-to-action button
  static const List<BoxShadow> shadowOrangeGlow = [
    BoxShadow(
      color: Color(0x66FF6B35), // rgba(255, 107, 53, 0.4)
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // ============================================================================
  // EDGE INSETS PRESETS
  // ============================================================================

  /// Screen padding (standard)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
    vertical: screenPaddingVertical,
  );

  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(spaceMd);

  /// Badge padding
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 6.0,
  );

  /// Button padding (standard)
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: spaceLg,
    vertical: 12.0,
  );

  // ============================================================================
  // GAP CONSTANTS (for Flex widgets)
  // ============================================================================

  /// Gap between badges: 8px
  static const SizedBox gapBadges = SizedBox(width: spaceSm);

  /// Gap between stats: 16px
  static const SizedBox gapStats = SizedBox(width: spaceMd);

  /// Gap between sections: 24px
  static const SizedBox gapSections = SizedBox(height: spaceLg);

  /// Gap between list items: 12px
  static const SizedBox gapListItems = SizedBox(height: 12.0);
}
