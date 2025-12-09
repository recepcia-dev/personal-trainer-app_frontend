# Flutter Personal Trainer App - Complete Implementation Plan

## Project Overview
A cross-platform mobile application for personal trainers and their clients, built with Flutter targeting iOS and Android. The app supports dual authentication flows, offline-first architecture, subscription payments, and comprehensive client management features.

---

## 1. Architecture Overview

### Architecture Pattern: Clean Architecture + Riverpod

**Structure:**
```
Clean Architecture Layers:
├── Presentation Layer (UI + Riverpod State)
├── Domain Layer (Business Logic + Use Cases)
└── Data Layer (Repositories + Data Sources)
```

**Key Principles:**
- Dependency Rule: Dependencies point inward (Presentation → Domain ← Data)
- Domain layer is pure Dart (no Flutter dependencies)
- Use cases encapsulate business logic
- Riverpod providers for dependency injection

---

## 2. Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_endpoints.dart
│   │   └── storage_keys.dart
│   ├── error/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/
│   │   ├── network_info.dart
│   │   └── dio_client.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── color_schemes.dart
│   │   └── theme_provider.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_guards.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── extensions.dart
│   └── widgets/
│       ├── loading_indicator.dart
│       ├── error_widget.dart
│       └── custom_button.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── trainer_model.dart
│   │   │   │   └── client_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── trainer.dart
│   │   │   │   └── client.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_trainer.dart
│   │   │       ├── send_magic_link.dart
│   │   │       ├── verify_otp.dart
│   │   │       └── logout.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── auth_provider.dart
│   │       │   └── auth_state_provider.dart
│   │       ├── screens/
│   │       │   ├── trainer_login_screen.dart
│   │       │   ├── client_login_screen.dart
│   │       │   └── otp_verification_screen.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           └── otp_input.dart
│   ├── trainer_dashboard/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── client_management/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── workout_plans/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── subscription/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── payments/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── database/
│   ├── app_database.dart
│   ├── app_database.g.dart
│   ├── daos/
│   │   ├── trainer_dao.dart
│   │   ├── client_dao.dart
│   │   └── workout_dao.dart
│   └── tables/
│       ├── trainers_table.dart
│       ├── clients_table.dart
│       └── workouts_table.dart
└── main.dart
```

---

## 3. Package Dependencies

### pubspec.yaml - Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.0.2

  # Local Database (Drift/SQLite)
  drift: ^2.16.0
  sqlite3_flutter_libs: ^0.5.20
  path_provider: ^2.1.2
  path: ^1.9.0

  # Network
  dio: ^5.4.3+1
  connectivity_plus: ^5.0.2
  pretty_dio_logger: ^1.3.1

  # Secure Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2

  # Authentication
  crypto: ^3.0.3
  local_auth: ^2.2.0

  # Payments (Stripe)
  flutter_stripe: ^10.1.1

  # Push Notifications
  firebase_core: ^2.27.1
  firebase_messaging: ^14.7.19
  flutter_local_notifications: ^17.0.0

  # Analytics & Crashlytics
  firebase_analytics: ^10.8.9
  firebase_crashlytics: ^3.4.18

  # Deep Linking
  uni_links: ^0.5.1
  app_links: ^4.0.1

  # UI/UX
  dynamic_color: ^1.7.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  lottie: ^3.1.0
  flutter_svg: ^2.0.10+1

  # Utilities
  intl: ^0.19.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  equatable: ^2.0.5
  dartz: ^0.10.1

  # Environment Variables
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.11
  drift_dev: ^2.16.0
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  go_router_builder: ^2.4.1

  # Linting
  flutter_lints: ^3.0.1
  very_good_analysis: ^5.1.0

  # Testing
  mocktail: ^1.0.3
  integration_test:
    sdk: flutter
  patrol: ^3.6.1

  # CI/CD
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.11
```

---

## 4. State Management with Riverpod

### Provider Structure

**1. Repository Providers (Data Layer)**
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

