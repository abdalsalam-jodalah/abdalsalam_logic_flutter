// lib/src/storage/abstractions/storage_interface.dart

import '../exceptions/storage_exceptions.dart';
import '../types/storage_metadata.dart';

/// Base abstraction for all storage backends.
///
/// **LIFECYCLE MANAGEMENT ONLY** - Optional features are in capability interfaces.
///
/// Core responsibilities:
/// - Initialize storage lazily
/// - Check readiness state
/// - Clear all data
/// - Dispose resources safely
/// - Provide metadata
///
/// Design principle: Interface Segregation
/// - Base interface has only essential lifecycle operations
/// - Optional features (transactions, queries, schema, etc.) are separate capability interfaces
/// - Implementations opt-in to capabilities they support
///
/// Example:
/// ```dart
/// class MyStorage implements Storage {
///   bool _initialized = false;
///   bool _disposed = false;
///
///   @override
///   bool get isInitialized => _initialized;
///
///   @override
///   bool get isDisposed => _disposed;
///
///   @override
///   Future<void> initialize() async {
///     // Setup storage
///     _initialized = true;
///   }
///
///   @override
///   Future<void> clear() async {
///     // Clear all data
///   }
///
///   @override
///   Future<void> dispose() async {
///     // Cleanup resources
///     _disposed = true;
///   }
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
  /// - Initialize internal structures
  /// - Load configuration
  ///
  /// **NOTE:** Schema migrations are handled via [MigratableStorage] capability.
  ///
  /// Throws:
  /// - [StorageInitializationException] if initialization fails
  /// - [StorageStateException] if already disposed
  ///
  /// Must be idempotent - safe to call multiple times.
  Future<void> initialize();

  /// Clears all data from storage.
  ///
  /// Removes all keys, entities, tables, and associated data.
  /// Storage remains initialized and can be used after clearing.
  ///
  /// **WARNING:** This is a destructive operation that cannot be undone.
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
  /// Must be idempotent - safe to call multiple times.
  /// Implementations should:
  /// - Close database connections
  /// - Release file handles
  /// - Cleanup memory
  /// - Cancel pending operations
  /// - Stop background tasks
  ///
  /// After disposal, call [initialize] to use storage again.
  Future<void> dispose();

  /// Gets metadata about the storage implementation.
  ///
  /// Returns [StorageMetadata] with:
  /// - Storage type and version
  /// - Supported capabilities
  /// - Limits (max size, max keys, etc.)
  /// - Performance characteristics
  /// - Platform compatibility
  ///
  /// Returns `null` if metadata is unavailable.
  ///
  /// Use metadata to:
  /// - Detect supported features before using capability interfaces
  /// - Respect implementation limits
  /// - Optimize for performance characteristics
  StorageMetadata? getMetadata();
}
