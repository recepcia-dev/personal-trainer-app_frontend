# Bug Tracker

## Active Bugs

*No bugs reported yet.*

---

## Resolved Bugs

*No resolved bugs yet.*

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
