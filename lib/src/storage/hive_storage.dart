// lib/src/storage/hive_storage.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../logging/logger_service.dart';
import '../core/interfaces/repository_interface.dart';

abstract class HiveStorage<T> implements RepositoryInterface<T> {
  Box<T>? get box;
  String get boxName;
}

class HiveStorageImpl<T> implements HiveStorage<T> {
  final LoggerService _logger;
  final String _boxName;
  Box<T>? _box;

  HiveStorageImpl(this._logger, this._boxName);

  @override
  Box<T>? get box => _box;

  @override
  String get boxName => _boxName;

  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<T>(_boxName);
      _logger.info('Hive box $_boxName initialized');
    } catch (e) {
      _logger.error('Failed to initialize Hive box', error: e);
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }

  @override
  Future<T?> get(String id) async {
    try {
      if (_box == null) await initialize();
      return _box!.get(id);
    } catch (e) {
      _logger.error('Failed to get value for key: $id', error: e);
      return null;
    }
  }

  @override
  Future<List<T>> getAll() async {
    try {
      if (_box == null) await initialize();
      return _box!.values.toList();
    } catch (e) {
      _logger.error('Failed to get all values', error: e);
      return [];
    }
  }

  @override
  Future<T> create(T entity) async {
    try {
      if (_box == null) await initialize();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await _box!.put(id, entity);
      return entity;
    } catch (e) {
      _logger.error('Failed to create entity', error: e);
      rethrow;
    }
  }

  @override
  Future<T> update(T entity) async {
    return create(entity);
  }

  @override
  Future<void> delete(String id) async {
    try {
      if (_box == null) await initialize();
      await _box!.delete(id);
    } catch (e) {
      _logger.error('Failed to delete entity with id: $id', error: e);
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      if (_box == null) await initialize();
      await _box!.clear();
    } catch (e) {
      _logger.error('Failed to clear box', error: e);
      rethrow;
    }
  }
}


