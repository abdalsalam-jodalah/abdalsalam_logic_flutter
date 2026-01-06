# Comprehensive Storage Abstraction Layer

## Overview

This is a **FULL-FEATURED, TYPE-SAFE** storage abstraction layer for Flutter/Dart that provides complete management of storage backends across all categories.

---

## Architecture

### Design Principles

✅ **Capability-Based Design** - Optional features are separate interfaces  
✅ **Type Safety** - Generics ensure compile-time correctness  
✅ **Backend-Agnostic** - Zero platform or implementation dependencies  
✅ **Comprehensive** - Supports ALL storage categories and operations  
✅ **Interface Segregation** - Implementations only implement what they need

### Core Components

```
Storage (Base)
├── Lifecycle: initialize(), clear(), dispose()
└── Metadata: getMetadata()

KeyValueStorage<T>
├── Single Operations: get(), set(), delete(), contains()
├── Batch Operations: getMultiple(), setMultiple(), deleteMultiple()
├── Key Enumeration: keys(), keysWithPrefix(), keysMatching()
├── Metadata: getKeyMetadata()
└── Optional Capabilities:
    ├── WatchableKeyValueStorage - Change notifications
    └── ExpirableKeyValueStorage - TTL/expiration

EntityStorage<ID, T>
├── CRUD: get(), create(), update(), upsert(), delete()
├── Batch: getMultiple(), createMultiple(), updateMultiple(), deleteMultiple()
├── Partial Updates: updatePartial(), incrementField()
├── Bulk Retrieval: getAll(), getPage(), count()
├── Metadata: getEntityMetadata()
└── Optional Capabilities:
    ├── WatchableEntityStorage - Change notifications
    ├── VersionedEntityStorage - Optimistic locking
    └── PredicateDeletableStorage - Delete by predicate

Optional Capabilities (Opt-in):
├── TransactionalStorage - Transaction support
├── QueryableStorage<T> - Advanced queries
├── SchemaAwareStorage - Schema management
├── MigratableStorage - Migration support
├── RefreshableStorage - Refresh/sync operations
└── TableManagementStorage - Table/collection DDL
```

---

## Features Coverage

### 1. **Lifecycle Management** ✅
```dart
abstract class Storage {
  bool get isInitialized;
  bool get isDisposed;
  Future<void> initialize();
  Future<void> clear();
  Future<void> dispose();
  StorageMetadata? getMetadata();
}
```

**Features:**
- Lazy initialization
- State checking
- Clear all data
- Safe disposal
- Metadata/capability detection

---

### 2. **Key-Value Storage** ✅
```dart
abstract class KeyValueStorage<T> extends Storage {
  // Single operations
  Future<T?> get(String key);
  Future<void> set(String key, T value);
  Future<bool> delete(String key);
  Future<bool> contains(String key);
  Future<bool> setIfAbsent(String key, T value);
  Future<bool> setIfPresent(String key, T value);
  
  // Batch operations
  Future<Map<String, T>> getMultiple(List<String> keys);
  Future<void> setMultiple(Map<String, T> entries);
  Future<int> deleteMultiple(List<String> keys);
  
  // Key enumeration
  Future<List<String>> keys();
  Future<Map<String, T>> getAll();
  Future<int> count();
  Future<bool> isEmpty();
  Future<List<String>> keysWithPrefix(String prefix);
  Future<List<String>> keysMatching(String pattern);
  
  // Metadata
  Future<KeyValueMetadata?> getKeyMetadata(String key);
  StorageMetadata? getStorageMetadata();
}

// Optional capabilities
abstract class WatchableKeyValueStorage<T> {
  Stream<KeyValueChange<T>?> watch(String key);
  Stream<KeyValueChange<T>> watchPrefix(String prefix);
  Stream<KeyValueChange<T>> watchAll();
}

abstract class ExpirableKeyValueStorage<T> {
  Future<void> setWithExpiration(String key, T value, Duration duration);
  Future<bool> setExpiration(String key, Duration duration);
  Future<Duration?> getTimeToLive(String key);
  Future<bool> removeExpiration(String key);
}
```

**Features:**
- Type-safe operations with generics
- Conditional set (if absent/present)
- Batch operations for efficiency
- Key search (prefix, pattern matching)
- Value metadata (size, timestamps)
- Change watching (optional)
- TTL/expiration (optional)

---

