# Hot Reload + Centralized Tokens Guide

Quick workflow for live design changes during development.

## Setup (One Time)

```bash
export PATH="$HOME/flutter/bin:$PATH" && flutter run
```

Keep this running in a terminal. You'll see output like:
```
Launching lib/main.dart on Android Emulator...
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

## Workflow: Making Design Changes

### Step 1: Edit Design Tokens
Edit `lib/core/constants/design_tokens.dart`:

```dart
// Change spacing
static const double spaceMd = 24.0; // was 16.0

// Change border radius
static const double radiusMd = 16.0; // was 12.0

// Change colors in AppTheme
static const Color _primaryOrange = Color(0xFFFF8855); // was 0xFFFF6B35
```

### Step 2: Press `r` in Terminal
In the terminal running `flutter run`, press `r` and hit Enter:

```
flutter> r
Rebuilding...
✓ Rebuilt in 1.234ms (4 files changed)
```

**Changes appear on screen instantly** ✓

### Step 3: Iterate
Make more adjustments → Press `r` → See results live

## What Works with Hot Reload

✓ Color changes
✓ Spacing values
✓ Border radius
✓ Font sizes
✓ Shadows
✓ Opacity values
✓ Border widths
✓ Animation durations

## What Requires Full Rebuild

Press `R` (capital) instead of `r` for full rebuild when:
- Adding/removing new constants
- Modifying Riverpod providers
- Changing Dart code logic
- Database changes

## Pro Tips

### 1. Reference Tokens Everywhere
Bad ❌
```dart
Container(padding: EdgeInsets.all(16.0))
```

Good ✓
```dart
Container(padding: EdgeInsets.all(DesignTokens.spaceMd))
```

### 2. Keep Common Patterns
Example button with consistent styling:
```dart
ElevatedButton(
  onPressed: () {},
  child: Padding(
    padding: EdgeInsets.all(DesignTokens.spaceMd),
    child: Text('Sign In'),
  ),
)
```

### 3. Use AppTheme Getters
For semantic colors:
```dart
Container(
  color: AppTheme.successColor,
  child: Text(
    'Success!',
    style: TextStyle(color: AppTheme.textPrimary),
  ),
)
```

### 4. Group Related Edits
If changing spacing system, edit all related tokens:
```dart
static const double spaceSm = 12.0;  // was 8.0
static const double spaceMd = 20.0;  // was 16.0
static const double spaceLg = 32.0;  // was 24.0
```

Then one `r` for all changes at once.

## Troubleshooting

**Changes don't appear?**
→ Press `R` (capital) for full rebuild
→ Or restart: `flutter run`

**Hot reload error message?**
→ Press `R` and try again
→ If stuck, restart the app

**Need to see multiple screens?**
→ Keep your UI navigation available
→ Navigate between screens while editing
→ Tokens apply everywhere instantly

## Quick Reference

| Action | Command |
|--------|---------|
| Hot reload | Press `r` in terminal |
| Full rebuild | Press `R` in terminal |
| Quit | Press `q` in terminal |
| Help | Press `h` in terminal |

## File Locations

- **Tokens**: `lib/core/constants/design_tokens.dart`
- **Theme**: `lib/core/theme/app_theme.dart`
- **Screens**: `lib/core/router/screens/`

## Example: Changing Primary Color

1. Open `lib/core/theme/app_theme.dart`
2. Find: `static const Color _primaryOrange = Color(0xFFFF6B35);`
3. Change to: `static const Color _primaryOrange = Color(0xFF1E88E5);`
4. Press `r` in terminal
5. See all buttons, icons, and accents update instantly ✓
