# Performance Guidelines

## Image Caching

### Aggressive Caching Strategy
```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: trainerPhotoUrl,
  memCacheWidth: 800,           // Max memory cache dimensions
  memCacheHeight: 800,
  maxWidthDiskCache: 1000,      // Max disk cache dimensions
  maxHeightDiskCache: 1000,
  fadeInDuration: const Duration(milliseconds: 300),
  placeholder: (context, url) => const ShimmerPlaceholder(),
  errorWidget: (context, url, error) => const PlaceholderImage(),
  cacheManager: CacheManager(
    Config(
      'custom_image_cache',
      stalePeriod: const Duration(days: 30),  // Keep for 30 days
      maxNrOfCacheObjects: 100,                // Max 100 images in cache
    ),
  ),
)
```

### Image Compression
```dart
// Resize before uploading
final bytes = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  imageQuality: 80,  // Compress to 80% quality
  maxWidth: 1024,
  maxHeight: 1024,
).then((file) => file?.readAsBytes());

// Or use image package for advanced resizing
final originalImage = decodeImage(await file.readAsBytes());
final resized = copyResize(originalImage, width: 800);
final compressed = encodeJpg(resized, quality: 85);
```

### Lazy Loading Images in Lists
```dart
class WorkoutListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        // Load image lazily only when visible
        return CachedNetworkImage(
          imageUrl: workouts[index].thumbnailUrl,
          memCacheWidth: 300,  // Thumbnail size, not full size
          memCacheHeight: 200,
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}
```

---

## List Pagination

### Paginated Loading
```dart
// Model
class WorkoutsPage {
  final List<Workout> items;
  final bool hasMore;
  final int currentPage;

  WorkoutsPage({
    required this.items,
    required this.hasMore,
    required this.currentPage,
  });
}

// Repository
Future<Either<Failure, WorkoutsPage>> getWorkoutsPage(
  int page, {
  int pageSize = 20,
}) async {
  try {
    final response = await dio.get('/workouts', queryParameters: {
      'page': page,
      'limit': pageSize,
    });

    final data = response.data;
    return Right(WorkoutsPage(
      items: (data['items'] as List)
          .map((w) => WorkoutModel.fromJson(w))
          .toList(),
      hasMore: data['has_more'] as bool,
      currentPage: page,
    ));
  } catch (e) {
    return Left(ServerFailure('Failed to load workouts: $e'));
  }
}

// Provider with pagination
@riverpod
class WorkoutListState extends _$WorkoutListState {
  @override
  FutureOr<WorkoutsPage> build() async {
    return await ref.watch(workoutRepositoryProvider).getWorkoutsPage(0);
  }

  Future<void> loadMore() async {
    state = const AsyncValue.loading();

    final current = state.asData?.value;
    if (current == null || !current.hasMore) return;

    final result = await ref
        .read(workoutRepositoryProvider)
        .getWorkoutsPage(current.currentPage + 1);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (newPage) {
        // Append to existing list
        final combined = [
          ...current.items,
          ...newPage.items,
        ];

        return AsyncValue.data(
          WorkoutsPage(
            items: combined,
            hasMore: newPage.hasMore,
            currentPage: newPage.currentPage,
          ),
        );
      },
    );
  }
}

// UI with auto-load
class WorkoutListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutListStateProvider);

    return workouts.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text('Error: $e'),
      data: (page) => ListView.builder(
        itemCount: page.items.length + (page.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Load more when near end
          if (index == page.items.length - 5 && page.hasMore) {
            ref.read(workoutListStateProvider.notifier).loadMore();
          }

          if (index == page.items.length) {
            // Loading indicator at bottom
            return const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            );
          }

          return WorkoutCard(workout: page.items[index]);
        },
      ),
    );
  }
}
```

---

## Search Input Debouncing

### Debounce Helper
```dart
// Utility
extension DebouncedValueChanged<T> on ValueChanged<T> {
  Future<void> debounced(T value, {Duration delay = const Duration(milliseconds: 300)}) async {
    await Future.delayed(delay);
    this(value);
  }
}

// Or use Timer-based debounce
class DebouncedCallback {
  Timer? _timer;
  final Duration delay;

  DebouncedCallback(this.delay);

  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() => _timer?.cancel();
}
```

### Search Implementation
```dart
@riverpod
class SearchState extends _$SearchState {
  final _debounce = DebouncedCallback(const Duration(milliseconds: 300));

  @override
  FutureOr<List<Trainer>> build() async {
    return [];
  }

  void search(String query) {
    _debounce.call(() async {
      if (query.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      state = const AsyncValue.loading();

      final result = await ref
          .read(trainerRepositoryProvider)
          .searchTrainers(query);

      state = result.fold(
        (failure) => AsyncValue.error(failure, StackTrace.current),
        (trainers) => AsyncValue.data(trainers),
      );
    });
  }
}

// UI with debounce
class SearchScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchStateProvider);

    return Column(
      children: [
        TextField(
          onChanged: (query) {
            // Only called after 300ms of no typing
            ref.read(searchStateProvider.notifier).search(query);
          },
          decoration: const InputDecoration(hintText: 'Search trainers...'),
        ),
        Expanded(
          child: results.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => Text('Error: $e'),
            data: (trainers) => ListView(
              children: trainers
                  .map((t) => TrainerTile(trainer: t))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## Firebase Quota Management

### Current Free Tier Limits
```
FCM (Cloud Messaging):
- 12,000 messages/day (free)
- 100 messages/second

