# Personal Trainer App - Architecture Guide

## Overview

This document defines the architectural principles, patterns, and structure for the Personal Trainer Flutter mobile application. It serves as the authoritative guide for maintaining consistency across the codebase.

**Core Pattern**: Clean Architecture + Riverpod State Management
**Language**: Dart/Flutter
**Target**: iOS/Android with offline-first capability

---

## 1. Architectural Principles

### 1.1 Dependency Rule (MANDATORY)
Dependencies MUST point inward only:
```
Presentation Layer
      ↓ (depends on)
Domain Layer
      ↑ (depends on)
Data Layer
```

**Violations of this rule are code review blockers.**

- Presentation layer imports Domain and Data
- Domain layer imports NOTHING (pure Dart, no Flutter imports)
- Data layer imports Domain (implements interfaces)
- NEVER: Domain→Data, Data→Presentation, Presentation→Presentation across features

### 1.2 Separation of Concerns
Each layer has distinct responsibilities:

| Layer | Responsibility | Examples |
|-------|---|---|
| **Presentation** | UI rendering, user interaction, state presentation | Screens, Widgets, Riverpod providers |
| **Domain** | Business rules, core logic, use cases | LoginTrainer, GetClientWorkouts |
| **Data** | Data retrieval/storage, API calls, local caching | Repositories, DataSources, Models |

### 1.3 Testability First
All layers must be independently testable:
- Domain layer: Pure unit tests (no mocks)
- Data layer: Mocked remote/local sources
- Presentation layer: Widget tests with mocked providers

---

## 2. Project Structure

### 2.1 Directory Hierarchy

```
lib/
├── core/                           # Shared utilities (no feature imports)
│   ├── constants/                  # app_constants.dart, api_endpoints.dart
│   ├── error/                      # failures.dart, exceptions.dart
│   ├── network/                    # network_info.dart, dio_client.dart
│   ├── router/                     # app_router.dart, route_guards.dart
│   ├── theme/                      # app_theme.dart, color_schemes.dart
│   ├── utils/                      # validators.dart, formatters.dart, extensions.dart
│   └── widgets/                    # loading_indicator.dart, error_widget.dart
│
├── features/                       # Feature modules (self-contained)
│   ├── auth/                       # Feature 1: Authentication
│   │   ├── data/
│   │   │   ├── datasources/        # Remote & local data sources
│   │   │   ├── models/             # JSON-serializable models
│   │   │   └── repositories/       # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/           # Plain Dart entities (no serialization)
│   │   │   ├── repositories/       # Repository interfaces (contracts)
│   │   │   └── usecases/           # Business logic (login_trainer.dart, send_magic_link.dart)
│   │   └── presentation/
│   │       ├── providers/          # Riverpod state providers
│   │       ├── screens/            # Screens/Pages
│   │       └── widgets/            # Feature-specific widgets
│   │
│   ├── trainer_dashboard/          # Feature 2: Trainer Dashboard
│   ├── client_management/          # Feature 3: Client Management
│   ├── workout_plans/              # Feature 4: Workout Plans
│   ├── payments/                   # Feature 5: Payments (Stripe)
│   └── subscription/               # Feature 6: Subscriptions
│
├── database/                       # Local SQLite (Drift)
│   ├── app_database.dart           # Database definition (@DriftDatabase)
│   ├── daos/                       # Data Access Objects
│   └── tables/                     # Table definitions
│
└── main.dart                       # Entry point
```

### 2.2 Feature Module Self-Containment
Each feature is a **self-contained module**:
- **Never** directly access another feature's data sources
- **Always** use repository interfaces from Domain layer
- **Cross-feature** communication happens through Riverpod providers in core or root app
- Features can depend on other features' domain/presentation exports, but NOT data layer

**Example: Correct dependency**
```dart
// ✓ Correct: Workout feature uses auth repository interface
final authRepository = ref.watch(authRepositoryProvider);

// ✗ Wrong: Direct access to auth data source
import 'features/auth/data/datasources/auth_remote_datasource.dart';
```

---

## 3. Clean Architecture Layers

### 3.1 Domain Layer (Pure Business Logic)

**Location**: `lib/features/<feature>/domain/`
**Dependencies**: None (pure Dart, no Flutter imports)

