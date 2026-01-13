// lib/src/storage/sqlite_storage.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/interfaces/repository_interface.dart';
import 'abstractions/entity_storage_comprehensive.dart';
import 'abstractions/storage_capabilities.dart';
import 'abstractions/storage_transaction.dart';
import 'abstractions/query_comprehensive.dart';
import 'types/storage_metadata.dart';
import 'implementations/batch_operations_mixin.dart';
import 'implementations/watchable_storage_mixin.dart';
import 'implementations/versioned_storage_mixin.dart';
import 'implementations/queryable_storage_mixin.dart';
import 'implementations/transaction_impl.dart';

abstract class SqliteStorage<T> implements RepositoryInterface<T> {
  Database? get database;
  String get tableName;
  Map<String, dynamic> toMap(T entity);
  T fromMap(Map<String, dynamic> map);
}

class SqliteStorageImpl<T> extends EntityStorage<String, T>
    with
        BatchEntityOperationsMixin<String, T>,
        WatchableEntityStorageMixin<String, T>,
        VersionedEntityStorageMixin<String, T>,
        QueryableStorageMixin<String, T>
    implements SqliteStorage<T>, TransactionalStorage {
  final String _databaseName;
  final String _tableName;
  final Map<String, dynamic> Function(T) _toMap;
  final T Function(Map<String, dynamic>) _fromMap;
  Database? _database;
  bool _initialized = false;
  bool _disposed = false;

  SqliteStorageImpl(
    this._databaseName,
    this._tableName,
    this._toMap,
    this._fromMap,
  );

  @override
  Database? get database => _database;

  @override
  String get tableName => _tableName;

  @override
  bool get isInitialized => _initialized;

  @override
  bool get isDisposed => _disposed;

  @override
  Map<String, dynamic> toMap(T entity) => _toMap(entity);

  @override
  T fromMap(Map<String, dynamic> map) => _fromMap(map);

  @override
  String getEntityId(T entity) {
    final map = toMap(entity);
    return map['id']?.toString() ?? '';
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await _createTable(db);
        },
      );

      _initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> initializeWithTableSql(String createTableSql) async {
    if (_initialized) return;

    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(createTableSql);
        },
      );

      _initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;

    await _database?.close();
    await disposeWatchable();
    _database = null;
    _disposed = true;
    _initialized = false;
  }

  @override
  Future<void> clear() async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    await _database!.delete(_tableName);
    clearVersions();
  }

  @override
  StorageMetadata? getMetadata() {
    return null;
  }

  @override
  Future<T?> get(dynamic id) async {
    try {
      if (_database == null) {
        throw Exception('Database not initialized');
      }

      final maps = await _database!.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return fromMap(maps.first);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<T>> getAll() async {
    try {
      if (_database == null) {
        throw Exception('Database not initialized');
      }

      final maps = await _database!.query(_tableName);
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<T> create(T entity) async {
    try {
      if (_database == null) {
        throw Exception('Database not initialized');
      }

      final map = toMap(entity);
      await _database!.insert(_tableName, map);

      final id = getEntityId(entity);
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
      if (_database == null) {
        throw Exception('Database not initialized');
      }

      final map = toMap(entity);
      final id = getEntityId(entity);
      final oldEntity = await get(id);

      await _database!.update(
        _tableName,
        map,
        where: 'id = ?',
        whereArgs: [map['id']],
      );

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
      if (_database == null) {
        throw Exception('Database not initialized');
      }

      final oldEntity = await get(id);
      final count = await _database!.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count > 0) {
        resetVersion(id);
        emitEntityDeleted(id, oldEntity);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> contains(dynamic id) async {
    final entity = await get(id);
    return entity != null;
  }

  @override
  Future<int> count() async {
    try {
      if (_database == null) {
        throw Exception('Database not initialized');
      }

      final result = await _database!.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
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
  Future<StorageTransaction> beginTransaction() async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    final transaction = SqliteTransactionImpl(_database!);
    await transaction.begin();
    return transaction;
  }

  @override
  Future<void> updatePartial(dynamic id, Map<String, dynamic> updates) async {
    throw UnsupportedError(
      'Partial update not supported for generic SQLite storage',
    );
  }

  @override
  Future<num> incrementField(dynamic id, String field, num delta) async {
    throw UnsupportedError(
      'Increment field not supported for generic SQLite storage',
    );
  }

  @override
  Future<List<T>> getPage(int offset, int limit) async {
    try {
      if (_database == null) {
        throw Exception('Database not initialized');
      }

      final maps = await _database!.query(
        _tableName,
        limit: limit,
        offset: offset,
      );
      return maps.map((map) => fromMap(map)).toList();
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
