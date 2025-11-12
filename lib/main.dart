/*
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const TringoApp());

class TringoApp extends StatelessWidget {
  const TringoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tringo Caller Card',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF2E7DFF)),
      home: const OverlayHomePage(),
    );
  }
}

class Bridge {
  static const _ch = MethodChannel('tringo/overlay');

  static Future<bool> requestOverlayPermission() async =>
      await _ch.invokeMethod<bool>('requestOverlayPermission') ?? false;

  static Future<void> startService() =>
      _ch.invokeMethod('startOverlayService');

  static Future<void> stopService() =>
      _ch.invokeMethod('stopOverlayService');

  // NEW: show a dummy overlay now (auto-hides in service after ~4s)
  static Future<void> showDummy(String name, String number) =>
      _ch.invokeMethod('showDummy', {'name': name, 'number': number});

  // NEW: request Call Redirection role (Android 10+)
  static Future<void> requestCallRedirectionRole() =>
      _ch.invokeMethod('requestCallRedirectionRole');
}

class OverlayHomePage extends StatefulWidget {
  const OverlayHomePage({super.key});
  @override
  State<OverlayHomePage> createState() => _OverlayHomePageState();
}

class _OverlayHomePageState extends State<OverlayHomePage> {
  bool hasOverlay = false;
  bool busy = false;

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(m)));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Bridge.requestOverlayPermission().then((ok) {
      if (mounted) setState(() => hasOverlay = ok);
    });
  }

  Future<void> _askOverlay() async {
    if (!Platform.isAndroid) return _snack('Android only.');
    setState(() => busy = true);
    try {
      final ok = await Bridge.requestOverlayPermission();
      if (!mounted) return;
      setState(() => hasOverlay = ok);
      _snack(ok ? 'Overlay already granted.' : 'Open Settings and enable overlay, then return.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _requestRuntimePerms() async {
    final phone = await Permission.phone.request();
    final notif = await Permission.notification.request();
    if (!phone.isGranted || !notif.isGranted) {
      _snack('Phone/Notification permission denied');
      return;
    }
    _snack('Runtime permissions granted.');
  }

  Future<void> _start() async {
    if (!hasOverlay) return _snack('Grant overlay permission first.');
    await _requestRuntimePerms();
    await Bridge.startService();
    _snack('Manual test service started. Now place/receive a call.');
  }

  Future<void> _stop() async {
    await Bridge.stopService();
    _snack('Service stopped.');
  }

  Future<void> _enableOutgoing() async {
    if (!Platform.isAndroid) return;
    await Bridge.requestCallRedirectionRole();
  }

  Future<void> _showDummy() async {
    if (!Platform.isAndroid) return _snack('Android only.');
    if (!hasOverlay) return _snack('Grant overlay permission first.');
    await Bridge.showDummy('Luke (Dummy)', '+91 98765 43210');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tringo Caller Card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Shows a small overlay card with Name + Number during incoming/outgoing calls.'),
          const SizedBox(height: 16),
          Wrap(spacing: 10, runSpacing: 12, children: [
            FilledButton.icon(
              onPressed: busy ? null : _askOverlay,
              icon: const Icon(Icons.security),
              label: const Text('Grant Overlay Permission'),
            ),
            FilledButton.tonalIcon(
              onPressed: busy ? null : _start,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Test Service'),
            ),
            OutlinedButton.icon(
              onPressed: busy ? null : _stop,
              icon: const Icon(Icons.stop),
              label: const Text('Stop Service'),
            ),
            OutlinedButton.icon(
              onPressed: _enableOutgoing,
              icon: const Icon(Icons.call_made),
              label: const Text('Enable Outgoing Detection'),
            ),
            // NEW: Dummy card trigger
            FilledButton.icon(
              onPressed: busy ? null : _showDummy,
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Show Dummy Card'),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Chip(label: Text('Overlay: ${hasOverlay ? "Granted" : "Not granted"}')),
          ]),
        ]),
      ),
    );
  }
}

*/

import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor/Presentation/Login/Screens/login_screens.dart';
import 'package:tringo_vendor/Presentation/Register/Screens/register_screen.dart';
import 'package:tringo_vendor/sample_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(scaffoldBackgroundColor: AppColor.scaffoldColor),
          home: child,
        );
      },
      child: LoginScreen(),
    );
  }
}
