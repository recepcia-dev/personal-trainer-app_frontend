# Bug Tracker

**⚠️ FORMAT RULE**: Keep bug reports COMPACT. Use minimal formatting, max 3-4 lines per section.

## Active Bugs

*No bugs reported yet.*

---

## Resolved Bugs

### [BACKEND-001] Dev JWT Auth Disabled

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-08

**Issue**: Dev tokens rejected with 401 "Signature verification failed"

**Root Cause**: Docker `APP_ENV=production` prevented dev JWT fallback (security.py:111)

**Fix**: Set `APP_ENV: development`, `DEBUG: "True"`, added `ENABLE_DEV_JWT: "True"`

**Files**: `/backend/docker-compose.yml`

---

### [BACKEND-002] Foreign Key Type Mismatch

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-08

**Issue**: Backend startup failed - FK columns (String) incompatible with users.id (UUID)

**Root Cause**: 7 model files used `String` instead of `Uuid` for 18 foreign key columns

**Fix**: Changed all FK columns to `Uuid` type with proper ForeignKey constraints

**Files**: meal_plan.py, meal_assignment.py, meal.py, payment.py, progress_tracking.py, diet_assignment.py, user.py

---

### [BACKEND-003] Dev User Missing Timestamps

**Status**: `Resolved` | **Priority**: `High` | **Reported**: 2026-01-08

**Issue**: `/api/v1/trainer/profile` returned 500 - `created_at` is None

**Root Cause**: Mock User for dev tokens missing timestamp fields

**Fix**: Added datetime.now(timezone.utc) for both created_at and updated_at

**Files**: `/backend/app/api/dependencies.py`

---

### [BACKEND-004] Dictionary Access on User Object

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-08

**Issue**: 500 Internal Server Error when calling `/api/v1/auth/me/subscription` - `TypeError: 'User' object is not subscriptable`

**Root Cause**: `get_current_user` dependency returns a `User` Pydantic model, but endpoints tried to access it as dict using `current_user["user_id"]`

**Fix**: Changed all 14 occurrences across 5 files from dict subscript to attribute access: `current_user.id` instead of `current_user["user_id"]`, `current_user.user_type` instead of `current_user.get("user_type")`

**Files**: /backend/app/api/v1/auth.py, clients.py, exercises.py, payments.py, progress.py, notifications.py

---

### [QUALITY-001] 30 Flutter Lint Issues

**Status**: `Resolved` | **Priority**: `High` | **Reported**: 2025-12-10

**Issue**: `flutter analyze` found 30 code quality violations (6 unrecognized rules, 12 constructor violations, 8 super parameter violations, etc.)

**Root Cause**: analysis_options.yaml included unsupported lint rules; code didn't follow very_good_analysis standards

**Fix**: Removed 6 unrecognized rules, fixed constructor ordering, converted to super parameters, sorted deps alphabetically

**Result**: 0 linting issues ✅ | **Files**: analysis_options.yaml, 10+ model/exception files

---

## Bug Report Template

When reporting a bug, use this format:

### [BUG-XXX] Brief Description

**Status**: `Open` | `In Progress` | `Resolved`
**Priority**: `Critical` | `High` | `Medium` | `Low`
**Reported**: YYYY-MM-DD
**Assigned To**: Developer name

**Description**:
Clear description of the bug.

**Steps to Reproduce**:
1. Step one
2. Step two
3. Step three

**Expected Behavior**:
What should happen.

**Actual Behavior**:
What actually happens.

**Environment**:
- Device: iOS 17.0 / Android 14
- Flutter version: 3.19.0
- Build mode: Debug / Release

**Stack Trace**:
```
Paste stack trace here
```

**Screenshots/Videos**:
Attach if applicable.

**Potential Root Cause**:
Initial analysis or hypothesis.

**Resolution** (when resolved):
How the bug was fixed.

---

## Example Bug Report

### [BUG-001] App crashes when submitting workout without internet

**Status**: `Resolved`
**Priority**: `High`
**Reported**: 2025-01-15
**Assigned To**: Dev Team

**Description**:
Application crashes when trainer tries to create a workout while offline.

**Steps to Reproduce**:
1. Enable airplane mode
2. Navigate to "Create Workout" screen
3. Fill in workout details
4. Tap "Save" button

**Expected Behavior**:
Workout should save locally and sync when online.

**Actual Behavior**:
App crashes with null pointer exception.

**Environment**:
- Device: iPhone 15 Pro (iOS 17.2)
- Flutter version: 3.19.0
- Build mode: Debug

**Stack Trace**:
```dart
Exception: Null check operator used on a null value
at WorkoutRepository.createWorkout (workout_repository.dart:45)
```

**Potential Root Cause**:
Repository is not checking network connectivity before attempting remote call.

**Resolution**:
Implemented offline-first pattern in WorkoutRepository. Now saves locally first, then attempts remote sync. Fixed in commit abc123.
