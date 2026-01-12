# Bug Tracker

**⚠️ FORMAT RULE**: Keep bug reports COMPACT. Use minimal formatting, max 3-4 lines per section.

## Active Bugs

### [BACKEND-014] Client Profile Endpoint Returns 404 for Dev Token Clients - FIXED

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-12 | **Fixed**: 2026-01-12

**Issue**: Frontend error when loading client profile: `GET /api/v1/clients/{client_id}` endpoint returned HTTP 404 "Client with ID 478f7ffe-61c2-5038-8411-75ad04de5573 not found" when called with dev token. Frontend called this endpoint to fetch the client's own profile using their user_id, but endpoint only queried database for Client records by ID (not by user_id) and had no dev token handling.

**Root Cause**: Endpoint had two issues: (1) **No client-role support**: Endpoint was designed for trainers to fetch their clients by client ID, but clients need to fetch their own profile by user_id. (2) **No dev token handling**: Unlike other endpoints (e.g., `/api/v1/auth/me`), no check for dev tokens that return in-memory mock objects without database persistence.

**Fix**: Modified `GET /api/v1/clients/{client_id}` endpoint (`/backend/app/api/v1/clients.py` lines 104-183) to: (1) Check if user is a **client** role—if so, look up Client by `user_id` instead of `id`, allowing clients to fetch their own profile. (2) For dev tokens with no Client record, return a mock client object with deterministic UUID and mock trainer_id. (3) Added permission check so clients can only view their own profile. (4) For trainers/admins, preserve existing behavior of looking up by client ID.

**Files Modified**: `/backend/app/api/v1/clients.py` (lines 104-183)

**Test Results**: ✅ Client can fetch own profile with dev token (HTTP 200) | ✅ Response has all required fields (id, trainer_id, user_id, email, is_active, created_at, updated_at) | ✅ Client gets 403 when trying to access another user's profile | ✅ Trainer gets 404 for non-existent client | ✅ Backwards compatible with existing trainer/admin usage

---

### [BACKEND-013] Unknown User Type Error - GET /api/v1/auth/me Returns 404 for Dev Tokens - FIXED

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-12 | **Fixed**: 2026-01-12

**Issue**: Frontend error when restoring client session: `GET /api/v1/auth/me` endpoint returned HTTP 404 "User not found" when called with dev token credentials. Error message: "RESOURCE_NOT_FOUND: User 478f7ffe-61c2-5038-8411-75ad04de5573 not found". Occurred when switching to client role and trying to display Profile tab.

**Root Cause**: `GET /api/v1/auth/me` endpoint unconditionally called `AuthService.get_user(current_user.id, db)` which queries the database. For dev tokens, `get_current_user` dependency creates a mock User object (not persisted to DB) with a deterministic UUID. The endpoint tried to fetch this non-existent user from the database, resulting in 404 error.

**Fix**: Modified `GET /api/v1/auth/me` endpoint (`/backend/app/api/v1/auth.py` lines 194-208) to check if current_user is a dev token (by checking for `_dev_token_user_id` attribute set by `get_current_user` dependency). For dev tokens, return the mock User object directly without database query. For production tokens, continue fetching fresh data from database.

**Files Modified**: `/backend/app/api/v1/auth.py` (lines 194-208)

**Test Results**: ✅ GET /api/v1/auth/me returns 200 with dev client token | ✅ Response contains correct user_type, email, id fields | ✅ Frontend can now restore client session on app startup

---

### [BACKEND-012] Client Deletion Not Deleting User Records - FIXED

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-12 | **Fixed**: 2026-01-12

**Issue**: DELETE `/api/v1/clients/{client_id}` returned 204 No Content, but: (1) client remained in database with `is_active=false` (soft delete), (2) associated user account never deleted, (3) list endpoints returned deleted clients mixed with active ones, (4) frontend cache had UNIQUE constraint violations on user_id field.

