import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Api/DataSource/api_data_source.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Firebase_service/firebase_service.dart';
import 'package:tringo_owner/Core/Utility/app_prefs.dart';
import 'package:tringo_owner/Core/Utility/device_helper.dart';

class DeviceTokenSync {
  DeviceTokenSync._();

  static final DeviceTokenSync instance = DeviceTokenSync._();

  static const _kLastSentToken = 'fcmToken_lastSent';
  static const _kLastSentAtMs = 'fcmToken_lastSentAtMs';
  static const _kPendingSync = 'fcmToken_pendingSync';

  final ApiDataSource _api = ApiDataSource();

  Completer<void>? _syncCompleter;
  DateTime? _lastSyncAttemptAt;

  Future<void> sync({required String reason, bool force = false}) async {
    if (_syncCompleter != null) return _syncCompleter!.future;

    final now = DateTime.now();
    final lastAttempt = _lastSyncAttemptAt;
    if (lastAttempt != null &&
        now.difference(lastAttempt) < const Duration(seconds: 10)) {
      return;
    }
    _lastSyncAttemptAt = now;

    final completer = Completer<void>();
    _syncCompleter = completer;

    try {
      final authToken = (await AppPrefs.getToken())?.trim() ?? '';
      if (authToken.isEmpty) {
        // Not logged in yet; mark pending so OTP flow can retry.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kPendingSync, true);
        return;
      }

      var token = await FirebaseService.instance.ensureFcmToken();
      if ((token ?? '').trim().isEmpty) {
        await FirebaseService.instance.waitForFcmToken();
        token = await FirebaseService.instance.ensureFcmToken();
      }
      final fcmToken = (token ?? '').trim();
      if (fcmToken.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final lastSent = (prefs.getString(_kLastSentToken) ?? '').trim();
      final lastSentAtMs = prefs.getInt(_kLastSentAtMs) ?? 0;
      final lastSentAt = DateTime.fromMillisecondsSinceEpoch(lastSentAtMs);

      // Avoid spamming the API when multiple screens call sync back-to-back.
      final sentRecently =
          now.difference(lastSentAt) < const Duration(minutes: 2);
      if (!force && sentRecently && lastSent == fcmToken) return;

      final platform = Platform.isAndroid ? 'android' : 'ios';
      final deviceId = await DeviceIdHelper.getDeviceId();

      await _sendWithRetry(
        fcmToken: fcmToken,
        platform: platform,
        deviceId: deviceId,
        reason: reason,
      );

      await prefs.setString(_kLastSentToken, fcmToken);
      await prefs.setInt(_kLastSentAtMs, now.millisecondsSinceEpoch);
      await prefs.setBool(_kPendingSync, false);
    } catch (e, st) {
      AppLogger.log.w('Device token sync failed ($reason): $e\n$st');
    } finally {
      _syncCompleter = null;
      if (!completer.isCompleted) completer.complete();
    }
  }

  Future<void> _sendWithRetry({
    required String fcmToken,
    required String platform,
    required String deviceId,
    required String reason,
  }) async {
    const delays = <Duration>[
      Duration(milliseconds: 0),
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 10),
    ];

    for (final delay in delays) {
      if (delay.inMilliseconds > 0) {
        await Future.delayed(delay);
      }

      final results = await _api.fcmTokenSend(
        fcmToken: fcmToken,
        platform: platform,
        deviceId: deviceId,
      );

      final ok = results.isRight();
      if (ok) {
        AppLogger.log.i('Device token synced ($reason)');
        return;
      }

      results.fold(
        (failure) {
          AppLogger.log.w('Device token sync failed ($reason): ${failure.message}');
        },
        (_) {},
      );
    }
  }
}
