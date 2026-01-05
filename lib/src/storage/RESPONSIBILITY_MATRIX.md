# Storage Abstraction - Responsibility Matrix

## Interface Responsibilities

### Storage (Base)
**When to use**: Base operations needed by all backends

| Responsibility | Method | Required |
|---|---|---|
| Initialize | `initialize()` | ✅ Yes |
| Cleanup | `dispose()` | ✅ Yes |
| Clear data | `clear()` | ✅ Yes |
| State check | `isInitialized` | ✅ Yes |
| Disposed check | `isDisposed` | ✅ Yes |
| Health check | `isHealthy()` | ✅ Yes |
| Transactions | `transaction()` | ⚠️ Optional |
| Metadata | `getMetadata()` | ⚠️ Optional |

---

### KeyValueStorage<T>
**When to use**: Simple key-value data (settings, cache, tokens)

| Responsibility | Method | Complexity | Batch |
|---|---|---|---|
| Single get | `get(key)` | Low | ❌ |
| Single set | `set(key, value)` | Low | ❌ |
| Single delete | `delete(key)` | Low | ❌ |
| Multiple gets | `getMultiple(keys)` | Medium | ✅ Yes |
| Multiple sets | `setMultiple(entries)` | Medium | ✅ Yes |
| Multiple deletes | `deleteMultiple(keys)` | Medium | ✅ Yes |
| Get all | `getAll()` | Medium | - |
| Get all keys | `getAllKeys()` | Low | - |
| Count | `count()` | Low | - |
| Contains | `contains(key)` | Low | - |
| Predicate delete | `deleteWhere(predicate)` | High | - |
| With metadata | `getWithMetadata(key)` | Medium | ⚠️ Optional |

---

### EntityStorage<ID, T>
**When to use**: Complex structured data (models, relationships, queries)

#### CRUD Operations

| Operation | Methods | Single | Batch |
|---|---|---|---|
| Create | `create(entity)` | ✅ | `createMultiple()` ✅ |
| Read | `get(id)` | ✅ | `getMultiple()` ✅ |
| Update | `update(entity)` | ✅ | `updateMultiple()` ✅ |
| Delete | `delete(id)` | ✅ | `deleteMultiple()` ✅ |
| Partial update | `updateFields(id, map)` | ✅ | - |
| Upsert | `createOrUpdate(entity)` | ✅ | - |
| Predicate delete | `deleteWhere(predicate)` | ✅ | - |

#### Query Operations

| Capability | Method | Required | Fallback |
|---|---|---|---|
| Basic queries | `query()` | ⚠️ Optional | Fetch all + filter |
| Raw queries | `queryRaw(sql)` | ⚠️ Optional | None |
| Count | `count()` | ✅ Yes | Count fetched items |
| Get all | `getAll()` | ✅ Yes | - |
| Utilities | `contains(id)` | ✅ Yes | Fetch & check |

#### Sync Operations

| Capability | Method | Required | Use Case |
|---|---|---|---|
| Modified since | `getModifiedSince()` | ⚠️ Optional | Sync with backend |

#### Schema Operations

| Capability | Method | Required | Purpose |
|---|---|---|---|
| Schema validation | `validateSchema()` | ⚠️ Optional | Migration detection |
| Schema version | `getSchemaVersion()` | ⚠️ Optional | Versioning |

---

### StorageTransaction
**When to use**: Atomic multi-operation sequences

| Responsibility | Method | Level |
|---|---|---|
| Start transaction | Constructor | - |
| Commit | `commit()` | Required |
| Rollback | `rollback()` | Required |
| Execute in context | `execute(fn)` | Required |
| Create savepoint | `savepoint(name)` | Optional |
| Rollback to savepoint | `rollbackToSavepoint(sp)` | Optional |
| State tracking | `isActive`, `isCommitted`, `isRolledBack` | Required |
| Isolation level | `isolationLevel` | Optional |

---

### EntityQuery<T>
**When to use**: Complex queries with filters, sorts, pagination

| Capability | Method | Supported |
|---|---|---|
| Filter by condition | `where(filter)` | ✅ Yes |
| OR conditions | `orWhere(filters)` | ⚠️ Optional |
| Sort by field | `orderBy(sort)` | ⚠️ Optional |
| Pagination | `paginate(pagination)` | ⚠️ Optional |
| Limit results | `limit(n)` | ⚠️ Optional |
| Skip results | `skip(n)` | ⚠️ Optional |
| Select fields | `select(fields)` | ⚠️ Optional |
| Execute query | `execute()` | ✅ Yes |
| Get first result | `first()` | ✅ Yes |
| Count results | `count()` | ⚠️ Optional |
| Check existence | `exists()` | ⚠️ Optional |
| Feature detection | `supportsFeature()` | ✅ Yes |
| Query string | `toQueryString()` | ⚠️ Optional |

