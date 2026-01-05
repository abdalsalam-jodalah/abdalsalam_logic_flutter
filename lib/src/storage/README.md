# Storage Abstraction Layer - Quick Index

**Location**: `lib/src/storage/`  
**Status**: ✅ Complete - Pure Dart, No Implementations  
**Date**: January 6, 2026

## 📚 Documentation

1. **[DELIVERY_SUMMARY.md](DELIVERY_SUMMARY.md)** - What was delivered, checklist, files created
2. **[STORAGE_ABSTRACTION.md](STORAGE_ABSTRACTION.md)** - Complete architecture guide
3. **[RESPONSIBILITY_MATRIX.md](RESPONSIBILITY_MATRIX.md)** - Who does what, required vs optional
4. **[README.md](README.md)** (this file)

## 🎯 Core Abstractions

### Base Contract
- **[storage_interface.dart](abstractions/storage_interface.dart)** - `Storage` base class
  - Lifecycle: `initialize()`, `dispose()`, `clear()`
  - State: `isInitialized`, `isDisposed`, `isHealthy()`
  - Transactions: `transaction()`
  - Metadata: `getMetadata()`

### Key-Value Storage
- **[key_value_storage.dart](abstractions/key_value_storage.dart)** - `KeyValueStorage<T>` 
  - Generic typed storage for any value type
  - Get/set/delete single or multiple items
  - Count, contains, filtered deletion
  - Optional metadata retrieval

### Entity Storage
- **[entity_storage.dart](abstractions/entity_storage.dart)** - `EntityStorage<ID, T>`
  - Full CRUD for typed entities
  - Batch operations
  - Advanced queries (optional)
  - Schema versioning (optional)
  - Sync support (optional)

### Query DSL
- **[query.dart](abstractions/query.dart)** - Fluent query building
  - `QueryFilter` - 15+ operators
  - `QuerySort` - ASC/DESC sorting
  - `QueryPagination` - Offset/limit with helpers
  - `QueryResult<T>` - Results with metadata
  - `EntityQuery<T>` - Fluent builder pattern

### Transactions
- **[storage_transaction.dart](abstractions/storage_transaction.dart)** - ACID transactions
  - Commit/rollback
  - Savepoints
  - 4 isolation levels
  - Context-aware execution

## 🚨 Exception Hierarchy

**[exceptions/storage_exceptions.dart](exceptions/storage_exceptions.dart)**

10 specific exception types + base `StorageException`:
- `StorageInitializationException`
- `StorageNotFoundException`
- `StorageConstraintException`
- `StorageSpaceException`
- `StorageTimeoutException`
- `StorageCorruptionException`
- `StorageUnsupportedException`
- `StorageStateException`
- `StorageTransactionException`
- `StoragePermissionException`
- `StorageOperationException`

## 🧰 Helper Types

**[types/storage_result.dart](types/storage_result.dart)**

- `StorageResult<T>` - Sealed type for functional error handling
  - `StorageSuccess<T>` - Success case
  - `StorageFailure<T>` - Failure case
  - Methods: `when()`, `map()`, `getOrElse()`, `getOrThrow()`

- `StorageOperationOptions` - Configure CRUD behavior
- `BatchOptions` - Batch operation settings
- `StorageChangeNotification<T>` - Track storage changes
- `StorageStatistics` - Storage introspection
- `StorageMetrics` - Performance monitoring

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────┐
│         Application Code                        │
│  (Uses abstractions, not implementations)       │
└──────────────┬──────────────────────────────────┘
               │
        ┌──────▼──────────────────────────┐
        │  Storage Abstraction Layer       │
        │                                  │
        │  ┌──────────────────────────┐   │
        │  │ Storage (Base)           │   │
        │  │ - init, dispose, clear   │   │
        │  │ - transactions           │   │
        │  │ - metadata               │   │
        │  └──────────────────────────┘   │
        │           ▲                      │
        │     ┌─────┴────────┐             │
        │     │              │             │
        │  ┌──▼──┐      ┌───▼─┐            │
        │  │ KV  │      │Ent  │            │
        │  │<T>  │      │<ID,T>│          │
        │  └─────┘      └──┬──┘            │
        │                  │               │
        │         ┌────────▼────┐          │
        │         │ Query<T>    │          │
        │         │ - filters   │          │
        │         │ - sorting   │          │
        │         │ - pagination│          │
        │         └─────────────┘          │
        │                                  │
        │  + Exceptions + Result Types    │
        │  + Transaction Support          │
        └──────────────┬───────────────────┘
                       │
        ┌──────────────▼──────────────────┐
        │  Future Implementations         │
        │  (Your code here)               │
        │                                 │
        │  - SharedPreferences            │
        │  - Secure Storage               │
        │  - SQLite                       │
        │  - Hive / Isar                  │
        │  - Custom Backends              │
        └─────────────────────────────────┘
