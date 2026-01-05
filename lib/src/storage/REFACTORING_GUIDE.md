# Storage Abstraction Refactoring Guide

## Overview

This document explains the refactoring of the storage abstraction layer from a **FAT** to a **THIN** design following the **Interface Segregation Principle (ISP)**.

---

## What Changed and Why

### 1. **Base Storage Interface - THINNED**

**Before:**
```dart
abstract class Storage {
  Future<void> initialize();
  Future<void> clear();
  Future<void> dispose();
  Future<StorageTransaction> transaction();  // ❌ FORCED on all implementations
  StorageMetadata? getMetadata();             // ❌ FORCED on all implementations
  bool isHealthy();                           // ❌ FORCED on all implementations
}
```

**After:**
```dart
abstract class Storage {
  bool get isInitialized;
  bool get isDisposed;
  Future<void> initialize();
  Future<void> clear();
  Future<void> dispose();
}
```

**Rationale:**
- Base Storage now has **ONLY lifecycle management**
- Removed forced features (transactions, metadata, health checks)
- Implementations are not burdened with features they don't need
- Follows ISP: "No client should be forced to depend on methods it does not use"

---

### 2. **Capability-Based Interfaces - INTRODUCED**

**New Pattern:**
```dart
// Optional capabilities that implementations can opt-in to

abstract class TransactionalStorage implements Storage {
  Future<StorageTransaction> beginTransaction();
}

abstract class QueryableStorage<T> implements Storage {
  Future<StorageQuery<T>> query();
}

abstract class SchemaAwareStorage implements Storage {
  Future<SchemaDescriptor> getSchema();
  Future<void> applySchema(SchemaDescriptor schema);
  Future<bool> validateSchema(SchemaDescriptor expected);
}

abstract class MigratableStorage implements Storage {
  int get schemaVersion;
  Future<void> migrate(MigrationPlan plan);
}

abstract class RefreshableStorage implements Storage {
  Future<void> refresh();
  Future<List<dynamic>> getModifiedSince(DateTime since);
}
```

**Rationale:**
- Features are **opt-in**, not **forced**
- Simple key-value storage doesn't need transactions
- In-memory storage doesn't need schema management
- Each capability is a separate, composable interface
- Implementations mix capabilities as needed

**Example Usage:**
```dart
// Simple storage - no optional features
class InMemoryStorage implements Storage { ... }

// Transactional SQL storage
class SqliteStorage implements Storage, TransactionalStorage, SchemaAwareStorage { ... }

// Queryable document store
class DocumentStorage<T> implements Storage, QueryableStorage<T>, RefreshableStorage { ... }
```

---

### 3. **Schema & Migration - EXTERNALIZED**

**Before (WRONG):**
- Storage decided what migrations to run
- Migration logic was embedded in storage
- Storage performed automatic migrations during `initialize()`

**After (CORRECT):**
```dart
// Schema is DESCRIBED by the application
abstract class SchemaDescriptor {
  int get version;
  String get name;
  List<TableDescriptor> get tables;
}

// Migration is PLANNED by the application
abstract class MigrationPlan {
  int get fromVersion;
  int get toVersion;
  List<MigrationStep> get steps;
}

// Storage ONLY APPLIES what the app decides
abstract class MigratableStorage {
  int get schemaVersion;
  Future<void> migrate(MigrationPlan plan);  // Execute app's plan
}
```

**Rationale:**
- **Separation of concerns**: App decides, storage executes
- Storage is a **mechanism**, not a **policy**
- Migration logic is testable outside storage implementation
- App has full control over migration strategy

**Example Flow:**
```dart
// 1. App checks version
final storage = SqliteStorage();
await storage.initialize();

// 2. App creates migration plan
if (storage.schemaVersion < 3) {
  final plan = MigrationPlanBuilder()
    .from(storage.schemaVersion)
    .to(3)
    .addStep(CreateTableStep('users'))
    .addStep(AddColumnStep('users', 'email'))
    .build();

  // 3. App executes migration
  await storage.migrate(plan);
}
```

---

### 4. **Query DSL - SIMPLIFIED**

**Before:**
- Complex fluent DSL with 15+ filter operators
- SQL-like richness (projections, aggregations, joins)
- Backend-specific features leaked into abstraction

**After:**
```dart
abstract class StorageQuery<T> {
  StorageQuery<T> where(String field, {
    Object? isEqualTo,
    Object? isGreaterThan,
    Object? isLessThan,
    String? contains,
  });
  
  StorageQuery<T> orderBy(String field, {bool descending = false});
  StorageQuery<T> limit(int count);
  StorageQuery<T> offset(int count);
  
  Future<List<T>> execute();
  Future<int> count();
}
```

**Rationale:**
- Reduced to **essential backend-agnostic operations**
- Removed SQL-specific concepts (joins, aggregations, subqueries)
- Simple named parameters instead of builder classes
- Still supports common use cases (filter, sort, paginate)

**What was removed:**
- ❌ Complex filter operators (regex, GeoPoint, array operations)
- ❌ Field projections (select specific columns)
- ❌ Aggregations (SUM, AVG, GROUP BY)
- ❌ Joins and relationships
- ❌ Sub-queries