**Root Causes**: Four separate issues: (1) **Backend soft delete**: DELETE endpoint only marked `is_active=false` instead of hard-deleting. (2) **List filtering**: GET endpoints returned all clients regardless of `is_active` status. (3) **Schema incomplete**: ClientDetailResponse missing `trainer_id`, `user_id`, `updated_at` fields, causing frontend parser errors. (4) **Cache constraint**: Drift cache had stale deleted records with user_id values blocking inserts of new clients.

**Fix**: (1) **Backend hard delete** (`/backend/app/api/v1/clients.py` line 410-421): Changed from soft delete to hard delete using `delete(Client).where(Client.id==id)` statement that removes both Client and User records atomically. Added import: `from sqlalchemy import delete`. (2) **List filtering** (`/backend/app/api/v1/clients.py` lines 61-72 and `/backend/app/api/v1/trainer.py` lines 133-135): Added `Client.is_active == True` filter to WHERE clauses so deleted clients never returned. (3) **Schema fix** (`/backend/app/schemas/trainer.py` lines 25-44): Added missing `trainer_id: UUID`, `user_id: UUID`, `updated_at: datetime` fields to ClientDetailResponse. (4) **Cache cleanup** (`/lib/features/clients/data/datasources/client_local_datasource.dart` lines 77-84): Before caching fresh clients, delete ALL clients for that trainer (`trainerId.equals(trainerId)`) to clear stale records and avoid UNIQUE constraint violations on user_id.

**Files Modified**: `/backend/app/api/v1/clients.py`, `/backend/app/api/v1/trainer.py`, `/backend/app/schemas/trainer.py`, `/lib/features/clients/data/datasources/client_local_datasource.dart`

**Test Logs**: ✅ DELETE returns 204 | ✅ GET returns only 1 active client | ✅ Cache insert succeeds with no UNIQUE constraint errors

---

### [BACKEND-011] Trainers Viewing Other Trainers' Clients - FIXED

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-12 | **Fixed**: 2026-01-12

