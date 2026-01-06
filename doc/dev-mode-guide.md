# Development Mode Guide

Rapid UI/UX iteration without backend dependency. Test all user roles instantly with mock authentication, pre-seeded data, and optional debug tools.

## Quick Start

```bash
export PATH="$HOME/flutter/bin:$PATH" && \
flutter run -t lib/main_dev.dart
```

**What you get:**
- ✅ Mock authentication (no real login)
- ✅ Optional dev toolbar for role switching
- ✅ Pre-seeded test data
- ✅ Enhanced logging

---

## Dev Toolbar

Floating UI in bottom-right corner. Click `🛠️` to expand.

### Features

| Feature | What It Does |
|---------|-------------|
| **👨‍🏫 Trainer** | Login as trainer (John Trainer) |
| **👤 Client** | Login as client (Jane Client) |
| **👨‍💼 Admin** | Login as admin |
| **🚫 Not Auth** | Logout / test auth screens |
| **🔄 Reseed Data** | Repopulate DB with test data |
| **🗑️ Clear Data** | Delete all test data |

### Usage

```
1. flutter run -t lib/main_dev.dart
2. Click 🛠️ button (bottom-right)
3. Click "👨‍🏫 Trainer"
4. App shows trainer view instantly
5. Press 'r' to hot reload
6. Switch roles anytime (no re-login)
```

**No re-authentication needed** — Hot reload preserves auth state.

---

## Configuration

Edit `lib/core/dev/dev_config.dart`:

```dart
// Enable/disable features
static const bool mockAuthEnabled = true;           // Use fake auth
static const bool seedDummyDataEnabled = true;      // Pre-populate DB
static const bool devToolbarEnabled = true;         // Show toolbar
static const bool debugApiResponsesEnabled = false; // Log API calls
static const bool verboseLoggingEnabled = true;     // Extra logging
```

---

## Pre-configured Mock Users

Ready to use immediately:

### Trainer
```
Email: trainer@test.local
Name: John Trainer
ID: dev-trainer-001
Specialty: CrossFit & Strength
```

### Client
```
Email: client@test.local
Name: Jane Client
ID: dev-client-001
Trainer ID: dev-trainer-001
```

### Admin
```
Email: admin@test.local
Name: Admin User
```

---

## Seed Data (Test Database Population)

### Current State
Framework is ready in `lib/core/dev/seed_dev_data.dart`. Mock users are pre-configured.

### Adding More Test Data

Example: Pre-seed workouts for Trainer view

```dart
// File: lib/core/dev/seed_dev_data.dart

Future<void> seedWorkouts() async {
  final db = await AppDatabase.open();

  await db.batch((batch) {
    batch.insertAll(db.workouts, [
      WorkoutCompanion.insert(
        id: 'w1',
        trainerId: 'dev-trainer-001',
        name: 'Upper Body Strength',
        duration: 60,
      ),
      WorkoutCompanion.insert(
        id: 'w2',
        trainerId: 'dev-trainer-001',
        name: 'Lower Body Power',
        duration: 45,
      ),
    ]);
  });

  DevLogger.success('Seeded 2 workouts');
}

// Then add to seedAll():
Future<void> seedAll() async {
  if (!DevConfig.seedDummyDataEnabled) return;

  DevLogger.info('Seeding development data...');
  await seedWorkouts();  // ← Add this
  // await seedClients();
  // await seedExercises();
  DevLogger.success('Development data seeded successfully');
}
```

Then rebuild with code generation:
```bash
export PATH="$HOME/flutter/bin:$PATH" && \
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Debug API (Request/Response Logging)

Enable in `dev_config.dart`:

```dart
static const bool debugApiResponsesEnabled = true;
```

**Console output:**
```
🔍 DEV: POST /api/v1/auth/magic-link
🔍 DEV: Request body: {"email": "trainer@test.local"}
✅ SUCCESS: Response 200
🔍 DEV: Response: {"token": "abc123", "user": {...}}
```

**Use cases:**
- Debugging backend integration
- Verifying request/response format
- Monitoring API performance
- Testing authentication flows

---

## Common Workflows

### Workflow 1: Design Iteration (Fast)

```bash
# 1. Start dev mode
flutter run -t lib/main_dev.dart

# 2. Click dev toolbar → select role

# 3. Make design changes

# 4. Press 'r' in terminal (hot reload)
# Changes appear instantly - no re-login!

# 5. Switch roles via toolbar

# 6. Test different user views
```

### Workflow 2: Feature Development (Thorough)

```bash
# 1. Enable seed data
# Edit lib/core/dev/dev_config.dart
static const bool seedDummyDataEnabled = true;

# 2. Add seeding functions
# Edit lib/core/dev/seed_dev_data.dart
await seedWorkouts();
await seedClients();

