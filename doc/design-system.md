# Design System Reference

**Source:** Personal Trainer Profile Screen Design
**Last Updated:** 2025-12-18
**Design Philosophy:** Modern, minimalist fitness app with light theme and bold red accents

---

## 1. Color Palette

### Primary Colors (CSS Variables)
```css
:root {
  --color-primary: #2d2c33;     /* Primary color - dark grayish blue */
  --color-accent: #b10c0cff;    /* Accent color - bold red */
  --color-bg: #ffffff;          /* Background - white */
  --color-text: #2d2c33;        /* Text - matches primary */
}
```

### Semantic Mapping
- **Background Light**: `#ffffff` (var(--color-bg)) - Main app background
- **Surface Light**: `#f5f5f5` - Cards, elevated surfaces
- **Primary Accent Red**: `#b10c0c` (var(--color-accent)) - Call-to-action buttons, interactive elements
- **Primary Accent Red Variant**: `#d41414` - Hover/pressed states

### Text Colors
- **Text Primary**: `#2d2c33` (var(--color-text)) - Headings, primary content
- **Text Secondary**: `#6b6b6b` - Supporting text, labels, timestamps
- **Text Tertiary**: `#9e9e9e` - Disabled text, placeholders

### Semantic Colors
- **Success Green**: `#4CAF50` - Ratings, positive feedback
- **Warning Amber**: `#FFC107` - Important notices
- **Error Red**: `#F44336` - Errors, destructive actions
- **Info Blue**: `#2196F3` - Verification badges, informational

### Neutral Colors
- **Border Light**: `#e0e0e0` - Subtle borders, dividers
- **Border Medium**: `#bdbdbd` - Prominent borders
- **Overlay**: `rgba(0, 0, 0, 0.4)` - Modal overlays

---

## 2. Typography

### Font Family
- **Primary**: `Inter` or `SF Pro Display` (system default)
- **Fallback**: System UI fonts (`-apple-system, BlinkMacSystemFont, 'Segoe UI'`)

### Type Scale

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| **Display Large** | 32px | 700 (Bold) | 40px | Page titles |
| **Display Medium** | 28px | 700 (Bold) | 36px | Section headers |
| **Headline** | 24px | 700 (Bold) | 32px | Card titles, profile names |
| **Title** | 20px | 600 (SemiBold) | 28px | Stat values |
| **Body Large** | 16px | 400 (Regular) | 24px | Main content |
| **Body Medium** | 14px | 400 (Regular) | 20px | Review text, descriptions |
| **Label** | 12px | 600 (SemiBold) | 16px | Stats labels, timestamps |
| **Caption** | 10px | 600 (SemiBold) | 14px | Badges, tags |

### Typography Patterns
- **Profile Names**: Headline (24px/700) + verification badge
- **Stats Display**: Title (20px/600) for number + Label (12px/600) for description
- **Badges**: Caption (10px/600), uppercase, letter-spacing: 1px
- **Review Author**: Body Medium (14px/600)
- **Review Content**: Body Medium (14px/400), secondary text color

---

## 3. Spacing System

### Base Unit: 8px
All spacing follows an 8-point grid system for consistency.

| Token | Value | Usage |
|-------|-------|-------|
| `space-xs` | 4px | Icon padding, tight gaps |
| `space-sm` | 8px | Badge spacing, compact lists |
| `space-md` | 16px | Card padding, default gaps |
| `space-lg` | 24px | Section spacing, page padding |
| `space-xl` | 32px | Major section breaks |
| `space-2xl` | 48px | Hero sections, large whitespace |

### Common Spacing Patterns
- **Screen Padding**: 24px horizontal, 16px vertical
- **Card Padding**: 16px all sides
- **Section Gap**: 24px vertical spacing between major sections
- **List Item Gap**: 12px between review cards
- **Badge Gap**: 8px horizontal spacing between adjacent badges
- **Stats Row Gap**: 16px between stat items

---

## 4. Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 8px | Small chips, tags |
| `radius-md` | 12px | Buttons, input fields |
| `radius-lg` | 16px | Cards, containers |
| `radius-xl` | 24px | Large modals, sheets |
| `radius-full` | 9999px | Pills, circular avatars, icon buttons |

### Radius Patterns
- **Profile Avatar**: `radius-full` (circular)
- **Action Buttons** (call, camera, more): `radius-full`
- **Badges**: `radius-full` (pill shape)
- **Review Cards**: `radius-lg` (16px)
- **Stats Container**: `radius-md` (12px)

---

## 5. Elevation & Shadows

### Shadow Scale
```css
/* Elevation 1 - Subtle lift */
shadow-sm: 0px 2px 4px rgba(0, 0, 0, 0.1)

/* Elevation 2 - Cards */
shadow-md: 0px 4px 8px rgba(0, 0, 0, 0.15)

/* Elevation 3 - Floating elements */
shadow-lg: 0px 8px 16px rgba(0, 0, 0, 0.2)

/* Elevation 4 - Modals */
shadow-xl: 0px 16px 32px rgba(0, 0, 0, 0.25)
```

### Usage
- **Review Cards**: `shadow-sm` (subtle elevation)
- **Call Button**: `shadow-md` with red glow
- **Modals/Dialogs**: `shadow-xl`
- **Floating Action Button**: `shadow-lg`

---

## 6. Components

### 6.1 Avatar
- **Size**: 120px × 120px (large profile), 40px × 40px (review avatar)
- **Shape**: Circular (`radius-full`)
- **Border**: 4px solid surface color (optional)
- **Fallback**: Initials on gradient background

