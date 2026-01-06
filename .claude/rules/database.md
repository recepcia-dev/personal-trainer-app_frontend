# Database Guidelines (Drift/SQLite)

## Schema & Tables

### Structure
```
lib/database/
├── app_database.dart       # Main @DriftDatabase definition
├── tables/                 # Table definitions
│   ├── users_table.dart
│   ├── workouts_table.dart
│   └── ...
└── daos/                   # Data Access Objects
    ├── user_dao.dart
    └── workout_dao.dart
```

### Table Definition Example
```dart
@DataClassName("UserData")
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique().nullable()();
  TextColumn get email => text().unique()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// ✓ Always include:
// - Remote ID for syncing
// - isSynced flag for offline-first
// - Timestamps (createdAt, updatedAt)
// - Foreign keys with constraints
```

---

## Migrations

### Versioning
```dart
@DriftDatabase(
  tables: [Users, Workouts, ...],
  daos: [UserDao, WorkoutDao, ...],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;  // Increment for any schema change

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // Handle migrations
      if (from < 2) {
        // Migration: Add new column to Users table
        await m.addColumn(users, users.isSynced);
      }
    },
    beforeOpen: (details) async {
      // Run on every open
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
```

### Migration Rules
- **NEVER delete tables** without migration (data loss)
- **ALWAYS increment `schemaVersion`** for any schema change
- **ALWAYS implement `onUpgrade`** callback
- **Test migrations** in `test/database/migrations/`

### Adding a New Column
```dart
// Step 1: Update table definition
class Users extends Table {
  // ... existing columns ...
  TextColumn get phoneNumber => text().nullable()();  // NEW
}

// Step 2: Increment schemaVersion
int get schemaVersion => 3;  // was 2

// Step 3: Implement migration
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: (m, from, to) async {
    if (from < 3) {
      await m.addColumn(users, users.phoneNumber);
    }
  },
);

// Step 4: Test
// flutter test test/database/migrations/
```

### Testing Migrations
```dart
// test/database/migrations/user_table_migration_test.dart
void main() {
  group('User Table Migrations', () {
    test('schemaVersion 2 to 3: Add phoneNumber column', () async {
      // Use connection with schema version 2
      final connection = await driftConnection(
        DatabaseConnection.fromExecutor(_createInMemory()),
      );

      // Verify old schema exists
      final oldUsers = await connection.select(
        'SELECT * FROM users LIMIT 1',
      );

      // Trigger migration
      final db = AppDatabase();
      await db.customStatement('PRAGMA foreign_keys = ON');

      // Verify new column exists
      final newUsers = await db.select(db.users).get();
      // phoneNumber should be nullable/exist
    });
  });
}
```

---

## Data Access Objects (DAOs)

### DAO Pattern
```dart
@DriftAccessor(tables: [Users, Workouts])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  // Create
  Future<int> createUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  // Read
  Future<UserData?> getUserById(int id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  // Update
  Future<bool> updateUser(UserData user) {
    return update(users).replace(user);
  }

  // Delete
  Future<bool> deleteUser(int id) {
    return (delete(users)..where((u) => u.id.equals(id))).go();
  }

  // Custom queries
  Future<List<WorkoutData>> getUserWorkouts(int userId) {
    return (select(workouts)
          ..where((w) => w.userId.equals(userId))
          ..orderBy([(w) => OrderingTerm(expression: w.createdAt)]))
        .get();
  }
}
```

---

## Offline-First Sync

### isSynced Flag
Mark all mutations with `isSynced: false` until confirmed on server:

```dart
// 1. User creates workout locally
await workoutDao.createWorkout(
  WorkoutsCompanion(
    name: Value('Morning Run'),
    userId: Value(userId),
    isSynced: const Value(false),  // NEW: Mark for sync
  ),
);

// 2. If online, sync with server
if (await networkInfo.isConnected) {
  try {
    final response = await dio.post('/workouts', data: workout);
    final remoteId = response.data['id'];

    // Mark as synced
    await workoutDao.updateWorkout(
      workout.copyWith(remoteId: remoteId, isSynced: true),
    );
  } catch (e) {
    // If sync fails, leave isSynced: false for retry
  }
}

// 3. Periodic sync service
class SyncService {
  Future<void> syncPendingWorkouts() async {
    final pending = await workoutDao.getPendingSync();

    for (final workout in pending) {
      try {
        await _syncWorkout(workout);
      } catch (e) {
        // Log, continue with next
      }
    }
  }
}
```

