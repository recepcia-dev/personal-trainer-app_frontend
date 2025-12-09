# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Flutter mobile app for personal trainers and clients. Cross-platform (iOS/Android) with offline-first architecture, dual authentication flows, and Stripe payments.

## Architecture
**Clean Architecture + Riverpod**
- **Dependency Rule**: Presentation → Domain ← Data (dependencies point inward)
- **Domain Layer**: Pure Dart, no Flutter dependencies
- **Use Cases**: Encapsulate business logic
- **Riverpod**: Dependency injection and state management

Feature structure: `lib/features/<feature>/data|domain|presentation/`

## ⚠️ Project-Specific Warnings (CRITICAL)

### Security & Sensitive Data
- **NEVER commit `.env` files** - Contains Stripe keys, Firebase config, API secrets
- **Auth tokens MUST use `flutter_secure_storage`** - NEVER use `shared_preferences` for tokens
- **Client fitness/health data is PII** - Implement proper data encryption and GDPR compliance
- **Stripe webhook signatures MUST be verified** - Prevents payment fraud/manipulation

### Database & Migrations
- **Schema changes require migration strategy** - Increment `schemaVersion` and implement `onUpgrade`
- **Test migrations thoroughly** - Write tests in `test/database/migrations/`
- **NEVER delete tables without migration** - Data loss is unacceptable
- **Foreign key constraints** - Enable with `pragma foreign_keys = ON`

### Code Generation
- **ALWAYS run build_runner with `--delete-conflicting-outputs`** - Prevents merge conflicts
- **Run build_runner after EVERY generated code change** - Riverpod, Drift, Freezed, JSON serialization
- **Watch mode for active development** - Use `watch` instead of rebuilding manually

### Payment & Financial
- **Test ALL payment flows in Stripe test mode** - NEVER test with real cards in development
- **Handle payment failures gracefully** - Network errors, insufficient funds, card declined
- **Log failed payments for manual retry** - Store payment intent IDs for reconciliation
- **Subscription cancellation must be reversible** - Implement grace period (24-48 hours)

### Performance & Rate Limiting
- **Cache images aggressively** - Use `cached_network_image` with proper cache policy
- **Paginate large lists** - Workouts, clients, exercises (20-50 items per page)
- **Debounce search inputs** - Wait 300ms before triggering API calls
- **Firebase quota limits** - Free tier has daily limits for FCM, Analytics, Crashlytics

### Documentation Requirements
- **All documentation goes in `doc/` directory** - Architecture decisions, API docs, deployment guides
- **Update `doc/progress.md` after major milestones** - Track implementation progress
- **Log bugs in `doc/bug.md`** - Include reproduction steps and stack traces
- **Architectural decisions in `doc/decision.md`** - ADR format: Context, Decision, Consequences

## Commands

### Flutter
```bash
# Code generation (run after modifying @riverpod, Drift tables, Freezed classes)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate during development)
flutter pub run build_runner watch --delete-conflicting-outputs

# Testing
flutter test --coverage                    # All tests with coverage
flutter test test/features/auth/          # Specific feature tests
flutter test --plain-name "LoginTrainer"  # Single test by name

# Analysis
flutter analyze

# Clean build (when facing caching issues)
flutter clean && flutter pub get
```

### Backend (FastAPI)
```bash
uv run uvicorn main:app --reload           # Development server
uv run pytest                              # Run tests
uv run ruff check .                        # Lint
```

## Critical Architecture Rules

### 1. Offline-First Pattern (MANDATORY)
All repository methods MUST follow this pattern:
```dart
Future<Either<Failure, T>> getData() async {
  if (await networkInfo.isConnected) {
    try {
      // 1. Fetch from remote
      final remote = await remoteDataSource.getData();
      // 2. Cache locally
      await localDataSource.cacheData(remote);
      return Right(remote);
    } catch (e) {
      // 3. Fallback to cache on error
      return _getLocalData();
    }
  }
  // 4. Offline: use cache
  return _getLocalData();
}
```

For mutations: save locally first, mark for sync, then attempt remote sync.

### 2. Clean Architecture Layers
- **Presentation**: Screens, Widgets, Riverpod State Providers (`@riverpod class`)
- **Domain**: Entities, Repository interfaces, Use Cases (pure Dart)
- **Data**: Models (Freezed), Repository implementations, Data Sources (remote/local)

**Rule**: Domain layer NEVER imports Flutter or data layer. Data layer implements domain interfaces.

### 3. State Management (Riverpod)
- Use code generation: `@riverpod` annotation
- State providers in `presentation/providers/`
- Repository providers in `data/repositories/`
- Use `AsyncNotifier` for mutable state
- Use `FutureProvider` for read-only async data

### 4. Authentication (Two-Tier System)
- **Trainers**: Email/password (`lib/features/auth/data/datasources/auth_remote_datasource.dart:loginTrainer`)
- **Clients**: Magic link + OTP/PIN (`lib/features/auth/data/datasources/auth_remote_datasource.dart:sendMagicLink`)
- **Token Storage**: ALWAYS use `flutter_secure_storage`, NEVER `shared_preferences`

### 5. Database (Drift/SQLite)
- All tables in `lib/database/tables/`
- DAOs in `lib/database/daos/`
- After modifying tables: run `build_runner`
- Mark unsynced records with `isSynced: false` flag

## Key Files
- `plan.md` - Complete implementation plan with all architectural decisions
- `lib/core/router/app_router.dart` - go_router navigation configuration
- `lib/database/app_database.dart` - Drift database schema
- `lib/core/constants/api_endpoints.dart` - Backend API routes
- `.env.development` / `.env.production` - Environment variables (NEVER commit)

## Testing Requirements
- **Minimum 80% coverage** for domain layer (use cases, entities)
- **Widget tests** required for all screens
- **Integration tests** for: authentication flows, payment flows, offline sync
- Mock external dependencies: use `mocktail` for repositories/data sources

## Common Issues

### Build Runner Conflicts
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Riverpod State Not Updating
Restart watch mode or rebuild:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Drift Migration Errors
1. Check `schemaVersion` in `lib/database/app_database.dart`
2. Implement `onUpgrade` callback
3. Test migration with: `flutter test test/database/`

### iOS Build Fails
Verify Xcode command line tools:
```bash
xcode-select --install
```

## Payment Integration (Stripe)
- Store Stripe keys in environment variables
- Test mode: `pk_test_...` (development)
- Live mode: `pk_live_...` (production)
- Always handle payment errors gracefully
- Log failed payments for retry

## Repository Etiquette
- Branch naming: `feature/<description>` or `bugfix/<description>`
- Branch from `develop`, PR to `develop`
- Before pushing: `flutter analyze && flutter test`
- Update `doc/progress.md` after major milestones
- Log architectural decisions in `doc/decision.md`
- Report bugs in `doc/bug.md` with reproduction steps

## Technology Stack
**Frontend (Flutter)**
- State: Riverpod 2.5+
- Navigation: go_router
- Database: Drift (SQLite)
- Network: Dio
- Payments: flutter_stripe
- Auth: flutter_secure_storage + local_auth (biometrics)

**Backend (FastAPI)**
- Python 3.12+
- Pydantic for validation
- PostgreSQL (production)

**Infrastructure**
- Firebase: Push notifications, Analytics, Crashlytics
- GitHub Actions: CI/CD
- TestFlight: iOS beta distribution
- Firebase App Distribution: Android beta