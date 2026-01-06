# Personal Trainer App - Frontend

Flutter mobile app for personal trainers and clients. Cross-platform (iOS/Android/Web) with offline-first architecture, dual authentication flows, and Stripe payments.

## Prerequisites

- Flutter SDK 3.19.0+ installed at `~/flutter/`
- Chrome browser (for web development)
- Backend server running (see Backend Setup section)

## Quick Start

### 1. Environment Setup

```bash
# Run initialization script (sets up environment variables)
./init.sh

# Install dependencies
flutter pub get
```

### 2. Running on Chrome

```bash
# Run the app on Chrome with hot reload
flutter run -d chrome

# Or run in release mode (optimized, faster)
flutter run -d chrome --release

# Run on a custom port
flutter run -d chrome --web-port=8080
```

### 3. Backend Setup (Required)

The frontend connects to `http://localhost:8000` for API calls. **You must start the backend server to avoid network errors.**

Open a **new terminal** and run:

```bash
cd ../backend
uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Verify backend is running:
```bash
curl http://localhost:8000/health
```

## Development Commands

### Code Generation

After modifying Riverpod providers, Drift tables, Freezed classes, or JSON serializable models:

```bash
# Generate code once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate during development)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing

```bash
# Run all tests with coverage
flutter test --coverage

# Run specific feature tests
flutter test test/features/auth/

# Run single test by name
flutter test --plain-name "LoginTrainer"
```

### Analysis & Linting

```bash
# Run static analysis
flutter analyze

# Combined: analyze + test + build
flutter analyze && flutter test && flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean Build

If you encounter caching issues:

```bash
flutter clean && flutter pub get
```

## Troubleshooting

### XMLHttpRequest / Network Error

**Symptom:** "The XMLHttpRequest onError callback was called" in Chrome console

**Cause:** Backend server is not running or not accessible at `http://localhost:8000`

**Solution:**
1. Check if backend is running: `curl http://localhost:8000/health`
2. If not running, start backend: `cd ../backend && uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000`
3. Verify `.env.development` has correct `API_BASE_URL=http://localhost:8000`

### Flutter Command Not Found

**Symptom:** `bash: flutter: command not found`

**Cause:** Flutter is not in your PATH

**Solution:** Always prefix commands with PATH export:
```bash
flutter <command>
```

### Build Runner Conflicts

**Symptom:** Conflicting outputs during code generation

**Solution:** Always use `--delete-conflicting-outputs` flag:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### CORS Errors

**Symptom:** Browser blocks requests with CORS policy errors

**Cause:** Backend CORS settings don't allow `http://localhost` origins

**Solution:** Check backend CORS configuration in `backend/app/core/config.py`

## Project Structure

```
lib/
├── core/               # Core functionality (network, auth, routing, theme)
├── database/           # Drift SQLite database (tables, DAOs)
├── features/           # Feature modules (auth, payments, workouts, etc.)
│   └── <feature>/
│       ├── data/       # Data sources, models, repository implementations
│       ├── domain/     # Entities, repository interfaces, use cases
│       └── presentation/ # Screens, widgets, providers
└── main.dart           # App entry point
```

## Architecture

- **Clean Architecture**: Separation of concerns (Presentation → Domain ← Data)
- **Riverpod**: State management and dependency injection
- **Offline-First**: Local SQLite cache with background sync
- **Code Generation**: build_runner for Riverpod, Drift, Freezed, JSON serialization

## Environment Variables

Environment variables are loaded from `.env.development` or `.env.production`:

- `API_BASE_URL` - Backend API URL (e.g., `http://localhost:8000`)
- `STRIPE_PUBLISHABLE_KEY` - Stripe public key for payments
- `FIREBASE_OPTIONS_ANDROID` - Firebase config for Android
- `FIREBASE_OPTIONS_IOS` - Firebase config for iOS

**Warning:** Never commit `.env` files to version control!

## Available Devices

Check available devices for running the app:

```bash
flutter devices
```

Example output:
```
Chrome (web)    • chrome • web-javascript • Google Chrome 140.0.7339.127
Linux (desktop) • linux  • linux-x64      • Ubuntu 24.04.2 LTS
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Project Plan](./plan.md)
- [CLAUDE.md](./CLAUDE.md) - Development guidelines for Claude Code
