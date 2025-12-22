// lib/src/contacts/contacts_service_impl.dart
import 'package:contacts_service/contacts_service.dart' as contacts;
import '../logging/logger_service.dart';
import 'contacts_service.dart';

class ContactsServiceImpl implements ContactsService {
  final LoggerService _logger;

  ContactsServiceImpl(this._logger);

  @override
  Future<void> initialize() async {
    _logger.info('Contacts service initialized');
  }

  @override
  Future<void> dispose() async {
    _logger.info('Contacts service disposed');
  }

  @override
  Future<List<Map<String, dynamic>>> getContacts() async {
    try {
      final contactsList = await contacts.ContactsService.getContacts();
      return contactsList
          .map(
            (contact) => {
              'identifier': contact.identifier,
              'displayName': contact.displayName,
              'givenName': contact.givenName,
              'familyName': contact.familyName,
              'emails': contact.emails?.map((e) => e.value).toList() ?? [],
              'phones': contact.phones?.map((p) => p.value).toList() ?? [],
            },
          )
          .toList();
    } catch (e) {
      _logger.error('Failed to get contacts', error: e);
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> getContact(String identifier) async {
    try {
      final contactsList = await contacts.ContactsService.getContacts(
        withThumbnails: false,
      );
      final contact = contactsList.firstWhere(
        (c) => c.identifier == identifier,
        orElse: () => throw Exception('Contact not found'),
      );
      return {
        'identifier': contact.identifier,
        'displayName': contact.displayName,
        'givenName': contact.givenName,
        'familyName': contact.familyName,
        'emails': contact.emails?.map((e) => e.value).toList() ?? [],
        'phones': contact.phones?.map((p) => p.value).toList() ?? [],
      };
    } catch (e) {
      _logger.error('Failed to get contact: $identifier', error: e);
      return null;
    }
  }

  @override
  Future<void> addContact(Map<String, dynamic> contact) async {
    try {
      final newContact = contacts.Contact(
        givenName: contact['givenName'] as String? ?? '',
        familyName: contact['familyName'] as String? ?? '',
        emails:
            (contact['emails'] as List<dynamic>?)
                ?.map((e) => contacts.Item(label: 'email', value: e.toString()))
                .toList() ??
            [],
        phones:
            (contact['phones'] as List<dynamic>?)
                ?.map((p) => contacts.Item(label: 'phone', value: p.toString()))
                .toList() ??
            [],
      );
      await contacts.ContactsService.addContact(newContact);
      _logger.info('Contact added successfully');
    } catch (e) {
      _logger.error('Failed to add contact', error: e);
      rethrow;
    }
  }

  @override
  Future<void> updateContact(
    String identifier,
    Map<String, dynamic> updates,
  ) async {
    try {
      final contactsList = await contacts.ContactsService.getContacts();
      final contact = contactsList.firstWhere(
        (c) => c.identifier == identifier,
        orElse: () => throw Exception('Contact not found'),
      );

      final updatedContact = contacts.Contact(
        givenName: updates['givenName'] as String? ?? contact.givenName,
        familyName: updates['familyName'] as String? ?? contact.familyName,
        emails:
            (updates['emails'] as List<dynamic>?)
                ?.map((e) => contacts.Item(label: 'email', value: e.toString()))
                .toList() ??
            contact.emails,
        phones:
            (updates['phones'] as List<dynamic>?)
                ?.map((p) => contacts.Item(label: 'phone', value: p.toString()))
                .toList() ??
            contact.phones,
      );

      updatedContact.identifier = contact.identifier;

      await contacts.ContactsService.updateContact(updatedContact);
      _logger.info('Contact updated: $identifier');
    } catch (e) {
      _logger.error('Failed to update contact', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(String identifier) async {
    try {
      final contactsList = await contacts.ContactsService.getContacts();
      final contact = contactsList.firstWhere(
        (c) => c.identifier == identifier,
        orElse: () => throw Exception('Contact not found'),
      );
      await contacts.ContactsService.deleteContact(contact);
      _logger.info('Contact deleted: $identifier');
    } catch (e) {
      _logger.error('Failed to delete contact', error: e);
      rethrow;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      await contacts.ContactsService.getContacts();
      return true;
    } catch (e) {
      _logger.error('Failed to request contacts permission', error: e);
      return false;
    }
  }
}
