import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_trainer_app/core/notifications/notification_service.dart';

/// Provider for FirebaseMessaging instance
final firebaseMessagingProvider = Provider((ref) {
  return FirebaseMessaging.instance;
});

/// Provider for FlutterLocalNotificationsPlugin instance
final flutterLocalNotificationsProvider = Provider((ref) {
  return FlutterLocalNotificationsPlugin();
});

/// Provider for NotificationService
final notificationServiceProvider = FutureProvider<NotificationService>((ref) async {
  final firebaseMessaging = ref.watch(firebaseMessagingProvider);
  final localNotifications = ref.watch(flutterLocalNotificationsProvider);

  final service = NotificationService(
    firebaseMessaging: firebaseMessaging,
    localNotifications: localNotifications,
  );

  await service.initialize();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider to get notification stream
final notificationStreamProvider =
    StreamProvider.autoDispose<Map<String, dynamic>>((ref) async* {
  final service = await ref.watch(notificationServiceProvider.future);
  yield* service.notificationStream;
});

/// Provider to get FCM token
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final service = await ref.watch(notificationServiceProvider.future);
  return service.getFCMToken();
});
