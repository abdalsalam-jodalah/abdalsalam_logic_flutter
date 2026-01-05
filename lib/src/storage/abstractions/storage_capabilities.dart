// lib/src/storage/abstractions/storage_capabilities.dart

import 'storage_interface.dart';
import 'storage_transaction.dart';
import 'query_simplified.dart';
import '../exceptions/storage_exceptions.dart';

/// Capability interface for storages that support transactions.
///
/// **OPT-IN CAPABILITY**
/// Only implement this if your storage backend truly supports
/// atomic transactions with commit/rollback semantics.
///
/// Example:
/// ```dart
/// class SqliteStorage extends Storage implements TransactionalStorage {
///   @override
///   Future<StorageTransaction> beginTransaction() async {
///     // Start a database transaction
///     return SqliteTransaction(...);
///   }
/// }
/// ```
abstract class TransactionalStorage implements Storage {
  /// Begins a new transaction.
  ///
  /// Transactions allow grouping multiple operations as a single atomic unit.
  /// If any operation fails, all changes are rolled back.
  ///
  /// Returns a [StorageTransaction] that supports:
  /// - Committing all changes
  /// - Rolling back all changes
  /// - Savepoints for nested transactions
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageTransactionException] if transaction creation fails
  Future<StorageTransaction> beginTransaction();
}

/// Capability interface for storages that support advanced queries.
///
/// **OPT-IN CAPABILITY**
/// Implement this if your storage supports filtering, sorting, and pagination.
///
/// Generic type [T] represents the data type being queried.
///
/// Example:
/// ```dart
/// class DocumentStorage<T> extends Storage implements QueryableStorage<T> {
///   @override
///   Future<StorageQuery<T>> query() async {
///     return DocumentQuery<T>(...);
///   }
/// }
/// ```
abstract class QueryableStorage<T> implements Storage {
  /// Creates a query builder for filtering and sorting data.
  ///
  /// Returns a [StorageQuery<T>] that supports:
  /// - Filtering with conditions
  /// - Sorting by fields
  /// - Pagination (limit/offset)
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  ///
  /// Example:
  /// ```dart
  /// final results = await storage
  ///     .query()
  ///     .where('status', isEqualTo: 'active')
  ///     .orderBy('createdAt', descending: true)
  ///     .limit(10)
  ///     .execute();
  /// ```
  Future<StorageQuery<T>> query();
}

/// Capability interface for storages that are schema-aware.
///
/// **OPT-IN CAPABILITY**
/// Implement this if your storage has a structured schema (e.g., SQL tables).
///
/// Example:
/// ```dart
/// class SqlStorage extends Storage implements SchemaAwareStorage {
///   @override
///   Future<SchemaDescriptor> getSchema() async {
///     // Return current schema
///   }
///
///   @override
///   Future<void> applySchema(SchemaDescriptor schema) async {
///     // Apply schema changes
///   }
/// }
/// ```
abstract class SchemaAwareStorage implements Storage {
  /// Gets the current storage schema.
  ///
  /// Returns a [SchemaDescriptor] describing:
  /// - Tables/collections and their structures
  /// - Indexes
  /// - Constraints
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if schema cannot be read
  Future<SchemaDescriptor> getSchema();

  /// Applies a schema to the storage.
  ///
  /// This method ONLY APPLIES the schema, it does NOT decide what to apply.
  /// Schema changes are determined externally through [MigrationPlan].
  ///
  /// The application is responsible for:
  /// - Comparing current schema with target schema
  /// - Creating a [MigrationPlan]
  /// - Executing the plan through this method
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if schema application fails
  /// - [StorageCorruptionException] if schema is incompatible
  Future<void> applySchema(SchemaDescriptor schema);

  /// Validates the current schema against expected structure.
  ///
  /// Returns `true` if schema is valid and compatible.
  /// Returns `false` if schema is missing, corrupt, or incompatible.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  Future<bool> validateSchema(SchemaDescriptor expected);
}

/// Capability interface for storages that support migrations.
///
/// **OPT-IN CAPABILITY**
/// Implement this if your storage needs versioned schema migrations.
///
/// **IMPORTANT:** Storage does NOT decide migration logic.
/// The application creates a [MigrationPlan], and storage executes it.
///
/// Example:
/// ```dart
/// class DatabaseStorage extends Storage implements MigratableStorage {
///   @override
///   int get schemaVersion => _currentVersion;
///
///   @override
///   Future<void> migrate(MigrationPlan plan) async {
///     // Execute migration steps
///   }
/// }
/// ```
abstract class MigratableStorage implements Storage {
  /// Gets the current schema version.
  ///
  /// Returns an integer representing the schema version.
  /// Version 0 typically means no schema or unversioned storage.
  int get schemaVersion;

