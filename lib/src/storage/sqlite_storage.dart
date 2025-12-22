// lib/src/storage/sqlite_storage.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../logging/logger_service.dart';
import '../core/interfaces/repository_interface.dart';

abstract class SqliteStorage<T> implements RepositoryInterface<T> {
  Database? get database;
  String get tableName;
  Map<String, dynamic> toMap(T entity);
  T fromMap(Map<String, dynamic> map);
}

class SqliteStorageImpl<T> implements SqliteStorage<T> {
  final LoggerService _logger;
  final String _databaseName;
  final String _tableName;
  final Map<String, dynamic> Function(T) _toMap;
  final T Function(Map<String, dynamic>) _fromMap;
  Database? _database;

  SqliteStorageImpl(
    this._logger,
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
  Map<String, dynamic> toMap(T entity) => _toMap(entity);

  @override
  T fromMap(Map<String, dynamic> map) => _fromMap(map);

  Future<void> initialize(String createTableSql) async {
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

      _logger.info('SQLite database $_databaseName initialized');
    } catch (e) {
      _logger.error('Failed to initialize SQLite database', error: e);
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _database?.close();
    _database = null;
  }

  @override
  Future<T?> get(String id) async {
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
      _logger.error('Failed to get entity with id: $id', error: e);
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
      _logger.error('Failed to get all entities', error: e);
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
      final id = await _database!.insert(_tableName, map);
      return await get(id.toString()) ?? entity;
    } catch (e) {
      _logger.error('Failed to create entity', error: e);
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
      await _database!.update(
        _tableName,
        map,
        where: 'id = ?',
        whereArgs: [map['id']],
      );
      return entity;
    } catch (e) {
      _logger.error('Failed to update entity', error: e);
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      if (_database == null) {
        throw Exception('Database not initialized');
      }

      await _database!.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _logger.error('Failed to delete entity with id: $id', error: e);
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      if (_database == null) {
        throw Exception('Database not initialized');
      }

      await _database!.delete(_tableName);
    } catch (e) {
      _logger.error('Failed to clear table', error: e);
      rethrow;
    }
  }
}