**2. Use Case Providers (Domain Layer)**
```dart
@riverpod
LoginTrainer loginTrainer(LoginTrainerRef ref) {
  return LoginTrainer(ref.watch(authRepositoryProvider));
}
```

**3. State Providers (Presentation Layer)**
```dart
@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<User?> build() async {
    return await ref.watch(authRepositoryProvider).getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await ref.read(loginTrainerProvider)(email, password);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }
}
```

---

## 5. Navigation with go_router

### Route Configuration

```dart
@TypedGoRoute<TrainerLoginRoute>(
  path: '/trainer/login',
)
class TrainerLoginRoute extends GoRouteData {
  const TrainerLoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TrainerLoginScreen();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authState,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';

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
});
```

---

## 6. Backend Integration (FastAPI)

### API Client Setup with Dio

```dart
@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(ref),
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ),
  ]);

  return dio;
}
```

### API Endpoints Structure

```dart
class ApiEndpoints {
  // Auth endpoints
  static const String trainerLogin = '/api/v1/auth/trainer/login';
  static const String sendMagicLink = '/api/v1/auth/client/magic-link';
  static const String verifyOtp = '/api/v1/auth/client/verify-otp';
  static const String refreshToken = '/api/v1/auth/refresh';

  // Trainer endpoints
  static const String trainerProfile = '/api/v1/trainers/profile';
  static const String clients = '/api/v1/trainers/clients';

  // Workout endpoints
  static const String workouts = '/api/v1/workouts';
  static const String workoutPlans = '/api/v1/workout-plans';

  // Payment endpoints
  static const String createPaymentIntent = '/api/v1/payments/intent';
  static const String subscriptions = '/api/v1/subscriptions';
}
```

---

## 7. Authentication Implementation

### Two-Tier Authentication System

**Trainer Authentication (Email/Password)**
```dart
class AuthRemoteDataSource {
  Future<TrainerModel> loginTrainer(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.trainerLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    final tokens = TokenModel.fromJson(response.data);
    await _secureStorage.write(key: 'access_token', value: tokens.accessToken);
    await _secureStorage.write(key: 'refresh_token', value: tokens.refreshToken);

    return TrainerModel.fromJson(response.data['trainer']);
  }
}
```

**Client Authentication (Magic Link + OTP/PIN)**
```dart
class AuthRemoteDataSource {
  Future<void> sendMagicLink(String email) async {
    await _dio.post(
      ApiEndpoints.sendMagicLink,
      data: {'email': email},
    );
  }

  Future<ClientModel> verifyOtp(String email, String otp) async {
    final response = await _dio.post(
      ApiEndpoints.verifyOtp,
      data: {
        'email': email,
        'otp': otp,
      },
    );

    final tokens = TokenModel.fromJson(response.data);
    await _secureStorage.write(key: 'access_token', value: tokens.accessToken);

    return ClientModel.fromJson(response.data['client']);
  }
}
```

