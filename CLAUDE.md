# CLAUDE.md - Development Guidelines

## Project Goals

Cross-platform Flutter mobile app for personal trainers and clients. Offline-first architecture with passwordless authentication (magic links + device biometrics), subscription payments via Stripe, and real-time client management.

---

## Architecture

**Pattern:** Clean Architecture + Riverpod
**Key Rule:** Dependencies point inward (Presentation → Domain ← Data)

### Quick Reference
- **Presentation:** Screens, widgets, Riverpod state providers (`@riverpod class`)
- **Domain:** Entities, repository interfaces, use cases (pure Dart, no Flutter imports)
- **Data:** Models (Freezed), repository implementations, data sources (remote/local)

### Feature Structure
```
lib/features/<feature>/
├── data/          # Models, repositories, data sources
├── domain/        # Entities, use cases, repository interfaces
└── presentation/  # Screens, widgets, Riverpod providers
```

**See:** [`.claude/rules/architecture.md`](./.claude/rules/architecture.md) for complete patterns and examples.

---

## Design & UX Guidelines

**Design System:** Modern minimalist with Material 3 + dynamic color
**Typography:** Inter/SF Pro Display, dark text (`#2d2c33`), bold red accents
**Colors:** Lavender (`#d0cfef`), purple (`#9b51e0`), green (`#10b981`), pink (`#FF66C4`)

**See:** [`doc/design-system.md`](./doc/design-system.md) for full type scale, spacing, and component guidelines.

---

## Constraints & Policies

### Authentication (Mandatory)
- Magic links + device-bound biometrics/PIN (no passwords)
- Tokens stored via `flutter_secure_storage` (NEVER `shared_preferences`)
- Short-lived tokens with refresh mechanism

**See:** [`.claude/rules/security.md`](./.claude/rules/security.md)

### Database & Migrations
- Schema changes require `schemaVersion` increment + `onUpgrade` implementation
- Test migrations thoroughly in `test/database/migrations/`
- Enable foreign key constraints: `pragma foreign_keys = ON`
- Mark unsynced records: `isSynced: false` flag for offline sync

**See:** [`.claude/rules/database_schema.md`](./.claude/rules/database_schema.md)

### Code Generation
- Run **after modifying** `@riverpod`, Drift tables, Freezed classes, JSON serialization
- Always use `--delete-conflicting-outputs` flag to prevent merge conflicts

**See:** [`.claude/rules/code-generation.md`](./.claude/rules/code-generation.md)

### Offline-First (Mandatory)
All repository read methods:
1. Check network availability
2. Fetch from remote + cache locally
3. On error, fallback to cache
4. If offline, use cache

Mutations: Save locally first, mark for sync, attempt remote sync.

### Payments (Stripe)
- Test mode only in development (`pk_test_...`)
- Handle failures gracefully (network, insufficient funds, declined card)
- Log failed payments for manual retry with payment intent IDs

**See:** [`.claude/rules/payments.md`](./.claude/rules/payments.md)

### Performance
- Cache images aggressively with `cached_network_image`
- Paginate lists (20-50 items per page)
- Debounce search inputs (300ms)

**See:** [`.claude/rules/performance.md`](./.claude/rules/performance.md)

### Data Protection
- Client fitness/health data is PII → implement encryption + GDPR compliance
- NEVER commit `.env` files (contains Stripe keys, Firebase config, API secrets)
- Stripe webhook signatures MUST be verified (prevents fraud)

---

## Git Workflows

### Branch Naming
```
feature/<description>     # New features
bugfix/<description>      # Bug fixes
refactor/<description>    # Code improvements
```

### Commit Messages
```
feat: add offline sync service for workouts
fix: resolve token refresh race condition
refactor: consolidate duplicate validation
test: add integration tests for payments
docs: update architecture guide
```

### Session Start Checklist
1. **Check Persistent Bugs**: Review `.claude/rules/bug.md` for "Active Bugs"
   - If bug matches current issue, refer to notes for context
   - Update bug status if working on a known issue
2. Run tests to validate baseline: `export PATH="$HOME/flutter/bin:$PATH" && flutter test`

### Commit Checklist
1. Run code analysis: `export PATH="$HOME/flutter/bin:$PATH" && flutter analyze`
2. Run tests: `export PATH="$HOME/flutter/bin:$PATH" && flutter test --coverage`
3. Update docs (`doc/progress.md`, `doc/decision.md`, `.claude/rules/bug.md`)
   - Add new bugs to `.claude/rules/bug.md` (Active Bugs section)
   - Move to Resolved Bugs when fixed
4. Verify 80%+ domain layer coverage
5. Push to branch, open PR to `develop`