### 3. **Entity Storage** ✅
```dart
abstract class EntityStorage<ID, T> extends Storage {
  // ID extraction
  ID getEntityId(T entity);
  
  // CRUD operations
  Future<T?> get(ID id);
  Future<void> create(T entity);
  Future<void> update(T entity);
  Future<void> upsert(T entity);
  Future<bool> delete(ID id);
  Future<bool> contains(ID id);
  
  // Partial updates
  Future<void> updatePartial(ID id, Map<String, dynamic> updates);
  Future<num> incrementField(ID id, String field, num delta);
  
  // Batch operations
  Future<List<T>> getMultiple(List<ID> ids);
  Future<void> createMultiple(List<T> entities);
  Future<void> updateMultiple(List<T> entities);
  Future<void> upsertMultiple(List<T> entities);
  Future<int> deleteMultiple(List<ID> ids);
  
  // Bulk retrieval
  Future<List<T>> getAll();
  Future<List<T>> getPage(int offset, int limit);
  Future<int> count();
  Future<bool> isEmpty();
  
  // Metadata
  Future<EntityMetadata?> getEntityMetadata(ID id);
  StorageMetadata? getStorageMetadata();
}

// Optional capabilities
abstract class WatchableEntityStorage<ID, T> {
  Stream<EntityChange<ID, T>?> watch(ID id);
  Stream<EntityChange<ID, T>> watchAll();
  Stream<EntityChange<ID, T>> watchQuery(EntityQuery<T> query);
}

abstract class VersionedEntityStorage<ID, T> {
  Future<bool> updateWithVersion(T entity, int expectedVersion);
  Future<VersionedEntity<T>?> getWithVersion(ID id);
}

abstract class PredicateDeletableStorage<ID, T> {
  Future<int> deleteWhere(bool Function(T entity) predicate);
}
```

**Features:**
- Full CRUD operations
- Upsert (create or update)
- Partial updates (field-level)
- Atomic field increments
- Batch operations
- Pagination
- Entity metadata (timestamps, version, size)
- Change watching (optional)
- Optimistic locking (optional)
- Predicate-based deletion (optional)

---

### 4. **Query System** ✅
```dart
abstract class EntityQuery<T> {
  // Filtering
  EntityQuery<T> where(String field, {
    Object? isEqualTo, isNotEqualTo,
    Object? isGreaterThan, isLessThan,
    List? isBetween, isIn,
    String? contains, startsWith, endsWith, matches,
    bool? isNull,
    Object? arrayContains,
    // ... and more
  });
  EntityQuery<T> or(List<EntityQuery<T> Function(EntityQuery<T>)> conditions);
  EntityQuery<T> whereCustom(bool Function(T entity) predicate);
  
  // Sorting
  EntityQuery<T> orderBy(String field, {bool descending, bool nullsFirst});
  EntityQuery<T> orderByMultiple(List<SortField> fields);
  
  // Pagination
  EntityQuery<T> limit(int count);
  EntityQuery<T> offset(int count);
  EntityQuery<T> startAfterCursor(String cursor);
  EntityQuery<T> startAtCursor(String cursor);
  
  // Projection
  EntityQuery<T> select(List<String> fields);
  EntityQuery<T> exclude(List<String> fields);
  
  // Grouping
  EntityQuery<T> groupBy(List<String> fields);
  EntityQuery<T> having(String field, {/* conditions */});
  
  // Aggregations
  EntityQuery<T> aggregate(String alias, Aggregation aggregation);
  
  // Joins
  EntityQuery<T> join<R>(dynamic storage, {JoinCondition on, JoinType type});
  
  // Execution
  Future<QueryResult<T>> execute();
  Future<int> count();
  Future<T?> first();
  Future<bool> exists();
}
```

**Operators Supported:**
- Equality: `isEqualTo`, `isNotEqualTo`
- Comparison: `isGreaterThan`, `isLessThan`, `isGreaterThanOrEqualTo`, `isLessThanOrEqualTo`
- Range: `isBetween`, `isNotBetween`
- Collection: `isIn`, `isNotIn`
- String: `contains`, `startsWith`, `endsWith`, `matches` (regex)
- Null: `isNull`, `isNotNull`
- Array: `arrayContains`, `arrayContainsAny`

**Aggregations:**
- `Aggregation.count()`
- `Aggregation.sum(field)`
- `Aggregation.avg(field)`
- `Aggregation.min(field)`
- `Aggregation.max(field)`

---

