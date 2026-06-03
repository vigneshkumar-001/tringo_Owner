import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  final status = await FlutterContacts.permissions.request(
    PermissionType.readWrite,
  );
  if (status == PermissionStatus.granted ||
      status == PermissionStatus.limited) {
    return FlutterContacts.getAll(properties: {ContactProperty.phone});
  }
  return [];
});