#### Entities
- Plain Dart classes representing core business objects
- Immutable and serialization-free
- No generated code (@freezed, @JsonSerializable not allowed)

```dart
// ✓ Correct: Plain entity
class Trainer {
  final String id;
  final String email;
  final String name;

  Trainer({
    required this.id,
    required this.email,
    required this.name,
  });

  @override
  bool operator ==(Object other) => identical(this, other) ||
      other is Trainer && runtimeType == other.runtimeType &&
      id == other.id && email == other.email && name == other.name;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ name.hashCode;
}
```

#### Repository Interfaces
- Define contracts between Domain and Data layers
- Enable dependency inversion and testability

```dart
abstract class AuthRepository {
  Future<Either<Failure, Trainer>> loginTrainer(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, Trainer?>> getCurrentUser();
}
```

#### Use Cases
- Encapsulate a single business rule
- Accept input parameters, return `Either<Failure, Success>`
- Called from Presentation layer via Riverpod providers

```dart
class LoginTrainer {
  final AuthRepository repository;

  LoginTrainer(this.repository);

  Future<Either<Failure, Trainer>> call(String email, String password) {
    return repository.loginTrainer(email, password);
  }
}
```

### 3.2 Data Layer (Persistence & Remote)

**Location**: `lib/features/<feature>/data/`

#### Models (Freezed + JSON Serialization)
- Implement `@freezed` with `@JsonSerializable`
- Convert to/from JSON for API communication
- **Never** expose models to Presentation layer; use Entities

```dart
@freezed
class TrainerModel with _$TrainerModel {
  const factory TrainerModel({
    required String id,
    required String email,
    required String name,
  }) = _TrainerModel;

  factory TrainerModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerModelFromJson(json);

  // Convert to Domain entity
  Trainer toEntity() => Trainer(
    id: id,
    email: email,
    name: name,
  );
}
```

#### Data Sources
- **Remote**: API calls via Dio
- **Local**: SQLite via Drift DAOs

```dart
// Remote Data Source
abstract class AuthRemoteDataSource {
  Future<TrainerModel> loginTrainer(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  @override
  Future<TrainerModel> loginTrainer(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.trainerLogin,
        data: {'email': email, 'password': password},
      );

      final tokens = TokenModel.fromJson(response.data);
      await _secureStorage.write(key: 'access_token', value: tokens.accessToken);

      return TrainerModel.fromJson(response.data['trainer']);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error');
    }
  }
}

// Local Data Source
abstract class AuthLocalDataSource {
  Future<TrainerModel?> getCachedTrainer();
  Future<void> cacheTrainer(TrainerModel trainer);
}
```

#### Repositories (Implementation)
- Implement Domain layer repository interfaces
- Orchestrate Data Sources (remote + local)
- Handle offline-first logic and error mapping

```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, Trainer>> loginTrainer(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final trainerModel = await remoteDataSource.loginTrainer(email, password);
        await localDataSource.cacheTrainer(trainerModel);
        return Right(trainerModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cachedTrainer = await localDataSource.getCachedTrainer();
        if (cachedTrainer != null) {
          return Right(cachedTrainer.toEntity());
        }
        return Left(CacheFailure('No cached trainer found'));
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }
}
```

### 3.3 Presentation Layer (UI + State)

**Location**: `lib/features/<feature>/presentation/`

#### Screens/Pages
- Extend `ConsumerWidget` or `ConsumerStatefulWidget` for Riverpod integration
- Handle **only** UI rendering and user interaction
- Delegate business logic to Riverpod providers

```dart
class TrainerLoginScreen extends ConsumerWidget {
  const TrainerLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Login')),
      body: authState.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => ErrorWidget(error: error.toString()),
        data: (trainer) => trainer != null
            ? const DashboardScreen()
            : const LoginForm(),
      ),
    );
  }
}
```

#### Riverpod Providers (State Management)

**Types of Providers**:

1. **Repository Providers** (keep alive, singleton)
   ```dart
   @Riverpod(keepAlive: true)
   AuthRepository authRepository(AuthRepositoryRef ref) {
     return AuthRepositoryImpl(
       remoteDataSource: ref.watch(authRemoteDataSourceProvider),
       localDataSource: ref.watch(authLocalDataSourceProvider),
       networkInfo: ref.watch(networkInfoProvider),
     );
   }
   ```

