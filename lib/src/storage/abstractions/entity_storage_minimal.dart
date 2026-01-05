// lib/src/storage/abstractions/entity_storage_minimal.dart

import 'storage_interface.dart';
import '../exceptions/storage_exceptions.dart';

/// Minimal entity-based storage abstraction.
///
/// **THIN INTERFACE** - Only essential CRUD operations.
/// Stores and retrieves typed entities (structured objects) by ID.
///
/// Core responsibilities:
/// - Create new entities
/// - Read entities by ID
/// - Update existing entities
/// - Delete entities by ID
///
/// Generic types:
/// - [ID] - Primary key type (String, int, UUID, etc.)
/// - [T] - Entity type
///
/// Implementations decide:
/// - Serialization strategy
/// - ID generation (if needed)
/// - Index management
///
/// Example:
/// ```dart
/// class User {
///   final String id;
///   final String name;
///   User(this.id, this.name);
/// }
///
/// class UserStorage implements EntityStorage<String, User> {
///   @override
///   String getEntityId(User entity) => entity.id;
///
///   @override
///   Future<User?> get(String id) async {
///     // Retrieve user from database
///   }
///
///   @override
///   Future<void> create(User entity) async {
///     // Insert user into database
///   }
/// }
/// ```
abstract class EntityStorage<ID, T> extends Storage {
  /// Extracts the ID from an entity.
  ///
  /// Must be implemented to define how to get the primary key from an entity.
  /// Used internally for CRUD operations.
  ID getEntityId(T entity);

  /// Gets an entity by ID.
  ///
  /// Returns the entity if found.
  /// Returns `null` if the entity doesn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  Future<T?> get(ID id);

  /// Creates a new entity in storage.
  ///
  /// Entity must have a valid, unique ID.
  /// Fails if an entity with the same ID already exists.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageConstraintException] if ID already exists
  /// - [StorageSpaceException] if insufficient space
  Future<void> create(T entity);

  /// Updates an existing entity in storage.
  ///
  /// Entity must already exist (ID must match an existing entity).
  /// Replaces the entire entity with the new value.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageNotFoundException] if entity doesn't exist
  /// - [StorageSpaceException] if insufficient space
  Future<void> update(T entity);

  /// Deletes an entity by ID.
  ///
  /// Returns `true` if the entity existed and was deleted.
  /// Returns `false` if the entity didn't exist (no-op).
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  Future<bool> delete(ID id);

  /// Checks if an entity with the given ID exists.
  ///
  /// Returns `true` if entity exists, `false` otherwise.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  Future<bool> contains(ID id);

  /// Gets all entities from storage.
  ///
  /// Returns a list of all stored entities.
  /// Order is not guaranteed.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// Note: May be expensive for large datasets.
  /// Consider using queries with pagination for large collections.
  Future<List<T>> getAll();

  /// Gets the total count of entities in storage.
  ///
  /// Returns the number of stored entities.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// More efficient than getAll().length for large datasets.
  Future<int> count();
}

/// Batch operations capability for entity storage.
///
/// **OPTIONAL CAPABILITY**
/// Implement this for efficient batch operations on entity storage.
abstract class BatchEntityStorage<ID, T> implements EntityStorage<ID, T> {
  /// Gets multiple entities by IDs in a single operation.
  ///
  /// Returns a list of entities found.
  /// Missing IDs are silently omitted from results.
  /// Order is not guaranteed to match input order.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// More efficient than multiple [get] calls for many IDs.
  Future<List<T>> getMultiple(List<ID> ids);

  /// Creates multiple entities in a single operation.
  ///
  /// All entities are inserted atomically (where supported).
  /// All IDs must be unique (no duplicates in input or storage).
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageConstraintException] if any ID already exists
  /// - [StorageSpaceException] if insufficient space
  ///
  /// More efficient than multiple [create] calls for many entities.
  Future<void> createMultiple(List<T> entities);

  /// Updates multiple entities in a single operation.
  ///
  /// All entities are updated atomically (where supported).
  /// All entities must already exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageNotFoundException] if any entity doesn't exist
  /// - [StorageSpaceException] if insufficient space
  ///
  /// More efficient than multiple [update] calls for many entities.
  Future<void> updateMultiple(List<T> entities);

  /// Deletes multiple entities by IDs in a single operation.
  ///
  /// Returns the number of entities actually deleted.
  /// Non-existent IDs are silently ignored.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// More efficient than multiple [delete] calls for many IDs.
  Future<int> deleteMultiple(List<ID> ids);
}

/// Upsert capability for entity storage.
///
/// **OPTIONAL CAPABILITY**
/// Implement this to support "create or update" semantics.
abstract class UpsertableEntityStorage<ID, T> implements EntityStorage<ID, T> {
  /// Creates or updates an entity.
  ///
  /// If entity ID exists: updates the existing entity.
  /// If entity ID doesn't exist: creates a new entity.
  ///
  /// Atomic operation - no race condition between check and insert/update.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageSpaceException] if insufficient space
  Future<void> upsert(T entity);

  /// Creates or updates multiple entities in a single operation.
  ///
  /// Combines create and update logic for all entities atomically.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageSpaceException] if insufficient space
  Future<void> upsertMultiple(List<T> entities);
}