---

## Common Commands

### Backend Setup (Required for Development)
The backend must be running for the frontend to connect to APIs. Start it from the backend directory:
```bash
# Start backend (first time or after changes)
cd ~/Desktop/projects/game-changer/personal-trainer-app/backend
docker-compose up

# View logs
docker-compose logs backend

# Stop backend
docker-compose down
```

**Status Check**: Backend runs on `http://localhost:8000`

### ⚠️ Critical: Flutter PATH Setup
All Flutter commands require PATH export (Flutter not in default PATH):
```bash
export PATH="$HOME/flutter/bin:$PATH" && flutter <command>
```

### Code Generation
```bash
# Build once
export   flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (recommended during development)
export   flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing
```bash
# All tests with coverage
export PATH="$HOME/flutter/bin:$PATH" && flutter test --coverage

# Specific feature
export PATH="$HOME/flutter/bin:$PATH" && flutter test test/features/auth/

# Single test by name
export PATH="$HOME/flutter/bin:$PATH" && flutter test --plain-name "LoginTrainer"
```

### Analysis & Validation
```bash
# Code analysis
export PATH="$HOME/flutter/bin:$PATH" && flutter analyze

# Clean build (if caching issues)
export PATH="$HOME/flutter/bin:$PATH" && flutter clean && flutter pub get
```

### Chaining Commands
```bash
export   flutter analyze && \
  flutter test && \
  flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Testing Rules

### Minimum Coverage
- **Domain layer:** 80%+ (business logic critical)
- **Data layer:** 70%+ (API/cache logic)
- **Presentation layer:** 60%+ (UI logic)

### Test Structure
```dart
// ✓ Clear test names
test_parse_job_offer_with_valid_input_returns_job_model
test_parse_job_offer_with_missing_skills_raises_value_error

// ✓ Mock external dependencies
// ✓ Use fixtures for reusable test data
// ✓ Test happy path + error cases + edge cases
```

### Integration Tests
- Test complete workflows (auth, payments, offline sync)
- Focus on component interfaces, not internal implementation details
- Use real data sources where possible (not all mocked)

### Widget Tests
- All screens require widget tests
- Mock Riverpod providers: `ref.watch(authStateProvider).overrideWithValue(...)`
- Test user interactions and state changes

---

## Key Files

### Project Management
- **`features.json`** - Granular feature list with verification steps (source of truth)
- **`claude-progress.txt`** - Session-by-session work log (update after each session)
- **`init.sh`** - Environment setup (run at session start)

### Documentation
- **`plan.md`** - Complete implementation plan
- **`doc/progress.md`** - High-level milestone tracking
- **`doc/decision.md`** - Architectural decision records (ADRs)
- **`doc/bug.md`** - Bug tracking with reproduction steps
- **`doc/design-system.md`** - UI/UX guidelines
- **`doc/database_schema.md`** - Database schema reference

### Guidelines (`.claude/rules/`)
- **`bug.md`** - 🔴 **PERSISTENT BUG TRACKER** - Check at session start (Active Bugs section)
- **`architecture.md`** - Deep-dive into clean architecture patterns
- **`security.md`** - Auth, token storage, data protection
- **`database.md`** - Migrations, schema changes, Drift usage
- **`payments.md`** - Stripe integration, payment flows
- **`code-generation.md`** - Build runner, Riverpod, Freezed, JSON serialization
- **`performance.md`** - Caching, pagination, debouncing

---

## Quick Troubleshooting

**Before debugging**: Check `.claude/rules/bug.md` → "Active Bugs" section for known issues & workarounds.

| Issue | Solution |
|-------|----------|
| Build runner conflicts | `flutter pub run build_runner build --delete-conflicting-outputs` |
| Riverpod state not updating | Restart watch mode: `flutter pub run build_runner watch --delete-conflicting-outputs` |
| Drift migration errors | Check `schemaVersion` + implement `onUpgrade`, test with `flutter test test/database/` |
| iOS build fails | Install Xcode tools: `xcode-select --install` |
| **Backend 401 Unauthorized** | Check `.claude/rules/bug.md` → `[BACKEND-001]` for dev JWT config |

---

## Technology Stack

**Frontend (Flutter)**
- State: Riverpod 2.5+
- Navigation: go_router
- Database: Drift (SQLite)
- Network: Dio
- Payments: flutter_stripe
- Auth: flutter_secure_storage + local_auth (biometrics)
- UI: Material 3 + dynamic colors

**Infrastructure**
- Firebase: Push notifications, Analytics, Crashlytics
- GitHub Actions: CI/CD
- TestFlight: iOS beta distribution
- Firebase App Distribution: Android beta