Analytics:
- Unlimited events
- 1 year data retention

Crashlytics:
- Unlimited crash reports
- 30 days retention

Realtime Database:
- 100 simultaneous connections
- 1GB storage

Firestore:
- 50,000 reads/day
- 20,000 writes/day
- 20,000 deletes/day
```

### Optimization Strategies
```dart
// 1. Batch FCM messages
Future<void> sendNotifications(List<String> userIds) async {
  const batchSize = 100;

  for (int i = 0; i < userIds.length; i += batchSize) {
    final batch = userIds.sublist(
      i,
      min(i + batchSize, userIds.length),
    );

    // Send batch
    await FirebaseMessaging.instance.sendMulticast(
      MulticastMessage(
        tokens: batch,
        notification: const Notification(
          title: 'New Workout Plan',
          body: 'Check your custom workout plan!',
        ),
      ),
    );

    // Add delay between batches
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// 2. Efficient Firestore queries
// ✗ WRONG: Triggers read for every document
QuerySnapshot snap = await FirebaseFirestore.instance
    .collection('users')
    .get();  // Reads ALL docs

// ✓ CORRECT: Use pagination
QuerySnapshot snap = await FirebaseFirestore.instance
    .collection('users')
    .limit(100)
    .get();

// 3. Cloud functions instead of direct writes
// ✗ WRONG: Multiple client writes
await db.collection('users').doc(uid).update({'points': increment});
await db.collection('leaderboard').update({'scores': increment});

// ✓ CORRECT: Batch in cloud function
await functions.httpsCallable('updateUserPoints').call({'amount': 10});
```

---

## Widget Rebuild Optimization

### Avoid Unnecessary Rebuilds
```dart
// ✗ WRONG: Rebuilds entire tree
@riverpod
class AppState extends _$AppState {
  @override
  FutureOr<AppData> build() async {
    final user = await getUser();
    final workouts = await getWorkouts();
    final payments = await getPayments();
    return AppData(user: user, workouts: workouts, payments: payments);
  }
}

// If any part changes, entire widget tree rebuilds

// ✓ CORRECT: Separate providers
@riverpod
Future<User> currentUser(CurrentUserRef ref) async {
  return await getUserRepository().getCurrentUser();
}

@riverpod
Future<List<Workout>> userWorkouts(UserWorkoutsRef ref) async {
  return await getWorkoutRepository().getWorkouts();
}

@riverpod
Future<List<Payment>> userPayments(UserPaymentsRef ref) async {
  return await getPaymentRepository().getPayments();
}

// Now only affected widgets rebuild when their dependency changes
final user = ref.watch(currentUserProvider);
final workouts = ref.watch(userWorkoutsProvider);  // Independent
```

### Use select() for Specific Properties
```dart
// ✗ WRONG: Watches entire user object
final user = ref.watch(currentUserProvider);
if (user.isTrainer) { }  // Rebuilds if ANY user field changes

// ✓ CORRECT: Watch specific field
final isTrainer = ref.watch(
  currentUserProvider.select((user) => user.asData?.value?.isTrainer ?? false),
);
// Only rebuilds if isTrainer actually changes
```

---

## Animation Performance

### Use RepaintBoundary for Expensive Widgets
```dart
class ExpensiveAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(seconds: 2),
        builder: (context, value, child) {
          return CustomPaint(
            painter: ComplexPainter(value),  // Expensive paint
            size: const Size(300, 300),
          );
        },
      ),
    );
  }
}
```

### Disable vsync-intensive animations in background
```dart
class WorkoutAnimation extends StatefulWidget {
  @override
  State<WorkoutAnimation> createState() => _WorkoutAnimationState();
}

class _WorkoutAnimationState extends State<WorkoutAnimation>
    with WidgetsBindingObserver {
  late AnimationController _controller;
  bool _isInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(duration: const Duration(seconds: 2));
    _controller.forward();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isInForeground = true;
      _controller.forward();
    } else {
      _isInForeground = false;
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: const Icon(Icons.check, size: 100),
    );
  }
}
```

---

## Performance Monitoring

### Analytics Tracking
```dart
// Track expensive operations
Future<void> syncWorkouts() async {
  final stopwatch = Stopwatch()..start();

  try {
    await workoutRepository.syncWorkouts();
    stopwatch.stop();

    // Log performance
    await FirebaseAnalytics.instance.logEvent(
      name: 'workout_sync_success',
      parameters: {
        'duration_ms': stopwatch.elapsedMilliseconds,
      },
    );
  } catch (e) {
    stopwatch.stop();
    await FirebaseAnalytics.instance.logEvent(
      name: 'workout_sync_error',
      parameters: {
        'error': e.toString(),
        'duration_ms': stopwatch.elapsedMilliseconds,
      },
    );
  }
}
```

---

## Performance Checklist

- [ ] **Images:** Using `CachedNetworkImage` with memory/disk limits
- [ ] **Image Compression:** Limiting dimensions to viewport size
- [ ] **Pagination:** Lists load 20-50 items, not all at once
- [ ] **Search:** Debounced with 300ms delay before API call
- [ ] **Animations:** RepaintBoundary for expensive custom paints
- [ ] **Lifecycle:** Animations pause when app backgrounded
- [ ] **Firebase:** Respecting quota limits with batching
- [ ] **Riverpod:** Using separate providers for independent state
- [ ] **Select:** Using `.select()` to avoid unnecessary rebuilds
- [ ] **Monitoring:** Tracking slow operations with analytics