**What remains:**
- ✅ Basic comparisons (equals, greater than, less than)
- ✅ String contains
- ✅ Single-field sorting
- ✅ Limit/offset pagination

---

### 5. **KeyValueStorage - MINIMIZED**

**Before:**
```dart
abstract class KeyValueStorage<T> extends Storage {
  Future<T?> get(String key);
  Future<Map<String, T>> getMultiple(List<String> keys);  // Batch ops in base
  Future<Map<String, T>> getAll();
  Future<void> set(String key, T value);
  Future<void> setMultiple(Map<String, T> entries);       // Batch ops in base
  Future<bool> delete(String key);
  Future<int> deleteMultiple(List<String> keys);          // Batch ops in base
  Future<bool> contains(String key);
  Future<List<String>> keys();
  // ... more methods
}
```

**After:**
```dart
// CORE interface - minimal
abstract class KeyValueStorage<T> extends Storage {
  Future<T?> get(String key);
  Future<void> set(String key, T value);
  Future<bool> delete(String key);
  Future<bool> contains(String key);
  Future<List<String>> keys();
}

// OPTIONAL batch capability
abstract class BatchKeyValueStorage<T> implements KeyValueStorage<T> {
  Future<Map<String, T>> getMultiple(List<String> keys);
  Future<void> setMultiple(Map<String, T> entries);
  Future<int> deleteMultiple(List<String> keys);
}
```

**Rationale:**
- Base interface has **only single-key operations**
- Batch operations are **opt-in** via `BatchKeyValueStorage`
- Simple implementations don't need to support batching
- More efficient implementations can opt-in to batching

---

### 6. **EntityStorage - MINIMIZED**

**Before:**
```dart
abstract class EntityStorage<ID, T> extends Storage {
  Future<T?> get(ID id);
  Future<List<T>> getMultiple(List<ID> ids);             // Batch in base
  Future<List<T>> getAll();
  Future<void> create(T entity);
  Future<void> createMultiple(List<T> entities);         // Batch in base
  Future<void> update(T entity);
  Future<void> updateMultiple(List<T> entities);         // Batch in base
  Future<void> updatePartial(ID id, Map<String, dynamic> updates);  // Complex
  Future<bool> delete(ID id);
  Future<int> deleteMultiple(List<ID> ids);              // Batch in base
  Future<int> deleteWhere(bool Function(T) predicate);   // Complex
  Future<void> upsert(T entity);                         // Forced on all
  Future<int> count();
  Future<bool> contains(ID id);
  Future<EntityQuery<T>> query();                        // Forced on all
  Future<List<T>> getModifiedSince(DateTime since);     // Forced on all
  Future<bool> validateSchema();                         // Forced on all
  Future<int> getSchemaVersion();                        // Forced on all
}
```

**After:**
```dart
// CORE interface - minimal CRUD
abstract class EntityStorage<ID, T> extends Storage {
  ID getEntityId(T entity);
  Future<T?> get(ID id);
  Future<void> create(T entity);
  Future<void> update(T entity);
  Future<bool> delete(ID id);
  Future<bool> contains(ID id);
  Future<List<T>> getAll();
  Future<int> count();
}

// OPTIONAL batch capability
abstract class BatchEntityStorage<ID, T> implements EntityStorage<ID, T> {
  Future<List<T>> getMultiple(List<ID> ids);
  Future<void> createMultiple(List<T> entities);
  Future<void> updateMultiple(List<T> entities);
  Future<int> deleteMultiple(List<ID> ids);
}

// OPTIONAL upsert capability
abstract class UpsertableEntityStorage<ID, T> implements EntityStorage<ID, T> {
  Future<void> upsert(T entity);
  Future<void> upsertMultiple(List<T> entities);
}
```

**Rationale:**
- Base interface has **only essential CRUD**
- Batch operations moved to `BatchEntityStorage` capability
- Upsert moved to `UpsertableEntityStorage` capability
- Queries removed (use `QueryableStorage<T>` capability instead)
- Schema/migration removed (use `SchemaAwareStorage`/`MigratableStorage` instead)
- Sync features removed (use `RefreshableStorage` capability instead)

---

### 7. **Result Types - CLEANED**

**Before:**
```dart
sealed class StorageResult<T> {
  final DateTime timestamp;
  final StorageMetrics? metrics;
  final StorageOperationOptions? options;
}

class StorageChangeNotification<T> { ... }  // Complex pub/sub
class StorageStatistics { ... }            // Detailed metrics
class StorageMetrics { ... }               // Performance tracking
class BatchOptions { ... }                 // Configuration objects
```

**After:**
```dart
sealed class StorageResult<T> { }

final class StorageSuccess<T> extends StorageResult<T> {
  final T value;
}

final class StorageFailure<T> extends StorageResult<T> {
  final Exception error;
  final String? message;
}
```

**Rationale:**
- **Removed unnecessary complexity**
- No forced timestamps, metrics, or notifications
- Simple success/failure result type
- Implementations can add metrics separately if needed
- Most operations throw exceptions directly (Result is optional)

---

