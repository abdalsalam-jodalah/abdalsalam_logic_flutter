# Storage Abstraction Layer - Architecture & Design

**Status**: Pure Dart Abstraction - No Implementations  
**Date**: January 6, 2026

## Overview

This document describes the robust, extensible storage abstraction layer for `abdalsalam_logic_flutter`. It provides unified, type-safe interfaces for multiple storage backends without implementation details or platform dependencies.

### Goals

1. **Unified API** - Consistent interface across all storage types
2. **Type Safety** - Generics-based, compile-time type safety
3. **Extensibility** - Easy to add new storage backends without modification
4. **Composability** - Mix and match different storage types in one app
5. **Pure Dart** - No Flutter/platform dependencies in abstractions
6. **AI-Ready** - Suitable for AI-agent automation and code generation

---

## Architecture Overview

### Folder Structure

```
lib/src/storage/
├── abstractions/              # Pure Dart interfaces
│   ├── storage_interface.dart     # Base Storage contract
│   ├── storage_transaction.dart   # Transaction abstraction
│   ├── key_value_storage.dart     # KeyValue<T> interface
│   ├── entity_storage.dart        # Entity<ID, T> interface
│   ├── query.dart                 # Query DSL and abstractions
│   └── index.dart                 # Export index
│
├── exceptions/                # Package-level exceptions
│   ├── storage_exceptions.dart    # 10 exception types
│   └── index.dart
│
├── types/                     # Helper types and results
│   ├── storage_result.dart        # StorageResult<T> sealed type
│   └── index.dart
│
└── index.dart                 # Main export
```

---

## Core Abstractions

### 1. **Storage Interface** (Base Contract)

**Location**: `storage_interface.dart`

Minimal base contract that all storage implementations must fulfill.

```dart
abstract class Storage {
  bool get isInitialized;
  bool get isDisposed;
  
  Future<void> initialize();
  Future<void> clear();
  Future<void> dispose();
  
  Future<StorageTransaction> transaction();
  StorageMetadata? getMetadata();
  bool isHealthy();
}
```

**Responsibilities**:
- Lifecycle management (init, clear, dispose)
- Health checking
- Transaction support
- Metadata exposure

**Key Principles**:
- Idempotent operations (safe to call multiple times)
- State tracking (`isInitialized`, `isDisposed`)
- Exception wrapping (all errors → `StorageException` subclasses)
- Metadata for feature detection

---

### 2. **KeyValueStorage<T>** (Typed Key-Value)

**Location**: `key_value_storage.dart`

Generic key-value storage with type safety.

```dart
abstract class KeyValueStorage<T> extends Storage {
  Future<T?> get(String key);
  Future<Map<String, T>> getMultiple(List<String> keys);
  Future<void> set(String key, T value);
  Future<void> setMultiple(Map<String, T> entries);
  Future<bool> delete(String key);
  Future<int> deleteMultiple(List<String> keys);
  
  Future<List<String>> getAllKeys();
  Future<int> count();
  Future<bool> contains(String key);
  
  Future<int> deleteWhere(bool Function(T value) predicate);
  Future<KeyValueEntry<T>?> getWithMetadata(String key);
}
```

**Use Cases**:
- User preferences
- Application settings
- Session data
- Secure token storage
- Cache entries

**Features**:
- Single-type values (generic T)
- Atomic operations
- Batch operations for efficiency
- Metadata retrieval
- Predicate-based deletion

**Type Variants**:
- `KeyValueStorage<String>` - Text storage
- `KeyValueStorage<int>` - Numeric storage
- `KeyValueStorage<List<String>>` - Collections
- `KeyValueStorage<dynamic>` - Mixed-type (if backend allows)

---

### 3. **EntityStorage<ID, T>** (Structured Entities)

**Location**: `entity_storage.dart`

Type-safe entity storage with full CRUD + querying.