**Issue**: Frontend displayed clients from multiple trainers when authenticated as single trainer. GET `/api/v1/trainer/clients?trainer_id=...` returned correct filtered results from backend, but app UI showed mixed clients from different trainer IDs (e.g., trainer 1 saw trainer 2's clients).

**Root Cause**: Three-layer failure: (1) Backend `/api/v1/trainer/clients` endpoint didn't support pagination parameters (`skip`, `limit`, `trainer_id`), ignoring all query params. (2) Frontend local cache in Drift database didn't filter by trainer_id—`getClients()` returned ALL clients from all trainers. (3) Riverpod state was not invalidated on logout/auth change, causing stale cached data to persist.

**Fix**: (1) **Backend** (`/backend/app/api/v1/trainer.py` lines 102-148): Added `trainer_id`, `skip`, `limit` query parameters; added security validation that provided `trainer_id` must match authenticated user; implemented `.offset(skip).limit(limit)` pagination. (2) **Frontend Local Cache** (`/lib/features/clients/data/datasources/client_local_datasource.dart`): Made `trainerId` required parameter in `getClients()`; added `.where((c) => c.trainerId.equals(trainerId))` filter; added `clearClientsByTrainer(trainerId)` method for trainer-specific cache clearing. (3) **Frontend Repository** (`/lib/features/clients/data/repositories/client_repository_impl.dart`): Updated `_getLocalClients()` to require `trainerId` parameter; added client-side security filtering to detect data leakage with debug logging. (4) **Auth Provider** (`/lib/features/auth/presentation/providers/auth_state_provider.dart`): Added `ref.invalidate(clientsProvider)` and `ref.invalidate(allClientsProvider)` on logout.

**Security Impact**: Dual-layer trainer_id filtering (backend + frontend). Backend rejects requests with mismatched trainer_id. Frontend filters cache by trainer_id and detects any leaked data.

**Files Modified**: `/backend/app/api/v1/trainer.py`, `/lib/features/clients/data/datasources/client_local_datasource.dart`, `/lib/features/clients/data/repositories/client_repository_impl.dart`, `/lib/features/auth/presentation/providers/auth_state_provider.dart`

---

### [FRONTEND-004] Type Casting Error in getCurrentUser - Fixed

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-12 | **Fixed**: 2026-01-12

**Issue**: `_TypeError: type 'Null' is not a subtype of type 'String' in type cast` when calling `/api/v1/auth/me` endpoint. The API returns `first_name` and `last_name` fields, but TrainerModel.fromJson() expects a `name` field, causing null value to be cast to String.

**Root Cause**: Field name mismatch between API response and model expectations. API returns `first_name`/`last_name` (e.g., "John"/"Trainer"), but models expected `name` field directly. `fromJson()` tried to cast null `name` field to String. Additionally, `trainer_id` could be int in API but model expected String, causing second type casting error.

**Fix**: (1) Added `fromApi()` factory methods to TrainerModel and ClientModel that map API fields correctly. (2) TrainerModel.fromApi() checks if `name` exists; if not, concatenates `first_name` and `last_name`. (3) ClientModel.fromApi() same logic plus handles `trainer_id` as either int or String by converting int to String. (4) Updated getCurrentUser() and verifyMagicLink() datasource methods to use `fromApi()` instead of `fromJson()`. (5) Updated VerifyMagicLinkResponseModel.parseUser() extension to use `fromApi()` factory methods.

**Files Modified**: `/lib/features/auth/data/models/trainer_model.dart` (added fromApi factory), `/lib/features/auth/data/models/client_model.dart` (added fromApi factory with int→String conversion), `/lib/features/auth/data/datasources/auth_remote_datasource.dart` (use fromApi in getCurrentUser and verifyMagicLink), `/lib/features/auth/data/models/verify_magic_link_response_model.dart` (parseUser extension uses fromApi), `/test/features/auth/data/datasources/auth_remote_datasource_test.dart` (updated test expectations for trainer_id as String)

---

### [BACKEND-009] Client List Empty After Creation with Dev Tokens

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-10 | **Fixed**: 2026-01-10

**Issue**: POST `/api/v1/clients` returned HTTP 201 with full client details, but subsequent GET `/api/v1/clients` returned empty list. Created clients were never visible in the list endpoint despite successful creation response.

**Root Cause**: Dev token UUID v5 mismatch. Previous fix used deterministic UUID v5 IDs for dev tokens, but when a trainer email existed from previous test sessions, the code fell back to using the old trainer ID. This caused: clients created with old trainer ID (from DB), but GET listing used new UUID v5 ID, resulting in no matches.

**Fix**: (1) Always use deterministic UUID v5 ID for dev tokens, never fall back. (2) If old trainer with same email exists, delete it and any associated clients (development cleanup). (3) Always create new trainer with the UUID v5 ID. This ensures consistency between create and list operations. (4) Commit: `0da337a` - fix: resolve client list being empty after creation with dev tokens.

**Files Modified**: `/backend/app/api/v1/clients.py` (lines 188-222)

---

### [FRONTEND-003] Conflicting dioProvider Instances Missing Authorization Header - FIXED

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-09 | **Fixed**: 2026-01-09

**Issue**: POST `/api/v1/clients` failed with 401 "Missing authorization header" while GET endpoints worked. Frontend AuthInterceptor logged token being added, but POST request never received the header.

**Root Cause**: Two conflicting `dioProvider` definitions shadowing each other. Exercise feature created plain `Dio()` instance without interceptors, which was imported and used by client and admin features instead of the correct `DioClient().dio` instance from core network module.

**Fix**: (1) Removed conflicting `dioProvider = Provider<Dio>((ref) => Dio())` from `/lib/features/progress/presentation/providers/exercise_provider.dart`. (2) Added proper import of `dioProvider` from `../../../../core/network/dio_provider.dart` in admin_provider.dart and client_provider.dart. (3) Now all features use the single configured DioClient instance with AuthInterceptor.

**Files Modified**: `/lib/features/progress/presentation/providers/exercise_provider.dart`, `/lib/features/admin/presentation/providers/admin_provider.dart`, `/lib/features/clients/presentation/providers/client_provider.dart`

---

### [FRONTEND-002] Silent Error Handling in Client Creation - Now Fixed

**Status**: `Resolved` | **Priority**: `High` | **Reported**: 2026-01-09

**Issue**: POST `/api/v1/clients` request reaches backend and returns 401 Unauthorized, but frontend logs don't show the detailed error message from backend. User sees generic "Error: Exception: Failed to create client: 401 Unauthorized" SnackBar without understanding root cause (e.g., auth header present but token invalid, trainer not in DB, subscription limit, etc.).

**Root Cause**: `ClientRemoteDataSourceImpl` catches `DioException` and wraps it in generic `Exception(e.message)` which only contains HTTP status/method, not response body. Backend returns JSON error with details, but this is lost in the generic exception. `PrettyDioLogger` shows response, but not visible to users.

**Fix**: (1) Created `ApiError` model in `/lib/core/network/api_error.dart` to parse structured error responses from backend. (2) Updated all client remote datasource methods to extract detailed error messages from `DioException.response?.data`. (3) Added debug logging with `debugPrint()` to show detailed errors in console. (4) Users now see actual backend error message instead of generic HTTP status.

**Example**: Instead of "Failed to create client: 401 Unauthorized", user now sees "Failed to create client: AUTHENTICATION_ERROR: token invalid or expired" (if backend provides it).

**Files Modified**: `/lib/core/network/api_error.dart` (NEW), `/lib/features/clients/data/datasources/client_remote_datasource.dart` (all 5 methods updated)

---

### [BACKEND-008] Dev Mode POST Missing Authorization Header - ACTUALLY RESOLVED

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-09 | **Actually Fixed**: 2026-01-09

**Issue**: POST `/api/v1/clients` fails with `AUTHENTICATION_ERROR: Missing authorization header` in dev mode. GET endpoints work. Backend dependencies.get_current_user() receives `authorization: None`. Issue persisted even after instance mismatch fix.

**Actual Root Cause**: **Missing iOS Keychain Configuration** - FlutterSecureStorage requires iOS entitlements files with `keychain-access-groups` configuration. Without proper keychain setup, the official documentation states: **"values appearing to be written successfully but never actually being written"**. Tokens appeared to save (DevLogger showed success) but were never persisted to iOS Keychain, causing token reads to return null on subsequent requests. Additional issue: Default `KeychainAccessibility.unlocked` setting doesn't work properly on iOS.

**Previous Attempted Fix (Incomplete)**: Single FlutterSecureStorage instance pattern was correct but insufficient. The instance needed proper iOS/Android configuration options, and iOS entitlements files were completely missing from the project.

**Complete Fix**:
1. Created `ios/Runner/Debug.entitlements` and `ios/Runner/Release.entitlements` with keychain-access-groups
2. Updated all FlutterSecureStorage instantiations with proper options: `IOSOptions(accessibility: KeychainAccessibility.first_unlock)` and `AndroidOptions(encryptedSharedPreferences: true)`
3. Applied configuration to both dev mode (`main_dev.dart`) and production (`main.dart`)
4. Fixed `DevDataSeeder.reseedAll()` to use same configuration
5. Created comprehensive test suite (`test/core/dev/token_persistence_test.dart`) to validate token persistence

**Files Modified**:
- NEW: `/ios/Runner/Debug.entitlements`, `/ios/Runner/Release.entitlements`
- UPDATED: `/lib/main.dart` (lines 44-58), `/lib/main_dev.dart` (lines 34-43), `/lib/core/dev/seed_dev_data.dart` (lines 108-122)
- NEW: `/test/core/dev/token_persistence_test.dart` (validation tests)

**Sources**: [flutter_secure_storage documentation](https://pub.dev/packages/flutter_secure_storage), [iOS configuration issues](https://github.com/mogol/flutter_secure_storage/issues/532)

---

## Resolved Bugs

### [BACKEND-007] Client Creation Returns 404 "Trainer Not Found" in Dev Mode

**Status**: `Resolved` | **Priority**: `Critical` | **Reported**: 2026-01-08

**Issue**: POST `/api/v1/clients` returned 500 errors when creating clients with dev JWT tokens. Two root causes: (1) Database column datetime type mismatch (timezone-aware vs naive), (2) Dev trainer user never inserted into database, causing FK constraint violation.

**Root Cause**: (1) BaseModel used `DateTime(timezone=True)` but PostgreSQL stored as `TIMESTAMP WITHOUT TIME ZONE`, causing "can't subtract offset-naive and offset-aware datetimes" error. (2) Dev tokens create random UUID User objects not in DB; Client insertion referenced non-existent trainer_id. (3) Client model had `age: String` but schema required `int`.

**Fix**: (1) Changed BaseModel datetime columns to timezone-naive UTC (`.replace(tzinfo=None)`). (2) Dependencies.py dev user creation now uses naive datetimes. (3) Clients.py endpoint checks if trainer exists in DB; if not, inserts dev trainer or uses existing email-matched user. (4) Client model age column changed from String to Integer. (5) ClientResponse schema UUID fields changed from `str` to `UUID` type.

**Files**: `/backend/app/models/base.py`, `/backend/app/api/dependencies.py`, `/backend/app/api/v1/clients.py`, `/backend/app/models/client.py`, `/backend/app/schemas/client.py`

---

## Resolved Bugs (Archive)

### [BACKEND-006] Dev JWT Mock User Missing Subscription Fields

**Status**: `Resolved` | **Priority**: `High` | **Reported**: 2026-01-08

**Issue**: Frontend in dev mode got 404 "User not found" on GET `/api/v1/auth/me/subscription` despite valid JWT token. Subscription endpoint tried to query database for dev user UUID, which doesn't exist.

**Root Cause**: (1) Dev JWT creates mock User object with random UUID in `dependencies.py` but doesn't initialize subscription fields (plan, status, stripe_id, max_clients). (2) SubscriptionService always queries database for user, never accepting in-memory dev user object.

**Fix**: (1) Initialize subscription fields on dev user creation (plan='free', status='active', max_clients=5). (2) SubscriptionService.get_user_subscription_info accepts optional user_obj parameter to use dev user directly instead of querying DB. (3) Auth endpoint passes current_user object to service.

**Files**: `/backend/app/api/dependencies.py`, `/backend/app/services/subscription_service.py`, `/backend/app/api/v1/auth.py`

---

### [BACKEND-005] Trainer Stats Endpoint 500 Error

**Status**: `Resolved` | **Priority**: `High` | **Reported**: 2026-01-08

**Issue**: GET `/api/v1/trainer/stats` returned 500 "AttributeError: 'WorkoutAssignment' has no attribute 'trainer_id'"

**Root Cause**: Query used wrong column name `WorkoutAssignment.trainer_id` but model uses `assigned_by` (FK to users.id for trainer/admin who assigned)

**Fix**: Changed line 82 in `/backend/app/api/v1/trainer.py` from `WorkoutAssignment.trainer_id` to `WorkoutAssignment.assigned_by`

**Files**: `/backend/app/api/v1/trainer.py`

---

### [THEME-001] Theme Preference Not Persisting Over Sessions

**Status**: `Resolved` | **Priority**: `High` | **Reported**: 2026-01-08

**Issue**: Theme preference reverted to Light after app restart (e.g., change to Dark → close app → restart → reverts to Light) in both `main.dart` and `main_dev.dart`

**Root Cause**: `ThemeModeNotifier.initialize()` was called in `main.dart` but NOT in `main_dev.dart`. Dev entry point created new instance without loading saved preference.

**Fix**: (1) `main.dart`: Call `themeNotifier.initialize()` before ProviderScope. (2) `main_dev.dart`: Added same initialization before DevDataSeeder to match production flow.

**Files**: `/lib/main.dart`, `/lib/main_dev.dart`, `/test/core/theme/theme_provider_test.dart` (tests verified)

---

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
