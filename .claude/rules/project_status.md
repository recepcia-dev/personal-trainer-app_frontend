# Personal Trainer App - Project Status

**Last Updated**: 2026-01-06
**Project**: Flutter Personal Trainer App (iOS/Android)
**Status**: Active Development
**Architecture**: Clean Architecture + Riverpod State Management

---

## 📊 Project Overview

A cross-platform mobile application for personal trainers and clients featuring:
- **Dual authentication flows**: Trainers (email/password), Clients (magic link + OTP)
- **Offline-first architecture**: Full functionality without internet, background sync when available
- **Real-time collaboration**: Workout planning, progress tracking, messaging
- **Payment integration**: Stripe for subscriptions and one-time payments
- **Biometric security**: Touch ID, Face ID, PIN on device
- **Cross-platform**: iOS and Android with shared Dart codebase

---

## 🏗️ Architecture Foundation

### Core Pattern
**Clean Architecture + Riverpod 2.5+**
- **Dependency Rule**: Presentation → Domain ← Data (dependencies point inward only)
- **Layers**:
  - **Domain**: Pure Dart, no Flutter dependencies (use cases, entities, repository interfaces)
  - **Data**: Repository implementations, data sources (remote/local), models with Freezed
  - **Presentation**: Screens, widgets, Riverpod state providers (AsyncNotifier, FutureProvider)

### Key Technologies
| Component | Technology | Version |
|-----------|-----------|---------|
| State Management | Riverpod | 2.5+ |
| Navigation | go_router | Latest |
| Database | Drift (SQLite) | Latest |
| HTTP Client | Dio | Latest |
| Payment | flutter_stripe | Latest |
| Auth | flutter_secure_storage + local_auth | Latest |
| Code Gen | build_runner, Freezed | Latest |
| Testing | flutter test + mocktail | Latest |
| Analytics | Firebase Analytics | Latest |
| Push Notifications | Firebase Cloud Messaging | Latest |
| Crash Reporting | Firebase Crashlytics | Latest |

---

## 📋 Feature Implementation Status

**Total Features**: 46 (from `features.json`)
**Categories**:
- Authentication (F001-F007): Magic link, OTP, biometric, session management
- Trainer Dashboard (F008-F015): Client management, analytics, scheduling
- Workout Management (F016-F025): Workout creation, exercises, progress tracking
- Client Features (F026-F032): Workout completion, progress visualization, messaging
- Payments (F033-F037): Subscription, one-time payments, invoicing
- Analytics & Reporting (F038-F042): Performance metrics, charts, export
- Admin & Settings (F043-F046): User management, app settings, notifications

**Current Progress**:
- ✅ **Architecture & Setup**: Complete (structure defined, Riverpod/Drift configured)
- ✅ **Documentation**: CLAUDE.md, plan.md, architecture.md created
- 🔄 **Feature Implementation**: Pending (check `features.json` for detailed status)
- ⚠️ **Testing**: Framework set up, implementation in progress
- ⚠️ **Backend API**: Contracts defined, implementation status unknown (separate project)

---

## ✨ Completed Work

### Documentation
- ✅ `CLAUDE.md` - Development guidelines and architecture rules
- ✅ `plan.md` - Comprehensive implementation plan (1540 lines)
- ✅ `architecture.md` - Synthesized architectural reference guide (22 sections)
- ✅ `features.json` - Granular feature tracking with verification steps
- ✅ `testing-guideline.md` - Testing standards and requirements

### Project Structure
- ✅ Directory hierarchy defined in plan.md
- ✅ Feature module organization established
- ✅ Layer separation patterns documented
- ✅ Code generation guidelines specified

### Development Setup
- ✅ `init.sh` script created for environment setup
- ✅ Flutter PATH configuration documented
- ✅ Build runner commands established
- ✅ Test command patterns documented

---

## ⚙️ Current Focus Areas

### 1. **Authentication System** (Priority: HIGH)
- **Status**: Architecture designed, implementation pending
- **Key Features**:
  - Trainer login (email/password)
  - Client magic link + OTP flow
  - Device-bound biometric verification (Touch ID, Face ID, PIN)
  - Secure token storage (FlutterSecureStorage, NOT SharedPreferences)
  - Token refresh mechanism
- **Files to Implement**:
  - `lib/features/auth/domain/usecases/` - LoginTrainer, SendMagicLink, VerifyOtp
  - `lib/features/auth/data/datasources/` - AuthRemoteDataSource, AuthLocalDataSource
  - `lib/features/auth/data/repositories/` - AuthRepositoryImpl
  - `lib/features/auth/presentation/providers/` - AuthStateProvider
  - `lib/features/auth/presentation/screens/` - LoginScreen, OtpScreen, BiometricScreen