```dart
abstract class EntityStorage<ID, T> extends Storage {
  ID getEntityId(T entity);
  
  // CRUD
  Future<T?> get(ID id);
  Future<List<T>> getMultiple(List<ID> ids);
  Future<void> create(T entity);
  Future<void> createMultiple(List<T> entities);
  Future<void> update(T entity);
  Future<void> updateMultiple(List<T> entities);
  Future<void> updateFields(ID id, Map<String, dynamic> updates);
  Future<void> createOrUpdate(T entity);
  Future<bool> delete(ID id);
  Future<int> deleteMultiple(List<ID> ids);
  
  // Query
  Future<EntityQuery<T>> query();
  Future<List<T>> queryRaw(String rawQuery, {Map<String, dynamic>? params});
  
  // Sync
  Future<List<T>> getModifiedSince(DateTime since);
  
  // Schema
  Future<bool> validateSchema();
  Future<int> getSchemaVersion();
  
  // Utilities
  Future<int> count();
  Future<bool> contains(ID id);
}
```

**Use Cases**:
- Relational data (users, posts, comments)
- Sync with backend
- Complex queries
- Schema evolution
- Offline-first apps

**Features**:
- CRUD operations
- Batch operations
- Partial updates
- Upsert (create-or-update)
- Advanced querying (filters, sorts, pagination)
- Sync support (modified-since tracking)
- Schema versioning
- Predicate-based deletion

**Generic Type Safety**:
```dart
// User entity with String ID
class EntityStorage<String, User> { }

// Post entity with int ID  
class EntityStorage<int, Post> { }

// Custom ID type
class EntityStorage<UUID, Product> { }
```

---

### 4. **StorageTransaction** (Atomicity)

**Location**: `storage_transaction.dart`

Abstraction for transactional operations.

```dart
abstract class StorageTransaction {
  bool get isActive;
  bool get isCommitted;
  bool get isRolledBack;
  IsolationLevel get isolationLevel;
  
  Future<void> commit();
  Future<void> rollback();
  Future<T> execute<T>(
    Future<T> Function(StorageTransaction tx) operation
  );
  
  Future<SavePoint> savepoint(String name);
  Future<void> rollbackToSavepoint(SavePoint savepoint);
}

enum IsolationLevel {
  dirty,        // Lowest safety, best perf
  committed,    // Good balance
  repeatable,   // Better safety
  serializable, // Highest safety, worst perf
}
```

**Features**:
- Atomic operations (all-or-nothing)
- Multiple isolation levels
- Savepoints (nested rollback)
- Context-aware execution
- Safe failure handling

**Usage Pattern**:
```dart
final tx = await storage.transaction();
try {
  await tx.execute((tx) async {
    // All operations here are atomic
    await keyValueStorage.set('key', 'value');
    await entityStorage.create(entity);
  });
  await tx.commit();  // Persist all changes
} catch (e) {
  await tx.rollback();  // Discard all changes
  rethrow;
}
```

---

### 5. **EntityQuery<T>** (Advanced Querying)

**Location**: `query.dart`

DSL for building complex queries.

```dart
abstract class EntityQuery<T> {
  EntityQuery<T> where(QueryFilter filter);
  EntityQuery<T> orWhere(List<QueryFilter> conditions);
  EntityQuery<T> orderBy(QuerySort sort);
  EntityQuery<T> paginate(QueryPagination pagination);
  EntityQuery<T> limit(int limit);
  EntityQuery<T> skip(int count);
  EntityQuery<T> select(List<String> fields);
  
  Future<QueryResult<T>> execute();
  Future<T?> first();
  Future<int> count();
  Future<bool> exists();
  
  bool supportsFeature(String feature);
  String toQueryString();
}

// Supporting types
class QueryFilter { }           // Conditions
class QuerySort { }              // Ordering
class QueryPagination { }        // Pagination
class QueryResult<T> { }         // Results
enum FilterOperator { }          // Comparison operators
enum SortDirection { }           // ASC/DESC
```

