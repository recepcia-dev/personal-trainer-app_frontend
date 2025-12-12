import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/notifications/notification_service.dart';

// Mock classes
class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockFlutterLocalNotificationsPlugin mockLocalNotifications;
  late NotificationService notificationService;

  setUpAll(() {
    registerFallbackValue(
      const InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
      ),
    );
  });

  setUp(() {
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockLocalNotifications = MockFlutterLocalNotificationsPlugin();

    notificationService = NotificationService(
      firebaseMessaging: mockFirebaseMessaging,
      localNotifications: mockLocalNotifications,
    );

    // Setup default mock behaviors
    when(() => mockFirebaseMessaging.getToken())
        .thenAnswer((_) async => 'mock-fcm-token');

    when(() => mockLocalNotifications.initialize(
          any(),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
        ))
        .thenAnswer((_) async => true);

    when(() => mockLocalNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()).thenReturn(null);

    when(() => mockFirebaseMessaging.subscribeToTopic(any()))
        .thenAnswer((_) async {});

    when(() => mockFirebaseMessaging.unsubscribeFromTopic(any()))
        .thenAnswer((_) async {});
  });

  group('NotificationService', () {
    test('getFCMToken() returns token from Firebase', () async {
      final token = await notificationService.getFCMToken();

      expect(token, equals('mock-fcm-token'));
      verify(() => mockFirebaseMessaging.getToken()).called(1);
    });

    test('getFCMToken() returns null on error', () async {
      when(() => mockFirebaseMessaging.getToken())
          .thenThrow(Exception('Token error'));

      final token = await notificationService.getFCMToken();

      expect(token, isNull);
    });

    test('notificationStream is accessible', () {
      final stream = notificationService.notificationStream;

      expect(stream, isNotNull);
      expect(stream.isBroadcast, isTrue);
    });

    test('subscribeToTopic() calls Firebase subscribeToTopic', () async {
      await notificationService.subscribeToTopic('test-topic');

      verify(() => mockFirebaseMessaging.subscribeToTopic('test-topic'))
          .called(1);
    });

    test('unsubscribeFromTopic() calls Firebase unsubscribeFromTopic',
        () async {
      await notificationService.unsubscribeFromTopic('test-topic');

      verify(() => mockFirebaseMessaging.unsubscribeFromTopic('test-topic'))
          .called(1);
    });

    test('setNotificationsEnabled(true) subscribes to all topic', () async {
      await notificationService.setNotificationsEnabled(true);

      verify(() => mockFirebaseMessaging.subscribeToTopic('all')).called(1);
    });

    test('setNotificationsEnabled(false) unsubscribes from all topic',
        () async {
      await notificationService.setNotificationsEnabled(false);

      verify(() => mockFirebaseMessaging.unsubscribeFromTopic('all'))
          .called(1);
    });

    test('dispose() completes successfully', () async {
      await notificationService.dispose();

      // If dispose succeeds without throwing, test passes
      expect(true, isTrue);
    });

    test('NotificationService creates valid instance', () {
      expect(notificationService, isNotNull);
      expect(
        notificationService.notificationStream,
        isA<Stream<Map<String, dynamic>>>(),
      );
    });
  });
}
