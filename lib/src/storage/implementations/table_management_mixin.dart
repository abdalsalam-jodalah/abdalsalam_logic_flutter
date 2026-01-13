// lib/src/storage/implementations/table_management_mixin.dart

import 'package:sqflite/sqflite.dart';
import '../abstractions/table_management.dart';
import '../exceptions/storage_exceptions.dart';

/// Mixin providing table management capabilities for SQL databases.
///
/// This implementation is designed for SQLite using sqflite.
mixin TableManagementMixin implements TableManagementStorage {
  /// Get the underlying database instance.
  /// Must be implemented by the storage class.
  Database? get database;

  @override
  Future<void> createTable(String name, {TableSchema? schema}) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      if (schema == null) {
        throw StorageOperationException(
          operation: 'createTable',
          message: 'Schema is required for table creation',
        );
      }

      final sql = _buildCreateTableSql(schema);
      await database!.execute(sql);

      // Create indexes if specified
      for (final index in schema.indexes) {
        await createIndex(name, index.name, index.fields, unique: index.unique);
      }
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to create table: $e',
      );
    }
  }

  @override
  Future<void> dropTable(String name, {bool ifExists = false}) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final sql = 'DROP TABLE ${ifExists ? 'IF EXISTS' : ''} $name';
      await database!.execute(sql);
    } catch (e) {
      if (!ifExists) {
        throw StorageOperationException(
          operation: 'storage',
          message: 'Failed to drop table: $e',
        );
      }
    }
  }

  @override
  Future<void> renameTable(String oldName, String newName) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      await database!.execute('ALTER TABLE $oldName RENAME TO $newName');
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to rename table: $e',
      );
    }
  }

  @override
  Future<void> truncateTable(String name) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      await database!.delete(name);
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to truncate table: $e',
      );
    }
  }

  @override
  Future<bool> tableExists(String name) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final result = await database!.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', name],
      );

      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> listTables() async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final result = await database!.query(
        'sqlite_master',
        columns: ['name'],
        where: 'type = ?',
        whereArgs: ['table'],
      );

      return result.map((row) => row['name'] as String).toList();
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to list tables: $e',
      );
    }
  }

  @override
  Future<TableInfo?> getTableInfo(String name) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      if (!await tableExists(name)) {
        return null;
      }

      // Get row count
      final countResult = await database!.rawQuery(
        'SELECT COUNT(*) as count FROM $name',
      );
      final count = countResult.first['count'] as int;

      return TableInfo(name: name, count: count);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> alterTable(String name, TableSchemaChange change) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      if (change is AddFieldChange) {
        final field = change.field;
        final sql = 'ALTER TABLE $name ADD COLUMN ${_buildFieldSql(field)}';
        await database!.execute(sql);
      } else if (change is DropFieldChange) {
        // SQLite doesn't support DROP COLUMN directly, need to recreate table
        throw StorageUnsupportedException(
          operation: 'dropColumn',
          message: 'SQLite does not support dropping columns',
        );
      } else if (change is RenameFieldChange) {
        final sql =
            'ALTER TABLE $name RENAME COLUMN ${change.oldName} TO ${change.newName}';
        await database!.execute(sql);
      } else if (change is ModifyFieldChange) {
        // SQLite doesn't support MODIFY COLUMN, need to recreate table
        throw StorageUnsupportedException(
          operation: 'modifyColumn',
          message: 'SQLite does not support modifying columns',
        );
      }
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to alter table: $e',
      );
    }
  }

  @override
  Future<TableSchema?> getTableSchema(String name) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final result = await database!.rawQuery('PRAGMA table_info($name)');
      if (result.isEmpty) {
        return null;
      }

      final fields = result.map((row) {
        return FieldSchema(
          name: row['name'] as String,
          type: _mapSqliteType(row['type'] as String),
          required: (row['notnull'] as int) == 1,
          defaultValue: row['dflt_value'],
        );
      }).toList();

      return TableSchema(name: name, fields: fields);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createIndex(
    String tableName,
    String indexName,
    List<String> fields, {
    bool unique = false,
  }) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final uniqueKeyword = unique ? 'UNIQUE' : '';
      final fieldsList = fields.join(', ');
      final sql =
          'CREATE $uniqueKeyword INDEX $indexName ON $tableName($fieldsList)';
      await database!.execute(sql);
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to create index: $e',
      );
    }
  }

  @override
  Future<void> dropIndex(String tableName, String indexName) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      await database!.execute('DROP INDEX $indexName');
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to drop index: $e',
      );
    }
  }

  @override
  Future<List<String>> listIndexes(String tableName) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final result = await database!.query(
        'sqlite_master',
        columns: ['name'],
        where: 'type = ? AND tbl_name = ?',
        whereArgs: ['index', tableName],
      );

      return result.map((row) => row['name'] as String).toList();
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to list indexes: $e',
      );
    }
  }

  // Helper methods

  String _buildCreateTableSql(TableSchema schema) {
    final fields = schema.fields.map(_buildFieldSql).join(', ');
    final primaryKey = schema.primaryKeys.isNotEmpty
        ? ', PRIMARY KEY (${schema.primaryKeys.join(', ')})'
        : '';

    return 'CREATE TABLE ${schema.name} ($fields$primaryKey)';
  }

  String _buildFieldSql(FieldSchema field) {
    final typeStr = _mapFieldTypeToSql(field.type);
    final notNull = field.required ? ' NOT NULL' : '';
    final defaultValue = field.defaultValue != null
        ? ' DEFAULT ${_formatValue(field.defaultValue)}'
        : '';
    final unique = field.unique ? ' UNIQUE' : '';

    return '${field.name} $typeStr$notNull$defaultValue$unique';
  }

  String _mapFieldTypeToSql(FieldType type) {
    switch (type) {
      case FieldType.string:
        return 'TEXT';
      case FieldType.integer:
        return 'INTEGER';
      case FieldType.double:
        return 'REAL';
      case FieldType.boolean:
        return 'INTEGER';
      case FieldType.dateTime:
      case FieldType.date:
      case FieldType.time:
        return 'TEXT';
      case FieldType.blob:
        return 'BLOB';
      case FieldType.json:
      case FieldType.list:
      case FieldType.map:
        return 'TEXT';
      case FieldType.uuid:
        return 'TEXT';
    }
  }

  FieldType _mapSqliteType(String sqlType) {
    final type = sqlType.toUpperCase();
    if (type.contains('INT')) return FieldType.integer;
    if (type.contains('REAL') ||
        type.contains('FLOAT') ||
        type.contains('DOUBLE'))
      return FieldType.double;
    if (type.contains('BLOB')) return FieldType.blob;
    return FieldType.string;
  }

  String _formatValue(dynamic value) {
    if (value is String) return "'$value'";
    if (value is bool) return value ? '1' : '0';
    return value.toString();
  }
}