```

## 💡 Quick Start

### For App Developers
```dart
import 'package:abdalsalam_logic_flutter/src/storage/index.dart';

// Use any implementation
final storage = MyCustomStorage<String>();
await storage.initialize();

// Type-safe operations
await storage.set('key', 'value');
final value = await storage.get('key');

// For entities
final entityStorage = MyEntityStorage();
final results = await entityStorage
    .query()
    .where(QueryFilter.equals('status', 'active'))
    .execute();
```

### For Implementation Developers
```dart
class MyStorage<T> extends KeyValueStorage<T> {
  // Extend and implement the abstraction
  
  @override
  Future<T?> get(String key) async {
    // Your implementation here
  }
  
  // Implement all required methods
  // Optional: implement advanced features
}
```

## 📋 Supported Storage Types

| Type | Interface | Use Case |
|------|-----------|----------|
| Secure Key-Value | `KeyValueStorage<T>` | Tokens, secrets |
| Preferences | `KeyValueStorage<T>` | App settings |
| SQLite Structured | `EntityStorage<ID, T>` | Relational data |
| SQLite Key-Value | `KeyValueStorage<T>` | Hybrid approach |
| NoSQL/Object | `EntityStorage<ID, T>` | Hive, Isar-like |

## ✨ Key Features

- ✅ **Type Safety** - Compile-time generic types
- ✅ **Transactions** - ACID with savepoints
- ✅ **Queries** - Fluent DSL
- ✅ **Batch Ops** - Efficient multi-item operations
- ✅ **Error Handling** - Unified exception hierarchy
- ✅ **Pure Dart** - No platform dependencies
- ✅ **Extensible** - Add new types without modification
- ✅ **AI-Ready** - Pure interfaces for code generation
- ✅ **Well-Documented** - Multiple guides included

## 🔍 Design Principles

1. **SOLID** - Single responsibility, open-closed, etc.
2. **Clean Architecture** - No framework or platform dependencies
3. **Golden Rule** - If not used, don't include it
4. **Type Safety** - Generics and compile-time checking
5. **Composability** - Mix multiple storage types
6. **Extensibility** - Easy to add implementations
7. **Clear Contracts** - Interface-based design
8. **Error Handling** - Unified exceptions

## 📖 Where to Start

1. **New to storage abstractions?**
   - Read [STORAGE_ABSTRACTION.md](STORAGE_ABSTRACTION.md) - Complete guide

2. **Implementing storage?**
   - Check [RESPONSIBILITY_MATRIX.md](RESPONSIBILITY_MATRIX.md) - What to implement
   - See implementation patterns in guide

3. **Using storage in your app?**
   - Look at the interface files directly
   - Check what your implementation supports via `supportsFeature()`

4. **Need quick overview?**
   - Read [DELIVERY_SUMMARY.md](DELIVERY_SUMMARY.md)

## 🚀 Next Steps

Ready for implementations to extend these abstractions. Each implementation will:

1. Extend `Storage` for lifecycle
2. Extend `KeyValueStorage<T>` and/or `EntityStorage<ID, T>` 
3. Implement required methods
4. Implement optional advanced features
5. Wrap backend errors as `StorageException` subclasses
6. Advertise features via `supportsFeature()`

All implementations will be interchangeable, following the same contract.

## 📊 Statistics

- **Files**: 10 Dart files + 3 documentation files
- **Code**: ~2,500 lines of pure abstraction
- **Errors**: 0
- **Abstractions**: 5 main interfaces
- **Exceptions**: 11 types
- **Helper Types**: 8 types
- **Query Operators**: 15+

## 📝 License

Same as parent package.

---

**Created**: January 6, 2026  
**Status**: ✅ Complete - Ready for Implementation
