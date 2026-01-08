# Code Generation Guidelines

## Build Runner Setup

### Installation
```yaml
# pubspec.yaml
dev_dependencies:
  build_runner: ^2.4.0
  # Specific generators
  riverpod_generator: ^2.3.0
  freezed_annotation: ^2.1.0
  freezed: ^2.4.0
  drift_dev: ^2.14.0
  json_serializable: ^6.7.0
```

### Commands
```bash
# Build once (clean output)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate during development - RECOMMENDED)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter pub run build_runner clean
```

**ALWAYS use `--delete-conflicting-outputs`** to prevent merge conflicts with generated code.

---

## Riverpod Code Generation

### File Structure
```
lib/features/<feature>/
├── presentation/
│   └── providers/
│       ├── auth_state_provider.dart    # @riverpod class
│       ├── user_provider.dart          # @riverpod
│       └── login_providers.dart        # Multiple @riverpod functions
```

### Riverpod Annotations

#### State Provider (Mutable)
```dart
// ✓ Use for feature state with mutations
@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<User?> build() async {
    return await ref.watch(authRepositoryProvider).getCurrentUser();
  }

  // Mutations
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await ref.read(loginUseCaseProvider)(email, password);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }
}
```

#### Future Provider (Read-Only)
```dart
// ✓ Use for read-only async data
@riverpod
Future<List<Workout>> userWorkouts(UserWorkoutsRef ref) async {
  return await ref.watch(workoutRepositoryProvider).getWorkouts();
}
```

#### Stream Provider (Real-Time)
```dart
// ✓ Use for real-time data streams
@riverpod
Stream<PaymentStatus> paymentStatus(
  PaymentStatusRef ref,
  String paymentId,
) {
  return ref.watch(paymentRepositoryProvider).watchPaymentStatus(paymentId);
}
```

#### Function Provider (Utility)
```dart
// ✓ Use for dependencies and utilities
@riverpod
String formatDate(FormatDateRef ref, DateTime date) {
  return DateFormat.yMMMd().format(date);
}
```

### Generated Files
After adding `@riverpod` annotations:

```bash
export   flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `auth_state_provider.g.dart` - Provider implementations
- Contains: `authStateProvider`, `authStateNotifier`, etc.

**NEVER edit `.g.dart` files directly!**

---

## Freezed Data Classes

### Model Definition
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? name,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### Immutability & Value Objects
```dart
// Freezed generates:
// - Immutable copyWith() method
// - toString() with all fields
// - equality (==) and hashCode
// - fromJson/toJson if JSON annotation added

final user1 = User(id: '1', email: 'test@example.com');
final user2 = user1.copyWith(email: 'new@example.com');

// Equality based on values, not reference
assert(user1 != user2);  // Different email
```

### Union Types (Pattern Matching)
```dart
@freezed
abstract class AsyncResult<T> with _$AsyncResult<T> {
  const factory AsyncResult.loading() = Loading<T>;
  const factory AsyncResult.error(String message) = Error<T>;
  const factory AsyncResult.success(T data) = Success<T>;
}

// Use with pattern matching
result.when(
  loading: () => ShowLoadingSpinner(),
  error: (msg) => ShowError(msg),
  success: (data) => ShowData(data),
);
```

### After Defining
```bash
export   flutter pub run build_runner build --delete-conflicting-outputs
```

Generates:
- `user.freezed.dart` - Immutability implementation
- `user.g.dart` - JSON serialization (if added)

---

## JSON Serialization

### With Freezed
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    @JsonKey(name: 'user_id') required String id,
    required String email,
    @JsonKey(fromJson: _dateTimeFromJson) DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

// Custom JSON converters
DateTime _dateTimeFromJson(String? dateStr) {
  return dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
}
```

### API Response Handling
```dart
// ✓ Validate API response before parsing
Future<Either<Failure, User>> getUser(String userId) async {
  try {
    final response = await dio.get('/users/$userId');

    // Validate response structure
    if (!response.data.containsKey('id')) {
      return Left(ServerFailure('Invalid user response'));
    }

    final user = UserModel.fromJson(response.data);
    return Right(user.toEntity());  // Convert model to entity
  } on DioException catch (e) {
    return Left(ServerFailure(e.message ?? 'Network error'));
  }
}
```

---

## Drift Code Generation

### Table Definition
```dart
import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Database Definition
```dart
import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Users, Workouts, ...],
  daos: [UserDao, WorkoutDao, ...],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