**Biometric Authentication**
```dart
class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

---

## 8. Local Database with Drift

### Database Setup

```dart
@DriftDatabase(tables: [Trainers, Clients, Workouts, WorkoutExercises])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(join(dbFolder.path, 'app_database.sqlite'));
      return NativeDatabase(file);
    });
  }
}
```

### Table Definitions

```dart
class Trainers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  IntColumn get trainerId => integer().references(Trainers, #id)();
  DateTimeColumn get lastSyncedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
```

### DAOs (Data Access Objects)

```dart
@DriftAccessor(tables: [Trainers, Clients])
class TrainerDao extends DatabaseAccessor<AppDatabase> with _$TrainerDaoMixin {
  TrainerDao(AppDatabase db) : super(db);

  Future<List<ClientData>> getClientsForTrainer(int trainerId) {
    return (select(clients)..where((c) => c.trainerId.equals(trainerId))).get();
  }

  Future<void> upsertClient(ClientsCompanion client) {
    return into(clients).insertOnConflictUpdate(client);
  }
}
```

---

## 9. Offline-First Architecture

### Sync Strategy

**1. Repository Pattern with Sync Logic**
```dart
class WorkoutRepositoryImpl implements WorkoutRepository {
  @override
  Future<Either<Failure, List<Workout>>> getWorkouts(int trainerId) async {
    // Check network connectivity
    if (await _networkInfo.isConnected) {
      try {
        // Fetch from remote
        final remoteWorkouts = await _remoteDataSource.getWorkouts(trainerId);

        // Cache locally
        await _localDataSource.cacheWorkouts(remoteWorkouts);

        return Right(remoteWorkouts);
      } on ServerException {
        // Fallback to local cache
        return _getLocalWorkouts(trainerId);
      }
    } else {
      // No connection, use local cache
      return _getLocalWorkouts(trainerId);
    }
  }

  Future<Either<Failure, Workout>> createWorkout(Workout workout) async {
    // Always save locally first
    final localWorkout = await _localDataSource.createWorkout(workout);

    // Try to sync with server
    if (await _networkInfo.isConnected) {
      try {
        final remoteWorkout = await _remoteDataSource.createWorkout(localWorkout);
        await _localDataSource.updateWorkout(remoteWorkout);
        return Right(remoteWorkout);
      } catch (e) {
        // Mark for later sync
        await _localDataSource.markForSync(localWorkout.id);
      }
    } else {
      await _localDataSource.markForSync(localWorkout.id);
    }

    return Right(localWorkout);
  }
}
```

**2. Background Sync Service**
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
        // Log error, continue with next item
        await ref.read(crashlyticsProvider).recordError(e, StackTrace.current);
      }
    }
  }
}
```

---

## 10. Payment Integration with Stripe

### Stripe Setup

```dart
@Riverpod(keepAlive: true)
class StripeService extends _$StripeService {
  @override
  Future<void> build() async {
    await Stripe.instance.applySettings();
  }

  Future<Either<Failure, PaymentIntent>> createPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    try {
      final response = await ref.read(dioProvider).post(
        ApiEndpoints.createPaymentIntent,
        data: {
          'amount': (amount * 100).toInt(), // Convert to cents
          'currency': currency,
        },
      );

      final clientSecret = response.data['client_secret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Personal Trainer App',
          style: ThemeMode.system,
        ),
      );

      return Right(PaymentIntent.fromJson(response.data));
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return const Right(null);
    } on StripeException catch (e) {
      return Left(PaymentFailure(e.error.localizedMessage ?? 'Payment failed'));
    }
  }
}
```

### Subscription Management

```dart
@riverpod
class SubscriptionState extends _$SubscriptionState {
  @override
  FutureOr<Subscription?> build() async {
    return await ref.read(subscriptionRepositoryProvider).getCurrentSubscription();
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

  Future<void> cancelSubscription() async {
    final subscription = state.value;
    if (subscription == null) return;

    state = const AsyncValue.loading();

    final result = await ref.read(subscriptionRepositoryProvider)
        .cancelSubscription(subscription.id);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}
```

---

## 11. Theming with Material Design 3 + Dynamic Color

### Theme Configuration

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

class AppTheme {
  static ThemeData light(ColorScheme? dynamicColorScheme) {
    final colorScheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }

  static ThemeData dark(ColorScheme? dynamicColorScheme) {
    final colorScheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
}
```

### Dynamic Color Implementation

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

---

## 12. Push Notifications

### Firebase Cloud Messaging Setup

```dart
@Riverpod(keepAlive: true)
class NotificationService extends _$NotificationService {
  @override
  Future<void> build() async {
    await _initializeFirebaseMessaging();
    await _initializeLocalNotifications();
    _setupMessageHandlers();
  }

  Future<void> _initializeFirebaseMessaging() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await _sendTokenToServer(fcmToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(_sendTokenToServer);
  }

  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _flutterLocalNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(message.data),
    );
  }
}
```

---

## 13. Analytics & Crashlytics

### Firebase Analytics

```dart
@Riverpod(keepAlive: true)
FirebaseAnalytics analytics(AnalyticsRef ref) {
  return FirebaseAnalytics.instance;
}

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logWorkoutCreated(String workoutType) async {
    await _analytics.logEvent(
      name: 'workout_created',
      parameters: {'workout_type': workoutType},
    );
  }

  Future<void> logSubscriptionPurchase(String planId, double price) async {
    await _analytics.logEvent(
      name: 'subscription_purchased',
      parameters: {
        'plan_id': planId,
        'price': price,
        'currency': 'USD',
      },
    );
  }
}
```

### Crashlytics

```dart
@Riverpod(keepAlive: true)
FirebaseCrashlytics crashlytics(CrashlyticsRef ref) {
  return FirebaseCrashlytics.instance;
}

