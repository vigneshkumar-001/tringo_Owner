import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Routes/app_go_routes.dart';

class PushNotificationRouter {
  PushNotificationRouter._();

  static final PushNotificationRouter instance = PushNotificationRouter._();

  static const String _kEventType = 'eventType';

  Future<void> handleRemoteMessage(RemoteMessage message) async {
    final data = message.data;
    if (data.isEmpty) return;
    await handleData(data);
  }

  Future<void> handleData(Map<String, dynamic> raw) async {
    try {
      final data = _normalize(raw);
      final eventType = _readString(data[_kEventType]).toUpperCase();

      if (eventType.isEmpty) {
        AppLogger.log.w(
          '🔔 Push open ignored: missing data.eventType. data=$data',
        );
        return;
      }

      AppLogger.log.i('🔔 Push open: eventType=$eventType data=$data');

      switch (eventType) {
        case 'SMART_CONNECT_NEW_REQUEST':
          await _goSmartConnectIncomingRequests(data);
          return;
        default:
          AppLogger.log.w(
            '🔔 Push open: unknown eventType=$eventType data=$data',
          );
          return;
      }
    } catch (e, st) {
      AppLogger.log.e('🔔 Push open failed: $e\n$st');
    }
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    final normalized = <String, dynamic>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is Map) {
        normalized[key] = value.map((k, v) => MapEntry(k.toString(), v));
      } else {
        normalized[key] = value;
      }
    }
    return normalized;
  }

  String _readString(Object? v) => (v ?? '').toString().trim();

  Future<void> _goSmartConnectIncomingRequests(
    Map<String, dynamic> data,
  ) async {
    final requestId = _readString(data['requestId']);
    final customerUserId = _readString(data['customerUserId']);
    final productName = _readString(data['productName']);
    final category = _readString(data['category']);
    final city = _readString(data['city']);

    await _goAfterFrame(() {
      goRouter.go(
        AppRoutes.homeScreenPath,
        extra: <String, dynamic>{
          'initialIndex': 1, // Enquiry tab (incoming requests)
          'eventType': 'SMART_CONNECT_NEW_REQUEST',
          'pushOpenId': DateTime.now().microsecondsSinceEpoch.toString(),
          'requestId': requestId,
          'customerUserId': customerUserId,
          'productName': productName,
          'category': category,
          'city': city,
        },
      );
    });
  }

  Future<void> _goAfterFrame(VoidCallback action) async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          action();
        } catch (e, st) {
          AppLogger.log.e('🔔 Push navigation failed: $e\n$st');
        }
      });
    } catch (_) {
      // WidgetsBinding might not be ready in rare cases; fallback to microtask.
      await Future<void>.microtask(action);
    }
  }

  Map<String, dynamic>? tryParseLocalPayload(String? payload) {
    if (payload == null) return null;
    final p = payload.trim();
    if (p.isEmpty) return null;

    try {
      final decoded = jsonDecode(p);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {
      // ignore; payload might be a legacy `.toString()` map.
    }
    return null;
  }
}
