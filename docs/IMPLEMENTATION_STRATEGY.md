# Storage Abstraction - Implementation Strategy

**Package:** abdalsalam_logic_flutter  
**Date:** January 6, 2026

---

## Overview

This document categorizes what should be implemented as **shared package logic** vs what should be left for **users to implement** based on whether the logic is:
- **Reusable** across all backends
- **Backend-specific** (varies by implementation)
- **Domain-specific** (varies by user's app)

---

## ✅ SHOULD IMPLEMENT (Shared Package Logic)

These components are **identical across all storage backends** and should be implemented once in the package.

### 1. Exception Hierarchy ✅ **ALREADY IMPLEMENTED**

**Why:** Exception types and handling logic are the same regardless of backend.

**Status:** ✅ Complete in `storage_exceptions.dart`

**Components:**
```dart
✅ StorageException (base)
✅ StorageInitializationException
✅ StorageNotFoundException
✅ StorageConstraintException
✅ StorageSpaceException
✅ StorageTimeoutException
✅ StorageCorruptionException
✅ StorageUnsupportedException
✅ StorageStateException
✅ StorageTransactionException
✅ StoragePermissionException
✅ StorageOperationException
```

**Benefit:** Users just throw these exceptions, no need to define their own.

---

### 2. Storage Metadata System ✅ **ALREADY IMPLEMENTED**

**Why:** Metadata structure is standardized across all backends.

**Status:** ✅ Complete in `storage_metadata.dart`

**Components:**
```dart
✅ StorageMetadata class
✅ 30+ capability flags
✅ Limit properties
✅ Performance properties
✅ Platform properties
✅ supports() helper method
```

**Benefit:** Users just fill in values, structure is provided.

---

### 3. Change Event Types ✅ **ALREADY IMPLEMENTED**

**Why:** Change event structure is same for all watchable storage.

**Status:** ✅ Complete in interfaces

**Components:**
```dart
✅ KeyValueChange<T>
✅ KeyValueChangeType enum (created, updated, deleted)
✅ EntityChange<ID, T>
✅ EntityChangeType enum (created, updated, deleted)
```

**Benefit:** Standardized events across all implementations.

---

### 4. Query DSL Builder 🔨 **SHOULD IMPLEMENT**

**Why:** Query construction logic (building filters, sorts, etc.) is the same. Only execution varies.

**Status:** ⚠️ Interface exists, builder implementation needed

**What to Implement:**
```dart
// Query builder that constructs query objects
class QueryBuilder<T> implements EntityQuery<T> {
  final List<Filter> _filters = [];
  final List<SortField> _sorts = [];
  int? _limit;
  int? _offset;
  
  @override
  EntityQuery<T> where(String field, {/* conditions */}) {
    _filters.add(Filter(field, /* conditions */));
    return this;
  }
  
  @override
  EntityQuery<T> orderBy(String field, {bool descending = false}) {
    _sorts.add(SortField(field, descending));
    return this;
  }
  
  @override
  EntityQuery<T> limit(int count) {
    _limit = count;
    return this;
  }
  
  // Build final query object
  QueryDescriptor build() {
    return QueryDescriptor(
      filters: _filters,
      sorts: _sorts,
      limit: _limit,
      offset: _offset,
    );
  }
  
  // Subclasses implement execute() with backend-specific logic
  @override
  Future<QueryResult<T>> execute();
}
```

**Benefit:** Users extend QueryBuilder and only implement `execute()`.

---

### 5. Result Wrappers 🔨 **SHOULD IMPLEMENT**

**Why:** Result structures are standardized.

**Status:** ⚠️ Minimal version exists, needs enhancement

**What to Implement:**
```dart
// Enhanced QueryResult
class QueryResult<T> {
  final List<T> items;
  final int totalCount;
  final String? nextCursor;
  final String? previousCursor;
  final bool hasMore;
  final Map<String, dynamic>? aggregations;
  
  QueryResult({
    required this.items,
    required this.totalCount,
    this.nextCursor,
    this.previousCursor,
    this.hasMore = false,
    this.aggregations,
  });
  
  // Helper methods
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get count => items.length;
  T? get firstOrNull => items.isEmpty ? null : items.first;
}

// Batch operation result
class BatchResult<T> {
  final List<T> successful;
  final List<BatchError> failed;
  final int successCount;
  final int failureCount;
  
  BatchResult({
    required this.successful,
    required this.failed,
  }) : successCount = successful.length,
       failureCount = failed.length;
  
  bool get hasFailures => failed.isNotEmpty;
  bool get allSucceeded => failed.isEmpty;
}

class BatchError {
  final dynamic item;
  final StorageException exception;
  
  BatchError(this.item, this.exception);
}
```

**Benefit:** Consistent result handling across all storage types.

---

### 6. Validation Helpers 🔨 **SHOULD IMPLEMENT**

**Why:** Common validation logic for keys, limits, etc.

**Status:** ❌ Not implemented

**What to Implement:**
```dart
class StorageValidation {
  // Validate key format
  static void validateKey(String key, StorageMetadata? metadata) {
    if (key.isEmpty) {
      throw StorageOperationException('Key cannot be empty');
    }
    
    final maxLength = metadata?.maxKeyLength;
    if (maxLength != null && key.length > maxLength) {
      throw StorageOperationException(
        'Key length ${key.length} exceeds maximum $maxLength'
      );
    }
  }
  
  // Validate batch size
  static void validateBatchSize(int size, StorageMetadata? metadata) {
    final maxBatch = metadata?.maxBatchSize;
    if (maxBatch != null && size > maxBatch) {
      throw StorageOperationException(
        'Batch size $size exceeds maximum $maxBatch'
      );
    }
  }
  
  // Validate value size
  static void validateValueSize(dynamic value, StorageMetadata? metadata) {
    final maxSize = metadata?.maxValueSize;
    if (maxSize != null) {
      final size = _estimateSize(value);
      if (size > maxSize) {
        throw StorageSpaceException(
          'Value size $size exceeds maximum $maxSize'
        );
      }
    }
  }
  
  // Validate storage state
  static void ensureInitialized(Storage storage) {
    if (!storage.isInitialized) {
      throw StorageStateException('Storage not initialized');
    }
    if (storage.isDisposed) {
      throw StorageStateException('Storage is disposed');
    }
  }
}
```

**Benefit:** Reusable validation across all implementations.

---

### 7. Batch Operation Helpers 🔨 **SHOULD IMPLEMENT**

**Why:** Logic for splitting batches is the same everywhere.

**Status:** ❌ Not implemented

**What to Implement:**
```dart
class BatchHelper {
  // Split list into chunks respecting batch limit
  static List<List<T>> chunk<T>(List<T> items, int? maxBatchSize) {
    final batchSize = maxBatchSize ?? items.length;
    final chunks = <List<T>>[];
    
    for (var i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      chunks.add(items.sublist(i, end));
    }
    
    return chunks;
  }
  
  // Execute batch operation with automatic chunking
  static Future<BatchResult<T>> executeBatch<T>({
    required List<T> items,
    required Future<void> Function(T item) operation,
    int? maxBatchSize,
  }) async {
    final chunks = chunk(items, maxBatchSize);
    final successful = <T>[];
    final failed = <BatchError>[];
    
    for (final chunk in chunks) {
      for (final item in chunk) {
        try {
          await operation(item);
          successful.add(item);
        } on StorageException catch (e) {
          failed.add(BatchError(item, e));
        }
      }
    }
    
    return BatchResult(successful: successful, failed: failed);
  }
}
```

**Benefit:** Automatic batch splitting for all storage implementations.

---

### 8. Metadata Helpers 🔨 **SHOULD IMPLEMENT**

**Why:** Common metadata queries and comparisons.

**Status:** ❌ Not implemented

**What to Implement:**
```dart
class MetadataHelper {
  // Check if storage has required capabilities
  static bool hasCapabilities(
    StorageMetadata? metadata,
    List<String> requiredCapabilities,
  ) {
    if (metadata == null) return false;
    return requiredCapabilities.every((cap) => metadata.supports(cap));
  }
  
  // Get best storage for use case
  static Storage? selectBestStorage(
    List<Storage> storages,
    StorageRequirements requirements,
  ) {
    for (final storage in storages) {
      final metadata = storage.getMetadata();
      if (metadata == null) continue;
      
      // Check encryption requirement
      if (requirements.requiresEncryption && !metadata.isEncrypted) {
        continue;
      }
      
      // Check transaction requirement
      if (requirements.requiresTransactions && !metadata.supportsTransactions) {
        continue;
      }
      
      // Check query requirement
      if (requirements.requiresQueries && !metadata.supportsQueries) {
        continue;
      }
      
      return storage; // Found match
    }
    
    return null; // No match
  }
  
  // Compare storage performance
  static int comparePerformance(StorageMetadata? a, StorageMetadata? b) {
    if (a == null || b == null) return 0;
    
    final aScore = _calculatePerformanceScore(a);
    final bScore = _calculatePerformanceScore(b);
    
    return aScore.compareTo(bScore);
  }
  
  static int _calculatePerformanceScore(StorageMetadata metadata) {
    var score = 0;
    if (metadata.fastReads) score += 10;
    if (metadata.fastWrites) score += 10;
    
    final readLatency = metadata.typicalReadLatencyMs ?? 100;
    score += (100 - readLatency).clamp(0, 50);
    
    return score;
  }
}

class StorageRequirements {
  final bool requiresEncryption;
  final bool requiresTransactions;
  final bool requiresQueries;
  final bool requiresPersistence;
  
  StorageRequirements({
    this.requiresEncryption = false,
    this.requiresTransactions = false,
    this.requiresQueries = false,
    this.requiresPersistence = true,
  });
}
```

**Benefit:** Smart storage selection and capability checking.

---

### 9. Pagination Helpers 🔨 **SHOULD IMPLEMENT**

**Why:** Pagination logic is standardized.

**Status:** ❌ Not implemented

**What to Implement:**
```dart
class PageRequest {
  final int pageNumber;
  final int pageSize;
  final int offset;
  
  PageRequest({
    required this.pageNumber,
    required this.pageSize,
  }) : offset = (pageNumber - 1) * pageSize;
  
  factory PageRequest.first(int pageSize) => PageRequest(pageNumber: 1, pageSize: pageSize);
  
  PageRequest next() => PageRequest(pageNumber: pageNumber + 1, pageSize: pageSize);
  PageRequest previous() => PageRequest(pageNumber: pageNumber - 1, pageSize: pageSize);
}

class Page<T> {
  final List<T> items;
  final int pageNumber;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  
  Page({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalItems,
  }) : totalPages = (totalItems / pageSize).ceil(),
       hasNext = pageNumber < (totalItems / pageSize).ceil(),
       hasPrevious = pageNumber > 1;
  
  bool get isFirst => pageNumber == 1;
  bool get isLast => !hasNext;
  int get itemsInPage => items.length;
}

class CursorPagination {
  static String encodeCursor(Map<String, dynamic> data) {
    final json = jsonEncode(data);
    return base64.encode(utf8.encode(json));
  }
  
  static Map<String, dynamic> decodeCursor(String cursor) {
    final json = utf8.decode(base64.decode(cursor));
    return jsonDecode(json);
  }
}
```

**Benefit:** Ready-to-use pagination for all storage types.

---

### 10. Base CRUD Implementation Helper 🔨 **SHOULD IMPLEMENT**

**Why:** Common CRUD patterns can be abstracted to reduce user boilerplate.

**Status:** ❌ Not implemented

**What to Implement:**
```dart
// Abstract base for entity storage with common patterns
abstract class BaseCrudStorage<ID, T> extends EntityStorage<ID, T> {
  StorageMetadata? getMetadata() => StorageMetadata(
    type: 'base_crud',
    supportsBatchOperations: true,
    supportsPartialUpdates: true,
  );

  // Template method for create - backend implements _insertOne
  @override
  Future<void> create(T entity) async {
    StorageValidation.ensureInitialized(this);
    await _insertOne(entity);
  }

  // Template method for update - backend implements _updateOne
  @override
  Future<void> update(T entity) async {
    StorageValidation.ensureInitialized(this);
    await _updateOne(entity);
  }

  // Template method for upsert - tries update, falls back to create
  @override
  Future<void> upsert(T entity) async {
    StorageValidation.ensureInitialized(this);
    final id = getEntityId(entity);
    if (await contains(id)) {
      await _updateOne(entity);
    } else {
      await _insertOne(entity);
    }
  }

  // Batch create with chunking
  @override
  Future<void> createMultiple(List<T> entities) async {
    StorageValidation.ensureInitialized(this);
    StorageValidation.validateBatchSize(entities.length, getMetadata());
    
    final chunks = BatchHelper.chunk(entities, getMetadata()?.maxBatchSize);
    for (final chunk in chunks) {
      await _insertBatch(chunk);
    }
  }

  // Backend-specific implementations
  Future<void> _insertOne(T entity);
  Future<void> _updateOne(T entity);
  Future<void> _insertBatch(List<T> entities) async {
    // Default: insert one by one
    for (final entity in entities) {
      await _insertOne(entity);
    }
  }
}
```

**Benefit:** Reduces boilerplate in user implementations, standardizes common patterns.

---

### 11. Transaction Helper for CRUD 🔨 **SHOULD IMPLEMENT**

**Why:** Transaction patterns for CRUD operations are common and repetitive.

**Status:** ❌ Not implemented

**What to Implement:**
```dart
// Helper for managing CRUD within transactions
class CrudTransaction {
  final StorageTransaction _transaction;
  
  CrudTransaction(this._transaction);
  
  // Execute multiple operations in transaction
  Future<T> execute<T>(Future<T> Function() operations) async {
    try {
      final result = await operations();
      await _transaction.commit();
      return result;
    } catch (e) {
      await _transaction.rollback();
      rethrow;
    }
  }
  
  // Create multiple entities in transaction
  Future<void> createMultiple<ID, T>(
    EntityStorage<ID, T> storage,
    List<T> entities,
  ) async {
    for (final entity in entities) {
      await storage.create(entity);
    }
  }
  
  // Update multiple entities in transaction
  Future<void> updateMultiple<ID, T>(
    EntityStorage<ID, T> storage,
    List<T> entities,
  ) async {
    for (final entity in entities) {
      await storage.update(entity);
    }
  }
  
  // Delete multiple entities in transaction
  Future<int> deleteMultiple<ID, T>(
    EntityStorage<ID, T> storage,
    List<ID> ids,
  ) async {
    var count = 0;
    for (final id in ids) {
      if (await storage.delete(id)) {
        count++;
      }
    }
    return count;
  }
}

// Usage example:
final txStorage = storage as TransactionalStorage;
final tx = await txStorage.beginTransaction();
final crudTx = CrudTransaction(tx);

await crudTx.execute(() async {
  await crudTx.createMultiple(userStorage, [user1, user2, user3]);
  await crudTx.updateMultiple(productStorage, [product1, product2]);
});
```

**Benefit:** Simplifies transaction handling for batch CRUD operations.

---

### 12. Table Creation Helper 🔨 **SHOULD IMPLEMENT**

**Why:** Table creation logic patterns are common (building DDL, managing indices, constraints).

**Status:** ❌ Not implemented

**What to Implement:**
```dart
// Helper for building tables with common patterns
abstract class TableBuilder {
  final String tableName;
  final List<FieldSchema> fields = [];
  final List<String> primaryKeys = [];
  final List<IndexSchema> indexes = [];
  
  TableBuilder(this.tableName);
  
  // Fluent API for building schema
  TableBuilder addField(
    String name,
    FieldType type, {
    bool required = false,
    dynamic defaultValue,
    int? maxLength,
  }) {
    fields.add(FieldSchema(
      name: name,
      type: type,
      required: required,
      defaultValue: defaultValue,
      maxLength: maxLength,
    ));
    return this;
  }
  
  TableBuilder setPrimaryKey(String field) {
    primaryKeys.add(field);
    return this;
  }
  
  TableBuilder setPrimaryKeys(List<String> keys) {
    primaryKeys.addAll(keys);
    return this;
  }
  
  TableBuilder addIndex(String name, List<String> fields, {bool unique = false}) {
    indexes.add(IndexSchema(
      name: name,
      fields: fields,
      unique: unique,
    ));
    return this;
  }
  
  // Build final schema
  TableSchema build() => TableSchema(
    name: tableName,
    fields: fields,
    primaryKeys: primaryKeys,
    indexes: indexes,
  );
  
  // Create table in storage (abstract - user implements DDL)
  Future<void> createIn(TableManagementStorage storage) async {
    await storage.createTable(tableName, schema: build());
  }
}

// Usage:
final userTableSchema = TableBuilder('users')
  .addField('id', FieldType.integer, required: true)
  .addField('name', FieldType.string, required: true)
  .addField('email', FieldType.string, required: true)
  .addField('settings', FieldType.json)
  .setPrimaryKey('id')
  .addIndex('idx_email', ['email'], unique: true)
  .build();

await storage.createTable('users', schema: userTableSchema);
```

**Benefit:** Fluent API for table schema definition, reduces boilerplate.

---

### 13. Initialization Helper 🔨 **SHOULD IMPLEMENT**

**Why:** Common initialization patterns (create tables, run migrations, setup indexes).

**Status:** ❌ Not implemented

**What to Implement:**
```dart
// Helper for managing storage initialization
class StorageInitializer {
  final Storage storage;
  final List<TableSchema> tables = [];
  final List<Migration> migrations = [];
  
  StorageInitializer(this.storage);
  
  // Register table to create on init
  StorageInitializer addTable(TableSchema schema) {
    tables.add(schema);
    return this;
  }
  
  // Register migration to run on init
  StorageInitializer addMigration(Migration migration) {
    migrations.add(migration);
    return this;
  }
  
  // Initialize: create tables and run migrations
  Future<void> initialize() async {
    if (storage.isInitialized) return;
    
    await storage.initialize();
    
    // Create tables
    if (storage is TableManagementStorage) {
      final tableStorage = storage as TableManagementStorage;
      for (final table in tables) {
        await tableStorage.createTable(table.name, schema: table);
      }
    }
    
    // Run migrations
    for (final migration in migrations) {
      await migration.migrate(storage);
    }
  }
  
  // Cleanup
  Future<void> dispose() async {
    await storage.dispose();
  }
}

// Usage:
final initializer = StorageInitializer(database)
  .addTable(userTableSchema)
  .addTable(productTableSchema)
  .addMigration(MigrationV1ToV2())
  .addMigration(MigrationV2ToV3());

await initializer.initialize(); // Creates tables and runs migrations
```

**Benefit:** Centralized initialization logic, clean setup pattern.

---

### 5. Backup & Snapshot System 💡

**Why:** Common need to backup/export storage data to files or strings.

**Priority:** Medium

**Example:**
```dart
// Backup entire storage to JSON file
class StorageBackup {
  final Storage storage;
  
  // Export all data to JSON file
  Future<File> backupToFile(String filename) async {
    final data = await _exportAllData();
    final file = File(filename);
    await file.writeAsString(jsonEncode(data));
    return file;
  }
  
  // Export as backup string (base64 encoded)
  Future<String> backupToString() async {
    final data = await _exportAllData();
    final json = jsonEncode(data);
    return base64.encode(utf8.encode(json));
  }
  
  // Restore from JSON file
  Future<void> restoreFromFile(String filename) async {
    final file = File(filename);
    final json = await file.readAsString();
    final data = jsonDecode(json) as Map<String, dynamic>;
    await _importAllData(data);
  }
  
  // Restore from backup string
  Future<void> restoreFromString(String backupString) async {
    final json = utf8.decode(base64.decode(backupString));
    final data = jsonDecode(json) as Map<String, dynamic>;
    await _importAllData(data);
  }
  
  // Create timestamped backup
  Future<File> createAutoBackup(String backupDir) async {
    final timestamp = DateTime.now().toIso8601String();
    final filename = 'backup_$timestamp.json';
    final filepath = '$backupDir/$filename';
    return await backupToFile(filepath);
  }
  
  // Extract snapshot of specific table/entity
  Future<Map<String, dynamic>> snapshotEntity<ID, T>(
    EntityStorage<ID, T> storage,
    {DateTime? asOfDate}
  ) async {
    final entities = await storage.getAll();
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'asOfDate': asOfDate?.toIso8601String(),
      'entityCount': entities.length,
      'entities': entities,
    };
  }
  
  // Export all data (abstract - user implements per backend)
  Future<Map<String, dynamic>> _exportAllData();
  
  // Import all data (abstract - user implements per backend)
  Future<void> _importAllData(Map<String, dynamic> data);
}
```

**Features:**
- Export to file (JSON)
- Export to string (base64 encoded for portability)
- Restore from file or string
- Auto-timestamped backups
- Snapshot specific tables/entities
- Backend-agnostic (user implements _exportAllData, _importAllData)

**Benefit:** Users get backup/restore framework without implementing from scratch.

---

## 🤔 MIGHT IMPLEMENT (Optional Helpers)

These are **useful utilities** but not strictly necessary. Can be added later based on user demand.

### 1. In-Memory Storage (For Testing) 💡

**Why:** Useful for testing without real backend.

**Priority:** Medium

**Example:**
```dart
class InMemoryKeyValueStorage<T> implements KeyValueStorage<T> {
  final Map<String, T> _data = {};
  bool _initialized = false;
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get isDisposed => false;
  
  @override
  Future<void> initialize() async {
    _initialized = true;
  }
  
  @override
  Future<void> clear() async {
    _data.clear();
  }
  
  @override
  Future<void> dispose() async {}
  
  @override
  Future<T?> get(String key) async => _data[key];
  
  @override
  Future<void> set(String key, T value) async => _data[key] = value;
  
  @override
  Future<bool> delete(String key) async {
    return _data.remove(key) != null;
  }
  
  @override
  StorageMetadata? getMetadata() => StorageMetadata(
    type: 'in_memory',
    isPersistent: false,
    isInMemory: true,
  );
  
  // ... implement remaining methods
}
```

**Benefit:** Easy testing without dependencies.

---

### 2. Storage Decorators/Wrappers 💡

**Why:** Add cross-cutting concerns (logging, caching, metrics).

**Priority:** Low

**Examples:**
```dart
// Logging wrapper
class LoggingStorage<T> implements KeyValueStorage<T> {
  final KeyValueStorage<T> _inner;
  final Logger _logger;
  
  @override
  Future<T?> get(String key) async {
    _logger.info('Getting key: $key');
    final value = await _inner.get(key);
    _logger.info('Got value: $value');
    return value;
  }
}

// Caching wrapper
class CachingStorage<T> implements KeyValueStorage<T> {
  final KeyValueStorage<T> _inner;
  final Map<String, T> _cache = {};
  
  @override
  Future<T?> get(String key) async {
    if (_cache.containsKey(key)) return _cache[key];
    
    final value = await _inner.get(key);
    if (value != null) _cache[key] = value;
    return value;
  }
}

// Metrics wrapper
class MetricsStorage<T> implements KeyValueStorage<T> {
  final KeyValueStorage<T> _inner;
  int _readCount = 0;
  int _writeCount = 0;
  
  int get readCount => _readCount;
  int get writeCount => _writeCount;
  
  @override
  Future<T?> get(String key) async {
    _readCount++;
    return await _inner.get(key);
  }
}
```

**Benefit:** Reusable cross-cutting concerns.

---

### 3. Migration Helper Framework 💡

**Why:** Migration logic patterns are common.

**Priority:** Medium

**Example:**
```dart
abstract class Migration {
  int get version;
  Future<void> migrate(Storage storage);
}

class MigrationManager {
  final List<Migration> migrations;
  
  Future<void> migrate(Storage storage, int fromVersion, int toVersion) async {
    final applicable = migrations
      .where((m) => m.version > fromVersion && m.version <= toVersion)
      .toList()
      ..sort((a, b) => a.version.compareTo(b.version));
    
    for (final migration in applicable) {
      await migration.migrate(storage);
    }
  }
}

// User defines migrations:
class AddUserEmailMigration extends Migration {
  @override
  int get version => 2;
  
  @override
  Future<void> migrate(Storage storage) async {
    // User-specific migration logic
  }
}
```

**Benefit:** Structured migration management.

---

### 4. Statistics Aggregator 💡

**Why:** Common statistics calculations.

**Priority:** Low

**Example:**
```dart
class StorageStatistics {
  final Storage storage;
  
  Future<StorageStats> calculate() async {
    // Calculate various statistics
  }
}
```

**Benefit:** Built-in analytics.

---

## ❌ SHOULD NOT IMPLEMENT (User/Backend Specific)

These are **specific to each backend or user's domain** and must be implemented by users.

### 1. Actual Storage Backend Implementations ❌

**Why:** Each backend (SQLite, Hive, SharedPreferences, etc.) has different API and behavior.

**User Implements:**
```dart
// User creates their own implementation
class MyHiveStorage implements KeyValueStorage<String> {
  final Box _box;
  
  @override
  Future<String?> get(String key) async => _box.get(key);
  
  @override
  Future<void> set(String key, String value) async => await _box.put(key, value);
  
  // ... etc
}

class MySqliteStorage implements EntityStorage<int, User> {
  final Database _db;
  
  @override
  Future<User?> get(int id) async {
    final maps = await _db.query('users', where: 'id = ?', whereArgs: [id]);
    return maps.isEmpty ? null : User.fromMap(maps.first);
  }
  
  // ... etc
}
```

**Reason:** We can't know which backend user will choose (SQLite, Hive, Isar, Firebase, etc.).

---

### 2. Table/Collection Schemas ❌

**Why:** Each app has different data models.

**User Defines:**
```dart
// User defines their tables
final userTable = TableSchema(
  name: 'users',
  fields: [
    FieldSchema(name: 'id', type: FieldType.integer, required: true),
    FieldSchema(name: 'name', type: FieldType.string, required: true),
    FieldSchema(name: 'email', type: FieldType.string, required: true),
  ],
  primaryKeys: ['id'],
);

final productsTable = TableSchema(
  name: 'products',
  fields: [
    FieldSchema(name: 'id', type: FieldType.uuid, required: true),
    FieldSchema(name: 'title', type: FieldType.string),
    FieldSchema(name: 'price', type: FieldType.double),
    FieldSchema(name: 'metadata', type: FieldType.json),
  ],
);
```

**Reason:** Every app has different entities and schemas.

---

### 3. Entity Models ❌

**Why:** Each app has different domain objects.

**User Defines:**
```dart
// User defines their entities
class User {
  final int id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
  
  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    name: map['name'],
    email: map['email'],
  );
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
  };
}
```

**Reason:** Domain models are app-specific.

---

### 4. Query Execution Logic ❌

**Why:** Each backend executes queries differently.

**User Implements:**
```dart
class SqliteUserQuery extends QueryBuilder<User> {
  final Database _db;
  
  @override
  Future<QueryResult<User>> execute() async {
    // Convert filters to SQL WHERE clause
    final where = _buildWhereClause(_filters);
    final orderBy = _buildOrderByClause(_sorts);
    
    // Execute SQL query
    final maps = await _db.query(
      'users',
      where: where,
      orderBy: orderBy,
      limit: _limit,
      offset: _offset,
    );
    
    // Convert to User objects
    final users = maps.map((m) => User.fromMap(m)).toList();
    
    return QueryResult(items: users, totalCount: users.length);
  }
  
  String _buildWhereClause(List<Filter> filters) {
    // Backend-specific SQL generation
  }
}
```

**Reason:** SQL, NoSQL, key-value stores all execute queries differently.

---

### 5. Transaction Management ❌

**Why:** Transaction semantics vary by backend.

**User Implements:**
```dart
class SqliteTransaction implements StorageTransaction {
  final Database _db;
  final Transaction _tx;
  
  @override
  Future<void> commit() async {
    // SQLite-specific commit
    await _tx.commit();
  }
  
  @override
  Future<void> rollback() async {
    // SQLite-specific rollback
    await _tx.rollback();
  }
}
```

**Reason:** Transactions work differently in SQL vs NoSQL vs in-memory.

---

### 6. Platform-Specific Features ❌

**Why:** Encryption, file paths, permissions are platform-specific.

**User Handles:**
```dart
// User chooses encryption library
class SecureStorage implements KeyValueStorage<String> {
  final FlutterSecureStorage _secure; // iOS/Android specific
  
  // User implements platform-specific encryption
}

// User chooses file storage location
class FileStorage {
  Future<Directory> getStorageDirectory() async {
    // Platform-specific path logic
    if (Platform.isAndroid) {
      return await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      return await getLibraryDirectory();
    }
    // ...
  }
}
```

**Reason:** Platform APIs differ (iOS Keychain, Android KeyStore, etc.).

---

### 7. ID Generation Strategy ❌

**Why:** ID generation varies by use case and backend.

**User Chooses:**
```dart
class UserStorage implements EntityStorage<int, User> {
  int _nextId = 1;
  
  @override
  Future<void> create(User user) async {
    // User chooses: auto-increment, UUID, timestamp, etc.
    final id = _nextId++;
    // Or: final id = Uuid().v4();
    // Or: final id = DateTime.now().millisecondsSinceEpoch;
  }
}
```

**Reason:** Different strategies (auto-increment, UUID, CUID, etc.) suit different needs.

---

### 8. Connection/Pool Management ❌

**Why:** Connection handling is backend-specific.

**User Implements:**
```dart
class DatabasePool {
  final List<Database> _connections = [];
  
  Future<Database> acquire() async {
    // Backend-specific connection pooling
  }
  
  void release(Database db) {
    // Backend-specific release
  }
}
```

**Reason:** Only relevant for SQL databases, not for key-value stores.

---

## 📊 Summary Table

| Component | Status | Who Implements | Priority |
|-----------|--------|---------------|----------|
| **Exception Hierarchy** | ✅ Done | Package | Critical |
| **Storage Metadata** | ✅ Done | Package | Critical |
| **Change Events** | ✅ Done | Package | Critical |
| **Query DSL Builder** | 🔨 TODO | Package | High |
| **Result Wrappers** | 🔨 TODO | Package | High |
| **Validation Helpers** | 🔨 TODO | Package | High |
| **Batch Helpers** | 🔨 TODO | Package | Medium |
| **Metadata Helpers** | 🔨 TODO | Package | Medium |
| **Pagination Helpers** | 🔨 TODO | Package | Medium |
| **Base CRUD Implementation Helper** | 🔨 TODO | Package | High |
| **Transaction Helper for CRUD** | 🔨 TODO | Package | High |
| **Table Creation Helper** | 🔨 TODO | Package | High |
| **Initialization Helper** | 🔨 TODO | Package | High |
| **In-Memory Storage** | 💡 Optional | Package | Low |
| **Storage Decorators** | 💡 Optional | Package | Low |
| **Backup & Snapshot** | 💡 Optional | Package | Medium |
| **Migration Framework** | 💡 Optional | Package | Low |
| **Statistics Aggregator** | 💡 Optional | Package | Low |
| ||||
| **Backend Implementations** | ❌ Never | User | N/A |
| **Table Schemas** | ❌ Never | User | N/A |
| **Entity Models** | ❌ Never | User | N/A |
| **Query Execution** | ❌ Never | User | N/A |
| **Transaction Management** | ❌ Never | User | N/A |
| **Platform Features** | ❌ Never | User | N/A |
| **ID Generation** | ❌ Never | User | N/A |
| **Connection Pooling** | ❌ Never | User | N/A |

---

## 🎯 Recommended Implementation Order

### Phase 1: Critical Shared Logic (High Priority)
1. ✅ Exception hierarchy (DONE)
2. ✅ Storage metadata (DONE)
3. ✅ Change events (DONE)
4. 🔨 Query DSL builder
5. 🔨 Result wrappers (enhanced)
6. 🔨 Validation helpers
7. 🔨 Base CRUD Implementation Helper
8. 🔨 Transaction Helper for CRUD
9. 🔨 Table Creation Helper
10. 🔨 Initialization Helper

### Phase 2: Productivity Helpers (Medium Priority)
11. 🔨 Batch helpers
12. 🔨 Metadata helpers
13. 🔨 Pagination helpers

### Phase 3: Optional Utilities (Low Priority)
14. 💡 In-memory storage for testing
15. 💡 Storage decorators (logging, caching)
16. 💡 Backup & Snapshot system
17. 💡 Migration framework
18. 💡 Statistics aggregator

---

## 📖 User Implementation Guide

### What Users MUST Implement:

```dart
// 1. Choose a backend and implement storage interface
class MyStorage implements EntityStorage<int, User> {
  final Database _db; // SQLite, Hive, etc.
  
  // Implement all required methods
  @override
  Future<User?> get(int id) async {
    // Backend-specific logic
  }
  
  // ... all other methods
}

// 2. Define their entity models
class User {
  final int id;
  final String name;
  // ... fields
}

// 3. Define their schemas (if using TableManagement)
final schema = TableSchema(
  name: 'users',
  fields: [/* their fields */],
);

// 4. Implement query execution (if using QueryableStorage)
class MyQuery extends QueryBuilder<User> {
  @override
  Future<QueryResult<User>> execute() async {
    // Backend-specific query execution
  }
}
```

### What Users GET from Package:

```dart
// 1. Throw exceptions
throw StorageNotFoundException('User not found');

// 2. Return metadata
@override
StorageMetadata getMetadata() => StorageMetadata(
  type: 'my_storage',
  isEncrypted: true,
  supportsQueries: true,
);

// 3. Use validation
StorageValidation.validateKey(key, getMetadata());
StorageValidation.ensureInitialized(this);

// 4. Use batch helpers
final chunks = BatchHelper.chunk(items, getMetadata()?.maxBatchSize);

// 5. Use pagination
final page = PageRequest.first(20);
final results = await storage.getPage(page.offset, page.pageSize);
```

---

## ✅ Final Recommendations

### ✅ IMPLEMENT NOW (Critical - CRUD & Initialization):
1. Base CRUD Implementation Helper (reduces boilerplate)
2. Transaction Helper for CRUD (transaction patterns)
3. Table Creation Helper (fluent schema API)
4. Initialization Helper (centralized setup)
5. Query DSL builder (query construction)
6. Enhanced result wrappers (consistent results)
7. Validation helpers (input validation)
8. Batch operation helpers (efficient bulk ops)

### 🤔 IMPLEMENT LATER (Optional - Utilities):
1. Pagination helpers
2. Metadata helpers
3. In-memory storage for testing
4. Storage decorators (logging, caching)
5. Backup & snapshot system
6. Migration framework helpers

### ❌ NEVER IMPLEMENT (User-Specific):
1. Backend implementations (SQLite, Hive, etc.)
2. Entity models
3. Table schemas
4. Actual query execution logic
5. Actual transaction management
6. ID generation
7. Connection pooling

**This keeps the abstraction clean, reusable, and flexible!** 🎯
