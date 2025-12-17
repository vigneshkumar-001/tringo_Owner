import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  if (await FlutterContacts.requestPermission()) {
    return FlutterContacts.getContacts(withProperties: true);
  }
  return [];
});
