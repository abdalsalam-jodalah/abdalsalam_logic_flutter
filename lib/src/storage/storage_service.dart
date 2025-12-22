// lib/src/storage/storage_service.dart
import '../core/interfaces/service_interface.dart';

abstract class StorageService extends ServiceInterface {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value);
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
  Future<Map<String, dynamic>> getAll();
}

