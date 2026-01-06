# Development Mode Setup

This directory contains utilities for rapid development and design iteration without needing a real backend or authentication.

## Quick Start

### Launch Dev Mode
```bash
export PATH="$HOME/flutter/bin:$PATH" && \
flutter pub run build_runner build --delete-conflicting-outputs && \
flutter run -t lib/main_dev.dart
```

Or in one command:
```bash
cd ~/Desktop/projects/game-changer/personal-trainer-app/frontend && \
export PATH="$HOME/flutter/bin:$PATH" && \
flutter pub run build_runner build --delete-conflicting-outputs && \
flutter run -t lib/main_dev.dart
```

### Files Overview

| File | Purpose |
|------|---------|
| `dev_config.dart` | Feature flags and dev configuration |
| `mock_providers.dart` | Mock authentication providers for Riverpod |
| `seed_dev_data.dart` | Dummy data seeding utilities |
| `dev_utils.dart` | Development utility functions and shortcuts |
| `README.md` | This file |

## Features

### 1. Mock Authentication
- **No backend required** - Authenticate without real API calls
- **Multiple roles** - Switch between Trainer, Client, and Admin
- **Quick testing** - Test all user types without creating accounts

**How to use:**
```dart
// In dev toolbar (bottom-right corner) or manually:
ref.read(devRoleProvider.notifier).selectTrainer();
ref.read(devRoleProvider.notifier).selectClient();
ref.read(devRoleProvider.notifier).selectAdmin();
```

### 2. Dev Toolbar (Optional)
- **Quick role switching** - Click buttons to switch user roles
- **Data management** - Reseed or clear test data
- **Floating UI** - Non-intrusive overlay in bottom-right corner

**Enable/disable:**
```dart
// In lib/core/dev/dev_config.dart:
static const bool devToolbarEnabled = true; // Enable toolbar
```

### 3. Dummy Data Seeding
- **Pre-populate app** - Seed test data on startup
- **Multiple scenarios** - Test with empty state or full data
- **Easy reset** - Reseed or clear data from dev toolbar

**Available functions:**
```dart
await DevDataSeeder.seedAll();     // Seed all test data
await DevDataSeeder.clearAll();    // Clear all test data
await DevDataSeeder.reseedAll();   // Reset and reseed
```

### 4. Verbose Logging
- **Dev-specific logs** - Identify dev mode issues easily
- **State changes** - Watch authentication and state updates
- **API responses** - Debug data flow

**Enable logging:**
```dart
// In lib/core/dev/dev_config.dart:
static const bool verboseLoggingEnabled = true;
static const bool debugApiResponsesEnabled = true;
```

## Configuration

Edit `lib/core/dev/dev_config.dart` to enable/disable features:

```dart
/// Development configuration flags
abstract class DevConfig {
  static const bool mockAuthEnabled = kDebugMode;           // Mock auth
  static const bool seedDummyDataEnabled = kDebugMode;      // Seed data
  static const bool verboseLoggingEnabled = kDebugMode;     // Extra logging
  static const bool autoLoginEnabled = kDebugMode;          // Auto-login
  static const bool debugNavigationEnabled = kDebugMode;    // Route logging
  static const bool debugStateChangesEnabled = kDebugMode;  // State logging
  static const bool devToolbarEnabled = kDebugMode && false; // UI toolbar
  static const bool debugApiResponsesEnabled = kDebugMode && false; // API debug
}
```

## Development Workflow

### Design Iteration (Fast)
```bash
# 1. Launch dev mode with mock auth
flutter run -t lib/main_dev.dart

# 2. Use dev toolbar to switch roles
# Click buttons in bottom-right corner to login as different users

# 3. Hot reload with 'r' command
# Changes are instant, no re-authentication needed

# 4. Iterate on design
# Test all user types without backend
```

### Feature Implementation (Thorough)
```bash
# 1. Launch dev mode
flutter run -t lib/main_dev.dart

# 2. Enable data seeding
# Uncomment seeding functions in lib/core/dev/seed_dev_data.dart

# 3. Run tests
flutter test

# 4. Test with real backend
# Switch to main.dart with actual authentication

# 5. Run full test suite
flutter test
```

### Testing All User States
```dart
// Trainer view
ref.read(devRoleProvider.notifier).selectTrainer();

// Client view
ref.read(devRoleProvider.notifier).selectClient();

// Admin view
ref.read(devRoleProvider.notifier).selectAdmin();

// Not authenticated
ref.read(devRoleProvider.notifier).selectNotAuthenticated();
```

## Data Seeding Examples

Once you add database tables, you can seed test data:

```dart
// In lib/core/dev/seed_dev_data.dart (uncomment and modify):

Future<void> seedWorkouts() async {
  final db = await AppDatabase.open();

  await db.batch((batch) {
    batch.insertAll(db.workouts, [
      WorkoutCompanion.insert(
        id: 'workout-1',
        trainerId: 'dev-trainer-001',
        name: 'Upper Body Strength',
        description: 'Focus on chest, back, shoulders',
      ),
    ]);
  });

  DevLogger.success('Seeded 1 workout');
}
```

## Common Issues

### Build Runner Errors
```bash
# Regenerate all code
export PATH="$HOME/flutter/bin:$PATH" && \
flutter pub run build_runner build --delete-conflicting-outputs
```

### Mock Providers Not Updating
```bash
# Refresh provider cache
ref.refresh(devRoleProvider);
ref.refresh(mockAuthStateProvider);
```

### Auth Still Shows Login Screen
- Ensure `mockAuthEnabled` is `true` in dev_config.dart
- Check that `authStateProvider` override is in `getDevProviderOverrides()`
- Verify router redirects are not blocking auth

### Dev Toolbar Not Showing
- Set `devToolbarEnabled = true` in dev_config.dart
- Rebuild: `flutter pub run build_runner build`
- Restart app

## Architecture

```
App Structure:
├── lib/main.dart           ← Production entry point
├── lib/main_dev.dart       ← Development entry point
└── lib/core/dev/           ← Development utilities
    ├── dev_config.dart          (Feature flags)
    ├── mock_providers.dart      (Mock auth)
    ├── seed_dev_data.dart       (Test data)
    └── dev_utils.dart           (Utilities)

Dev Mode Flow:
App Launch
  ↓
Load .env.development
  ↓
Initialize Mock Auth
  ↓
Seed Dummy Data (optional)
  ↓
Show Dev Toolbar (optional)
  ↓
Ready for Testing
```

## Best Practices

1. **Never commit dev code** - Dev files only run with `main_dev.dart`
2. **Keep production clean** - Production uses `main.dart` with real auth
3. **Test all roles** - Always verify Trainer, Client, and Admin views
4. **Use hot reload** - Don't restart app during design iteration
5. **Mock all external APIs** - No real Stripe/Firebase calls in dev mode
6. **Document features** - Add seeding functions as you build

## Next Steps

As you build features:
1. Add database tables to `lib/database/`
2. Uncomment and implement seeding functions in `seed_dev_data.dart`
3. Add new dummy data models in `mock_providers.dart`
4. Test with real backend before production release

## Production Release Checklist

Before deploying:
- [ ] Remove all dev-specific code from production flow
- [ ] Verify `main.dart` uses real authentication
- [ ] Remove `.env.development` from build
- [ ] Run full test suite with real backend
- [ ] Disable verbose logging in production
- [ ] Test payment flows with Stripe test mode
