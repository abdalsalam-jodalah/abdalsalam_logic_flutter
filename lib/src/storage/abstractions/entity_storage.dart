// lib/src/storage/abstractions/entity_storage.dart

import 'storage_interface.dart';
import 'query.dart';
import '../exceptions/storage_exceptions.dart';

/// Abstraction for entity-based structured storage.
///
/// Stores and retrieves typed entities (objects) with:
/// - Type safety
/// - Structured queries
/// - Relationships (if supported)
/// - Schema/migration support
///
/// Implements [Storage] base contract.
///
/// Generic types:
/// - [ID] - Primary key type (usually String, int, or UUID)
/// - [T] - Entity type
///
/// Responsibilities:
/// - CRUD operations on entities
/// - Querying and filtering
/// - Relationship management (if applicable)
/// - Schema versioning (if applicable)
///
/// Example:
/// ```dart
/// abstract class EntityStorage<ID, T> extends Storage {
///   Future<T?> get(ID id);
///   Future<void> create(T entity);
///   Future<void> update(T entity);
///   Future<bool> delete(ID id);
///   Future<EntityQuery<T>> query();
/// }
/// ```
abstract class EntityStorage<ID, T> extends Storage {
  /// Gets the primary key value from an entity.
  ///
  /// Must be implemented by subclasses to extract the ID from an entity.
  /// Used for CRUD operations and relationship management.
  ID getEntityId(T entity);

  /// Creates a copy of the entity with updated fields (shallow copy).
  ///
  /// Default implementation uses reflection or must be overridden.
  /// Used internally for update operations.
  T copyWithId(T entity, ID newId);

  /// Gets an entity by ID.
  ///
  /// Returns the entity if found.
  /// Returns `null` if the entity doesn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageNotFoundException] if ID doesn't exist (optional, depends on implementation)
  Future<T?> get(ID id);

  /// Gets multiple entities by IDs.
  ///
  /// Returns a list of entities found. Missing IDs are omitted.
  /// Results order is not guaranteed to match input order.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// May be more efficient than multiple [get] calls.
  Future<List<T>> getMultiple(List<ID> ids);

  /// Gets all entities from storage.
  ///
  /// Returns a complete list of all stored entities.
  /// May be expensive for large datasets.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  Future<List<T>> getAll();

  /// Creates a new entity in storage.
  ///
  /// Inserts the entity with its ID as the primary key.
  /// Entity must have a valid, unique ID.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if creation fails
  /// - [StorageConstraintException] if ID already exists or other constraints violated
  /// - [StorageSpaceException] if insufficient storage space
  Future<void> create(T entity);

  /// Creates multiple entities in a single operation.
  ///
  /// All entities are inserted atomically.
  /// All IDs must be unique.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageConstraintException] if any ID already exists
  /// - [StorageSpaceException] if insufficient storage space
  ///
  /// May be more efficient than multiple [create] calls.
  /// Implementations should batch the operation when possible.
  Future<void> createMultiple(List<T> entities);

  /// Updates an entity in storage.
  ///
  /// The entity must already exist (ID must match an existing entity).
  /// Replaces all fields of the existing entity.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageNotFoundException] if entity doesn't exist
  /// - [StorageConstraintException] if update violates constraints
  /// - [StorageSpaceException] if insufficient storage space
  Future<void> update(T entity);

  /// Updates multiple entities in a single operation.
  ///
  /// All updates are applied atomically.
  /// All entities must already exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageNotFoundException] if any entity doesn't exist
  /// - [StorageConstraintException] if any update violates constraints
  /// - [StorageSpaceException] if insufficient storage space
  ///
  /// May be more efficient than multiple [update] calls.
  Future<void> updateMultiple(List<T> entities);

