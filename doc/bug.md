# Bug Tracker

## Active Bugs

*No bugs reported yet.*

---

## Resolved Bugs

### [QUALITY-001] 30 Flutter Analyze Issues from F004-F005

**Status**: `Resolved`
**Priority**: `High`
**Reported**: 2025-12-10 (Session 8)
**Assigned To**: Dev Team

**Description**:
After completing F004 and F005, `flutter analyze` reported 30 code quality issues:
- 6 unrecognized lint rules in analysis_options.yaml
- 12 sort_constructors_first violations (fields before constructors)
- 8 use_super_parameters violations (using `: super(...)` instead of `super.`)
- 2 prefer_expression_function_bodies violations
- 1 use_setters_to_change_properties violation
- 2 sort_pub_dependencies violations in pubspec.yaml

**Environment**:
- Flutter version: 3.24.3
- Build mode: Analysis

**Stack Trace**:
```
30 issues found. (ran in 16.3s)

warning • 'prefer_if_null_to_conditional_expressions' is not a recognized lint rule • analysis_options.yaml:65:7
warning • 'prefer_null_coalescing_operators' is not a recognized lint rule • analysis_options.yaml:76:7
warning • 'sized_box_for_spacer' is not a recognized lint rule • analysis_options.yaml:82:7
... (27 more issues)
```

**Potential Root Cause**:
1. analysis_options.yaml included lint rules not available in current Flutter/Dart version
2. Previous implementations (F004, F005) did not follow code style guidelines
3. Dependency sorting was not alphabetical per very_good_analysis linter

**Resolution**:
Resolved in F006 implementation:
1. Removed 6 unrecognized lint rules from analysis_options.yaml:
   - prefer_if_null_to_conditional_expressions
   - prefer_null_coalescing_operators
   - sized_box_for_spacer
   - use_getters_to_define_property_names
   - use_to_close_resource
   - use_underscores_to_denote_unused_callback_parameters

2. Fixed sort_constructors_first violations:
   - Moved all field declarations to AFTER constructors
   - Affected: AppException, ServerException, Failure, ServerFailure, DioClient

3. Converted to super parameters:
   - Changed `ServerException({...}) : super(message: message);`
   - To: `ServerException({required super.message});`
   - Applied to all 5 exception types and 5 failure types

4. Used expression function bodies:
   - Changed block bodies to arrow syntax (=>)
   - Examples: `factory DioClient() => _instance;`

5. Changed property vs method:
   - Changed `static void setTokenProvider()` to `static set tokenProvider`

6. Sorted dependencies alphabetically:
   - Removed section comments between dependencies
   - Sorted all 37 dependencies alphabetically
   - Sorted all 16 dev_dependencies alphabetically
   - Final result: "No issues found! (ran in 3.5s)"

**Impact**:
- Code quality now excellent (0 linting issues)
- Follows Flutter best practices and very_good_analysis standards
- All tests still pass (5/5 for F006)
- Project ready for further development with clean codebase

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
