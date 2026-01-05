// lib/src/storage/abstractions/storage_interface.dart

import 'storage_transaction.dart';
import '../exceptions/storage_exceptions.dart';

/// Base abstraction for all storage backends.
///
/// Defines the minimal contract that every storage implementation must fulfill.
/// Implementations handle:
/// - Initialization and cleanup
/// - Storage metadata and state
/// - Transaction support
/// - Error handling
///
/// Responsibilities:
/// - Ensure thread-safe operations
/// - Handle cleanup properly
/// - Wrap backend errors as StorageException subclasses
/// - Support lazy initialization
///
/// Example:
/// ```dart
/// abstract class Storage {
///   Future<void> initialize();
///   Future<void> clear();
///   Future<void> dispose();
///   Future<StorageTransaction> transaction();
/// }
/// ```
abstract class Storage {
  /// Whether the storage has been initialized.
  ///
  /// Returns `true` if [initialize] has been called and completed successfully.
  /// Returns `false` if storage is not yet initialized or has been disposed.
  bool get isInitialized;

  /// Whether the storage is currently disposed.
  ///
  /// Returns `true` if [dispose] has been called.
  /// All operations should fail with [StorageStateException] when disposed.
  bool get isDisposed;

  /// Initializes the storage backend.
  ///
  /// This method MUST be called before any other operations.
  /// Implementations should:
  /// - Create necessary files/databases
  /// - Verify storage is accessible
  /// - Perform migrations if needed
  /// - Initialize internal structures
  ///
  /// Throws:
  /// - [StorageInitializationException] if initialization fails
  /// - [StorageStateException] if already initialized
  ///
  /// May be called multiple times without issue (idempotent).
  Future<void> initialize();

  /// Clears all data from storage.
  ///
  /// Removes all keys, entities, and associated data.
  /// Storage remains initialized and can be used after clearing.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if clear operation fails
  Future<void> clear();

  /// Disposes the storage backend.
  ///
  /// Closes connections, releases resources, and cleans up.
  /// After disposal, all operations should fail with [StorageStateException].
  ///
  /// Should be idempotent - calling dispose multiple times is safe.
  /// Implementations should:
  /// - Close database connections
  /// - Release file handles
  /// - Cleanup memory
  /// - Cancel pending operations
  Future<void> dispose();

  /// Begins a new transaction.
  ///
  /// Transactions allow grouping multiple operations as a single atomic unit.
  /// If any operation in the transaction fails, all changes are rolled back.
  ///
  /// Returns a [StorageTransaction] that supports:
  /// - Committing all changes
  /// - Rolling back all changes
  /// - Executing operations within transaction context
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageUnsupportedException] if backend doesn't support transactions
  /// - [StorageTransactionException] if transaction creation fails
  ///
  /// Note: Nested transactions behavior depends on implementation.
  /// Implementations may not support nested transactions.
  Future<StorageTransaction> transaction();

  /// Gets metadata about the storage.
  ///
  /// Returns information about:
  /// - Storage type name
  /// - Version
  /// - Supported features
  /// - Performance characteristics
  ///
  /// Returns `null` if metadata is unavailable.
  StorageMetadata? getMetadata();

  /// Checks if storage is in a valid, usable state.
  ///
  /// Performs a quick validation to ensure:
  /// - Storage is initialized
  /// - Storage is not disposed
  /// - Storage is accessible
  ///
  /// Returns `true` if storage is healthy and ready to use.
  /// Returns `false` if storage is unusable.
  bool isHealthy();
}

/// Metadata about a storage implementation.
///
/// Provides information for debugging, logging, and feature detection.
class StorageMetadata {
  /// Name of the storage backend.
  final String type;

  /// Version of the storage backend.
  final String version;

  /// List of supported features.
  ///
  /// Examples: 'transactions', 'queries', 'encryption', 'compression'
  final List<String> supportedFeatures;

  /// Maximum size per value (in bytes), or `null` if unlimited.
  final int? maxValueSize;

  /// Maximum number of keys, or `null` if unlimited.
  final int? maxKeys;

  /// Whether this storage supports transactions.
  final bool supportsTransactions;

  /// Whether this storage supports queries.
  final bool supportsQueries;

  /// Whether this storage supports concurrent access.
  final bool supportsConcurrency;

  /// Additional metadata as key-value pairs.
  final Map<String, dynamic> custom;

  const StorageMetadata({
    required this.type,
    required this.version,
    this.supportedFeatures = const [],
    this.maxValueSize,
    this.maxKeys,
    this.supportsTransactions = false,
    this.supportsQueries = false,
    this.supportsConcurrency = false,
    this.custom = const {},
  });

  /// Returns `true` if this storage supports the given feature.
  bool supports(String feature) => supportedFeatures.contains(feature);

  @override
  String toString() {
    return 'StorageMetadata(type: $type, version: $version, features: $supportedFeatures)';
  }
}