  /// Updates only specific fields of an entity.
  ///
  /// Partial update - only fields in [updates] map are modified.
  /// Other fields remain unchanged.
  /// The entity must already exist.
  ///
  /// Parameters:
  /// - [id] - The entity ID
  /// - [updates] - Map of field names to new values
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageNotFoundException] if entity doesn't exist
  /// - [StorageConstraintException] if update violates constraints
  /// - [StorageSpaceException] if insufficient storage space
  /// - [StorageUnsupportedException] if partial updates are not supported
  Future<void> updateFields(ID id, Map<String, dynamic> updates);

  /// Creates entity if doesn't exist, updates if it does (upsert).
  ///
  /// Atomically inserts or updates the entity.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageConstraintException] if upsert violates constraints
  /// - [StorageSpaceException] if insufficient storage space
  /// - [StorageUnsupportedException] if upsert is not supported
  Future<void> createOrUpdate(T entity);

  /// Deletes an entity by ID.
  ///
  /// Returns `true` if the entity was deleted.
  /// Returns `false` if the entity didn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if deletion fails
  /// - [StorageConstraintException] if deletion violates constraints (foreign keys)
  Future<bool> delete(ID id);

  /// Deletes multiple entities by IDs.
  ///
  /// Returns the number of entities actually deleted.
  /// Non-existent IDs are silently ignored.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageConstraintException] if deletion violates constraints
  ///
  /// May be more efficient than multiple [delete] calls.
  Future<int> deleteMultiple(List<ID> ids);

  /// Deletes entities matching a predicate.
  ///
  /// Iterates through all entities and deletes those where [predicate]
  /// returns `true`.
  ///
  /// Returns the number of entities deleted.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageConstraintException] if deletion violates constraints
  ///
  /// Note: This operation may be slow for large datasets.
  /// Consider implementing efficient filters in [query] instead.
  Future<int> deleteWhere(bool Function(T entity) predicate);

  /// Gets the number of entities in storage.
  ///
  /// Returns the total count of stored entities.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  Future<int> count();

  /// Checks if an entity with the given ID exists.
  ///
  /// Returns `true` if entity exists, `false` otherwise.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  Future<bool> contains(ID id);

  /// Creates a query builder for advanced queries.
  ///
  /// Returns an [EntityQuery<T>] that supports:
  /// - Filtering with conditions
  /// - Sorting by fields
  /// - Pagination
  /// - Projection (field selection)
  /// - Aggregations
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageUnsupportedException] if queries are not supported
  ///
  /// Example:
  /// ```dart
  /// final results = await storage
  ///     .query()
  ///     .where(QueryFilter.equals('status', 'active'))
  ///     .orderBy(QuerySort.descending('createdAt'))
  ///     .paginate(QueryPagination.page(pageNumber: 1))
  ///     .execute();
  /// ```
  Future<EntityQuery<T>> query();

  /// Executes a raw query in the native backend language.
  ///
  /// Direct access to backend query capabilities (SQL, etc).
  /// Implementation-specific behavior.
  ///
  /// Parameters:
  /// - [rawQuery] - Backend-specific query string
  /// - [parameters] - Query parameters (if supported)
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if query fails
  /// - [StorageUnsupportedException] if raw queries are not supported
  ///
  /// Note: Use with caution. Raw queries bypass abstraction safety.
  Future<List<T>> queryRaw(
    String rawQuery, {
    Map<String, dynamic>? parameters,
  });

  /// Gets entities modified after a certain date.
  ///
  /// Useful for sync operations.
  /// Returns entities where lastModified > [since].
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageUnsupportedException] if metadata tracking is not supported
  Future<List<T>> getModifiedSince(DateTime since);

  /// Checks whether the storage schema exists and is compatible.
  ///
  /// Implementations may use this to validate schema compatibility
  /// without expensive operations.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageCorruptionException] if schema is corrupt or incompatible
  /// - [StorageOperationException] if validation fails
  Future<bool> validateSchema();

  /// Gets the storage schema version.
  ///
  /// Useful for migration detection.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageUnsupportedException] if schema versioning is not supported
  Future<int> getSchemaVersion();
}

/// Metadata about an entity in storage.
class EntityMetadata {
  /// Entity ID.
  final dynamic id;

  /// When the entity was created.
  final DateTime? createdAt;

  /// When the entity was last modified.
  final DateTime? modifiedAt;

  /// Size of the entity in bytes.
  final int? sizeInBytes;

  /// Version number (for optimistic locking).
  final int? version;

  /// Additional metadata.
  final Map<String, dynamic> custom;

  EntityMetadata({
    required this.id,
    this.createdAt,
    this.modifiedAt,
    this.sizeInBytes,
    this.version,
    this.custom = const {},
  });

  @override
  String toString() =>
      'EntityMetadata(id: $id, modified: $modifiedAt, version: $version)';
}
