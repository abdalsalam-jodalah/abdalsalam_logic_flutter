// lib/src/storage/abstractions/table_management.dart

import 'storage_interface.dart';
import '../exceptions/storage_exceptions.dart';

/// Optional capability for storages that support table/collection management.
///
/// **OPT-IN CAPABILITY**
/// Implement this for storages with explicit table or collection structures.
///
/// Use cases:
/// - SQL databases with table DDL
/// - NoSQL databases with collection management
/// - Document stores with namespace management
abstract class TableManagementStorage implements Storage {
  // ============================================================================
  // TABLE/COLLECTION OPERATIONS
  // ============================================================================

  /// Creates a new table or collection.
  ///
  /// Parameters:
  /// - [name] - Name of the table/collection
  /// - [schema] - Optional schema definition
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if creation fails
  /// - [StorageConstraintException] if table already exists
  Future<void> createTable(String name, {TableSchema? schema});

  /// Drops (deletes) a table or collection.
  ///
  /// Permanently removes the table and ALL its data.
  ///
  /// Parameters:
  /// - [name] - Name of the table/collection
  /// - [ifExists] - If true, no error if table doesn't exist (default: false)
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if deletion fails
  /// - [StorageNotFoundException] if table doesn't exist and ifExists=false
  Future<void> dropTable(String name, {bool ifExists = false});

  /// Renames a table or collection.
  ///
  /// Parameters:
  /// - [oldName] - Current table name
  /// - [newName] - New table name
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if rename fails
  /// - [StorageNotFoundException] if table doesn't exist
  /// - [StorageConstraintException] if newName already exists
  Future<void> renameTable(String oldName, String newName);

  /// Truncates a table (removes all data, keeps structure).
  ///
  /// More efficient than deleting all entities individually.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if truncate fails
  /// - [StorageNotFoundException] if table doesn't exist
  Future<void> truncateTable(String name);

  /// Checks if a table or collection exists.
  ///
  /// Returns `true` if table exists, `false` otherwise.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  Future<bool> tableExists(String name);

  /// Lists all tables or collections in storage.
  ///
  /// Returns names of all tables/collections.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if listing fails
  Future<List<String>> listTables();

  /// Gets metadata about a table or collection.
  ///
  /// Returns [TableInfo] with details about the table.
  /// Returns `null` if table doesn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  Future<TableInfo?> getTableInfo(String name);

  // ============================================================================
  // SCHEMA OPERATIONS (Optional)
  // ============================================================================

  /// Alters the schema of a table.
  ///
  /// Modifies table structure (add/drop/rename columns, indexes, etc).
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if alteration fails
  /// - [StorageNotFoundException] if table doesn't exist
  /// - [StorageUnsupportedException] if schema modification not supported
  Future<void> alterTable(String name, TableSchemaChange change);

  /// Gets the schema of a table.
  ///
  /// Returns [TableSchema] describing table structure.
  /// Returns `null` if table doesn't exist or schema not available.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageUnsupportedException] if schema retrieval not supported
  Future<TableSchema?> getTableSchema(String name);

  // ============================================================================
  // INDEX MANAGEMENT (Optional)
  // ============================================================================

  /// Creates an index on a table.
  ///
  /// Improves query performance for indexed fields.
  ///
  /// Parameters:
  /// - [tableName] - Table to create index on
  /// - [indexName] - Name of the index
  /// - [fields] - Fields to include in index
  /// - [unique] - Whether index enforces uniqueness
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if index creation fails
  /// - [StorageNotFoundException] if table doesn't exist
  /// - [StorageConstraintException] if index already exists
  /// - [StorageUnsupportedException] if indexes not supported
  Future<void> createIndex(
    String tableName,
    String indexName,
    List<String> fields, {
    bool unique = false,
  });

  /// Drops an index.
  ///
  /// Removes the index, queries will no longer use it.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if drop fails
  /// - [StorageNotFoundException] if index doesn't exist
  /// - [StorageUnsupportedException] if indexes not supported
  Future<void> dropIndex(String tableName, String indexName);

  /// Lists all indexes on a table.
  ///
  /// Returns names of all indexes.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageNotFoundException] if table doesn't exist
  /// - [StorageUnsupportedException] if indexes not supported
  Future<List<String>> listIndexes(String tableName);
}

/// Schema definition for a table/collection.
class TableSchema {
  /// Table name.
  final String name;

  /// Field definitions.
  final List<FieldSchema> fields;

  /// Primary key field names.
  final List<String> primaryKeys;

  /// Index definitions.
  final List<IndexSchema> indexes;

  /// Foreign key constraints.
  final List<ForeignKeySchema> foreignKeys;

  /// Unique constraints.
  final List<UniqueConstraint> uniqueConstraints;

  /// Check constraints (validation rules).
  final List<CheckConstraint> checkConstraints;

  /// Default values for fields.
  final Map<String, dynamic> defaults;

