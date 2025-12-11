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

## 🔄 Agent Session Workflow (MANDATORY)

**This project follows the long-running agent harness pattern from Anthropic Research.**

### Every Session MUST Start With:
1. **Verify working directory**: `pwd` - confirm you're in project root
2. **Read progress files**:
   - `claude-progress.txt` - what was completed in previous sessions
   - `git log --oneline -10` - recent commits
   - `features.json` - current feature status
   - Use context7 MCP (if available) or web search for external documentation (Example: Before implementing payment features, fetch Stripe Flutter documentation)
3. **Run initialization**: `./init.sh` - sets up environment
4. **Startup validation**:
   ```bash
  PATH="$HOME/flutter/bin:$PATH" && flutter analyze          # Check for code issues
   PATH="$HOME/flutter/bin:$PATH" && flutter test             # Run existing tests
   ```
5. **Review next feature**: Check `features.json` for next feature with `"passes": false`

### One Feature Per Session Rule
- **NEVER work on multiple features in one session**
- **ALWAYS complete verification steps** before marking feature as passing
- **COMMIT immediately** after completing a feature
- **UPDATE claude-progress.txt** with session summary

### ⚠️ VERIFICATION IS NON-NEGOTIABLE
**DO NOT mark `"passes": true` in features.json unless you have personally executed EVERY verification step listed for that feature.**

Each feature in `features.json` has a `"verification"` array with explicit, testable steps. These are NOT suggestions—they are REQUIREMENTS:

```json
{
  "id": "F001",
  "verification": [
    "Step 1: explicit command to run",
    "Step 2: explicit file to check",
    "Step 3: explicit assertion to verify"
  ]
}
```

**Before marking a feature as passing:**
1. Execute each verification step in order
2. Confirm the expected result for each step
3. Document the results in claude-progress.txt
4. ONLY THEN set `"passes": true` and commit

**If ANY verification step cannot be completed:**
- Leave `"passes": false`
- Document the blocker in claude-progress.txt
- Do NOT commit the feature as passing
- Example: "Cannot run `flutter --version` because Flutter SDK is not installed"

### Session End Checklist:
1. ✓ Feature implementation code written
2. ✓ **Feature verification steps EXECUTED and PASSED (100% required)**
3. ✓ Tests written/updated for the feature
4. ✓ Git commit with descriptive message
5. ✓ Update features.json: set `"passes": true` (ONLY if step 2 complete)
6. ✓ Update claude-progress.txt with session summary
7. ✓ **Handle any persistent bugs**:
   - If encountered persistent bugs/errors that required workarounds:
     * Ask user: "Would you like me to add this bug to `doc/bug.md`?"
     * If yes: Document in bug.md with full details (status, environment, steps, resolution)
     * If no: Note in claude-progress.txt for future reference
   - If bug already exists in bug.md: Reference it and verify resolution matches documented approach
8. ✓ Push to remote (if appropriate)

### Example Session Flow:
```bash
# Session start
pwd
cat claude-progress.txt
git log --oneline -10
./init.sh

# Check features.json for next feature (e.g., F001)
cat features.json | grep -A 10 '"id": "F001"'

# Implement F001 following Clean Architecture
# Write tests, create code, follow patterns from CLAUDE.md

# CRITICAL: Run EACH verification step from features.json
echo "=== F001 Verification Steps ==="
# Step 1: Run 'flutter --version' and verify version >= 3.19.0
flutter --version

# Step 2: Check lib/ folder structure matches plan.md architecture
ls -la lib/

# Step 3: Verify pubspec.yaml exists with correct app name
grep '^name:' pubspec.yaml

# If ALL verification steps pass:
git add .
git commit -m "feat: implement feature F001 description"

# ONLY AFTER verification is complete:
# Update features.json: F001 "passes": true
# Update claude-progress.txt with verification results and summary
```

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
- **Update `claude-progress.txt` after EVERY session** - Session log for agent continuity
- **Update `features.json` after completing features** - Mark `"passes": true` with verification
- **Update `doc/progress.md` after major milestones** - Track implementation progress
- **Log bugs in `doc/bug.md`** - Include reproduction steps and stack traces
- **Architectural decisions in `doc/decision.md`** - ADR format: Context, Decision, Consequences