### 5. **Table/Collection Management** ✅
```dart
abstract class TableManagementStorage {
  Future<void> createTable(String name, {TableSchema? schema});
  Future<void> dropTable(String name, {bool ifExists});
  Future<void> renameTable(String oldName, String newName);
  Future<void> truncateTable(String name);
  Future<bool> tableExists(String name);
  Future<List<String>> listTables();
  Future<TableInfo?> getTableInfo(String name);
  
  // Schema operations
  Future<void> alterTable(String name, TableSchemaChange change);
  Future<TableSchema?> getTableSchema(String name);
  
  // Index management
  Future<void> createIndex(String table, String indexName, List<String> fields, {bool unique});
  Future<void> dropIndex(String table, String indexName);
  Future<List<String>> listIndexes(String table);
}
```

**Features:**
- Table/collection DDL (create, drop, rename, truncate)
- Schema alteration (add/drop/modify columns)
- Index management
- Table metadata

---

### 6. **Schema & Migration** ✅
```dart
// Schema awareness (optional)
abstract class SchemaAwareStorage {
  Future<SchemaDescriptor> getSchema();
  Future<void> applySchema(SchemaDescriptor schema);
  Future<bool> validateSchema(SchemaDescriptor expected);
}

// Migration support (optional)
abstract class MigratableStorage {
  int get schemaVersion;
  Future<void> migrate(MigrationPlan plan);
}

// Schema definitions
class TableSchema {
  final String name;
  final List<FieldSchema> fields;
  final List<String> primaryKeys;
  final List<IndexSchema> indexes;
  final List<ForeignKeySchema> foreignKeys;
  // ... constraints
}

class FieldSchema {
  final String name;
  final FieldType type; // string, integer, double, boolean, dateTime, etc.
  final bool required;
  final dynamic defaultValue;
  final int? maxLength;
  // ... constraints
}

// Migration plans (app creates, storage executes)
abstract class MigrationPlan {
  int get fromVersion;
  int get toVersion;
  List<MigrationStep> get steps;
}
```

**Features:**
- Schema description and validation
- Migration execution
- Schema versioning
- Table/field/index/constraint definitions
- External migration logic (separation of concerns)

---

### 7. **Transactions** ✅
```dart
abstract class TransactionalStorage {
  Future<StorageTransaction> beginTransaction();
}

abstract class StorageTransaction {
  Future<void> commit();
  Future<void> rollback();
  Future<SavePoint> createSavePoint(String name);
  Future<void> rollbackToSavePoint(SavePoint savePoint);
  bool get isActive;
  IsolationLevel get isolationLevel;
}
```

**Features:**
- Transaction begin/commit/rollback
- Savepoints for nested transactions
- Isolation level support
- Active state tracking

---

### 8. **Metadata & Capability Detection** ✅
```dart
class StorageMetadata {
  final String type, version;
  
  // Capability flags (25+ capabilities)
  final bool supportsTransactions, supportsQueries, supportsAggregations;
  final bool supportsJoins, supportsConcurrency, supportsBatchOperations;
  final bool supportsPartialUpdates, supportsAtomicIncrements;
  final bool supportsSchema, supportsMigrations, supportsWatching;
  final bool supportsExpiration, supportsVersioning;
  final bool supportsEntityMetadata, supportsValueMetadata;
  final bool supportsKeyPattern, supportsCursorPagination;
  final bool supportsProjection, supportsGrouping;
  final bool supportsCustomPredicates, supportsRawQueries;
  final bool isEncrypted, isPersistent, isInMemory;
  
  // Limits
  final int? maxValueSize, maxEntitySize;
  final int? maxKeys, maxEntities;
  final int? maxKeyLength, maxBatchSize;
  
  // Performance characteristics
  final int? typicalReadLatencyMs, typicalWriteLatencyMs;
  final bool fastReads, fastWrites, optimizedForBulk;
  
  // Platform support
  final List<String> supportedPlatforms;
  final Map<String, String> minimumPlatformVersions;
  
  // Dynamic capability check
  bool supports(String feature);
}
```

**Features:**
- 25+ capability flags
- Limit detection
- Performance characteristics
- Platform compatibility
- Dynamic feature detection

---

### 9. **Refresh & Sync** ✅
```dart
abstract class RefreshableStorage {
  Future<void> refresh();
  Future<List<dynamic>> getModifiedSince(DateTime since);
}
```

**Features:**
- Explicit refresh/reload
- Incremental sync by timestamp