  /// Table-level options.
  final Map<String, dynamic> options;

  const TableSchema({
    required this.name,
    required this.fields,
    this.primaryKeys = const [],
    this.indexes = const [],
    this.foreignKeys = const [],
    this.uniqueConstraints = const [],
    this.checkConstraints = const [],
    this.defaults = const {},
    this.options = const {},
  });

  @override
  String toString() => 'TableSchema($name, ${fields.length} fields)';
}

/// Schema definition for a field/column.
class FieldSchema {
  /// Field name.
  final String name;

  /// Field data type.
  final FieldType type;

  /// Whether field is required (NOT NULL).
  final bool required;

  /// Default value.
  final dynamic defaultValue;

  /// Maximum length (for strings).
  final int? maxLength;

  /// Minimum value (for numbers).
  final num? minValue;

  /// Maximum value (for numbers).
  final num? maxValue;

  /// Whether field is indexed.
  final bool indexed;

  /// Whether field is unique.
  final bool unique;

  /// Custom field options.
  final Map<String, dynamic> options;

  const FieldSchema({
    required this.name,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.maxLength,
    this.minValue,
    this.maxValue,
    this.indexed = false,
    this.unique = false,
    this.options = const {},
  });

  @override
  String toString() => '$name: $type${required ? ' NOT NULL' : ''}';
}

/// Field data types.
enum FieldType {
  string,
  integer,
  double,
  boolean,
  dateTime,
  date,
  time,
  blob,
  json,
  uuid,
  list,
  map,
}

/// Index schema.
class IndexSchema {
  /// Index name.
  final String name;

  /// Fields included in index.
  final List<String> fields;

  /// Whether index enforces uniqueness.
  final bool unique;

  /// Index type (btree, hash, etc).
  final String? type;

  const IndexSchema({
    required this.name,
    required this.fields,
    this.unique = false,
    this.type,
  });

  @override
  String toString() => 'Index($name on ${fields.join(', ')})';
}

/// Foreign key constraint.
class ForeignKeySchema {
  /// Foreign key name.
  final String name;

  /// Fields in this table.
  final List<String> fields;

  /// Referenced table.
  final String referencedTable;

  /// Referenced fields.
  final List<String> referencedFields;

  /// On delete action.
  final ForeignKeyAction onDelete;

  /// On update action.
  final ForeignKeyAction onUpdate;

  const ForeignKeySchema({
    required this.name,
    required this.fields,
    required this.referencedTable,
    required this.referencedFields,
    this.onDelete = ForeignKeyAction.noAction,
    this.onUpdate = ForeignKeyAction.noAction,
  });

  @override
  String toString() => 'FK($name: ${fields.join(',')} -> $referencedTable)';
}

/// Foreign key actions.
enum ForeignKeyAction {
  noAction,
  restrict,
  cascade,
  setNull,
  setDefault,
}

/// Unique constraint.
class UniqueConstraint {
  /// Constraint name.
  final String name;

  /// Fields that must be unique together.
  final List<String> fields;

  const UniqueConstraint({
    required this.name,
    required this.fields,
  });

  @override
  String toString() => 'UNIQUE($name: ${fields.join(', ')})';
}

/// Check constraint (validation rule).
class CheckConstraint {
  /// Constraint name.
  final String name;

  /// Check expression (backend-specific).
  final String expression;

  const CheckConstraint({
    required this.name,
    required this.expression,
  });

  @override
  String toString() => 'CHECK($name: $expression)';
}

/// Information about a table.
class TableInfo {
  /// Table name.
  final String name;

  /// Number of entities/rows.
  final int count;

  /// Total size in bytes.
  final int? sizeInBytes;

  /// When table was created.
  final DateTime? createdAt;

  /// When table was last modified.
  final DateTime? modifiedAt;

  /// Table schema (if available).
  final TableSchema? schema;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  const TableInfo({
    required this.name,
    required this.count,
    this.sizeInBytes,
    this.createdAt,
    this.modifiedAt,
    this.schema,
    this.metadata = const {},
  });

  @override
  String toString() => 'TableInfo($name, $count rows)';
}

/// Schema change operation.
abstract class TableSchemaChange {
  const TableSchemaChange();
}

/// Add a field to the table.
class AddFieldChange extends TableSchemaChange {
  final FieldSchema field;
  const AddFieldChange(this.field);
}

/// Drop a field from the table.
class DropFieldChange extends TableSchemaChange {
  final String fieldName;
  const DropFieldChange(this.fieldName);
}

/// Rename a field.
class RenameFieldChange extends TableSchemaChange {
  final String oldName;
  final String newName;
  const RenameFieldChange(this.oldName, this.newName);
}

/// Modify a field's type or constraints.
class ModifyFieldChange extends TableSchemaChange {
  final FieldSchema field;
  const ModifyFieldChange(this.field);
}
