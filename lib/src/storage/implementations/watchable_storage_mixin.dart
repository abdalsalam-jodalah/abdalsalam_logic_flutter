// lib/src/storage/implementations/watchable_storage_mixin.dart

import 'dart:async';
import '../abstractions/entity_storage_comprehensive.dart';
import '../abstractions/key_value_storage_comprehensive.dart';
import '../abstractions/query_comprehensive.dart';
import '../exceptions/storage_exceptions.dart';

mixin WatchableEntityStorageMixin<ID, T> on EntityStorage<ID, T> {
  final StreamController<EntityChange<ID, T>> _changeController =
      StreamController<EntityChange<ID, T>>.broadcast();

  Stream<EntityChange<ID, T>?> watchEntity(ID id) {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    return _changeController.stream
        .where((change) => change.id == id)
        .map((change) => change);
  }

  Stream<EntityChange<ID, T>> watchAllEntities() {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    return _changeController.stream;
  }

  Stream<EntityChange<ID, T>> watchQueryEntities(EntityQuery<T> query) {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    return _changeController.stream;
  }

  void emitEntityCreated(ID id, T entity) {
    _changeController.add(
      EntityChange<ID, T>(
        id: id,
        type: EntityChangeType.created,
        newEntity: entity,
        oldEntity: null,
      ),
    );
  }

  void emitEntityUpdated(ID id, T entity, T? oldEntity) {
    _changeController.add(
      EntityChange<ID, T>(
        id: id,
        type: EntityChangeType.updated,
        newEntity: entity,
        oldEntity: oldEntity,
      ),
    );
  }

  void emitEntityDeleted(ID id, T? oldEntity) {
    _changeController.add(
      EntityChange<ID, T>(
        id: id,
        type: EntityChangeType.deleted,
        newEntity: null,
        oldEntity: oldEntity,
      ),
    );
  }

  Future<void> disposeWatchable() async {
    await _changeController.close();
  }
}

mixin WatchableKeyValueStorageMixin on KeyValueStorage {
  final StreamController<KeyValueChange> _changeController =
      StreamController<KeyValueChange>.broadcast();

  Stream<KeyValueChange?> watchKeyValue(String key) {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    return _changeController.stream
        .where((change) => change.key == key)
        .map((change) => change);
  }

  Stream<KeyValueChange> watchAllKeyValues() {
    return _changeController.stream;
  }

  Stream<KeyValueChange> watchKeyValuePrefix(String prefix) {
    return _changeController.stream.where(
      (change) => change.key.startsWith(prefix),
    );
  }

  void emitKeyValueChanged<T>(String key, T newValue, T? oldValue) {
    _changeController.add(
      KeyValueChange(
        key: key,
        type: oldValue == null
            ? KeyValueChangeType.created
            : KeyValueChangeType.updated,
        newValue: newValue,
        oldValue: oldValue,
      ),
    );
  }

  void emitKeyValueDeleted(String key, dynamic oldValue) {
    _changeController.add(
      KeyValueChange(
        key: key,
        type: KeyValueChangeType.deleted,
        oldValue: oldValue,
      ),
    );
  }

  Future<void> disposeWatchable() async {
    await _changeController.close();
  }
}

enum KeyValueChangeType { created, updated, deleted }

class KeyValueChange {
  final String key;
  final KeyValueChangeType type;
  final dynamic newValue;
  final dynamic oldValue;

  KeyValueChange({
    required this.key,
    required this.type,
    this.newValue,
    this.oldValue,
  });
}