## New File Structure

```
lib/src/storage/
├── abstractions/
│   ├── storage_interface.dart              ✨ THINNED - lifecycle only
│   ├── storage_capabilities.dart           ✨ NEW - opt-in capabilities
│   ├── key_value_storage_minimal.dart      ✨ NEW - minimal KV interface
│   ├── entity_storage_minimal.dart         ✨ NEW - minimal entity interface
│   ├── query_simplified.dart               ✨ NEW - simplified query DSL
│   ├── storage_transaction.dart            ✅ KEPT - still needed
│   ├── [OLD FILES - deprecated]
│   │   ├── key_value_storage.dart          ❌ DEPRECATED - too fat
│   │   ├── entity_storage.dart             ❌ DEPRECATED - too fat
│   │   └── query.dart                      ❌ DEPRECATED - too complex
│   └── index.dart
├── exceptions/
│   └── storage_exceptions.dart             ✅ KEPT - still valid
├── types/
│   ├── storage_result_minimal.dart         ✨ NEW - simplified result
│   └── [OLD FILES - deprecated]
│       └── storage_result.dart             ❌ DEPRECATED - too complex
└── [DOCUMENTATION]
    ├── REFACTORING_GUIDE.md               ✨ THIS FILE
    └── STORAGE_ABSTRACTION.md             ⚠️ NEEDS UPDATE
```

---

## Migration Guide for Implementations

### Migrating a Simple Key-Value Storage

**Before:**
```dart
class PreferencesStorage extends KeyValueStorage<String> {
  @override
  Future<Map<String, String>> getAll() async { ... }
  @override
  Future<Map<String, String>> getMultiple(List<String> keys) async { ... }
  // Had to implement many methods even though not efficient
}
```

**After:**
```dart
// Just implement the minimal interface
class PreferencesStorage extends KeyValueStorage<String> {
  // Only 5 core methods needed!
  @override
  Future<String?> get(String key) async { ... }
  @override
  Future<void> set(String key, String value) async { ... }
  @override
  Future<bool> delete(String key) async { ... }
  @override
  Future<bool> contains(String key) async { ... }
  @override
  Future<List<String>> keys() async { ... }
}
```

### Migrating a Full-Featured Database Storage

**Before:**
```dart
class SqliteStorage extends EntityStorage<int, User> 
    implements Storage {
  // Everything forced into one interface
}
```

**After:**
```dart
class SqliteStorage extends EntityStorage<int, User>
    implements
        TransactionalStorage,
        QueryableStorage<User>,
        SchemaAwareStorage,
        MigratableStorage,
        BatchEntityStorage<int, User> {
  // Explicitly opt-in to capabilities
  // Clear what this storage supports
}
```

---

## Design Principles Applied

### 1. **Interface Segregation Principle (ISP)**
> "No client should be forced to depend on methods it does not use"

**Applied:**
- Base `Storage` has only lifecycle methods
- Optional features are separate interfaces
- Implementations choose which capabilities to support

### 2. **Single Responsibility Principle (SRP)**
> "A class should have only one reason to change"

**Applied:**
- `Storage` - lifecycle only
- `TransactionalStorage` - transaction management only
- `QueryableStorage` - querying only
- `SchemaAwareStorage` - schema management only
- `MigratableStorage` - migration execution only

### 3. **Dependency Inversion Principle (DIP)**
> "Depend on abstractions, not concretions"

**Applied:**
- Schema and migration are **described**, not **implemented**
- Storage **executes** migrations, app **creates** them
- Clear separation between policy (app) and mechanism (storage)

### 4. **YAGNI (You Aren't Gonna Need It)**
> "Don't add functionality until it's necessary"

**Applied:**
- Removed metrics, statistics, notifications (can be added separately)
- Removed complex query features (aggregations, joins)
- Removed forced batch operations (opt-in instead)

### 5. **Composition Over Inheritance**
> "Prefer composing objects over inheriting"

**Applied:**
- Capabilities are composed via interface implementation
- No deep inheritance hierarchies
- Mix-and-match capabilities as needed

---

## Summary

| Aspect | Before | After | Benefit |
|--------|--------|-------|---------|
| **Base Storage** | 9 methods | 5 methods | 44% smaller |
| **KeyValueStorage** | 10+ methods | 5 methods | 50% smaller |
| **EntityStorage** | 20+ methods | 8 methods | 60% smaller |
| **Capabilities** | Forced in base | Opt-in interfaces | ISP compliance |
| **Query DSL** | 15+ operators | 7 operators | Simpler abstraction |
| **Schema/Migration** | Inside storage | External abstractions | Separation of concerns |
| **Result Types** | 8 helper types | 1 result type | Reduced complexity |

**Bottom line:** The abstraction is now **THIN**, **FOCUSED**, and **COMPOSABLE** instead of **FAT** and **MONOLITHIC**.

---

## Next Steps

1. ✅ Refactoring complete
2. ⏳ Update `STORAGE_ABSTRACTION.md` with new design
3. ⏳ Create implementation examples for each capability
4. ⏳ Write migration guide for existing implementations
5. ⏳ Update exports in `index.dart`
