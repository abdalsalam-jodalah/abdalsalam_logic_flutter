# Storage Exception Handling Guide

**Location**: `lib/src/storage/exceptions/storage_exceptions.dart`  
**Status**: ✅ Complete - 11 Exception Types  
**Date**: January 13, 2026

## 📋 Overview

All storage implementations use a unified exception hierarchy. This ensures consistent error handling across different storage backends (SQLite, Hive, SharedPreferences, etc.).

## 🎯 Core Principle

**NEVER throw backend-specific exceptions!**

❌ Bad:
```dart
throw SqlException('Database error');  // Backend-specific
throw HiveError('Box not open');       // Backend-specific
```

✅ Good:
```dart
throw StorageStateException(
  message: 'Database not initialized',
  originalError: sqlException,  // Preserve original
);
```

## 📚 Complete Exception Reference

### 1. StorageInitializationException

**When to use**: Storage fails to initialize

**Common scenarios**:
- Database file cannot be created or accessed
- Required permissions are missing
- Storage backend is unavailable
- Initialization timeout

**Example**:
```dart
@override
Future<void> initialize() async {
  try {
    _database = await openDatabase('storage.db');
  } catch (e) {
    throw StorageInitializationException(
      message: 'Failed to initialize database',
      originalError: e,
    );
  }
}
```

**Code**: `STORAGE_INIT_FAILED`

---

### 2. StorageNotFoundException

**When to use**: Requested item doesn't exist

**Common scenarios**:
- Getting a key that doesn't exist
- Fetching an entity by ID that doesn't exist
- Query returns no results but one was expected

**Example**:
```dart
@override
Future<T?> get(String id) async {
  final result = await database.query('table', where: 'id = ?', whereArgs: [id]);
  
  if (result.isEmpty && throwIfNotFound) {
    throw StorageNotFoundException(
      identifier: id,
      message: 'Entity with ID $id not found',
    );
  }
  
  return result.isNotEmpty ? _deserialize(result.first) : null;
}
```

**Code**: `NOT_FOUND`

---

### 3. StorageConstraintException

**When to use**: Operation violates storage constraints

**Common scenarios**:
- Duplicate key/ID in unique constraint
- Foreign key constraint violation
- Data type mismatch
- Invalid data format

**Example**:
```dart
@override
Future<void> create(T entity) async {
  try {
    await database.insert('table', _serialize(entity));
  } on DatabaseException catch (e) {
    if (e.isUniqueConstraintError()) {
      throw StorageConstraintException(
        message: 'Entity with this ID already exists',
        constraint: 'PRIMARY KEY',
        originalError: e,
      );
    }
    rethrow;
  }
}
```

**Code**: `CONSTRAINT_VIOLATION`

---

### 4. StorageSpaceException

**When to use**: Insufficient storage space

**Common scenarios**:
- Device storage is full
- Storage quota exceeded
- Cannot allocate more space

**Example**:
```dart
@override
Future<void> set(String key, T value) async {
  try {
    await storage.write(key, value);
  } on FileSystemException catch (e) {
    if (e.osError?.errorCode == 28) {  // ENOSPC
      throw StorageSpaceException(
        message: 'Insufficient storage space',
        originalError: e,
      );
    }
    rethrow;
  }
}
```

**Code**: `INSUFFICIENT_SPACE`

---

### 5. StorageTimeoutException

**When to use**: Operation times out

**Common scenarios**:
- Database lock timeout
- Query execution timeout
- Transaction timeout

**Example**:
```dart
@override
Future<List<T>> query(Query query) async {
  try {
    return await database
        .query('table')
        .timeout(Duration(seconds: 30));
  } on TimeoutException catch (e) {
    throw StorageTimeoutException(
      message: 'Query execution timeout',
      timeout: Duration(seconds: 30),
      originalError: e,
    );
  }
}
```

**Code**: `OPERATION_TIMEOUT`

---

### 6. StorageCorruptionException

**When to use**: Data corruption detected

**Common scenarios**:
- Database corruption detected
- Invalid data format
- Checksum mismatch
- Unrecoverable data error