2. **Use Case Providers**
   ```dart
   @riverpod
   LoginTrainer loginTrainer(LoginTrainerRef ref) {
     return LoginTrainer(ref.watch(authRepositoryProvider));
   }
   ```

3. **State Providers** (AsyncNotifier for mutable state)
   ```dart
   @riverpod
   class AuthState extends _$AuthState {
     @override
     FutureOr<Trainer?> build() async {
       return await ref.watch(authRepositoryProvider).getCurrentUser();
     }

     Future<void> loginTrainer(String email, String password) async {
       state = const AsyncValue.loading();
       final result = await ref.read(loginTrainerProvider)(email, password);
       state = result.fold(
         (failure) => AsyncValue.error(failure, StackTrace.current),
         (trainer) => AsyncValue.data(trainer),
       );
     }
   }
   ```

4. **Data Providers** (FutureProvider for read-only data)
   ```dart
   @riverpod
   Future<List<Trainer>> trainers(TrainersRef ref) async {
     return ref.watch(trainerRepositoryProvider).getAllTrainers();
   }
   ```

---

## 4. Riverpod State Management

### 4.1 Provider Organization
- **Keep Alive Providers**: Repositories, services, network clients (singletons)
- **Stateless Providers**: Use cases, utilities
- **Stateful Providers**: Feature state (AsyncNotifier, StateNotifier)
- **File Placement**: `presentation/providers/` directory per feature

### 4.2 State Patterns

**AsyncNotifier Pattern** (Recommended for mutable state):
```dart
@riverpod
class WorkoutState extends _$WorkoutState {
  @override
  FutureOr<List<Workout>> build() async {
    return ref.watch(workoutRepositoryProvider).getWorkouts();
  }

  Future<void> addWorkout(Workout workout) async {
    state = const AsyncValue.loading();
    final result = await ref.read(workoutRepositoryProvider).createWorkout(workout);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (workout) => AsyncValue.data([...state.value ?? [], workout]),
    );
  }
}
```

**FutureProvider Pattern** (Read-only data):
```dart
@riverpod
Future<Trainer> currentTrainer(CurrentTrainerRef ref) async {
  return ref.watch(authRepositoryProvider).getCurrentUser();
}
```

### 4.3 Provider Invalidation
- Use `ref.invalidate()` to trigger rebuilds
- Prefer automatic invalidation through dependencies
- Only manual invalidation for side effects (logout, cache clear)

```dart
Future<void> logout(WidgetRef ref) async {
  await ref.read(authRepositoryProvider).logout();

  // Invalidate all user-dependent providers
  ref.invalidate(authStateProvider);
  ref.invalidate(currentTrainerProvider);
  ref.invalidate(workoutStateProvider);
}
```

---

## 5. Error Handling

### 5.1 Failure Hierarchy (Domain Layer)

```dart
abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}
```

### 5.2 Exception Hierarchy (Data Layer)

```dart
abstract class AppException implements Exception {
  final String message;

  AppException(this.message);
}

class ServerException extends AppException {
  ServerException(String message) : super(message);
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

class CacheException extends AppException {
  CacheException(String message) : super(message);
}
```

### 5.3 Either Pattern (dartz)

All repository methods return `Either<Failure, Success>`:
- **Left**: Failure (error case)
- **Right**: Success (success case)

```dart
Future<Either<Failure, Trainer>> loginTrainer(String email, String password);

// Usage
final result = await authRepository.loginTrainer(email, password);
result.fold(
  (failure) => showError(failure.message),  // Left (failure)
  (trainer) => navigateToDashboard(trainer),  // Right (success)
);
```

---

## 6. Offline-First Architecture

### 6.1 Sync Strategy

**Read Operations**:
```dart
Future<Either<Failure, List<Workout>>> getWorkouts(int trainerId) async {
  if (await networkInfo.isConnected) {
    try {
      // 1. Fetch from remote
      final remoteWorkouts = await remoteDataSource.getWorkouts(trainerId);

      // 2. Cache locally
      await localDataSource.cacheWorkouts(remoteWorkouts);

      return Right(remoteWorkouts);
    } on ServerException {
      // 3. Fallback to cache
      return _getLocalWorkouts(trainerId);
    }
  } else {
    // 4. Offline: use cache
    return _getLocalWorkouts(trainerId);
  }
}
```