**Fluent API Example**:
```dart
final results = await storage
    .query()
    .where(QueryFilter.equals('status', 'active'))
    .where(QueryFilter.greaterThan('age', 18))
    .orWhere([
      QueryFilter.equals('role', 'admin'),
      QueryFilter.equals('role', 'moderator'),
    ])
    .orderBy(QuerySort.descending('createdAt'))
    .paginate(QueryPagination.page(pageNumber: 1, pageSize: 20))
    .execute();
```

**Supported Operations**:
- Equality, inequality
- Comparisons (>, <, >=, <=)
- Text search (contains, startsWith, endsWith)
- Range queries
- Set operations (in, notIn)
- Null checks
- Multi-field sorting
- Pagination (offset/limit)
- Field projection (select subset)

---

## Exception Hierarchy

**Location**: `exceptions/storage_exceptions.dart`

All storage errors are wrapped as `StorageException` subclasses. Backend errors never leak.

```
StorageException (base)
├── StorageInitializationException    // Init failed
├── StorageNotFoundException          // Item not found
├── StorageConstraintException        // Constraint violated
├── StorageSpaceException             // Disk full
├── StorageTimeoutException           // Operation timeout
├── StorageCorruptionException        // Data corruption
├── StorageUnsupportedException       // Feature not supported
├── StorageStateException             // Invalid state
├── StorageTransactionException       // Transaction failed
├── StoragePermissionException        // Access denied
└── StorageOperationException         // Generic operation error
```

**Benefits**:
- Uniform error handling
- No backend-specific exceptions leak
- Rich context (original error, code, stack trace)
- Consumer-friendly messages
- Easy to extend

---

## Helper Types

**Location**: `types/storage_result.dart`

### StorageResult<T> (Sealed Type)

Functional error handling without exceptions.

```dart
sealed class StorageResult<T> {
  StorageSuccess<T>
  StorageFailure<T>
}

// Usage
final result = await storage.get('key');
result.when(
  success: (data) => print('Got: $data'),
  failure: (error) => print('Error: $error'),
);
```

### StorageOperationOptions

Configurable operation behavior:
- Timeout
- Validation skip
- Change notifications
- Custom metadata

### BatchOptions

Batch operation configuration:
- Batch size
- Continue on error
- Transaction grouping

### StorageChangeNotification<T>

Change tracking for sync:
- Change type (created/updated/deleted/cleared)
- Affected entity ID
- Timestamp
- Metadata

### StorageStatistics

Storage introspection:
- Entry count
- Total size
- Table count
- Last optimization time

### StorageMetrics

Performance monitoring:
- Operation name
- Execution time
- Items affected
- Throughput calculation

---

## Design Principles

### 1. **Separation of Concerns**

- **Storage**: Lifecycle and state
- **KeyValueStorage**: Simple key-value operations
- **EntityStorage**: Complex entity operations
- **EntityQuery**: Advanced querying
- **StorageTransaction**: Atomicity

Each concern is isolated in a separate interface.

### 2. **Golden Rule: If Not Used, Don't Include**

- Query support is optional (check `supportsFeature`)
- Transactions are optional
- Savepoints are optional
- Metadata is optional
- Partial updates are optional

Implementations can selectively support features.

### 3. **SOLID Principles**

**Single Responsibility**: Each interface has one job  
**Open/Closed**: Extensible without modification  
**Liskov Substitution**: Implementations are interchangeable  
**Interface Segregation**: Focused interfaces  
**Dependency Inversion**: Depend on abstractions

### 4. **Composability**

Mix multiple storage types:
```dart
final keyValue = KeyValueStorage<String>();  // Settings
final entities = EntityStorage<int, User>();  // Users
final cache = KeyValueStorage<dynamic>();     // Cache

// All implement Storage
// Can be used together
// Can share transactions
```