# 3. Run code generation
export PATH="$HOME/flutter/bin:$PATH" && \
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Start dev mode
flutter run -t lib/main_dev.dart

# 5. Test with realistic data
# Click toolbar → select role → see seeded data

# 6. Build feature normally
# Use devRoleProvider to access user state

# 7. When ready for real backend
flutter run -t lib/main.dart  # Production entry point
```

### Workflow 3: Testing All User States

```
1. Test Trainer view
   → Click 👨‍🏫 Trainer in toolbar

2. Test Client view
   → Click 👤 Client in toolbar

3. Test Admin view
   → Click 👨‍💼 Admin in toolbar

4. Test Not Authenticated
   → Click 🚫 Not Auth in toolbar
   → See login screens

5. Test Empty State
   → Click 🗑️ Clear Data
   → App shows no data

6. Test With Data
   → Click 🔄 Reseed Data
   → Data reappears
```

---

## File Structure

```
lib/core/dev/
├── dev_config.dart         ← Feature flags (enable/disable)
├── mock_providers.dart     ← Mock authentication users
├── seed_dev_data.dart      ← Test data framework
├── dev_utils.dart          ← Developer utilities
├── README.md               ← Full documentation
└── mock_providers.g.dart   ← Generated (Riverpod)

lib/main_dev.dart           ← Development entry point
```

---

## Key Differences: main_dev.dart vs main.dart

| Aspect | `main_dev.dart` | `main.dart` |
|--------|-----------------|-----------|
| **Authentication** | Mock users | Real API |
| **Dev Toolbar** | Optional UI | None |
| **Seed Data** | Pre-populated | Real data only |
| **Logging** | Verbose (optional) | Production logs |
| **Database** | Test data | Real user data |
| **Use Case** | Design & dev | Production |

**Production safety:** All dev code is behind `if (kDebugMode)` checks.

---

## Troubleshooting

### Dev Toolbar Not Showing
```dart
// lib/core/dev/dev_config.dart
static const bool devToolbarEnabled = true;  // Must be true

// Then rebuild:
export PATH="$HOME/flutter/bin:$PATH" && \
flutter pub run build_runner build --delete-conflicting-outputs
```

### Mock Auth Not Working
- Verify `mockAuthEnabled = true` in dev_config.dart
- Ensure running `flutter run -t lib/main_dev.dart` (not `lib/main.dart`)
- Check that dev toolbar shows roles

### Seed Data Not Appearing
- Enable `seedDummyDataEnabled = true` in dev_config.dart
- Implement seeding functions in seed_dev_data.dart
- Run code generation (build_runner)
- Restart app

### Hot Reload Losing State
- This is expected behavior in dev mode
- Auth state persists via devRoleProvider
- Database changes persist (use 🔄 Reseed or 🗑️ Clear to manage)

---

## Best Practices

### ✅ Do
- Use dev mode for UI iteration
- Test all user roles during design
- Use seed data to test with realistic amounts of data
- Hot reload to see changes instantly
- Switch roles to test permission-based UIs

### ❌ Don't
- Commit dev-only code to main branch (already prevented)
- Use mock auth in production (won't happen - different entry point)
- Leave `debugApiResponsesEnabled = true` in commits (no problem - dev-only)
- Rely on mock data structure after shipping (different in real data)

---

## Extending Dev Mode

### Add New Mock User

```dart
// lib/core/dev/mock_providers.dart

case DevRoleEnum.manager:  // New role
  return ManagerModel(
    id: 'dev-manager-001',
    email: 'manager@test.local',
    name: 'Manager Name',
    permissions: ['view_analytics', 'manage_trainers'],
  );
```

### Add New Seeding Function

```dart
// lib/core/dev/seed_dev_data.dart

Future<void> seedAnalytics() async {
  // Add analytics data seeding
}

// Then call in seedAll():
await seedAnalytics();
```

---

## Related Documentation

- **Design System**: `doc/design-system.md` — Color, spacing, typography tokens
- **Hot Reload**: `doc/hot-reload-guide.md` — Live design editing workflow
- **Architecture**: `CLAUDE.md` — Clean architecture patterns
- **Full Dev Docs**: `lib/core/dev/README.md` — Detailed implementation guide

---

## Quick Reference

| Task | Command |
|------|---------|
| Start dev mode | `export PATH="$HOME/flutter/bin:$PATH" && flutter run -t lib/main_dev.dart` |
| Change role | Click toolbar button (🛠️ → select role) |
| Reseed data | Click 🔄 Reseed Data button |
| Hot reload | Press `r` in terminal |
| Full rebuild | Press `R` in terminal |
| Quit | Press `q` in terminal |
| Regenerate code | `export PATH="$HOME/flutter/bin:$PATH" && flutter pub run build_runner build --delete-conflicting-outputs` |