### 2. **Database Layer** (Priority: HIGH)
- **Status**: Schema designed in plan.md, Drift tables pending
- **Key Tables**:
  - Users (trainers + clients)
  - Workouts, Exercises, WorkoutLogs
  - Clients (for trainers)
  - Subscriptions, PaymentHistory
  - SyncQueue (for offline-first)
- **Files to Create**:
  - `lib/database/tables/` - Table definitions with Drift annotations
  - `lib/database/daos/` - Data Access Objects for each table
  - `lib/database/app_database.dart` - Main Drift database definition

### 3. **Offline-First Sync** (Priority: HIGH)
- **Status**: Architecture pattern documented, implementation pending
- **Pattern**:
  - Read operations: Try remote → cache → offline
  - Write operations: Save locally → mark for sync → attempt remote
  - Background sync service (periodic intervals)
  - SyncQueue table tracking pending changes
- **Files to Implement**:
  - `lib/core/services/sync_service.dart` - Background sync orchestration
  - `lib/database/daos/sync_queue_dao.dart` - Manage pending syncs
  - Repository pattern (each repository handles sync logic)

### 4. **Navigation** (Priority: MEDIUM)
- **Status**: Router architecture designed, implementation pending
- **Approach**: Typed routes with go_router
- **Key Routes**:
  - `/splash` → `/:role/dashboard` → feature-specific screens
  - Authentication guards (redirect unauthenticated users)
  - Deep linking support
- **Files to Create**:
  - `lib/core/router/app_router.dart` - Main router configuration
  - Route definitions for each feature

### 5. **Testing Infrastructure** (Priority: MEDIUM)
- **Status**: Patterns documented, test implementation in progress
- **Coverage Targets**:
  - Domain layer: 80%+
  - Data layer: 70%+
  - Presentation: 60%+
  - Overall: 70%+
- **Test Types**:
  - Unit tests (domain, data layer)
  - Widget tests (screens, UI)
  - Integration tests (offline sync, authentication flows)
  - Mocking: mocktail for repositories, mock Dio for API calls

---

## ⚠️ Known Issues & Blockers

### Critical (Blocking Development)
| Issue | Impact | Status | Resolution |
|-------|--------|--------|-----------|
| Flutter SDK PATH configuration | Commands fail without PATH export | ⚠️ Active | PREFIX all Flutter commands with `export PATH="$HOME/flutter/bin:$PATH"` |
| Backend API status | Frontend depends on API contracts | ❓ Unknown | Clarify if backend is implemented or still pending |
| Drift migration strategy | Schema changes without migration = data loss | 📋 Pending | Implement version increments + onUpgrade callbacks |

### Warnings (Non-Blocking but Important)
- **No `.env` file committed** - Stripe keys, Firebase config must be environment variables
- **Token storage** - MUST use FlutterSecureStorage, NOT SharedPreferences
- **Build runner** - MUST use `--delete-conflicting-outputs` to prevent merge conflicts
- **Code generation** - MUST run after EVERY modification to @riverpod, Drift tables, Freezed classes

---

## 🔐 Security Checklist

### Authentication
- [ ] Magic link codes are time-limited (10-15 min expiry)
- [ ] Device binding enforces biometric/PIN on each auth attempt
- [ ] Access tokens are short-lived (15-30 min)
- [ ] Refresh tokens stored securely with rotation policy
- [ ] No passwords stored (passwordless system)

### Data Protection
- [ ] PII (fitness/health data) encrypted at rest
- [ ] HTTPS enforced for all API communications
- [ ] Certificate pinning implemented (optional but recommended)
- [ ] Secure token storage via FlutterSecureStorage
- [ ] Local database encrypted (Drift with `sqlcipher`)

### Payment Security
- [ ] Stripe webhook signatures validated
- [ ] No credit card data stored locally
- [ ] Payment test mode strictly enforced in development
- [ ] Failed payments logged with manual retry capability

---

## 📅 Development Workflow

### Session Start (REQUIRED)
1. Run `./init.sh` to set up environment
2. Read `claude-progress.txt` - what was completed previously
3. Check `features.json` for next feature (with `"passes": false`)
4. Run `flutter analyze && flutter test` to validate current state

### Feature Implementation (Per Feature)
1. Read feature verification steps from `features.json`
2. Implement code following Clean Architecture patterns
3. Write tests (TDD: tests first, then implementation)
4. Execute EVERY verification step
5. Commit with descriptive message
6. Update `features.json`: set `"passes": true` (only after all verification steps pass)
7. Update `claude-progress.txt` with session summary

