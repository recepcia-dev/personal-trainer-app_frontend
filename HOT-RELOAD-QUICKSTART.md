# 🔄 Hot Reload Quick Start

## 30-Second Setup

Open terminal and run:
```bash
flutter run
```

Keep terminal open. You're ready to edit!

---

## Live Design Edit Workflow

### Example: Change Button Color

**Step 1: Edit the token**
```dart
// lib/core/theme/app_theme.dart, line 27
static const Color _primaryOrange = Color(0xFF1E88E5);  // blue instead of orange
```

**Step 2: Press `r` in terminal**
```
flutter> r
```

**Step 3: See it live ✓**
All buttons update instantly in the running app!

---

## Common Changes (All Work with Hot Reload)

### 1. Spacing
```dart
// lib/core/constants/design_tokens.dart

static const double spaceMd = 24.0;  // was 16
```
→ Press `r` → Card padding, gaps, padding all update

### 2. Border Radius
```dart
static const double radiusMd = 20.0;  // was 12
```
→ Press `r` → All buttons, inputs, cards get rounder corners

### 3. Colors
```dart
// lib/core/theme/app_theme.dart

static const Color _primaryOrange = Color(0xFFFF1744);  // bright pink
```
→ Press `r` → All themed elements change instantly

### 4. Text Styling
```dart
// In app_theme.dart, inside _buildTextTheme()

bodyLarge: TextStyle(
  fontSize: 18,  // was 16
  fontWeight: FontWeight.w600,  // was w400
  ...
),
```
→ Press `r` → All body text reflects new size/weight

### 5. Shadows
```dart
static const List<BoxShadow> shadowMd = [
  BoxShadow(
    color: Color(0x99000000),  // darker shadow
    offset: Offset(0, 6),  // was 4
    blurRadius: 12,  // was 8
    ...
  ),
];
```
→ Press `r` → Cards get new shadow depth

---

## Pro: Side-by-Side Editing

1. **Split your screen:**
   - Left: Code editor (VS Code with design files open)
   - Right: Flutter emulator/device

2. **Edit & Watch:**
   - Change token
   - Press `r`
   - See result instantly
   - Adjust and repeat

---

## Terminal Commands Cheat Sheet

| Press | Action |
|-------|--------|
| `r` | Hot reload (fast) |
| `R` | Full rebuild (slow, required for code changes) |
| `q` | Quit app |
| `h` | Help |
| `w` | Toggle widget inspector |

---

## Troubleshooting

**"Hot reload failed"**
- Press `R` (capital) for full rebuild
- Or type `q` to quit, then `flutter run` again

**Changes not showing**
- Make sure you edited the right file
- Press `R` instead of `r`

**Emulator too slow**
- Try physical device for faster feedback
- Or increase emulator RAM in settings

---

## Files You'll Edit Most

```
lib/
├── core/
│   ├── constants/design_tokens.dart     ← EDIT HERE for spacing, sizing
│   └── theme/app_theme.dart             ← EDIT HERE for colors, text styles
└── features/
    └── [feature-name]/
        └── presentation/
            └── screens/                  ← Your UI screens (no changes needed for token updates)
```

---

## Example: Complete Design Refresh

Want to try all the hot reload features at once?

```dart
// lib/core/theme/app_theme.dart

// Change primary color
static const Color _primaryOrange = Color(0xFF2196F3);  // blue

// Change background
static const Color _backgroundDark = Color(0xFF121212);  // darker

// Change spacing scale
static const double spaceMd = 20.0;  // was 16

// Change border radius
static const double radiusMd = 16.0;  // was 12
```

Press `r` and watch your whole app get a new look in **under 1 second** ✓

---

## Next Steps

1. Open `lib/core/theme/app_theme.dart`
2. Find a color constant
3. Change it to something bright (e.g., `Color(0xFFFF1744)`)
4. Press `r` in terminal
5. Watch it update on screen!
