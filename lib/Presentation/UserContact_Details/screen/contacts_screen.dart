import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class CallAndContactScreen extends StatefulWidget {
  const CallAndContactScreen({super.key});

  @override
  State<CallAndContactScreen> createState() => _CallAndContactScreenState();
}

class _CallAndContactScreenState extends State<CallAndContactScreen> {
  List<CallLogEntry> callLogs = [];
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    requestPermissionsAndLoad();
  }

  Future<void> requestPermissionsAndLoad() async {
    final status = await [
      Permission.phone,
      Permission.contacts,
    ].request();

    if (status[Permission.phone]!.isGranted) {
      final Iterable<CallLogEntry> logs = await CallLog.get();
      setState(() => callLogs = logs.toList());
    }

    if (status[Permission.contacts]!.isGranted) {
      final List<Contact> allContacts = await FlutterContacts.getContacts();
      setState(() => contacts = allContacts);
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
            const Text('Call Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...callLogs.map((e) => Text('${e.name ?? e.number} - ${e.callType} - ${e.duration}s')),
            const SizedBox(height: 20),
            const Text('Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...contacts.map((c) => Text(c.displayName)),
          ],
        ),
      ),
    );
  }
}
