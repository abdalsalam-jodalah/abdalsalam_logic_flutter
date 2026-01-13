// lib/src/storage/implementations/versioned_storage_mixin.dart

import 'dart:async';
import '../abstractions/entity_storage_comprehensive.dart';
import '../exceptions/storage_exceptions.dart';

mixin VersionedEntityStorageMixin<ID, T> on EntityStorage<ID, T> {
  final Map<ID, int> _versions = {};

  Future<bool> updateEntityWithVersion(T entity, int expectedVersion) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      final id = getEntityId(entity);
      final currentVersion = _versions[id] ?? 0;

      if (currentVersion != expectedVersion) {
        return false;
      }

      await update(entity);
      _versions[id] = currentVersion + 1;
      return true;
    } catch (e) {
      throw StorageOperationException(
        operation: 'updateWithVersion',
        message: 'Failed to update with version: $e',
      );
    }
  }

  Future<VersionedEntity<T>?> getEntityWithVersion(ID id) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      final entity = await get(id);
      if (entity == null) return null;

      final version = _versions[id] ?? 0;
      return VersionedEntity(entity, version);
    } catch (e) {
      throw StorageOperationException(
        operation: 'getWithVersion',
        message: 'Failed to get with version: $e',
      );
    }
  }

  void incrementVersion(ID id) {
    final currentVersion = _versions[id] ?? 0;
    _versions[id] = currentVersion + 1;
  }

  int getVersion(ID id) {
    return _versions[id] ?? 0;
  }

  void resetVersion(ID id) {
    _versions.remove(id);
  }

  void clearVersions() {
    _versions.clear();
  }
}