**Write Operations**:
```dart
Future<Either<Failure, Workout>> createWorkout(Workout workout) async {
  // 1. Always save locally first
  final localWorkout = await localDataSource.createWorkout(workout);

  // 2. Try to sync with server
  if (await networkInfo.isConnected) {
    try {
      final remoteWorkout = await remoteDataSource.createWorkout(localWorkout);
      await localDataSource.updateWorkout(remoteWorkout);
      return Right(remoteWorkout);
    } catch (e) {
      // 3. Mark for later sync
      await localDataSource.markForSync(localWorkout.id);
      return Right(localWorkout);  // Return local version
    }
  } else {
    await localDataSource.markForSync(localWorkout.id);
    return Right(localWorkout);
  }
}
```

### 6.2 Background Sync Service

```dart
@Riverpod(keepAlive: true)
class SyncService extends _$SyncService {
  @override
  FutureOr<void> build() async {
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    Timer.periodic(const Duration(minutes: 5), (_) async {
      if (await ref.read(networkInfoProvider).isConnected) {
        await syncPendingChanges();
      }
    });
  }

  Future<void> syncPendingChanges() async {
    final pendingWorkouts = await ref.read(workoutDaoProvider).getPendingSync();

    for (final workout in pendingWorkouts) {
      try {
        await ref.read(workoutRepositoryProvider).syncWorkout(workout);
      } catch (e) {
        // Log and continue
        await ref.read(crashlyticsProvider).recordError(e, StackTrace.current);
      }
    }
  }
}
```

### 6.3 Drift Database (Local Storage)

**Table Definition**:
```dart
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique().nullable()();
  TextColumn get name => text()();
  IntColumn get trainerId => integer().references(Trainers, #id)();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
```

**DAO Pattern**:
```dart
@DriftAccessor(tables: [Workouts, Trainers])
class WorkoutDao extends DatabaseAccessor<AppDatabase> with _$WorkoutDaoMixin {
  WorkoutDao(AppDatabase db) : super(db);

  Future<List<WorkoutData>> getPendingSync() {
    return (select(workouts)..where((w) => w.isSynced.equals(false))).get();
  }

  Future<void> upsertWorkout(WorkoutsCompanion workout) {
    return into(workouts).insertOnConflictUpdate(workout);
  }
}
```

---

## 7. Navigation (go_router)

### 7.1 Route Definition

**Typed Routes** (Recommended):
```dart
@TypedGoRoute<TrainerDashboardRoute>(
  path: '/trainer/dashboard',
)
class TrainerDashboardRoute extends GoRouteData {
  const TrainerDashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TrainerDashboardScreen();
  }
}

@TypedGoRoute<WorkoutDetailsRoute>(
  path: '/workouts/:id',
)
class WorkoutDetailsRoute extends GoRouteData {
  final String id;

  const WorkoutDetailsRoute({required this.id});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WorkoutDetailsScreen(id: id);
  }
}
```

### 7.2 Router Provider

```dart
@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authState,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation.contains('/login');

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }
      return null;
    },
    routes: $appRoutes,
    debugLogDiagnostics: true,
  );
}
```

---

## 8. Data Validation

### 8.1 Input Validation (Presentation Layer)

Use validators in form widgets:
```dart
TextFormField(
  validator: Validators.email,
  decoration: const InputDecoration(labelText: 'Email'),
)
```

### 8.2 Validator Functions

```dart
class Validators {
  static String? email(String? value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(value!) ? null : 'Invalid email';
  }

  static String? password(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    if ((value?.length ?? 0) < 8) return 'Minimum 8 characters';
    return null;
  }
}
```

---

## 9. Authentication Flow

### 9.1 Trainer Authentication (Email/Password)