**Example**:
```dart
@override
Future<T> deserialize(Map<String, dynamic> data) async {
  try {
    return T.fromJson(data);
  } on FormatException catch (e) {
    throw StorageCorruptionException(
      message: 'Data corruption detected: invalid JSON format',
      originalError: e,
    );
  }
}
```

**Code**: `DATA_CORRUPTION`

---

### 7. StorageUnsupportedException

**When to use**: Feature not available in this storage backend

**Common scenarios**:
- Operation not implemented
- Feature not available in this storage type
- Version incompatibility

**Example**:
```dart
@override
Future<void> executeJoin(JoinQuery query) async {
  // SharedPreferences doesn't support joins
  throw StorageUnsupportedException(
    operation: 'join',
    message: 'SharedPreferences does not support join operations',
  );
}
```

**Code**: `UNSUPPORTED_OPERATION`

---

### 8. StorageStateException

**When to use**: Invalid storage state

**Common scenarios**:
- Storage not initialized
- Storage already disposed
- Storage is locked by another process
- Inconsistent state

**Example**:
```dart
@override
Future<void> set(String key, T value) async {
  if (!isInitialized) {
    throw StorageStateException(
      message: 'Storage not initialized. Call initialize() first.',
    );
  }
  
  if (isDisposed) {
    throw StorageStateException(
      message: 'Storage already disposed',
    );
  }
  
  await _performSet(key, value);
}
```

**Code**: `INVALID_STATE`

---

### 9. StorageTransactionException

**When to use**: Transaction operation fails

**Common scenarios**:
- Transaction rollback
- Nested transaction error
- Transaction context mismatch
- Deadlock detected

**Example**:
```dart
@override
Future<void> commit() async {
  try {
    await _transaction.commit();
  } catch (e) {
    throw StorageTransactionException(
      message: 'Failed to commit transaction',
      originalError: e,
    );
  }
}
```

**Code**: `TRANSACTION_FAILED`

---

### 10. StoragePermissionException

**When to use**: Permission denied

**Common scenarios**:
- Permission denied
- Access rights insufficient
- Authentication failed

**Example**:
```dart
@override
Future<void> initialize() async {
  try {
    await createDatabaseFile();
  } on FileSystemException catch (e) {
    if (e.osError?.errorCode == 13) {  // EACCES
      throw StoragePermissionException(
        message: 'Permission denied to create database file',
        originalError: e,
      );
    }
    rethrow;
  }
}
```

**Code**: `PERMISSION_DENIED`

---

### 11. StorageOperationException

**When to use**: Generic operation failure (catch-all)

**Common scenarios**:
- Errors that don't fit other categories
- Unexpected failures
- Complex operation failures

**Example**:
```dart
@override
Future<void> complexOperation() async {
  try {
    // Complex multi-step operation
    await step1();
    await step2();
    await step3();
  } catch (e) {
    // If we can't categorize it specifically
    throw StorageOperationException(
      operation: 'complexOperation',
      message: 'Operation failed at step 2',
      originalError: e,
    );
  }
}
```

**Code**: `OPERATION_FAILED`

---

## 🎨 Usage Patterns

### Pattern 1: Wrapping Backend Exceptions

```dart
Future<T> operation() async {
  try {
    return await backendSpecificOperation();
  } on BackendSpecificException catch (e) {
    // Convert to storage exception
    throw _mapBackendException(e);
  }
}

StorageException _mapBackendException(dynamic e) {
  if (e is DatabaseLockException) {
    return StorageTimeoutException(
      message: 'Database locked',
      originalError: e,
    );
  } else if (e is UniqueConstraintException) {
    return StorageConstraintException(
      message: 'Duplicate key',
      originalError: e,
    );
  }
  // Default fallback
  return StorageOperationException(
    operation: 'operation',
    message: 'Operation failed',
    originalError: e,
  );
}
```

### Pattern 2: State Validation

```dart
void _checkState() {
  if (!isInitialized) {
    throw StorageStateException(
      message: 'Storage not initialized',
    );
  }
  if (isDisposed) {
    throw StorageStateException(
      message: 'Storage disposed',
    );
  }
}

@override
Future<void> operation() async {
  _checkState();  // Validate before every operation
  await _performOperation();
}
```

### Pattern 3: Resource Cleanup on Error

