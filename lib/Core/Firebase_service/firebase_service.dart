// firebase_service.dart
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';

class FirebaseService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'flutter_notification',
    'flutter_notification_title',
    description: 'Default notifications channel',
    importance: Importance.high,
    enableLights: true,
    showBadge: true,
    playSound: true,
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  StreamSubscription<String>? _tokenRefreshSub;
  bool _loggedServiceNotAvailable = false;

  Future<void> initializeFirebase() async {
    // Local notifications init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    // ✅ v20.x uses `settings:` (NOT `initializationSettings:`)
    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        AppLogger.log.i('🔔 Notification tapped. payload: ${response.payload}');
      },
    );

    // Create Android channel (Android 8+)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Ensure FCM auto-init is enabled (harmless if already enabled)
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    } catch (e, st) {
      AppLogger.log.w('setAutoInitEnabled failed: $e\n$st');
    }

    await _requestNotificationPermission();
    _listenToTokenRefresh();

    // iOS foreground presentation (harmless on Android)
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _requestNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      AppLogger.log.i(
        '🔔 Notification permission: ${settings.authorizationStatus}',
      );
    } catch (e, st) {
      AppLogger.log.w('requestPermission failed: $e\n$st');
    }
  }

  void _listenToTokenRefresh() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      t,
    ) async {
      final token = t.trim();
      if (token.isEmpty) return;
      if (token == _fcmToken) return;

      _fcmToken = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcmToken', token);
      AppLogger.log.i('🔁 FCM Token refreshed: $token');
    });
  }

  // ---- Robust token fetch with backoff (handles SERVICE_NOT_AVAILABLE) ----
  Future<String?> _getTokenWithBackoff() async {
    const delays = [1, 2, 4, 8]; // seconds
    for (final s in delays) {
      try {
        final t = await FirebaseMessaging.instance.getToken();
        if (t != null && t.isNotEmpty) return t;
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('SERVICE_NOT_AVAILABLE') &&
            !_loggedServiceNotAvailable) {
          _loggedServiceNotAvailable = true;
          AppLogger.log.w(
            'FCM token service temporarily unavailable (will retry). '
            'Common causes: first app start, weak network, or emulator without Google Play services.',
          );
        } else {
          AppLogger.log.w('getToken failed (retry in ${s}s): $e');
        }
      }
      await Future.delayed(Duration(seconds: s));
    }

    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e, st) {
      AppLogger.log.e('getToken final failure: $e\n$st');
      return null;
    }
  }

  Future<void> fetchFCMTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    _fcmToken = prefs.getString('fcmToken');

    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      AppLogger.log.i('ℹ️ Existing FCM Token: $_fcmToken');
      return;
    }

    final token = await _getTokenWithBackoff();
    _fcmToken = token;

    if (token != null && token.isNotEmpty) {
      await prefs.setString('fcmToken', token);
      AppLogger.log.i('✅ FCM Token: $token');
    } else {
      AppLogger.log.w(
        '⚠️ No FCM token (device/config/network). Will retry later.',
      );
    }
  }

  /// Call this when you receive an FCM message in foreground
  Future<void> showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'flutter_notification',
      'flutter_notification_title',
      channelDescription: 'Default notifications channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const details = NotificationDetails(android: androidDetails);

    final nid = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.show(
      id: nid,
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      notificationDetails: details,
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  void listenToMessages({
    required void Function(RemoteMessage) onMessage,
    required void Function(RemoteMessage) onMessageOpenedApp,
  }) {
    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
  }

  /// If app was terminated and opened by tapping a notification
  Future<RemoteMessage?> getInitialMessage() {
    return FirebaseMessaging.instance.getInitialMessage();
  }
}
