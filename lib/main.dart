import 'package:call_log/call_log.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tringo_owner/Core/Const/app_color.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Core/Routes/app_go_routes.dart';
import 'package:tringo_owner/Core/Session/session_manager.dart';
import 'package:tringo_owner/Core/Firebase_service/push_notification_router.dart';

import 'Core/Firebase_service/firebase_service.dart';
import 'Core/Firebase_service/device_token_sync.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Must initialize Firebase in background isolate too.
    await Firebase.initializeApp();
    AppLogger.log.i('🔕 [BG] messageId=${message.messageId}');
  } catch (e, st) {
    AppLogger.log.w('Firebase background init failed: $e\n$st');
  }
}

Future<bool> _initializeFirebaseSafely() async {
  try {
    await Firebase.initializeApp();
    return true;
  } catch (e, st) {
    AppLogger.log.w('Firebase init skipped: $e\n$st');
    return false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  final pushRouter = PushNotificationRouter.instance;
  RemoteMessage? initialMsg;

  final firebaseReady = await _initializeFirebaseSafely();
  if (firebaseReady) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final firebaseService = FirebaseService.instance;
    await firebaseService.initializeFirebase(
      onLocalNotificationTapData: (data) {
        pushRouter.handleData(data);
      },
    );

    firebaseService.onTokenRefreshed = (token) async {
      await DeviceTokenSync.instance.sync(reason: 'token_refresh');
    };
    // Delay token fetch a bit to avoid transient SERVICE_NOT_AVAILABLE on cold start.
    Future.delayed(const Duration(seconds: 2), () {
      firebaseService.fetchFCMTokenIfNeeded();
    });

    // ✅ Register listeners (no need for postFrame)
    firebaseService.listenToMessages(
      onMessage: (msg) async {
        AppLogger.log.i('📩 [FG] ${msg.messageId}');
        await firebaseService.showNotification(msg);
      },
      onMessageOpenedApp: (msg) {
        AppLogger.log.i('📬 [OPENED] ${msg.messageId}');
        pushRouter.handleRemoteMessage(msg);
      },
    );

    // ✅ Handle "terminated -> opened by tap"
    initialMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) {
      AppLogger.log.i('🚀 [TERMINATED OPEN] ${initialMsg.messageId}');
    }
  }

  runApp(AppRoot(initialMessage: initialMsg));
}

class AppRoot extends StatefulWidget {
  final RemoteMessage? initialMessage;

  const AppRoot({super.key, this.initialMessage});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final ValueNotifier<int> _scopeSeed = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    SessionManager.bindProviderScopeResetSignal(_scopeSeed);

    final msg = widget.initialMessage;
    if (msg != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PushNotificationRouter.instance.handleRemoteMessage(msg);
      });
    }
  }

  @override
  void dispose() {
    _scopeSeed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _scopeSeed,
      builder: (context, seed, _) {
        return ProviderScope(key: ValueKey(seed), child: const MyApp());
      },
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: goRouter,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(scaffoldBackgroundColor: AppColor.scaffoldColor),
        );
      },
    );
  }
}

class CallDashboardScreen extends StatefulWidget {
  const CallDashboardScreen({super.key});

  @override
  State<CallDashboardScreen> createState() => _CallDashboardScreenState();
}

class _CallDashboardScreenState extends State<CallDashboardScreen> {
  List<CallLogEntry> callLogs = [];
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    requestPermissionsAndLoad();
  }

  // 🔥 Request Default Dialer
  static final _channel = MethodChannel('tringo/system');

  static Future<void> requestDefaultDialer() async {
    try {
      await _channel.invokeMethod('requestDefaultDialer');
    } catch (e) {
      debugPrint('Default dialer error: $e');
    }
  }

  Future<void> requestPermissionsAndLoad() async {
    final statuses = await [Permission.contacts, Permission.phone].request();

    // CONTACTS
    if (statuses[Permission.contacts]!.isGranted) {
      final allContacts = await FlutterContacts.getContacts(
        withProperties: true,
      );
      setState(() => contacts = allContacts);
    }

    // CALL LOGS
    if (statuses[Permission.phone]!.isGranted) {
      try {
        final logs = await CallLog.get();
        setState(() => callLogs = logs.toList());
      } catch (e) {
        debugPrint('⚠️ Call logs blocked (not default dialer): $e');
        setState(() => callLogs = []);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Logs & Contacts')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== CALL LOGS =====
            const Text(
              'Call Logs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            if (callLogs.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Call logs unavailable.\nSet app as Default Dialer to view.',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: requestDefaultDialer,
                child: const Text('Set as Default Dialer'),
              ),
            ],

            ...callLogs.map(
              (e) => ListTile(
                leading: const Icon(Icons.call),
                title: Text(e.name ?? e.number ?? 'Unknown'),
                subtitle: Text('${e.callType} • ${e.duration ?? 0}s'),
              ),
            ),

            const SizedBox(height: 24),

            // ===== CONTACTS =====
            const Text(
              'Contacts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            if (contacts.isEmpty) const Text('No contacts found'),

            ...contacts.map(
              (c) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ...c.phones.map((p) => Text('📞 ${p.number}')),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SystemPermissions {
  static final _channel = MethodChannel('tringo/system');

  static Future<void> requestDefaultDialer() async {
    await _channel.invokeMethod('requestDefaultDialer');
  }

  static Future<void> requestOverlay() async {
    await _channel.invokeMethod('requestOverlayPermission');
  }

  static Future<void> requestCallRedirectionRole() async {
    await _channel.invokeMethod('requestCallRedirectionRole');
  }
}