class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics;

  void setUserIdentifier(String userId) {
    _crashlytics.setUserIdentifier(userId);
  }

  void recordError(dynamic exception, StackTrace? stack) {
    _crashlytics.recordError(exception, stack, fatal: false);
  }

  void log(String message) {
    _crashlytics.log(message);
  }
}
```

---

## 14. Deep Linking

### Setup Configuration

**Android (android/app/src/main/AndroidManifest.xml)**
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" />
    <data android:host="app.personaltrainer.com" />
</intent-filter>
```

**iOS (ios/Runner/Info.plist)**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>personaltrainer</string>
        </array>
    </dict>
</array>
```

### Deep Link Handler

```dart
@Riverpod(keepAlive: true)
class DeepLinkService extends _$DeepLinkService {
  @override
  Future<void> build() async {
    _handleInitialLink();
    _handleIncomingLinks();
  }

  Future<void> _handleInitialLink() async {
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _processDeepLink(Uri.parse(initialLink));
    }
  }

  void _handleIncomingLinks() {
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _processDeepLink(uri);
      }
    });
  }

  void _processDeepLink(Uri uri) {
    final router = ref.read(routerProvider);

    // Handle magic link authentication
    if (uri.path == '/auth/verify') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        router.go('/verify-magic-link?token=$token');
      }
    }

    // Handle workout plan sharing
    if (uri.path.startsWith('/workout/')) {
      final workoutId = uri.pathSegments.last;
      router.go('/workout/$workoutId');
    }
  }
}
```

---

## 15. Testing Strategy

### Unit Tests

```dart
void main() {
  group('LoginTrainer Use Case', () {
    late AuthRepository mockRepository;
    late LoginTrainer useCase;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = LoginTrainer(mockRepository);
    });

    test('should return Trainer when login is successful', () async {
      // Arrange
      final trainer = Trainer(id: '1', email: 'test@example.com');
      when(() => mockRepository.loginTrainer(any(), any()))
          .thenAnswer((_) async => Right(trainer));

      // Act
      final result = await useCase('test@example.com', 'password');

      // Assert
      expect(result, Right(trainer));
      verify(() => mockRepository.loginTrainer('test@example.com', 'password'));
    });
  });
}
```

### Widget Tests

```dart
void main() {
  testWidgets('Login button should trigger login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TrainerLoginScreen(),
        ),
      ),
    );

    // Enter email and password
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');

    // Tap login button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify navigation occurred
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
```

### Integration Tests with Patrol

```dart
void main() {
  patrolTest('Complete workout creation flow', (PatrolTester $) async {
    await $.pumpWidgetAndSettle(const MyApp());

    // Login
    await $('Email').enterText('trainer@example.com');
    await $('Password').enterText('password');
    await $('Login').tap();

    // Navigate to workouts
    await $('Workouts').tap();
    await $('Create Workout').tap();

    // Fill workout details
    await $('Workout Name').enterText('Morning Cardio');
    await $('Duration').enterText('30');
    await $('Save').tap();

    // Verify workout appears in list
    expect($('Morning Cardio'), findsOneWidget);
  });
}
```

---

## 16. CI/CD with GitHub Actions

### .github/workflows/flutter_ci.yml

```yaml
name: Flutter CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Run code generation
        run: flutter pub run build_runner build --delete-conflicting-outputs

      - name: Analyze code
        run: flutter analyze

      - name: Run unit tests
        run: flutter test --coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info

  build_android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Build APK
        run: flutter build apk --release

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Upload to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_ANDROID_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          groups: testers
          file: build/app/outputs/bundle/release/app-release.aab

  build_ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Build iOS (No Codesign)
        run: flutter build ios --release --no-codesign

      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: build/ios/iphoneos/Runner.app
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}
```

---

## 17. Environment Configuration

### .env files

**.env.development**
```
API_BASE_URL=http://localhost:8000
STRIPE_PUBLISHABLE_KEY=pk_test_...
FIREBASE_OPTIONS_ANDROID=...
FIREBASE_OPTIONS_IOS=...
```

**.env.production**
```
API_BASE_URL=https://api.personaltrainer.com
STRIPE_PUBLISHABLE_KEY=pk_live_...
FIREBASE_OPTIONS_ANDROID=...
FIREBASE_OPTIONS_IOS=...
```

### Loading Environment Variables

```dart
class AppConstants {
  static late String baseUrl;
  static late String stripePublishableKey;

