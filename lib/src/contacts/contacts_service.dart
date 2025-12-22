// lib/src/contacts/contacts_service.dart
import '../core/interfaces/service_interface.dart';

abstract class ContactsService extends ServiceInterface {
  Future<List<Map<String, dynamic>>> getContacts();
  Future<Map<String, dynamic>?> getContact(String identifier);
  Future<void> addContact(Map<String, dynamic> contact);
  Future<void> updateContact(String identifier, Map<String, dynamic> updates);
  Future<void> deleteContact(String identifier);
  Future<bool> requestPermission();
}

