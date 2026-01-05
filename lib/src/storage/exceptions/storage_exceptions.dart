// lib/src/storage/exceptions/storage_exceptions.dart

/// Base exception for all storage-related errors.
///
/// All storage implementations MUST throw package-level exceptions,
/// not backend-specific errors. This allows consumers to handle storage
/// errors uniformly regardless of the underlying implementation.
abstract class StorageException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;
  final StackTrace? stackTrace;

  StorageException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'StorageException: $message${code != null ? ' ($code)' : ''}';
}

/// Thrown when a storage operation fails to initialize.
///
/// Common causes:
/// - Database file cannot be created or accessed
/// - Required permissions are missing
/// - Storage backend is unavailable
/// - Initialization timeout
class StorageInitializationException extends StorageException {
  StorageInitializationException({
    required String message,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'STORAGE_INIT_FAILED',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Thrown when a requested item is not found.
///
/// Used when:
/// - Getting a key that doesn't exist
/// - Fetching an entity by ID that doesn't exist
/// - Querying returns no results but one was expected
class StorageNotFoundException extends StorageException {
  final String identifier;

  StorageNotFoundException({
    required this.identifier,
    String? message,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message ?? 'Item not found: $identifier',
    code: code ?? 'NOT_FOUND',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Thrown when a storage operation violates constraints.
///
/// Common causes:
/// - Duplicate key/ID in unique constraint
/// - Foreign key constraint violation
/// - Data type mismatch
/// - Invalid data format
class StorageConstraintException extends StorageException {
  final String? constraint;

  StorageConstraintException({
    required String message,
    this.constraint,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'CONSTRAINT_VIOLATION',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Thrown when storage space is insufficient.
///
/// Indicates:
/// - Device storage is full
/// - Storage quota exceeded
/// - Cannot allocate more space
class StorageSpaceException extends StorageException {
  StorageSpaceException({
    required String message,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'INSUFFICIENT_SPACE',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Thrown when a storage operation times out.
///
/// Indicates:
/// - Database lock timeout
/// - Query execution timeout
/// - Transaction timeout
class StorageTimeoutException extends StorageException {
  final Duration? timeout;

  StorageTimeoutException({
    required String message,
    this.timeout,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'OPERATION_TIMEOUT',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Thrown when a storage operation is corrupted or invalid.
///
/// Indicates:
/// - Database corruption detected
/// - Invalid data format
/// - Checksum mismatch
/// - Unrecoverable data error
class StorageCorruptionException extends StorageException {
  StorageCorruptionException({
    required String message,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'DATA_CORRUPTION',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Thrown when a storage operation is not supported by the backend.
///
/// Indicates:
/// - Operation not implemented
/// - Feature not available in this storage type
/// - Version incompatibility
class StorageUnsupportedException extends StorageException {
  final String operation;

  StorageUnsupportedException({
    required this.operation,
    String? message,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message ?? 'Operation not supported: $operation',
    code: code ?? 'UNSUPPORTED_OPERATION',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Thrown when a storage operation fails due to invalid state.
///
/// Common causes:
/// - Storage not initialized
/// - Storage already disposed
/// - Storage is locked by another process
/// - Inconsistent state
class StorageStateException extends StorageException {
  StorageStateException({
    required String message,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'INVALID_STATE',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Thrown when a transaction operation fails.
///
/// Common causes:
/// - Transaction rollback
/// - Nested transaction error
/// - Transaction context mismatch
class StorageTransactionException extends StorageException {
  StorageTransactionException({
    required String message,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'TRANSACTION_FAILED',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Thrown when a storage permission operation fails.
///
/// Indicates:
/// - Permission denied
/// - Access rights insufficient
/// - Authentication failed
class StoragePermissionException extends StorageException {
  StoragePermissionException({
    required String message,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'PERMISSION_DENIED',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Thrown when a generic storage operation fails.
///
/// Fallback exception for errors that don't fit other categories.
/// Should include details about the underlying error.
class StorageOperationException extends StorageException {
  final String operation;

  StorageOperationException({
    required this.operation,
    required String message,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'OPERATION_FAILED',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}