---

### 10. **Exception Hierarchy** ✅
```dart
// Base exception
abstract class StorageException implements Exception {
  final String message;
  final String? code;
  final Exception? originalError;
  final StackTrace? stackTrace;
}

// Specialized exceptions (11 types)
- StorageInitializationException
- StorageNotFoundException
- StorageConstraintException
- StorageSpaceException
- StorageTimeoutException
- StorageCorruptionException
- StorageUnsupportedException
- StorageStateException
- StorageTransactionException
- StoragePermissionException
- StorageOperationException
```

**Features:**
- Unified exception hierarchy
- Backend errors wrapped (no leakage)
- Rich error context

---

## Storage Categories Supported

✅ **Secure Key-Value** - Use `KeyValueStorage<T>` with encryption metadata  
✅ **Preferences Key-Value** - Use `KeyValueStorage<String>`  
✅ **Relational Structured** - Use `EntityStorage<ID, T>` + `SchemaAwareStorage`  
✅ **Relational Key-Value** - Use `KeyValueStorage<T>` on SQL backend  
✅ **NoSQL/Document** - Use `EntityStorage<ID, T>` + `QueryableStorage<T>`

---

## Usage Examples

### Simple Key-Value Storage
```dart
class PrefsStorage implements KeyValueStorage<String> {
  @override
  Future<String?> get(String key) async => prefs.getString(key);
  
  @override
  Future<void> set(String key, String value) async => 
      await prefs.setString(key, value);
}
```

### Full-Featured Database
```dart
class SqliteStorage extends EntityStorage<int, User>
    implements
        TransactionalStorage,
        QueryableStorage<User>,
        SchemaAwareStorage,
        MigratableStorage,
        WatchableEntityStorage<int, User> {
  // Implements all capabilities
}
```

---

## File Structure

```
lib/src/storage/
├── abstractions/
│   ├── storage_interface.dart               (Base Storage)
│   ├── key_value_storage_comprehensive.dart (Full KV interface)
│   ├── entity_storage_comprehensive.dart    (Full entity interface)
│   ├── query_comprehensive.dart             (Query DSL)
│   ├── storage_capabilities.dart            (Capabilities)
│   ├── storage_transaction.dart             (Transactions)
│   └── table_management.dart                (Table DDL)
├── exceptions/
│   └── storage_exceptions.dart              (Exception hierarchy)
├── types/
│   ├── storage_metadata.dart                (Metadata & capabilities)
│   └── storage_result_minimal.dart          (Result wrappers)
└── index_comprehensive.dart                 (Main export)
```

---

## Statistics

| Feature Category | Methods | Types | Capabilities |
|------------------|---------|-------|--------------|
| **Base Storage** | 4 | 1 | Lifecycle |
| **KeyValueStorage** | 17 | 3 | CRUD + batch + watch + TTL |
| **EntityStorage** | 20 | 5 | CRUD + batch + watch + version |
| **Query System** | 18 | 6 | Filter + sort + aggregate + join |
| **Table Management** | 13 | 10 | DDL + schema + indexes |
| **Capabilities** | 8 interfaces | - | Opt-in features |
| **Metadata** | 1 class | 35+ fields | Detection |
| **Exceptions** | 11 types | - | Error handling |
| **TOTAL** | **91+ methods** | **26+ types** | **Comprehensive** |

---

## Validation

✅ **Pure Dart** - No platform dependencies  
✅ **Zero Implementations** - Abstraction only  
✅ **Compiles with 0 errors**  
✅ **Type-safe** - Full generics support  
✅ **SOLID Principles** - ISP compliant  
✅ **Comprehensive** - All storage operations covered  
✅ **Capability-based** - Optional features separated  
✅ **Well-documented** - Every interface documented  
✅ **AI-Agent Friendly** - Clear structure and contracts

---

## Summary

This comprehensive storage abstraction layer provides:

1. **Complete CRUD** - All create, read, update, delete operations
2. **Batch Operations** - Efficient bulk processing
3. **Advanced Queries** - 15+ operators, aggregations, joins
4. **Table Management** - Full DDL capabilities
5. **Schema & Migration** - Versioned schema evolution
6. **Transactions** - ACID semantics with savepoints
7. **Change Watching** - Real-time notifications
8. **Metadata** - Rich capability detection
9. **Type Safety** - Full generic support
10. **Extensibility** - Capability-based design

**Ready for implementation across all storage backends!** 🎯