```
1. User enters email/password → TrainerLoginScreen
2. Tap login → calls authState.loginTrainer(email, password)
3. authState → calls loginTrainerUseCase
4. LoginTrainer → calls authRepository.loginTrainer()
5. AuthRepositoryImpl:
   - Calls remoteDataSource.loginTrainer() (API call)
   - Stores tokens in FlutterSecureStorage
   - Caches trainer locally
   - Returns Trainer entity
6. authState updates → Riverpod rebuilds → Navigate to dashboard
```

### 9.2 Client Authentication (Magic Link + OTP)

```
1. User enters email → sendMagicLink()
2. Backend sends OTP to email
3. User enters OTP → verifyOtp(email, otp)
4. Backend validates code → returns tokens
5. Tokens stored securely → User authenticated
```

### 9.3 Biometric Authentication

```
1. Check biometric availability: localAuth.canAuthenticate()
2. Trigger: localAuth.authenticate(localizedReason: '...')
3. On success: Allow app access (unlock local data)
4. On failure: Fallback to manual re-login
```

---

## 10. Payment Integration (Stripe)

### 10.1 Payment Flow

```dart
// Create payment intent
final result = await ref.read(stripeServiceProvider).createPaymentIntent(
  amount: 29.99,
  currency: 'USD',
);

result.fold(
  (failure) => showError(failure.message),
  (intent) async {
    // Present payment sheet
    final paymentResult = await ref.read(stripeServiceProvider).presentPaymentSheet();
    paymentResult.fold(
      (failure) => showError('Payment failed'),
      (_) => showSuccess('Payment successful'),
    );
  },
);
```

### 10.2 Subscription Management

```dart
@riverpod
class SubscriptionState extends _$SubscriptionState {
  @override
  FutureOr<Subscription?> build() async {
    return ref.watch(subscriptionRepositoryProvider).getCurrentSubscription();
  }

  Future<void> createSubscription(String priceId) async {
    state = const AsyncValue.loading();
    final result = await ref.read(subscriptionRepositoryProvider)
        .createSubscription(priceId);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (subscription) => AsyncValue.data(subscription),
    );
  }
}
```

---

## 11. Security Best Practices

### 11.1 Secure Token Storage
```dart
final secureStorage = FlutterSecureStorage();

// Store
await secureStorage.write(key: 'access_token', value: token);

// Retrieve
final token = await secureStorage.read(key: 'access_token');

// Delete (logout)
await secureStorage.delete(key: 'access_token');
```

### 11.2 Token Management
- Store access token in `FlutterSecureStorage`
- Store refresh token securely
- Implement token refresh interceptor in Dio
- Automatic refresh on 401 responses

### 11.3 Certificate Pinning (Optional)
```dart
class SecurityConfig {
  static SecurityContext getSecurityContext() {
    final context = SecurityContext.defaultContext;
    final certificate = File('assets/certificates/cert.pem').readAsBytesSync();
    context.setTrustedCertificatesBytes(certificate);
    return context;
  }
}
```

### 11.4 Input Validation
- ALWAYS validate user input in presentation layer
- ALWAYS validate API responses before parsing
- Use Pydantic models on backend for double validation

---

## 12. Theming Architecture

### 12.1 Dynamic Color + Material 3

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          title: 'Personal Trainer App',
          theme: AppTheme.light(lightDynamic),
          darkTheme: AppTheme.dark(darkDynamic),
          themeMode: themeMode.toMaterialThemeMode(),
          routerConfig: router,
        );
      },
    );
  }
}
```

### 12.2 Theme Persistence

```dart
@riverpod
class ThemeMode extends _$ThemeMode {
  @override
  ThemeModeEnum build() {
    final savedTheme = ref.read(sharedPreferencesProvider).getString('theme_mode');
    return ThemeModeEnum.values.firstWhere(
      (mode) => mode.name == savedTheme,
      orElse: () => ThemeModeEnum.system,
    );
  }