#### Supported Filter Operators

| Operator | Use Case | Example |
|---|---|---|
| equals | Exact match | `age = 25` |
| notEqual | Not equal | `status != 'inactive'` |
| greaterThan | Range | `price > 100` |
| greaterThanOrEqual | Range | `score >= 80` |
| lessThan | Range | `date < now` |
| lessThanOrEqual | Range | `age <= 18` |
| contains | Text search | `name contains 'John'` |
| startsWith | Text prefix | `email startsWith 'user'` |
| endsWith | Text suffix | `phone endsWith '123'` |
| inList | Set membership | `id in [1, 2, 3]` |
| notInList | Set exclusion | `status not in ['deleted']` |
| between | Range | `age between 18 AND 65` |
| isNull | Null check | `optionalField IS NULL` |
| isNotNull | Null check | `optionalField IS NOT NULL` |

---

## Exception Responsibilities

| Exception | When Thrown | Recovery |
|---|---|---|
| **StorageInitializationException** | `initialize()` fails | Retry or use different backend |
| **StorageNotFoundException** | `get(id)` returns nil | Provide default or create |
| **StorageConstraintException** | Constraint violation | Validate data before operation |
| **StorageSpaceException** | Disk full | Free space or cleanup old data |
| **StorageTimeoutException** | Operation timeout | Retry with longer timeout |
| **StorageCorruptionException** | Data corruption detected | Rebuild/restore from backup |
| **StorageUnsupportedException** | Feature not supported | Use different storage or fallback |
| **StorageStateException** | Invalid state (not init/disposed) | Call initialize() or use new instance |
| **StorageTransactionException** | Transaction fails | Retry transaction |
| **StoragePermissionException** | Access denied | Request permissions or use different backend |
| **StorageOperationException** | Generic operation failure | Log and retry or fallback |

---

## Implementation Guidance

### Must Implement (✅ Required)

From **Storage**:
- `initialize()` - Backend initialization
- `dispose()` - Resource cleanup
- `clear()` - Data clearing
- `isInitialized` - State tracking
- `isDisposed` - State tracking
- `isHealthy()` - Health check

### Should Implement (⚠️ Strongly Recommended)

- `getMetadata()` - For feature detection
- `transaction()` - For atomicity
- Proper error mapping to exceptions

### Can Implement (Optional)

- `savepoint()` / `rollbackToSavepoint()` - Advanced transactions
- All query operations - Can fetch-all and filter in-memory
- `getModifiedSince()` - Only if sync needed
- `validateSchema()` / `getSchemaVersion()` - Only if schema-aware

### Example: Minimal Implementation

```dart
class MinimalKeyValueStorage<T> extends KeyValueStorage<T> {
  Map<String, T> _data = {};
  bool _initialized = false;
  bool _disposed = false;

  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get isDisposed => _disposed;

  @override
  Future<void> initialize() async => _initialized = true;
  
  @override
  Future<void> dispose() async => _disposed = true;
  
  @override
  Future<void> clear() async => _data.clear();
  
  @override
  Future<T?> get(String key) async => _data[key];
  
  @override
  Future<void> set(String key, T value) async => _data[key] = value;
  
  @override
  Future<bool> delete(String key) async => _data.remove(key) != null;
  
  // ... implement remaining required methods
}
```

### Example: Full-Featured Implementation

Would additionally implement:
- All batch operations
- Transactions with savepoints
- Advanced query capabilities
- Schema versioning
- Sync support (modified-since)
- Metadata tracking
- Change notifications

---

## Feature Negotiation Pattern

Implementations use `supportsFeature()` to advertise capabilities:

```dart
// Consumer code
if (query.supportsFeature('sorting')) {
  // Use sorting
  query.orderBy(sort);
} else {
  // Fetch and sort in-memory
  results.sort(comparator);
}

// Same for other optional features
if (query.supportsFeature('pagination')) {
  query.paginate(pagination);
} else {
  results = results.skip(offset).take(limit);
}
```

---

## Summary

| Layer | Responsibility | Required | Optional |
|---|---|---|---|
| **Storage** | Lifecycle & state | ✅ 6 methods | ✅ Metadata, transactions |
| **KeyValueStorage** | Key-value ops | ✅ 3 core | ✅ 7 utilities |
| **EntityStorage** | Entity CRUD + queries | ✅ CRUD | ✅ Queries, sync, schema |
| **StorageTransaction** | Atomicity | ✅ Commit/rollback | ✅ Savepoints |
| **EntityQuery** | Query building | ✅ Execute | ✅ All filters/sorts |

All abstractions are **composition-friendly** - mix types as needed for your app's storage needs.