```dart
Future<void> operation() async {
  Resource? resource;
  try {
    resource = await acquireResource();
    await performOperation(resource);
  } catch (e) {
    await resource?.cleanup();
    throw StorageOperationException(
      operation: 'operation',
      message: 'Failed with cleanup',
      originalError: e,
    );
  }
}
```

## 🔍 Error Handling Best Practices

### 1. Always Preserve Original Error

```dart
✅ Good:
throw StorageOperationException(
  operation: 'save',
  message: 'Failed to save data',
  originalError: e,  // Preserve for debugging
  stackTrace: stackTrace,
);

❌ Bad:
throw StorageOperationException(
  operation: 'save',
  message: 'Failed to save data',
);
```

### 2. Provide Meaningful Messages

```dart
✅ Good:
throw StorageNotFoundException(
  identifier: userId,
  message: 'User with ID $userId not found in users table',
);

❌ Bad:
throw StorageNotFoundException(
  identifier: userId,
  message: 'Not found',
);
```

### 3. Use Specific Exception Types

```dart
✅ Good:
if (file.existsSync()) {
  throw StorageConstraintException(
    message: 'Database file already exists',
  );
}

❌ Bad:
if (file.existsSync()) {
  throw StorageOperationException(
    operation: 'init',
    message: 'File exists',
  );
}
```

### 4. Catch and Convert Backend Exceptions

```dart
✅ Good:
try {
  await sqfliteDatabase.insert(...);
} on DatabaseException catch (e) {
  if (e.isConstraintError()) {
    throw StorageConstraintException(...);
  }
  throw StorageOperationException(...);
}

❌ Bad:
await sqfliteDatabase.insert(...);  // Let backend exception leak
```

## 📊 Exception Coverage Matrix

| Operation | Primary Exception | Secondary Exceptions |
|-----------|-------------------|---------------------|
| initialize() | StorageInitializationException | StoragePermissionException, StorageSpaceException |
| dispose() | StorageStateException | - |
| get() | StorageNotFoundException | StorageStateException |
| set() | StorageSpaceException | StorageStateException, StorageConstraintException |
| delete() | StorageNotFoundException | StorageStateException |
| query() | StorageTimeoutException | StorageOperationException, StorageUnsupportedException |
| transaction() | StorageTransactionException | StorageStateException |
| clear() | StoragePermissionException | StorageStateException |

## 🧪 Testing Exception Handling

```dart
test('throws StorageNotFoundException when key not found', () async {
  final storage = TestStorage();
  await storage.initialize();
  
  expect(
    () => storage.get('nonexistent'),
    throwsA(isA<StorageNotFoundException>()),
  );
});

test('preserves original error in exception', () async {
  final storage = TestStorage();
  
  try {
    await storage.operationThatFails();
    fail('Should have thrown');
  } on StorageOperationException catch (e) {
    expect(e.originalError, isNotNull);
    expect(e.stackTrace, isNotNull);
  }
});
```

## 📝 Implementation Checklist

- ✅ All exceptions extend `StorageException`
- ✅ All exceptions have meaningful messages
- ✅ Original errors are preserved
- ✅ Stack traces are captured
- ✅ Error codes are consistent
- ✅ State is validated before operations
- ✅ Backend exceptions are converted
- ✅ Resources are cleaned up on errors
- ✅ Exceptions are documented
- ✅ Tests cover exception scenarios

## 🎯 Quick Reference

```dart
// State errors
throw StorageStateException(message: '...');
throw StorageInitializationException(message: '...');

// Data errors
throw StorageNotFoundException(identifier: '...', message: '...');
throw StorageConstraintException(message: '...', constraint: '...');
throw StorageCorruptionException(message: '...');

// Operation errors
throw StorageOperationException(operation: '...', message: '...');
throw StorageUnsupportedException(operation: '...', message: '...');
throw StorageTimeoutException(message: '...', timeout: Duration(...));

// Resource errors
throw StorageSpaceException(message: '...');
throw StoragePermissionException(message: '...');

// Transaction errors
throw StorageTransactionException(message: '...');
```

---

**Status**: All 11 exception types are fully implemented and integrated across all storage implementations.