### Query Unsynced Records
```dart
// Get all records pending sync
Future<List<WorkoutData>> getPendingSync() {
  return (select(workouts)..where((w) => w.isSynced.equals(false))).get();
}

// Get synced records (for offline display)
Future<List<WorkoutData>> getSyncedWorkouts(int userId) {
  return (select(workouts)
        ..where((w) => w.userId.equals(userId) & w.isSynced.equals(true)))
      .get();
}
```

---

## Foreign Keys & Constraints

### Enable Foreign Keys (MANDATORY)
```dart
@DriftDatabase(...)
class AppDatabase extends _$AppDatabase {
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // Enable foreign key constraints
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
```

### Define Foreign Keys
```dart
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  // ...
}

// ✓ Benefit: Database enforces referential integrity
// ✓ Prevents: Orphaned records, cascade deletes managed

// Delete user cascade
class Users extends Table {
  // ...
}

class Workouts extends Table {
  IntColumn get userId => integer()
      .references(Users, #id, onDelete: KeyAction.cascade)();
}
```

---

## Common Operations

### Upsert (Insert or Update)
```dart
// Insert if not exists, update if exists
Future<void> upsertUser(UserData user) {
  return into(users).insertOnConflictUpdate(user);
}

// Or custom conflict resolution
Future<void> upsertWorkout(WorkoutData workout) {
  return into(workouts).insert(
    workout,
    onConflict: DoUpdate(
      (old) => workout.copyWith(updatedAt: Value(DateTime.now())),
    ),
  );
}
```

### Batch Operations
```dart
// Batch insert
Future<void> createManyWorkouts(List<WorkoutData> workouts) {
  return batch((batch) {
    batch.insertAll(workouts, workouts);
  });
}

// Batch update
Future<void> updateManyToSynced(List<int> ids) {
  return batch((batch) {
    for (final id in ids) {
      batch.update(
        workouts,
        WorkoutsCompanion(isSynced: const Value(true)),
        where: (w) => w.id.equals(id),
      );
    }
  });
}
```

### Transactions
```dart
// Atomic operations
Future<void> transferWorkoutsBetweenUsers(int fromId, int toId) {
  return transaction(() async {
    // All operations succeed or all fail
    await workoutDao.updateUserWorkouts(fromId, toId);
    await userDao.updateUserStatus(fromId, 'archived');
  });
}
```

---

## Testing Databases

### In-Memory for Tests
```dart
// test/database/helpers.dart
AppDatabase createInMemoryDatabase() {
  final executor = SqliteQueryExecutor.inMemory();
  return AppDatabase._(executor);
}

// test/database/user_dao_test.dart
void main() {
  group('UserDao', () {
    late AppDatabase db;

    setUp(() {
      db = createInMemoryDatabase();
    });

    tearDown(() => db.close());

    test('createUser inserts user correctly', () async {
      final user = UsersCompanion(
        email: const Value('test@example.com'),
        name: const Value('John Doe'),
      );

      final id = await db.userDao.createUser(user);

      expect(id, isNotNull);
      final stored = await db.userDao.getUserById(id);
      expect(stored?.email, 'test@example.com');
    });
  });
}
```

### Avoid File-Based Tests
```dart
// ✗ WRONG: Creates actual database file
test('query operation', () async {
  final db = AppDatabase();  // Creates applications.db
});

// ✓ CORRECT: In-memory only
test('query operation', () async {
  final db = createInMemoryDatabase();  // :memory: SQLite
});
```

---

## Database Checklist

- [ ] **Versioning:** `schemaVersion` incremented for any change
- [ ] **Migrations:** `onUpgrade` implemented with all steps
- [ ] **Foreign Keys:** Enabled via `PRAGMA foreign_keys = ON`
- [ ] **Sync Flag:** `isSynced` column on all mutable tables
- [ ] **DAOs:** All CRUD operations in DAO layer
- [ ] **Testing:** Migrations tested in dedicated test file
- [ ] **No File Pollution:** Tests use in-memory database only
- [ ] **Transactions:** Atomic operations wrapped in transaction
- [ ] **Constraints:** No orphaned records possible
- [ ] **Indexing:** Frequently queried columns have indexes

---

## Performance Tips

### Indexing
```dart
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  // Indexes on frequently queried columns
  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, createdAt},  // Common query: user's workouts by date
  ];
}
```

### Pagination
```dart
Future<List<WorkoutData>> getPagedWorkouts(int userId, int page) {
  const pageSize = 20;
  return (select(workouts)
        ..where((w) => w.userId.equals(userId))
        ..limit(pageSize, offset: page * pageSize))
      .get();
}
```