  static Future<void> load() async {
    await dotenv.load(fileName: '.env.${const String.fromEnvironment('ENV', defaultValue: 'development')}');

    baseUrl = dotenv.env['API_BASE_URL']!;
    stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.load();
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: MyApp()));
}
```

---

## 18. Security Best Practices

### 1. Secure Storage
```dart
// Store sensitive data using flutter_secure_storage
final storage = FlutterSecureStorage();

await storage.write(key: 'access_token', value: token);
await storage.write(key: 'refresh_token', value: refreshToken);
```

### 2. Certificate Pinning
```dart
class SecurityConfig {
  static SecurityContext getSecurityContext() {
    final context = SecurityContext.defaultContext;

    // Add certificate pinning
    final certificate = File('assets/certificates/cert.pem').readAsBytesSync();
    context.setTrustedCertificatesBytes(certificate);

    return context;
  }
}
```

### 3. Input Validation
```dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
```

### 4. API Request Signing
```dart
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: 'access_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add request timestamp
    options.headers['X-Request-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();

    return handler.next(options);
  }
}
```

---

## 19. Performance Optimization

### 1. Image Optimization
```dart
CachedNetworkImage(
  imageUrl: workout.imageUrl,
  placeholder: (context, url) => const ShimmerPlaceholder(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  memCacheWidth: 800,
  maxHeightDiskCache: 1000,
  maxWidthDiskCache: 1000,
)
```

### 2. Lazy Loading Lists
```dart
ListView.builder(
  itemCount: workouts.length,
  itemBuilder: (context, index) {
    return WorkoutCard(workout: workouts[index]);
  },
)
```

### 3. Code Splitting with go_router
```dart
GoRoute(
  path: '/workout/:id',
  builder: (context, state) => const SizedBox.shrink(),
  routes: [
    GoRoute(
      path: 'details',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: WorkoutDetailsScreen(id: state.pathParameters['id']!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
  ],
)
```

---

## 20. Implementation Roadmap

### Phase 1: Foundation (Week 1-2)
- [ ] Project setup and dependencies
- [ ] Folder structure implementation
- [ ] Theme configuration (Material 3 + Dynamic Color)
- [ ] Navigation setup (go_router)
- [ ] Environment configuration
- [ ] Firebase initialization

### Phase 2: Authentication (Week 2-3)
- [ ] Trainer login (email/password)
- [ ] Client login (magic link)
- [ ] OTP verification
- [ ] Biometric authentication
- [ ] Token management and refresh
- [ ] Auth state persistence

### Phase 3: Database & Offline (Week 3-4)
- [ ] Drift database setup
- [ ] Table definitions and DAOs
- [ ] Repository pattern implementation
- [ ] Offline-first sync logic
- [ ] Background sync service

### Phase 4: Core Features (Week 4-6)
- [ ] Trainer dashboard
- [ ] Client management (CRUD)
- [ ] Workout plan creation
- [ ] Exercise library
- [ ] Progress tracking

### Phase 5: Payments (Week 6-7)
- [ ] Stripe integration
- [ ] Payment intent flow
- [ ] Subscription management
- [ ] Payment history

### Phase 6: Additional Features (Week 7-8)
- [ ] Push notifications
- [ ] Deep linking
- [ ] Analytics integration
- [ ] Crashlytics setup
- [ ] Image upload/caching

### Phase 7: Testing (Week 8-9)
- [ ] Unit tests (80%+ coverage)
- [ ] Widget tests
- [ ] Integration tests with Patrol
- [ ] E2E test scenarios

### Phase 8: CI/CD & Release (Week 9-10)
- [ ] GitHub Actions setup
- [ ] Automated testing pipeline
- [ ] Build automation
- [ ] TestFlight distribution
- [ ] Firebase App Distribution
- [ ] App Store submission
- [ ] Google Play submission

---

## 21. Code Generation Commands

### Run code generation
```bash
# Generate all code (Riverpod, Drift, Freezed, JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter pub run build_runner clean
```

---

## 22. Deployment Checklists

### iOS Deployment
- [ ] Update version in pubspec.yaml
- [ ] Update build number in ios/Runner.xcodeproj
- [ ] Configure signing certificates
- [ ] Update Info.plist with required permissions
- [ ] Test on physical iOS devices
- [ ] Create App Store Connect listing
- [ ] Upload build via Xcode or Fastlane
- [ ] Submit for review

### Android Deployment
- [ ] Update version in pubspec.yaml
- [ ] Update versionCode in android/app/build.gradle
- [ ] Generate signed APK/App Bundle
- [ ] Configure ProGuard rules
- [ ] Test on physical Android devices
- [ ] Create Google Play Console listing
- [ ] Upload bundle to Play Console
- [ ] Submit for review

---

## 23. Monitoring & Maintenance

### Production Monitoring
- Firebase Crashlytics for crash tracking
- Firebase Analytics for user behavior
- Custom logging with structured data
- Performance monitoring with Firebase Performance

### Regular Maintenance
- Dependency updates (monthly)
- Security patches (as needed)
- Database migrations (version bumps)
- API versioning strategy
- Backward compatibility testing

---

## 24. Documentation Standards

### Code Documentation
- Use meaningful variable and function names
- Add doc comments for public APIs
- Document complex algorithms
- Maintain CHANGELOG.md

### Architecture Decision Records (ADRs)
- Document major architectural decisions in `docs/adr/`
- Include context, decision, and consequences

---

## Appendix: Useful Resources

### Flutter Official
- [Flutter Documentation](https://docs.flutter.dev)
- [Material Design 3](https://m3.material.io)
- [Riverpod Documentation](https://riverpod.dev)

### Backend Integration
- [FastAPI Documentation](https://fastapi.tiangolo.com)
- [REST API Best Practices](https://restfulapi.net)

### Payment Integration
- [Stripe Flutter SDK](https://pub.dev/packages/flutter_stripe)
- [Stripe API Docs](https://stripe.com/docs/api)

### Testing
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Patrol Testing Framework](https://patrol.leancode.co)

---

## Decision Log Summary

✅ **Architecture**: Clean Architecture + Riverpod
✅ **Navigation**: go_router
✅ **Backend**: FastAPI
✅ **Authentication**: Trainers (email/password) + Clients (magic link + OTP)
✅ **Local Database**: Drift/SQLite
✅ **Payments**: Stripe (digital goods + subscriptions)
✅ **Theming**: Dynamic + Material Design 3
✅ **Offline**: Full offline-first with background sync
✅ **Testing**: Unit + Widget + Integration
✅ **CI/CD**: GitHub Actions
✅ **Distribution**: TestFlight + Firebase App Distribution
✅ **Features**: Push notifications, Analytics, Crashlytics, Biometrics, Deep linking

---

**Plan Version**: 1.0
**Last Updated**: 2025-12-09
**Status**: Ready for Implementation
