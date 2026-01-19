// lib/src/contacts/contacts_service_impl.dart
// import 'package:contacts_service/contacts_service.dart' as contacts;
import 'contacts_service.dart';

class ContactsServiceImpl implements ContactsService {
  ContactsServiceImpl();

  @override
  Future<void> initialize() async {
  }

  @override
  Future<void> dispose() async {
  }

  @override
  Future<List<Map<String, dynamic>>> getContacts() async {
    try {
      // final contactsList = await contacts.ContactsService.getContacts();
      // return contactsList
      //     .map(
      //       (contact) => {
      //         'identifier': contact.identifier,
      //         'displayName': contact.displayName,
      //         'givenName': contact.givenName,
      //         'familyName': contact.familyName,
      //         'emails': contact.emails?.map((e) => e.value).toList() ?? [],
      //         'phones': contact.phones?.map((p) => p.value).toList() ?? [],
      //       },
      //     )
      //     .toList();
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> getContact(String identifier) async {
    try {
      // final contactsList = await contacts.ContactsService.getContacts(
      //   withThumbnails: false,
      // );
      // final contact = contactsList.firstWhere(
      //   (c) => c.identifier == identifier,
      //   orElse: () => throw Exception('Contact not found'),
      // );
      // return {
      //   'identifier': contact.identifier,
      //   'displayName': contact.displayName,
      //   'givenName': contact.givenName,
      //   'familyName': contact.familyName,
      //   'emails': contact.emails?.map((e) => e.value).toList() ?? [],
      //   'phones': contact.phones?.map((p) => p.value).toList() ?? [],
      // };
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addContact(Map<String, dynamic> contact) async {
    try {
      // final newContact = contacts.Contact(
      //   givenName: contact['givenName'] as String? ?? '',
      //   familyName: contact['familyName'] as String? ?? '',
      //   emails:
      //       (contact['emails'] as List<dynamic>?)
      //           ?.map((e) => contacts.Item(label: 'email', value: e.toString()))
      //           .toList() ??
      //       [],
      //   phones:
      //       (contact['phones'] as List<dynamic>?)
      //           ?.map((p) => contacts.Item(label: 'phone', value: p.toString()))
      //           .toList() ??
      //       [],
      // );
      // await contacts.ContactsService.addContact(newContact);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateContact(
    String identifier,
    Map<String, dynamic> updates,
  ) async {
    try {
      // final contactsList = await contacts.ContactsService.getContacts();
      // final contact = contactsList.firstWhere(
      //   (c) => c.identifier == identifier,
      //   orElse: () => throw Exception('Contact not found'),
      // );
      //
      // final updatedContact = contacts.Contact(
      //   givenName: updates['givenName'] as String? ?? contact.givenName,
      //   familyName: updates['familyName'] as String? ?? contact.familyName,
      //   emails:
      //       (updates['emails'] as List<dynamic>?)
      //           ?.map((e) => contacts.Item(label: 'email', value: e.toString()))
      //           .toList() ??
      //       contact.emails,
      //   phones:
      //       (updates['phones'] as List<dynamic>?)
      //           ?.map((p) => contacts.Item(label: 'phone', value: p.toString()))
      //           .toList() ??
      //       contact.phones,
      // );
      //
      // updatedContact.identifier = contact.identifier;
      //
      // await contacts.ContactsService.updateContact(updatedContact);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(String identifier) async {
    try {
      // final contactsList = await contacts.ContactsService.getContacts();
      // final contact = contactsList.firstWhere(
      //   (c) => c.identifier == identifier,
      //   orElse: () => throw Exception('Contact not found'),
      // );
      // await contacts.ContactsService.deleteContact(contact);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      // await contacts.ContactsService.getContacts();
      return true;
    } catch (e) {
      return false;
    }
  }
}