  void setThemeMode(ThemeModeEnum mode) {
    state = mode;
    ref.read(sharedPreferencesProvider).setString('theme_mode', mode.name);
  }
}
```

---

## 13. Testing Architecture

### 13.1 Unit Tests (Domain Layer)

Test pure business logic:
```dart
void main() {
  group('LoginTrainer UseCase', () {
    late AuthRepository mockRepository;
    late LoginTrainer useCase;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = LoginTrainer(mockRepository);
    });

    test('should return Trainer on successful login', () async {
      final trainer = Trainer(id: '1', email: 'test@example.com', name: 'John');
      when(() => mockRepository.loginTrainer(any(), any()))
          .thenAnswer((_) async => Right(trainer));

      final result = await useCase('test@example.com', 'password');

      expect(result, Right(trainer));
      verify(() => mockRepository.loginTrainer('test@example.com', 'password'));
    });
  });
}
```

### 13.2 Widget Tests (Presentation Layer)

Test UI with mocked providers:
```dart
testWidgets('Login form shows error on invalid input', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWithValue(
          AsyncValue.data(null),
        ),
      ],
      child: MaterialApp(home: TrainerLoginScreen()),
    ),
  );

  await tester.enterText(find.byType(TextField).first, 'invalid-email');
  await tester.tap(find.byType(ElevatedButton));

  expect(find.byType(ErrorWidget), findsOneWidget);
});
```

### 13.3 Integration Tests

Test full features with Patrol:
```dart
patrolTest('Complete login and dashboard navigation', (PatrolTester $) async {
  await $.pumpWidgetAndSettle(const MyApp());

  await $('Email').enterText('trainer@example.com');
  await $('Password').enterText('password123');
  await $('Login').tap();

  expect($('Dashboard'), findsOneWidget);
});
```

### 13.4 Coverage Requirements
- **Domain**: 80%+ (business logic critical)
- **Data**: 70%+ (API and cache logic)
- **Presentation**: 60%+ (UI logic)
- **Overall**: 70%+

---

## 14. Code Generation

### 14.1 When to Run Build Runner

```bash
# Generate all code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (recommended during development)
flutter pub run build_runner watch --delete-conflicting-outputs
```

**Run build_runner after modifying**:
- `@riverpod` annotations
- `@freezed` classes
- `@DriftDatabase` tables
- `@JsonSerializable` models
- `@TypedGoRoute` routes

### 14.2 Files to Regenerate

- `*.g.dart` (generated)
- `*.freezed.dart` (Freezed)
- `*.config.dart` (Riverpod)

**NEVER edit generated files directly!**

---

## 15. Constants & Configuration

### 15.1 API Endpoints (core/constants/api_endpoints.dart)

```dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.personaltrainer.com';

  // Auth
  static const String trainerLogin = '/api/v1/auth/trainer/login';
  static const String sendMagicLink = '/api/v1/auth/client/magic-link';
  static const String verifyOtp = '/api/v1/auth/client/verify-otp';

  // Trainer
  static const String trainerProfile = '/api/v1/trainers/profile';
  static const String clients = '/api/v1/trainers/clients';

  // Workouts
  static const String workouts = '/api/v1/workouts';
}
```

### 15.2 App Constants (core/constants/app_constants.dart)

```dart
class AppConstants {
  static const String appName = 'Personal Trainer App';
  static const String appVersion = '1.0.0';

  // Timeout durations
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Sync intervals
  static const Duration syncInterval = Duration(minutes: 5);
}
```

### 15.3 Storage Keys (core/constants/storage_keys.dart)

```dart
class StorageKeys {
  // Auth
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String currentUserId = 'current_user_id';

  // Preferences
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
}
```

---

## 16. Architectural Anti-Patterns (AVOID!)

### ❌ Anti-Pattern 1: Domain Layer Dependencies on Flutter
```dart
// WRONG
import 'package:flutter/material.dart';

class LoginTrainer {
  void login(BuildContext context) { }  // ❌ Domain imports Flutter
}
```

### ❌ Anti-Pattern 2: Direct Data Source Access from Presentation
```dart
// WRONG
final trainer = await ref.read(authRemoteDataSourceProvider).loginTrainer(email, password);
```
**Correct**: Always go through repository interface

### ❌ Anti-Pattern 3: Business Logic in Widgets
```dart
// WRONG
class TrainerLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    final response = await dio.post('/api/v1/auth/trainer/login');  // ❌ API logic in widget
    return Text('Hello');
  }
}
```
**Correct**: Move to use case/repository

### ❌ Anti-Pattern 4: Exposing Models in Presentation
```dart
// WRONG
// In presentation widget
final trainerModel = TrainerModel.fromJson({...});  // ❌ Using data model
```
**Correct**: Use domain entities

### ❌ Anti-Pattern 5: Shared Preferences for Sensitive Data
```dart
// WRONG
await sharedPreferences.setString('access_token', token);  // ❌ Insecure
```
**Correct**: Use FlutterSecureStorage

### ❌ Anti-Pattern 6: Cross-Feature Data Access
```dart
// WRONG
import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
```
**Correct**: Depend on auth repository interface from domain

---

## 17. Component Communication Patterns

### 17.1 Parent → Child
Use constructor parameters or Riverpod providers:
```dart
class WorkoutCard extends StatelessWidget {
  final Workout workout;

