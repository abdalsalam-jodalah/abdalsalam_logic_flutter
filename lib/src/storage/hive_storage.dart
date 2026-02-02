// lib/src/storage/hive_storage.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../core/interfaces/repository_interface.dart';
import 'abstractions/entity_storage_comprehensive.dart';
import 'abstractions/query_comprehensive.dart';
import 'types/storage_metadata.dart';
import 'implementations/batch_operations_mixin.dart';
import 'implementations/watchable_storage_mixin.dart';
import 'implementations/versioned_storage_mixin.dart';
import 'implementations/queryable_storage_mixin.dart';

abstract class HiveStorage<T> implements RepositoryInterface<T> {
  Box<T>? get box;
  String get boxName;
}

class HiveStorageImpl<T> extends EntityStorage<String, T>
    with
        BatchEntityOperationsMixin<String, T>,
        WatchableEntityStorageMixin<String, T>,
        VersionedEntityStorageMixin<String, T>,
        QueryableStorageMixin<String, T>
    implements HiveStorage<T> {
  final String _boxName;
  final String Function(T)? _getEntityId;
  Box<T>? _box;
  bool _initialized = false;
  bool _disposed = false;

  HiveStorageImpl(this._boxName, {String Function(T)? getEntityId})
    : _getEntityId = getEntityId;

  @override
  Box<T>? get box => _box;

  @override
  String get boxName => _boxName;

  @override
  bool get isInitialized => _initialized;

  @override
  bool get isDisposed => _disposed;

  @override
  String getEntityId(T entity) {
    if (_getEntityId != null) {
      return _getEntityId(entity);
    }
    if (entity is Map && entity.containsKey('id')) {
      return entity['id'].toString();
    }
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<T>(_boxName);
      _initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;

    await _box?.close();
    await disposeWatchable();
    _box = null;
    _disposed = true;
    _initialized = false;
  }

  @override
  Future<void> clear() async {
    if (_box == null) {
      throw Exception('Box not initialized');
    }

    await _box!.clear();
    clearVersions();
  }

  @override
  StorageMetadata? getMetadata() {
    return null;
  }

  @override
  Future<T?> get(dynamic id) async {
    try {
      if (_box == null) {
        throw Exception('Box not initialized');
      }
      return _box!.get(id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<T>> getAll() async {
    try {
      if (_box == null) {
        throw Exception('Box not initialized');
      }
      return _box!.values.toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<T> create(T entity) async {
    try {
      if (_box == null) {
        throw Exception('Box not initialized');
      }

      final id = _getEntityId?.call(entity) ?? entity.toString();
      await _box!.put(id, entity);

      incrementVersion(id);
      emitEntityCreated(id, entity);
      return entity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<T> update(T entity) async {
    try {
      if (_box == null) {
        throw Exception('Box not initialized');
      }

      final id = _getEntityId?.call(entity) ?? entity.toString();
      final oldEntity = await get(id);
      await _box!.put(id, entity);

      incrementVersion(id);
      emitEntityUpdated(id, entity, oldEntity);
      return entity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> upsert(T entity) async {
    final id = getEntityId(entity);
    final exists = await contains(id);

    if (exists) {
      await update(entity);
    } else {
      await create(entity);
    }
  }

  @override
  Future<bool> delete(dynamic id) async {
    try {
      if (_box == null) {
        throw Exception('Box not initialized');
      }

      final oldEntity = await get(id);
      await _box!.delete(id);

      resetVersion(id);
      emitEntityDeleted(id, oldEntity);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> contains(dynamic id) async {
    if (_box == null) {
      throw Exception('Box not initialized');
    }
    return _box!.containsKey(id);
  }

  @override
  Future<int> count() async {
    if (_box == null) {
      throw Exception('Box not initialized');
    }
    return _box!.length;
  }

  @override
  Future<List<T>> getMultiple(List<dynamic> ids) async {
    return await getMultipleBatch(ids.cast<String>());
  }

  @override
  Future<void> createMultiple(List<T> entities) async {
    await createMultipleBatch(entities);
  }

  @override
  Future<void> updateMultiple(List<T> entities) async {
    await updateMultipleBatch(entities);
  }

  @override
  Future<void> upsertMultiple(List<T> entities) async {
    await upsertMultipleBatch(entities);
  }

  @override
  Future<int> deleteMultiple(List<dynamic> ids) async {
    return await deleteMultipleBatch(ids.cast<String>());
  }

  Stream<EntityChange<String, T>?> watch(String id) {
    return watchEntity(id);
  }

  Stream<EntityChange<String, T>> watchAll() {
    return watchAllEntities();
  }

  Stream<EntityChange<String, T>> watchQuery(EntityQuery<T> query) {
    return watchQueryEntities(query);
  }

  Future<bool> updateWithVersion(T entity, int expectedVersion) async {
    return await updateEntityWithVersion(entity, expectedVersion);
  }

  Future<VersionedEntity<T>?> getWithVersion(String id) async {
    return await getEntityWithVersion(id);
  }

  Future<EntityQuery<T>> query() async {
    return await createQuery();
  }

  @override
  Future<void> updatePartial(dynamic id, Map<String, dynamic> updates) async {
    throw UnsupportedError('Partial update not supported for Hive storage');
  }

  @override
  Future<num> incrementField(dynamic id, String field, num delta) async {
    throw UnsupportedError('Increment field not supported for Hive storage');
  }

  @override
  Future<List<T>> getPage(int offset, int limit) async {
    try {
      if (_box == null) {
        throw Exception('Box not initialized');
      }

      final all = _box!.values.toList();
      final start = offset.clamp(0, all.length);
      final end = (offset + limit).clamp(0, all.length);
      return all.sublist(start, end);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> isEmpty() async {
    final total = await count();
    return total == 0;
  }

  @override
  Future<EntityMetadata?> getEntityMetadata(dynamic id) async {
    return null;
  }

  @override
  StorageMetadata? getStorageMetadata() {
    return null;
  }
}