## Commands

### ⚠️ CRITICAL: Flutter PATH Setup
**ALL Flutter commands MUST be prefixed with PATH export.** Flutter is not in default PATH:
```bash
export PATH="$HOME/flutter/bin:$PATH" && flutter <command>
```

### Flutter
```bash
# ALWAYS use this pattern for every Flutter command (PATH export required)

# Code generation (run after modifying @riverpod, Drift tables, Freezed classes)
export PATH="$HOME/flutter/bin:$PATH" && flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate during development)
export PATH="$HOME/flutter/bin:$PATH" && flutter pub run build_runner watch --delete-conflicting-outputs

# Testing
export PATH="$HOME/flutter/bin:$PATH" && flutter test --coverage                    # All tests with coverage
export PATH="$HOME/flutter/bin:$PATH" && flutter test test/features/auth/          # Specific feature tests
export PATH="$HOME/flutter/bin:$PATH" && flutter test --plain-name "LoginTrainer"  # Single test by name

# Analysis
export PATH="$HOME/flutter/bin:$PATH" && flutter analyze

# Clean build (when facing caching issues)
export PATH="$HOME/flutter/bin:$PATH" && flutter clean && flutter pub get

# Chaining multiple commands (set PATH once):
export PATH="$HOME/flutter/bin:$PATH" && \
  flutter analyze && \
  flutter test && \
  flutter pub run build_runner build --delete-conflicting-outputs
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

### 4. Authentication (Unified Passwordless System)
**No credentials stored. All users authenticate via magic links + device-bound biometric/PIN.**

Flow (Sequential):
1. User enters email → Backend sends magic link via email
2. User enters code from email → Backend verifies code validity
3. User authenticates locally with device (biometric/PIN) → `local_auth` package
4. Token stored securely → `flutter_secure_storage` (NEVER `shared_preferences`)

Methods in `AuthRepository`:
- `sendMagicLink(email)` - Initiates passwordless flow, sends email link
- `verifyMagicLink(email, code)` - Validates code, returns authenticated user
- Device-bound auth happens in presentation layer via `local_auth` (Touch ID, Face ID, PIN)

Security principles:
- **Zero password storage** - Email/code based, device-bound verification prevents token reuse on other devices
- **Time-limited codes** - Codes expire after 10-15 minutes (backend responsibility)
- **Biometric/PIN binding** - Each authentication attempt requires device verification (cannot complete on different device)
- **Secure token storage** - Use `flutter_secure_storage` with encryption
- **Token refresh** - Implement short-lived tokens with secure refresh mechanism

### 5. Database (Drift/SQLite)
- All tables in `lib/database/tables/`
- DAOs in `lib/database/daos/`
- After modifying tables: run `build_runner`
- Mark unsynced records with `isSynced: false` flag

## Key Files

### Project Management (READ THESE FIRST)
- **`features.json`** - Granular feature list with verification steps (SOURCE OF TRUTH for what to implement)
- **`claude-progress.txt`** - Session-by-session work log (UPDATE after every session)
- **`init.sh`** - Environment setup script (RUN at start of each session)

### Documentation
- `plan.md` - Complete implementation plan with all architectural decisions
- `CLAUDE.md` - This file - development guidelines
- `doc/progress.md` - High-level milestone tracking
- `doc/decision.md` - Architectural decision records (ADRs)
- `doc/bug.md` - Bug tracking with reproduction steps

### Code (will be created during implementation)
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
- Before starting a new task, recommend which model to use and confirm choice.
- Before starting a new task, recommend which model to use and confirm choice.