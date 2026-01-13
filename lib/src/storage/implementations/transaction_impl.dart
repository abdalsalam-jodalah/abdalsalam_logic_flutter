// lib/src/storage/implementations/transaction_impl.dart

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../abstractions/storage_transaction.dart';
import '../exceptions/storage_exceptions.dart';

class SqliteTransactionImpl implements StorageTransaction {
  final Database _database;
  Transaction? _transaction;
  bool _isActive = false;
  bool _isCommitted = false;
  bool _isRolledBack = false;
  final List<SavePoint> _savepoints = [];

  SqliteTransactionImpl(this._database);

  @override
  bool get isActive => _isActive;

  @override
  bool get isCommitted => _isCommitted;

  @override
  bool get isRolledBack => _isRolledBack;

  @override
  IsolationLevel get isolationLevel => IsolationLevel.serializable;

  Future<void> begin() async {
    if (_isActive) {
      throw StorageTransactionException(message: 'Transaction already active');
    }

    try {
      await _database.transaction((txn) async {
        _transaction = txn;
        _isActive = true;
      });
    } catch (e) {
      throw StorageTransactionException(
        message: 'Failed to begin transaction: $e',
      );
    }
  }

  @override
  Future<void> commit() async {
    if (!_isActive) {
      throw StorageStateException(message: 'Transaction is not active');
    }

    if (_isCommitted || _isRolledBack) {
      return;
    }

    try {
      _isCommitted = true;
      _isActive = false;
      _savepoints.clear();
    } catch (e) {
      throw StorageTransactionException(
        message: 'Failed to commit transaction: $e',
      );
    }
  }

  @override
  Future<void> rollback() async {
    if (!_isActive) {
      throw StorageStateException(message: 'Transaction is not active');
    }

    if (_isCommitted || _isRolledBack) {
      return;
    }

    try {
      _isRolledBack = true;
      _isActive = false;
      _savepoints.clear();
      throw StorageTransactionException(message: 'Transaction rolled back');
    } catch (e) {
      throw StorageTransactionException(
        message: 'Failed to rollback transaction: $e',
      );
    }
  }

  @override
  Future<T> execute<T>(
    Future<T> Function(StorageTransaction tx) operation,
  ) async {
    if (!_isActive) {
      throw StorageStateException(message: 'Transaction is not active');
    }

    try {
      return await operation(this);
    } catch (e) {
      await rollback();
      rethrow;
    }
  }

  @override
  Future<SavePoint> savepoint(String name) async {
    if (!_isActive) {
      throw StorageStateException(message: 'Transaction is not active');
    }

    try {
      final savepoint = SavePoint(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      );

      _savepoints.add(savepoint);

      await _transaction!.execute('SAVEPOINT $name');

      return savepoint;
    } catch (e) {
      throw StorageTransactionException(
        message: 'Failed to create savepoint: $e',
      );
    }
  }

  @override
  Future<void> rollbackToSavepoint(SavePoint savepoint) async {
    if (!_isActive) {
      throw StorageStateException(message: 'Transaction is not active');
    }

    if (!_savepoints.contains(savepoint)) {
      throw StorageNotFoundException(
        identifier: savepoint.name,
        message: 'Savepoint not found: ${savepoint.name}',
      );
    }

    try {
      await _transaction!.execute('ROLLBACK TO SAVEPOINT ${savepoint.name}');

      final index = _savepoints.indexOf(savepoint);
      _savepoints.removeRange(index + 1, _savepoints.length);
    } catch (e) {
      throw StorageTransactionException(
        message: 'Failed to rollback to savepoint: $e',
      );
    }
  }

  Future<void> executeSql(String sql, [List<dynamic>? arguments]) async {
    if (!_isActive || _transaction == null) {
      throw StorageStateException(message: 'Transaction is not active');
    }

    try {
      await _transaction!.execute(sql, arguments);
    } catch (e) {
      throw StorageOperationException(
        operation: 'executeSql',
        message: 'Failed to execute SQL: $e',
      );
    }
  }

  Future<List<Map<String, dynamic>>> querySql(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    if (!_isActive || _transaction == null) {
      throw StorageStateException(message: 'Transaction is not active');
    }

    try {
      return await _transaction!.rawQuery(sql, arguments);
    } catch (e) {
      throw StorageOperationException(
        operation: 'querySql',
        message: 'Failed to query SQL: $e',
      );
    }
  }
}