### 6.2 Badges
- **Style**: Pill-shaped with border
- **Background**: Transparent or `surface-light`
- **Border**: 1.5px solid `border-medium`
- **Text**: Caption (10px/600), uppercase, primary color (#2d2c33)
- **Padding**: 6px horizontal, 4px vertical
- **Spacing**: 8px gap between badges

**Example**: `PROFESSIONAL`, `HUMAN`

### 6.3 Stats Display
- **Layout**: Horizontal row, evenly distributed
- **Structure**: Number (large, bold) above label (small, gray)
- **Alignment**: Center-aligned text
- **Divider**: Optional vertical line between stats

**Example**:
```
    8y          88+         4.5
Experience   Clients     Rating
```

### 6.4 Review Cards
- **Background**: `surface-light` (#f5f5f5)
- **Border Radius**: 16px
- **Padding**: 16px
- **Shadow**: `shadow-sm`
- **Layout**:
  - Top row: Avatar (left) + Name + Timestamp (right) + Menu icon
  - Content: Review text below
- **Gap**: 12px between cards

### 6.5 Call-to-Action Button
- **Size**: 64px diameter
- **Shape**: Circular
- **Background**: `primary-accent-red` (#b10c0c)
- **Icon**: Phone icon, white
- **Shadow**: `shadow-md` with red tint
- **Position**: Center-aligned below badges

### 6.6 Icon Buttons (Secondary)
- **Size**: 48px diameter
- **Background**: `rgba(45, 44, 51, 0.1)` (translucent primary)
- **Icon Color**: Primary (#2d2c33)
- **Border Radius**: Full circle
- **Position**: Top corners (camera left, more options right)

---

## 7. Layout Patterns

### Profile Header Layout
```
┌─────────────────────────┐
│  [Camera]      [More]   │  ← Icon buttons (top corners)
│                         │
│      [Profile Pic]      │  ← Large circular avatar (120px)
│                         │
│    [BADGE] [BADGE]      │  ← Badges row (centered)
│                         │
│   Farnese Vandimion ✓   │  ← Name + verification (24px bold)
│                         │
│      [@] Call [@]       │  ← CTA button (64px orange)
│                         │
│  [8y] [88+] [4.5]       │  ← Stats row (3 columns)
│  [Exp] [Clients] [Rate] │
└─────────────────────────┘
```

### Reviews Section Layout
```
┌─────────────────────────┐
│  Reviews       See All  │  ← Section header
├─────────────────────────┤
│  [Avatar] Casca Smith   │
│           2 days ago  ⋮ │
│                         │
│  Farnese has a deep...  │  ← Review text (gray)
└─────────────────────────┘
```

---

## 8. Interaction States

### Button States
- **Default**: Full opacity, defined colors
- **Hover**: +10% brightness (web), slight scale (1.02x)
- **Pressed**: -10% brightness, scale (0.98x)
- **Disabled**: 40% opacity, no interaction

### Card States
- **Default**: `shadow-sm`
- **Hover**: `shadow-md`, slight lift
- **Pressed**: `shadow-sm`, scale (0.99x)

---

## 9. Accessibility

### Color Contrast
- Text on light background: Minimum 7:1 contrast ratio (AAA)
- Red accent on light: 4.5:1 contrast ratio (AA)
- Secondary text: 4.5:1 contrast ratio (AA)

### Touch Targets
- Minimum: 48px × 48px for all interactive elements
- Spacing: 8px minimum between adjacent touch targets

### Focus States
- 2px solid focus ring with `info-blue` color
- 4px offset from element boundary

---

## 10. Design Principles

1. **Light-First**: Clean, modern interface optimized for readability
2. **Bold CTAs**: Red accent reserved for primary actions only
3. **Generous Whitespace**: 24px between major sections for breathing room
4. **Consistent Rounding**: 16px for cards, full circles for interactive elements
5. **Clear Hierarchy**: Bold numbers, subtle labels, distinct sections
6. **Minimalist Icons**: Simple, recognizable, monochrome
7. **Professional Trust**: Verification badges, ratings, experience display

---

## 11. Implementation Notes

### Flutter-Specific
- Use `Theme.of(context)` for all color/text references
- Implement `ThemeExtension` for custom design tokens
- Use `MediaQuery` for responsive spacing adjustments
- Material Design 3 `ColorScheme` for light theme
- `TextTheme` for typography scale

### Common Pitfalls
- ❌ Avoid mixing border radius values randomly
- ❌ Don't use red for non-critical elements
- ❌ Never use pure black (#000000) for text - use `#2d2c33`
- ❌ Don't exceed 2 font weights per component
- ✓ Always use design tokens instead of hardcoded values
- ✓ Test contrast ratios for all text/background combinations

---

## 12. Assets & Resources

### Image Assets
- **Location**: `assets/images/`
- **Reference Designs**:
  - `client.jpg` - Client persona reference image
  - `trainer.jpg` - Trainer persona reference image

### Usage in Flutter
```dart
// Reference images in code
Image.asset('assets/images/client.jpg')
Image.asset('assets/images/trainer.jpg')
```

### Asset Configuration
All assets are declared in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/
    - assets/images/
    - assets/icons/
```

### Asset Organization
- **Images**: `assets/images/` - Photos, illustrations, reference designs
- **Icons**: `assets/icons/` - SVG icons, custom icons
- **Fonts**: `assets/fonts/` - Custom font files

---

## 13. Future Considerations

- **Dark Mode**: Invert colors, increase contrast, deepen shadows
- **Accessibility Theme**: Higher contrast, larger text, simplified animations
- **Seasonal Themes**: Maintain red accent, adjust surface colors
- **Branding Flexibility**: Red accent can be swapped for brand color via theme variable