### Pre-Commit Checklist
- [ ] `flutter analyze` - No errors
- [ ] `flutter test` - All tests pass
- [ ] Coverage meets target (check with `--coverage` flag)
- [ ] Code generation updated (`flutter pub run build_runner build --delete-conflicting-outputs`)
- [ ] No hardcoded API keys or secrets
- [ ] No real OpenAI/Stripe API calls in tests (all mocked)

---

## 📚 Key Documentation Files

| File | Purpose | Last Updated |
|------|---------|--------------|
| `CLAUDE.md` | Development guidelines, project scope, technology stack | This session |
| `plan.md` | Comprehensive implementation plan with all features | This session |
| `architecture.md` | Architectural principles, patterns, anti-patterns | This session |
| `features.json` | Frontend feature checklist with verification steps | As updated |
| `claude-progress.txt` | Session-by-session work log (last 5 sessions) | After each session |
| `doc/decision.md` | Architectural Decision Records (ADRs) | As decisions made |
| `doc/bug.md` | Bug tracking with reproduction steps | As bugs found |
| `doc/sessions-archive.md` | Older sessions (6+) for historical reference | Ongoing |

---

## 🎯 Next Immediate Steps

### Session N+1 Priority (Recommended Order)

**Phase 1: Core Infrastructure** (1-2 sessions)
1. **Authentication Setup** (F001-F007)
   - Implement AuthRepository interface and RemoteDataSource
   - Set up secure token storage (FlutterSecureStorage)
   - Create LoginScreen and MagicLinkScreen
   - Verification: Run each screen, verify token storage, test logout

2. **Database Layer** (Foundational)
   - Create Drift tables and DAOs
   - Implement ApplicationDatabase
   - Verification: Run app without errors, check database file created

3. **Offline-First Framework**
   - Implement SyncService with background worker
   - Add sync queue mechanism
   - Verification: Offline mode works, sync queue persists changes

**Phase 2: Feature Implementation** (3-4 sessions)
- Trainer dashboard (F008-F015)
- Workout management (F016-F025)
- Client features (F026-F032)

**Phase 3: Advanced Features** (5+ sessions)
- Payments with Stripe (F033-F037)
- Analytics & reporting (F038-F042)
- Admin & settings (F043-F046)

---

## 🔗 Dependencies & External Services

### Required APIs/Services
1. **Backend API** - Must be running at `https://api.personaltrainer.com`
   - Authentication endpoints
   - Workout CRUD endpoints
   - Client management endpoints
   - Payment processing endpoints

2. **Firebase**
   - Analytics
   - Cloud Messaging (FCM)
   - Crashlytics
   - Authentication (optional, using email/biometric instead)

3. **Stripe**
   - Payment processing
   - Subscription management
   - Test mode for development

4. **Email Service** (Backend responsibility)
   - SendGrid or AWS SES for magic links

---

## ✅ Success Criteria

**Project is "Done" when:**
1. All 46 features in `features.json` have `"passes": true`
2. Overall test coverage ≥ 70%
3. Domain layer coverage ≥ 80%
4. `flutter analyze` produces no errors
5. App builds and runs on iOS and Android without crashes
6. Authentication flows work end-to-end (magic link, biometric, session management)
7. Offline-first sync functions correctly (all write operations persist and sync)
8. All security checklist items completed
9. Documented in `doc/decision.md` for all major architectural decisions

---

## 📞 Quick Reference

### Common Commands
```bash
# Environment setup (run once per session)
./init.sh

# Code analysis and generation (run before commits)
flutter analyze
flutter pub run build_runner build --delete-conflicting-outputs

# Testing (run before commits)
flutter test --coverage

# Running app
flutter run

# Watch mode for code generation (during development)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Critical Rules (Do NOT Ignore)
1. 🚨 **Dependency Rule**: Domain imports NOTHING. Data imports Domain. Presentation imports Domain+Data.
2. 🚨 **Token Storage**: Use FlutterSecureStorage ONLY. Never use SharedPreferences.
3. 🚨 **API Mocking**: All tests must mock API calls. No real network requests in tests.
4. 🚨 **Offline-First**: Every repository method follows: Try remote → Cache → Offline fallback.
5. 🚨 **Code Generation**: Run after EVERY modification to @riverpod, Drift, Freezed.

---

## Document Metadata

**Version**: 1.0
**Created**: 2026-01-06
**Maintainer**: Development Team
**Related Files**: CLAUDE.md, plan.md, architecture.md, features.json, claude-progress.txt
