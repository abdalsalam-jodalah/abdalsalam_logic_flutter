// lib/src/storage/types/storage_result.dart

/// Result wrapper for storage operations.
///
/// Provides consistent result handling with success/failure states.
/// Useful for functional-style error handling.
sealed class StorageResult<T> {
  const StorageResult();

  /// Executes different code paths based on result type.
  ///
  /// Use for pattern matching on success/failure.
  R when<R>({
    required R Function(T data) success,
    required R Function(Exception error) failure,
  }) {
    if (this is StorageSuccess<T>) {
      return success((this as StorageSuccess<T>).data);
    } else {
      return failure((this as StorageFailure<T>).error);
    }
  }

  /// Maps the success value to a different type.
  StorageResult<R> map<R>(R Function(T data) mapper) {
    if (this is StorageSuccess<T>) {
      try {
        return StorageSuccess(mapper((this as StorageSuccess<T>).data));
      } catch (e) {
        return StorageFailure(Exception(e));
      }
    } else {
      return StorageFailure((this as StorageFailure<T>).error);
    }
  }

  /// Recovers from failure with a default value.
  T getOrElse(T Function(Exception error) defaultValue) {
    if (this is StorageSuccess<T>) {
      return (this as StorageSuccess<T>).data;
    } else {
      return defaultValue((this as StorageFailure<T>).error);
    }
  }

  /// Gets the value or throws the exception.
  T getOrThrow() {
    if (this is StorageSuccess<T>) {
      return (this as StorageSuccess<T>).data;
    } else {
      throw (this as StorageFailure<T>).error;
    }
  }
}

/// Successful storage operation result.
class StorageSuccess<T> extends StorageResult<T> {
  /// The successful result value.
  final T data;

  /// Timestamp when result was created.
  final DateTime timestamp;

  StorageSuccess(
    this.data, {
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'StorageSuccess(data: $data)';
}

/// Failed storage operation result.
class StorageFailure<T> extends StorageResult<T> {
  /// The exception that occurred.
  final Exception error;

  /// Timestamp when error occurred.
  final DateTime timestamp;

  StorageFailure(
    this.error, {
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'StorageFailure(error: $error)';
}

/// Options for storage operations.
///
/// Allows configuring behavior of CRUD operations.
class StorageOperationOptions {
  /// Timeout for the operation.
  final Duration? timeout;

  /// Whether to skip validation.
  final bool skipValidation;

  /// Whether to skip indexing (if applicable).
  final bool skipIndexing;

  /// Whether to trigger change notifications.
  final bool notifyListeners;

  /// Custom operation metadata.
  final Map<String, dynamic> metadata;

  const StorageOperationOptions({
    this.timeout,
    this.skipValidation = false,
    this.skipIndexing = false,
    this.notifyListeners = true,
    this.metadata = const {},
  });

  /// Creates options with a specific timeout.
  StorageOperationOptions withTimeout(Duration timeout) {
    return StorageOperationOptions(
      timeout: timeout,
      skipValidation: skipValidation,
      skipIndexing: skipIndexing,
      notifyListeners: notifyListeners,
      metadata: metadata,
    );
  }

  @override
  String toString() => 'StorageOperationOptions(timeout: $timeout)';
}

/// Batch operation configuration.
///
/// Controls how batch operations are executed.
class BatchOptions {
  /// Size of each batch.
  final int batchSize;

  /// Whether to continue on error.
  final bool continueOnError;

  /// Timeout for entire batch.
  final Duration? timeout;

  /// Whether to use transaction for the batch.
  final bool useTransaction;

  const BatchOptions({
    this.batchSize = 100,
    this.continueOnError = false,
    this.timeout,
    this.useTransaction = true,
  });

  @override
  String toString() =>
      'BatchOptions(batchSize: $batchSize, continueOnError: $continueOnError)';
}

/// Change notification for storage updates.
///
/// Describes what changed in storage.
class StorageChangeNotification<T> {
  /// Type of change.
  final ChangeType changeType;

  /// Entity that was changed (if applicable).
  final T? entity;

  /// Entity ID that was changed.
  final dynamic entityId;

  /// When the change occurred.
  final DateTime timestamp;

  /// Additional metadata about the change.
  final Map<String, dynamic> metadata;

  StorageChangeNotification({
    required this.changeType,
    this.entity,
    required this.entityId,
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'StorageChangeNotification($changeType, id: $entityId, at: $timestamp)';
}

/// Types of storage changes.
enum ChangeType {
  /// Entity was created.
  created,

  /// Entity was updated.
  updated,

  /// Entity was deleted.
  deleted,

  /// Storage was cleared.
  cleared,

  /// Schema changed.
  schemaChanged,
}

/// Storage statistics.
class StorageStatistics {
  /// Total number of entries.
  final int totalEntries;

  /// Total size in bytes.
  final int? totalSizeBytes;

  /// Average entry size.
  final int? averageEntrySize;

  /// Number of tables/collections.
  final int? tableCount;

  /// Storage type name.
  final String storageType;

  /// Last optimization time.
  final DateTime? lastOptimized;

  /// Custom statistics.
  final Map<String, dynamic> custom;

  const StorageStatistics({
    required this.totalEntries,
    this.totalSizeBytes,
    this.averageEntrySize,
    this.tableCount,
    required this.storageType,
    this.lastOptimized,
    this.custom = const {},
  });

  @override
  String toString() =>
      'StorageStatistics(entries: $totalEntries, size: ${totalSizeBytes}B, type: $storageType)';
}

/// Performance metrics for storage operations.
class StorageMetrics {
  /// Operation name.
  final String operation;

  /// Execution time.
  final Duration duration;

  /// Number of items affected.
  final int? itemsAffected;

  /// Data transferred (bytes).
  final int? bytesTransferred;

  /// Timestamp of operation.
  final DateTime timestamp;

  StorageMetrics({
    required this.operation,
    required this.duration,
    this.itemsAffected,
    this.bytesTransferred,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Gets the throughput (items per second).
  double? get throughput {
    if (itemsAffected == null || duration.inMilliseconds == 0) return null;
    return itemsAffected! / (duration.inMilliseconds / 1000);
  }

  @override
  String toString() =>
      'StorageMetrics($operation: ${duration.inMilliseconds}ms, items: $itemsAffected)';
}
