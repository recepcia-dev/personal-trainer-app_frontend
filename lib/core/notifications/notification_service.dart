import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for managing Firebase Cloud Messaging and local notifications
class NotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  // Stream controller for handling notification events
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  NotificationService({
    required FirebaseMessaging firebaseMessaging,
    required FlutterLocalNotificationsPlugin localNotifications,
  })  : _firebaseMessaging = firebaseMessaging,
        _localNotifications = localNotifications;

  /// Initialize Firebase Cloud Messaging and local notifications
  /// Requests necessary permissions and sets up message handlers
  Future<void> initialize() async {
    // Request notification permissions (iOS/Android)
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Set up message handlers
    _setupMessageHandlers();
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Check permission status for logging/debugging
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // Permissions denied
      return;
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('app_icon'); // Make sure app_icon is in drawable
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _notificationController.add({
          'action': 'notification_tapped',
          'payload': response.payload,
        });
      },
    );

    // Request iOS notification permissions
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Set up message handlers for foreground and background messages
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle background messages (tap notification while app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _notificationController.add({
        'action': 'notification_opened',
        'data': message.data,
      });
    });
  }

  /// Handle foreground messages by showing local notifications
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
      payload: message.data.toString(),
    );

    // Also emit to stream for app-level handling
    _notificationController.add({
      'action': 'message_received',
      'title': title,
      'body': body,
      'data': message.data,
    });
  }

  /// Get FCM token and optionally send it to backend
  /// [onTokenReceived] callback to handle token (e.g., send to backend)
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Listen to FCM token refresh events
  /// [onTokenRefresh] callback triggered when token is refreshed
  void setTokenRefreshListener(Function(String) onTokenRefresh) {
    _firebaseMessaging.onTokenRefresh.listen(onTokenRefresh);
  }

  /// Get stream of notification events
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  /// Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      await _firebaseMessaging.subscribeToTopic('all');
    } else {
      await _firebaseMessaging.unsubscribeFromTopic('all');
    }
  }

  /// Subscribe to a specific topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a specific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _notificationController.close();
  }
}