```

### Code Generation
```bash
export   flutter pub run build_runner build --delete-conflicting-outputs
```

Generates:
- `app_database.g.dart` - Database implementation
- DAO implementations with typed queries
- Model classes from tables

---

## Common Issues & Solutions

### Issue: Conflicting Outputs
```
Error: Multiple outputs for same file
```

**Solution:** Always use `--delete-conflicting-outputs`:
```bash
export   flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Generated Files Not Updating
```
# Changes to @riverpod not reflected
```

**Solution:** Restart watch mode or rebuild:
```bash
# Stop existing watch (Ctrl+C)
export   flutter pub run build_runner watch --delete-conflicting-outputs
```

### Issue: Circular Dependencies
```
Error: Circular dependency detected
```

**Cause:** Provider A depends on Provider B, B depends on A

**Solution:** Restructure providers to avoid cycles:
```dart
// ✗ WRONG
@riverpod
User userProvider(UserRef ref) {
  final auth = ref.watch(authProvider);  // Circular if authProvider depends on this
}

// ✓ CORRECT: Share root dependency
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(...);
}

@riverpod
User user(UserRef ref) {
  return ref.watch(authRepositoryProvider).getUser();
}

@riverpod
Auth auth(AuthRef ref) {
  return Auth(repository: ref.watch(authRepositoryProvider));
}
```

### Issue: Type Mismatch After Generation
```
The argument type 'Future<User?>' can't be assigned to 'FutureOr<User?>'
```

**Cause:** Riverpod requires `FutureOr` return type

**Solution:**
```dart
// ✗ WRONG
@riverpod
class UserState extends _$UserState {
  @override
  Future<User?> build() async {  // Wrong
    return null;
  }
}

// ✓ CORRECT
@riverpod
class UserState extends _$UserState {
  @override
  FutureOr<User?> build() async {  // FutureOr<T>
    return null;
  }
}
```

---

## Workflow Best Practices

### When to Run Build Runner
```
✓ After adding @riverpod annotation
✓ After modifying @freezed class
✓ After adding @JsonSerializable
✓ After adding/modifying Drift tables
✓ After running `flutter pub get`
```

### Development Workflow
```bash
# 1. Start watch mode
export   flutter pub run build_runner watch --delete-conflicting-outputs

# 2. Write code with @riverpod, @freezed, etc.
# Build runner auto-generates in background

# 3. Analyze (watch window shows errors)
export PATH="$HOME/flutter/bin:$PATH" && flutter analyze

# 4. Test
export PATH="$HOME/flutter/bin:$PATH" && flutter test

# 5. Commit (generated files included)
git add -A
git commit -m "feat: add auth state management"
```

### Before Committing
```bash
# 1. Stop watch mode (Ctrl+C)

# 2. Clean and rebuild
export   flutter pub run build_runner clean && \
  flutter pub run build_runner build --delete-conflicting-outputs

# 3. Verify no conflicts
git status

# 4. Run full test suite
export PATH="$HOME/flutter/bin:$PATH" && flutter test

# 5. Commit with generated files
git add -A
git commit -m "feat: ..."
```

---

## Generated Files Management

### What to Commit
```
✓ .g.dart files (generated models, JSON serialization)
✓ .freezed.dart files (immutable classes)
✓ app_database.g.dart (Drift database)
```

These are auto-generated but should be committed for reproducibility.

### What NOT to Edit
```
✗ Never manually edit any .g.dart file
✗ Never manually edit any .freezed.dart file
✗ Never manually edit any database.g.dart file

If you need to change behavior:
1. Modify source file
2. Re-run build_runner
```

### Merge Conflicts in Generated Files
```
If merge conflict in .g.dart:
1. Keep both markers
2. Run build_runner to regenerate
3. Resolve manually if needed
```

---

## Code Generation Checklist

- [ ] **Riverpod:** All state/async data uses `@riverpod` annotation
- [ ] **Freezed:** Models use `@freezed` for immutability
- [ ] **JSON:** Models have `@JsonSerializable` if needed
- [ ] **Drift:** Tables and DAOs properly annotated
- [ ] **Build Runner:** Run after every annotation change
- [ ] **No Manual Edits:** Never modify `.g.dart` or `.freezed.dart`
- [ ] **Generated Files Committed:** Checked into git for reproducibility
- [ ] **No Conflicts:** Using `--delete-conflicting-outputs` flag
- [ ] **Tests Pass:** Generated code doesn't break tests
- [ ] **Clean Build:** Rebuild before committing
