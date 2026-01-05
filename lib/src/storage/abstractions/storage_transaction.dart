// lib/src/storage/abstractions/storage_transaction.dart

import '../exceptions/storage_exceptions.dart';

/// Abstraction for transactional operations in storage.
///
/// A transaction groups multiple operations as a single atomic unit.
/// Either all operations succeed and are committed, or all fail and are rolled back.
///
/// Responsibilities:
/// - Ensure atomicity of operations
/// - Manage transaction context
/// - Handle rollback on failure
/// - Support nested behavior (if applicable)
///
/// Example:
/// ```dart
/// final tx = await storage.transaction();
/// try {
///   await tx.execute(() async {
///     await keyValueStorage.set('key1', 'value1');
///     await entityStorage.create(entity);
///   });
///   await tx.commit();
/// } catch (e) {
///   await tx.rollback();
///   rethrow;
/// }
/// ```
abstract class StorageTransaction {
  /// Returns `true` if this transaction is active.
  ///
  /// A transaction is active until [commit] or [rollback] is called.
  bool get isActive;

  /// Returns `true` if this transaction has been committed.
  bool get isCommitted;

  /// Returns `true` if this transaction has been rolled back.
  bool get isRolledBack;

  /// The isolation level for this transaction.
  ///
  /// Determines how concurrent transactions interact:
  /// - [IsolationLevel.dirty] - Can read uncommitted data (not recommended)
  /// - [IsolationLevel.committed] - Can only read committed data
  /// - [IsolationLevel.repeatable] - Prevents dirty and non-repeatable reads
  /// - [IsolationLevel.serializable] - Highest isolation, serializes transactions
  IsolationLevel get isolationLevel;

  /// Commits this transaction.
  ///
  /// All operations executed within this transaction are persisted.
  /// After commit, the transaction is no longer active.
  ///
  /// Throws:
  /// - [StorageTransactionException] if commit fails
  /// - [StorageStateException] if transaction is not active
  ///
  /// Should be idempotent - calling commit multiple times is safe
  /// (subsequent calls return immediately).
  Future<void> commit();

  /// Rolls back this transaction.
  ///
  /// All operations executed within this transaction are discarded.
  /// After rollback, the transaction is no longer active.
  ///
  /// Throws:
  /// - [StorageTransactionException] if rollback fails
  /// - [StorageStateException] if transaction is not active
  ///
  /// Should be idempotent - calling rollback multiple times is safe.
  Future<void> rollback();

  /// Executes operations within this transaction context.
  ///
  /// The [operation] callback receives this transaction and can perform
  /// storage operations that will be grouped atomically.
  ///
  /// If [operation] throws, the transaction is automatically rolled back.
  /// If [operation] completes successfully, the transaction remains active
  /// and can have additional operations until [commit] or [rollback] is called.
  ///
  /// Throws:
  /// - [StorageStateException] if transaction is not active
  /// - Any exception thrown by [operation]
  ///
  /// Note: This method does NOT automatically commit.
  /// Caller must explicitly call [commit] to persist changes.
  Future<T> execute<T>(Future<T> Function(StorageTransaction tx) operation);

  /// Saves a savepoint within this transaction.
  ///
  /// Savepoints allow rolling back to a specific point without rolling back
  /// the entire transaction. Multiple savepoints can be created.
  ///
  /// Returns a [SavePoint] that can be used with [rollbackToSavepoint].
  ///
  /// Throws:
  /// - [StorageStateException] if transaction is not active
  /// - [StorageUnsupportedException] if backend doesn't support savepoints
  /// - [StorageTransactionException] if savepoint creation fails
  Future<SavePoint> savepoint(String name);

  /// Rolls back to a previously created savepoint.
  ///
  /// All operations after the savepoint are discarded, but the transaction
  /// remains active and can continue with new operations.
  ///
  /// Throws:
  /// - [StorageStateException] if transaction is not active
  /// - [StorageNotFoundException] if savepoint doesn't exist
  /// - [StorageUnsupportedException] if backend doesn't support savepoints
  /// - [StorageTransactionException] if rollback fails
  Future<void> rollbackToSavepoint(SavePoint savepoint);
}

/// Represents a savepoint within a transaction.
///
/// Savepoints allow granular rollback without affecting the entire transaction.
class SavePoint {
  /// Unique identifier for this savepoint.
  final String id;

  /// Human-readable name for this savepoint.
  final String name;

  /// Timestamp when this savepoint was created.
  final DateTime createdAt;

  SavePoint({
    required this.id,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  String toString() => 'SavePoint($name, created: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavePoint && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Isolation levels for transactions.
///
/// Determines how concurrent transactions interact and what data visibility is allowed.
enum IsolationLevel {
  /// Dirty read isolation.
  ///
  /// Transactions can read uncommitted data from other transactions.
  /// Offers best performance but lowest safety.
  ///
  /// Not recommended for most use cases.
  dirty,

  /// Read committed isolation.
  ///
  /// Transactions can only read data committed by other transactions.
  /// Prevents dirty reads but allows non-repeatable and phantom reads.
  ///
  /// Good balance between performance and safety.
  committed,

  /// Repeatable read isolation.
  ///
  /// Transactions can't read uncommitted data.
  /// Once a row is read, other transactions can't modify it.
  /// Prevents dirty and non-repeatable reads but allows phantom reads.
  ///
  /// Better safety, some performance cost.
  repeatable,

  /// Serializable isolation.
  ///
  /// Highest isolation level.
  /// Transactions are completely isolated - acts as if they execute serially.
  /// Prevents all read anomalies but has significant performance cost.
  ///
  /// Use only when absolute correctness is required.
  serializable,
}