  const WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) => Text(workout.name);
}
```

### 17.2 Child → Parent (Callbacks)
Use VoidCallback or custom callbacks:
```dart
class EditWorkoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EditWorkoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    child: const Text('Edit'),
  );
}
```

### 17.3 Sibling Communication
Use Riverpod providers (state at root or shared):
```dart
@riverpod
class SelectedWorkoutState extends _$SelectedWorkoutState {
  @override
  Workout? build() => null;

  void select(Workout workout) => state = workout;
}

// Widget A (list)
final selectedWorkout = ref.read(selectedWorkoutStateProvider.notifier).select(workout);

// Widget B (details)
final selected = ref.watch(selectedWorkoutStateProvider);
```

---

## 18. Performance Considerations

### 18.1 Image Caching
```dart
CachedNetworkImage(
  imageUrl: trainer.photoUrl,
  placeholder: (context, url) => const ShimmerPlaceholder(),
  memCacheWidth: 800,
  maxHeightDiskCache: 1000,
  maxWidthDiskCache: 1000,
)
```

### 18.2 List Pagination
```dart
ListView.builder(
  itemCount: workouts.length,
  itemBuilder: (context, index) {
    if (index == workouts.length - 1) {
      ref.read(workoutStateProvider.notifier).loadMore();
    }
    return WorkoutCard(workout: workouts[index]);
  },
)
```

### 18.3 Debounce Search
```dart
@riverpod
Future<List<Trainer>> searchTrainers(
  SearchTrainersRef ref,
  String query,
) async {
  if (query.isEmpty) return [];

  return ref.watch(
    trainerRepositoryProvider,
  ).searchTrainers(query);
}

// In UI: use debounce with TextFormField onChange
```

---

## 19. Documentation Requirements

### 19.1 Code Comments
- Comment **why**, not **what** (code shows what)
- Document non-obvious algorithms
- Use JSDoc-style comments for public APIs

```dart
/// Authenticates a trainer with email and password.
///
/// Returns [Trainer] on success or [ServerFailure] if credentials are invalid.
/// Tokens are automatically stored securely via [FlutterSecureStorage].
Future<Either<Failure, Trainer>> loginTrainer(
  String email,
  String password,
);
```

### 19.2 Architecture Decision Records (ADR)
Document major decisions in `doc/decision.md`:
- Context: Why the decision was needed
- Decision: What was chosen
- Consequences: Trade-offs and impacts

---

## 20. Dependency Injection

### 20.1 Riverpod as DI Container
Riverpod providers are the primary DI mechanism:
```dart
@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  return Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl))
    ..interceptors.add(AuthInterceptor(ref));
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}
```

### 20.2 Overriding Providers (Testing)
```dart
testWidgets('Login success', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MyApp(),
    ),
  );
  // Test code
});
```

---

## 21. Version Control Guidelines

### 21.1 Commit Messages
```
feat: add offline sync service for workouts
fix: resolve token refresh interceptor race condition
refactor: consolidate duplicate validation logic
test: add integration tests for payment flow
docs: update architecture documentation
```

### 21.2 Branch Naming
```
feature/auth-magic-link
bugfix/payment-sheet-crash
refactor/riverpod-migration
```

---

## 22. Quick Reference

### Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Analysis & Tests
```bash
flutter analyze
flutter test --coverage
```

### Build Commands
```bash
flutter build apk --release
flutter build ipa --release
```

---

## Document Metadata

**Version**: 1.0
**Last Updated**: 2025-12-09
**Maintainer**: Development Team
**Related Files**: CLAUDE.md, plan.md, doc/decision.md