  /// Executes a migration plan.
  ///
  /// The [MigrationPlan] is created by the application and contains
  /// all migration steps to move from current version to target version.
  ///
  /// Storage responsibility: EXECUTE the plan
  /// Application responsibility: CREATE the plan
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if migration fails
  /// - [StorageCorruptionException] if migration corrupts data
  ///
  /// Must be atomic - either all steps succeed or all are rolled back.
  Future<void> migrate(MigrationPlan plan);
}

/// Capability interface for storages that support explicit refresh/sync.
///
/// **OPT-IN CAPABILITY**
/// Implement this if your storage caches data or needs explicit sync.
///
/// Example:
/// ```dart
/// class CachedStorage extends Storage implements RefreshableStorage {
///   @override
///   Future<void> refresh() async {
///     // Reload data from disk/network
///   }
/// }
/// ```
abstract class RefreshableStorage implements Storage {
  /// Refreshes storage state from the underlying source.
  ///
  /// Use cases:
  /// - Reload data from disk after external changes
  /// - Invalidate caches
  /// - Resync with network or other sources
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if refresh fails
  Future<void> refresh();

  /// Gets entities modified after a certain date.
  ///
  /// Useful for incremental sync operations.
  /// Returns all data where lastModified > [since].
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageUnsupportedException] if timestamp tracking is not available
  Future<List<dynamic>> getModifiedSince(DateTime since);
}

/// Schema descriptor - describes storage structure.
///
/// **EXTERNAL TO STORAGE**
/// The application defines schemas, storage applies them.
///
/// Represents:
/// - Tables/Collections and their fields
/// - Indexes
/// - Constraints
/// - Version
abstract class SchemaDescriptor {
  /// Schema version number.
  int get version;

  /// Schema name or identifier.
  String get name;

  /// List of table/collection definitions.
  List<TableDescriptor> get tables;

  /// Validates this schema.
  ///
  /// Returns `true` if schema is valid and consistent.
  bool validate();
}

/// Describes a single table/collection in a schema.
class TableDescriptor {
  /// Table/collection name.
  final String name;

  /// List of fields/columns.
  final List<FieldDescriptor> fields;

  /// Primary key field names.
  final List<String> primaryKeys;

  /// Index definitions.
  final List<IndexDescriptor> indexes;

  const TableDescriptor({
    required this.name,
    required this.fields,
    this.primaryKeys = const [],
    this.indexes = const [],
  });
}

/// Describes a field/column in a table.
class FieldDescriptor {
  /// Field name.
  final String name;

  /// Field data type (e.g., 'string', 'int', 'bool', 'datetime').
  final String type;

  /// Whether field is required (NOT NULL).
  final bool required;

  /// Default value for field.
  final dynamic defaultValue;

  const FieldDescriptor({
    required this.name,
    required this.type,
    this.required = false,
    this.defaultValue,
  });
}

/// Describes an index on a table.
class IndexDescriptor {
  /// Index name.
  final String name;

  /// Fields included in the index.
  final List<String> fields;

  /// Whether index enforces uniqueness.
  final bool unique;

  const IndexDescriptor({
    required this.name,
    required this.fields,
    this.unique = false,
  });
}

/// Migration plan - describes how to migrate from one schema version to another.
///
/// **CREATED BY APPLICATION, EXECUTED BY STORAGE**
///
/// The application logic:
/// 1. Checks current schema version
/// 2. Compares with target schema version
/// 3. Creates a MigrationPlan with necessary steps
/// 4. Passes plan to [MigratableStorage.migrate()]
///
/// Storage responsibility: Execute the plan atomically.
abstract class MigrationPlan {
  /// Current schema version (starting point).
  int get fromVersion;

  /// Target schema version (ending point).
  int get toVersion;

  /// List of migration steps to execute in order.
  List<MigrationStep> get steps;

  /// Validates the migration plan.
  ///
  /// Returns `true` if plan is valid and safe to execute.
  bool validate();
}

/// A single step in a migration plan.
abstract class MigrationStep {
  /// Description of what this step does.
  String get description;

  /// Whether this step can be rolled back if migration fails.
  bool get canRollback;

  /// Executes this migration step.
  ///
  /// Returns `true` if successful.
  /// Throws [StorageOperationException] if step fails.
  Future<bool> execute();

  /// Rolls back this migration step (if supported).
  ///
  /// Only called if [canRollback] is `true` and a subsequent step fails.
  Future<void> rollback();
}
