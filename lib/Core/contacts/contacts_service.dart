import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SimpleContact {
  final String name;
  final String phone;
  SimpleContact({required this.name, required this.phone});
}

class ContactsService {
  static Future<List<SimpleContact>> getAllContacts() async {
    // ✅ Request using permission_handler (reliable)
    var status = await Permission.contacts.status;
    debugPrint("📛 Contacts permission status: $status");

    if (!status.isGranted) {
      status = await Permission.contacts.request();
      debugPrint("📛 Contacts permission after request: $status");
    }

    // Do not force users out of the app. Callers can show their own
    // in-app permission UI and let users open Settings manually if needed.
    if (status.isPermanentlyDenied) {
      debugPrint("❌ Contacts permission permanently denied.");
      return [];
    }

    if (!status.isGranted) {
      debugPrint("❌ Permission not granted.");
      return [];
    }

    // ✅ Now fetch contacts
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    debugPrint("📒 Raw contacts count = ${contacts.length}");

    final out = <SimpleContact>[];

    for (final c in contacts) {
      final name = (c.displayName).trim();
      for (final p in c.phones) {
        final phone = normalizePhone(p.number);
        if (phone.isNotEmpty) {
          out.add(
            SimpleContact(
              name: name.isEmpty ? "Unknown" : name,
              phone: phone,
            ),
          );
        }
      }
    }

    // remove duplicates by phone
    final map = <String, SimpleContact>{};
    for (final item in out) {
      map[item.phone] = item;
    }

    debugPrint("✅ Parsed phone entries count = ${map.length}");
    return map.values.toList();
  }

  static String normalizePhone(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('91') && cleaned.length > 10) {
      return cleaned.substring(cleaned.length - 10);
    }
    if (cleaned.length > 10) return cleaned.substring(cleaned.length - 10);
    return cleaned;
  }
}

