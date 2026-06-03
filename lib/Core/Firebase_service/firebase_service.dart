// firebase_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

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
  bool _tokenFetchInProgress = false;
  Timer? _tokenRetryTimer;
  int _tokenRetryIndex = 0;
  DateTime? _lastTokenAttemptAt;
  DateTime? _lastNoTokenLogAt;

  Future<void> Function(String token)? onTokenRefreshed;

  bool _isServiceNotAvailable(Object e) {
    final msg = e.toString();
    return msg.contains('SERVICE_NOT_AVAILABLE');
  }

  bool _isTokenTemporarilyUnavailable(Object e) {
    final msg = e.toString();
    return _isServiceNotAvailable(e) ||
        msg.contains('apns-token-not-set') ||
        msg.contains('APNS token has not been set');
  }

  Future<void> _waitForApnsTokenIfNeeded() async {
    if (!Platform.isIOS) return;

    const attempts = 10;
    for (var i = 0; i < attempts; i++) {
      try {
        final token = await FirebaseMessaging.instance.getAPNSToken();
        if ((token ?? '').trim().isNotEmpty) {
          AppLogger.log.i('APNs token available');
          return;
        }
      } catch (e) {
        AppLogger.log.w('APNs token check failed: $e');
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    AppLogger.log.w('APNs token not available yet; FCM token fetch will retry.');
  }

  Future<void> initializeFirebase({
    void Function(Map<String, dynamic> data)? onLocalNotificationTapData,
  }) async {
    // Local notifications init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // Ã¢Å“â€¦ v20.x uses `settings:` (NOT `initializationSettings:`)
    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        AppLogger.log.i('Notification tapped. payload: ${response.payload}');

        if (onLocalNotificationTapData == null) return;
        final payload = response.payload?.trim();
        if (payload == null || payload.isEmpty) return;

        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map) {
            onLocalNotificationTapData(
              decoded.map((k, v) => MapEntry(k.toString(), v)),
            );
          }
        } catch (e, st) {
          AppLogger.log.w('Local notification payload decode failed: $e\n$st');
        }
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
    unawaited(_waitForApnsTokenIfNeeded());
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
        'Notification permission: ${settings.authorizationStatus}',
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
      AppLogger.log.i('FCM Token refreshed');

      try {
        await onTokenRefreshed?.call(token);
      } catch (e, st) {
        AppLogger.log.w('onTokenRefreshed failed: $e\n$st');
      }
    });
  }

  // ---- Robust token fetch with backoff (handles SERVICE_NOT_AVAILABLE) ----
  Future<String?> _getTokenWithBackoff() async {
    const delays = [1, 2, 4, 8]; // seconds
    for (final s in delays) {
      try {
        await _waitForApnsTokenIfNeeded();
        final t = await FirebaseMessaging.instance.getToken();
        final token = (t ?? "").trim();
        if (token.isNotEmpty) return token;
      } catch (e) {
        if (_isTokenTemporarilyUnavailable(e)) {
          if (!_loggedServiceNotAvailable) {
            _loggedServiceNotAvailable = true;
            AppLogger.log.w(
              'FCM token temporarily unavailable. '
              'Common causes: first app start, weak network, APNs token delay, or emulator without Google Play services. '
              'Will retry in background.',
            );
          }
          // Keep retries silent to avoid log spam.
        } else {
          AppLogger.log.w('getToken failed (retry in ${s}s): $e');
        }
      }
      await Future.delayed(Duration(seconds: s));
    }

    // One last attempt (no stack traces).
    try {
      await _waitForApnsTokenIfNeeded();
      final t = await FirebaseMessaging.instance.getToken();
      final token = (t ?? "").trim();
      return token.isEmpty ? null : token;
    } catch (e) {
      if (_isTokenTemporarilyUnavailable(e)) {
        if (!_loggedServiceNotAvailable) {
          _loggedServiceNotAvailable = true;
          AppLogger.log.w(
            'FCM token temporarily unavailable. Will retry in background.',
          );
        }
        return null;
      }
      AppLogger.log.w('getToken final failure: $e');
      return null;
    }
  }

  Future<void> fetchFCMTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    _fcmToken = prefs.getString('fcmToken');

    final existing = (_fcmToken ?? "").trim();
    if (existing.isNotEmpty) {
      _fcmToken = existing;
      AppLogger.log.i('FCM token already available');
      return;
    }

    if (_tokenFetchInProgress) return;

    final now = DateTime.now();
    final last = _lastTokenAttemptAt;
    if (last != null && now.difference(last) < const Duration(seconds: 5)) {
      return;
    }

    _tokenFetchInProgress = true;
    _lastTokenAttemptAt = now;

    final token = await _getTokenWithBackoff();
    _tokenFetchInProgress = false;

    final trimmed = (token ?? "").trim();
    _fcmToken = trimmed.isEmpty ? null : trimmed;

    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      await prefs.setString('fcmToken', _fcmToken!);
      _tokenRetryIndex = 0;
      _tokenRetryTimer?.cancel();
      _tokenRetryTimer = null;
      AppLogger.log.i('FCM token fetched');
      return;
    }

    // Token could not be fetched now; schedule a background retry.
    _scheduleTokenRetry();

    final lastLog = _lastNoTokenLogAt;
    if (lastLog == null || now.difference(lastLog) > const Duration(minutes: 1)) {
      _lastNoTokenLogAt = now;
      AppLogger.log.w(
        'âš ï¸ No FCM token (device/config/network). Will retry later.',
      );
    }
  }

  void _scheduleTokenRetry() {
    if (_tokenRetryTimer?.isActive == true) return;

    const scheduleSeconds = [15, 30, 60, 120, 300];
    final idx = _tokenRetryIndex.clamp(0, scheduleSeconds.length - 1);
    final delay = Duration(seconds: scheduleSeconds[idx]);

    if (_tokenRetryIndex < scheduleSeconds.length - 1) {
      _tokenRetryIndex++;
    }

    _tokenRetryTimer = Timer(delay, () {
      fetchFCMTokenIfNeeded();
    });
  }

  /// Call this when you receive an FCM message in foreground
  Future<void> showNotification(RemoteMessage message) async {
    if (Platform.isIOS) return;

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
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
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

  /// Ensures an FCM token is available (cached/prefs or freshly fetched).
  /// Returns null if token cannot be obtained right now.
  Future<String?> ensureFcmToken() async {
    await fetchFCMTokenIfNeeded();
    final token = (_fcmToken ?? '').trim();
    return token.isEmpty ? null : token;
  }

  Future<void> waitForFcmToken({
    Duration timeout = const Duration(seconds: 15),
    Duration pollInterval = const Duration(milliseconds: 500),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final t = await ensureFcmToken();
      if ((t ?? '').trim().isNotEmpty) return;
      await Future.delayed(pollInterval);
    }
  }
}
