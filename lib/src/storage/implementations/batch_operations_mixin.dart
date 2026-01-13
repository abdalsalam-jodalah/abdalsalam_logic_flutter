// lib/src/storage/implementations/batch_operations_mixin.dart

import 'dart:async';
import '../abstractions/entity_storage_comprehensive.dart';
import '../abstractions/key_value_storage_comprehensive.dart';
import '../exceptions/storage_exceptions.dart';

mixin BatchEntityOperationsMixin<ID, T> on EntityStorage<ID, T> {
  Future<List<T>> getMultipleBatch(List<ID> ids) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      final results = <T>[];
      for (final id in ids) {
        final entity = await get(id);
        if (entity != null) {
          results.add(entity);
        }
      }
      return results;
    } catch (e) {
      throw StorageOperationException(
        operation: 'getMultiple',
        message: 'Failed to get multiple entities: $e',
      );
    }
  }

  Future<void> createMultipleBatch(List<T> entities) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      for (final entity in entities) {
        await create(entity);
      }
    } catch (e) {
      throw StorageOperationException(
        operation: 'createMultiple',
        message: 'Failed to create multiple entities: $e',
      );
    }
  }

  Future<void> updateMultipleBatch(List<T> entities) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      for (final entity in entities) {
        await update(entity);
      }
    } catch (e) {
      throw StorageOperationException(
        operation: 'updateMultiple',
        message: 'Failed to update multiple entities: $e',
      );
    }
  }

  Future<void> upsertMultipleBatch(List<T> entities) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      for (final entity in entities) {
        await upsert(entity);
      }
    } catch (e) {
      throw StorageOperationException(
        operation: 'upsertMultiple',
        message: 'Failed to upsert multiple entities: $e',
      );
    }
  }

  Future<int> deleteMultipleBatch(List<ID> ids) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      int count = 0;
      for (final id in ids) {
        final deleted = await delete(id);
        if (deleted) {
          count++;
        }
      }
      return count;
    } catch (e) {
      throw StorageOperationException(
        operation: 'deleteMultiple',
        message: 'Failed to delete multiple entities: $e',
      );
    }
  }
}

mixin BatchKeyValueOperationsMixin on KeyValueStorage {

  Future<Map<String, T>> getMultipleBatch<T>(List<String> keys) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      final results = <String, T>{};
      for (final key in keys) {
        final value = await get(key);
        if (value != null && value is T) {
          results[key] = value;
        }
      }
      return results;
    } catch (e) {
      throw StorageOperationException(
        operation: 'getMultiple',
        message: 'Failed to get multiple values: $e',
      );
    }
  }

  Future<void> setMultipleBatch<T>(Map<String, T> entries) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      for (final entry in entries.entries) {
        await set(entry.key, entry.value);
      }
    } catch (e) {
      throw StorageOperationException(
        operation: 'setMultiple',
        message: 'Failed to set multiple values: $e',
      );
    }
  }

  Future<int> removeMultipleBatch(List<String> keys) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      int count = 0;
      for (final key in keys) {
        final bool removed = await (this as KeyValueStorage).delete(key);
        if (removed) {
          count++;
        }
      }
      return count;
    } catch (e) {
      throw StorageOperationException(
        operation: 'removeMultiple',
        message: 'Failed to delete multiple keys: $e',
      );
    }
  }
}