### 5. **Type Safety**

- Generic types for all operations
- Compile-time type checking
- No unchecked casts
- Type coercion only where intentional

### 6. **Error Handling**

- All errors wrapped as `StorageException`
- Rich error context
- No silent failures
- Clear error messages

### 7. **Idempotence**

- `initialize()` safe to call multiple times
- `dispose()` safe to call multiple times
- `clear()` safe if already clear
- State is consistent

### 8. **Lifecycle Management**

```
[Uninitialized] → initialize() → [Initialized]
                                      ↓
                                 [In Use]
                                      ↓
                   dispose() → [Disposed]
```

Clear state transitions, no ambiguous states.

---

## Implementation Patterns

### Creating a Custom Storage

Implementations extend the base abstractions:

```dart
// Option 1: Simple key-value
class MyKeyValueStorage<T> extends KeyValueStorage<T> {
  @override
  Future<void> initialize() async { /* ... */ }
  
  @override
  Future<T?> get(String key) async { /* ... */ }
  
  // ... implement other methods
}

// Option 2: Full-featured entity storage
class MyEntityStorage<ID, T> extends EntityStorage<ID, T> {
  @override
  ID getEntityId(T entity) => /* extract ID */;
  
  @override
  Future<T?> get(ID id) async { /* ... */ }
  
  @override
  Future<EntityQuery<T>> query() async {
    return MyEntityQuery<T>();
  }
  
  // ... implement other methods
}
```

### Feature Detection

Check capabilities before use:

```dart
final storage = await createStorage();
final metadata = storage.getMetadata();

if (metadata?.supportsTransactions ?? false) {
  final tx = await storage.transaction();
  // Use transactions
} else {
  // Work without transactions
}

if (metadata?.supportsQueries ?? false) {
  final results = await entityStorage.query().execute();
} else {
  // Fetch all and filter in-memory
}
```

---

## Storage Categories Covered

| Category | Interface | Use Case |
|----------|-----------|----------|
| **Secure Key-Value** | `KeyValueStorage<T>` | Tokens, secrets, secure data |
| **Preferences Key-Value** | `KeyValueStorage<T>` | App settings, preferences |
| **SQLite Structured** | `EntityStorage<ID, T>` | Relational data, complex queries |
| **SQLite Key-Value** | `KeyValueStorage<T>` | Hybrid approach with SQLite |
| **NoSQL/Object Storage** | `EntityStorage<ID, T>` | Hive, Isar, ObjectBox style |

All covered through two main interfaces + optional transaction/query support.

---

## Future Extensions (Without Breaking Changes)

Extensibility points:
- New `QueryFilter` operators
- New `IsolationLevel` values
- New exception types
- New `StorageMetadata` fields
- New operation options
- New change notification types

All extensible through sealed types and factory constructors.

---

## Comparison with Other Approaches

### vs. Platform-Specific Abstraction
- ✅ Pure Dart - No framework dependencies
- ✅ Testable without mocks
- ✅ Can be used in backend/CLI Dart

### vs. Single-Backend Solution
- ✅ Support multiple storage types
- ✅ Easy to swap implementations
- ✅ No vendor lock-in

### vs. Generic Repository Pattern
- ✅ More specific interfaces
- ✅ Type-safe queries
- ✅ Built-in transaction support
- ✅ Feature detection

---

## Summary

This abstraction layer provides:

1. **Unified API** for all storage types
2. **Type Safety** via generics
3. **Extensibility** without modification
4. **No Dependencies** on platforms/frameworks
5. **Rich Features** (transactions, queries, batching)
6. **Clean Errors** via exception hierarchy
7. **AI-Ready** for code generation and automation
8. **Future-Proof** design for extensions

Implementations can now safely implement storage backends against these interfaces without fear of breaking changes or API modifications.

---

**Status**: ✅ Abstraction Complete - Ready for Implementation
