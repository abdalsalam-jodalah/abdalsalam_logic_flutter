// lib/src/storage/abstractions/entity_storage_comprehensive.dart

import 'dart:async';
import 'storage_interface.dart';
import 'query_comprehensive.dart';
import '../exceptions/storage_exceptions.dart';
import '../types/storage_metadata.dart';

/// Comprehensive entity-based storage abstraction.
///
/// **FULL-FEATURED INTERFACE** for entity (structured object) operations with:
/// - Full CRUD operations
/// - Batch operations
/// - Partial updates (field-level)
/// - Query support (via [QueryableStorage] capability)
/// - Entity metadata and versioning
/// - Change tracking
/// - Type safety
///
/// Generic types:
/// - [ID] - Primary key type (String, int, UUID, etc.)
/// - [T] - Entity type
///
/// All methods throw [StorageException] subclasses on errors.
///
/// Example:
/// ```dart
/// class User {
///   final String id;
///   final String name;
///   final int age;
///   User(this.id, this.name, this.age);
/// }
///
/// class UserStorage implements EntityStorage<String, User> {
///   @override
///   String getEntityId(User entity) => entity.id;
///
///   @override
///   Future<User?> get(String id) async {
///     // Fetch from database
///   }
/// }
/// ```
abstract class EntityStorage<ID, T> extends Storage {
  // ============================================================================
  // ID EXTRACTION
  // ============================================================================

  /// Extracts the ID from an entity.
  ///
  /// Must be implemented to define how to get the primary key from an entity.
  /// Used internally for all CRUD operations.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// String getEntityId(User user) => user.id;
  /// ```
  ID getEntityId(T entity);

  // ============================================================================
  // SINGLE OPERATIONS
  // ============================================================================

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
  /// - [StorageConstraintException] if ID already exists or constraints violated
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
  /// - [StorageConstraintException] if update violates constraints
  /// - [StorageSpaceException] if insufficient space
  Future<void> update(T entity);

  /// Creates or updates an entity (upsert).
  ///
  /// If entity ID exists: updates the existing entity.
  /// If entity ID doesn't exist: creates a new entity.
  ///
  /// Atomic operation - no race condition between check and insert/update.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageConstraintException] if constraints violated
  /// - [StorageSpaceException] if insufficient space
  Future<void> upsert(T entity);

  /// Deletes an entity by ID.
  ///
  /// Returns `true` if the entity existed and was deleted.
  /// Returns `false` if the entity didn't exist (no-op).
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageConstraintException] if deletion violates constraints (e.g., foreign key)
  Future<bool> delete(ID id);

  /// Checks if an entity with the given ID exists.
  ///
  /// Returns `true` if entity exists, `false` otherwise.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// More efficient than get(id) != null for some implementations.
  Future<bool> contains(ID id);

  // ============================================================================
  // PARTIAL UPDATES
  // ============================================================================

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
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageNotFoundException] if entity doesn't exist
  /// - [StorageConstraintException] if update violates constraints
  /// - [StorageUnsupportedException] if partial updates not supported
  ///
  /// Example:
  /// ```dart
  /// await storage.updatePartial(userId, {
  ///   'age': 25,
  ///   'email': 'new@example.com',
  /// });
  /// ```
  Future<void> updatePartial(ID id, Map<String, dynamic> updates);

  /// Increments a numeric field by a delta.
  ///
  /// Atomically increments the field value.
  /// Field must be numeric (int or double).
  ///
  /// Returns the new value after increment.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageNotFoundException] if entity doesn't exist
  /// - [StorageUnsupportedException] if atomic increment not supported
  ///
  /// Example:
  /// ```dart
  /// await storage.incrementField(userId, 'loginCount', 1);
  /// ```
  Future<num> incrementField(ID id, String field, num delta);

  // ============================================================================
  // BATCH OPERATIONS
  // ============================================================================

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
  /// - [StorageConstraintException] if any ID already exists or constraints violated
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
  /// - [StorageConstraintException] if any update violates constraints
  /// - [StorageSpaceException] if insufficient space
  ///
  /// More efficient than multiple [update] calls for many entities.
  Future<void> updateMultiple(List<T> entities);

  /// Creates or updates multiple entities in a single operation.
  ///
  /// Combines create and update logic for all entities atomically.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageConstraintException] if any operation violates constraints
  /// - [StorageSpaceException] if insufficient space
  ///
  /// More efficient than multiple [upsert] calls for many entities.
  Future<void> upsertMultiple(List<T> entities);

  /// Deletes multiple entities by IDs in a single operation.
  ///
  /// Returns the number of entities actually deleted.
  /// Non-existent IDs are silently ignored.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageConstraintException] if any deletion violates constraints
  ///
  /// More efficient than multiple [delete] calls for many IDs.
  Future<int> deleteMultiple(List<ID> ids);

  // ============================================================================
  // BULK RETRIEVAL
  // ============================================================================

  /// Gets all entities from storage.
  ///
  /// Returns a list of all stored entities.
  /// Order is not guaranteed unless storage explicitly maintains order.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// Warning: May be expensive for large datasets.
  /// Consider using queries with pagination for large collections.
  Future<List<T>> getAll();

  /// Gets a page of entities with offset and limit.
  ///
  /// Returns entities from [offset] up to [limit] count.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// More efficient than getAll() for large datasets.
  Future<List<T>> getPage(int offset, int limit);

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

  /// Checks if storage is empty.
  ///
  /// Returns `true` if no entities are stored.
  /// Returns `false` if at least one entity exists.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  Future<bool> isEmpty();

  // ============================================================================
  // ENTITY METADATA (Optional)
  // ============================================================================

  /// Gets metadata for an entity (timestamps, version, size, etc).
  ///
  /// Returns [EntityMetadata] if metadata is available.
  /// Returns `null` if entity doesn't exist or metadata not supported.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// Check [StorageMetadata.supportsEntityMetadata] before using.
  Future<EntityMetadata?> getEntityMetadata(ID id);

  // ============================================================================
  // STORAGE METADATA
  // ============================================================================

  /// Gets metadata about the storage implementation.
  ///
  /// Returns information about:
  /// - Storage type and version
  /// - Supported features and capabilities
  /// - Limits (max entities, max entity size)
  /// - Performance characteristics
  ///
  /// Returns `null` if metadata is unavailable.
  StorageMetadata? getStorageMetadata();
}

/// Metadata about an entity in storage.
///
/// Provides information about an entity beyond the entity data itself.
class EntityMetadata {
  /// Entity ID.
  final dynamic id;

  /// When the entity was created.
  final DateTime? createdAt;

  /// When the entity was last modified.
  final DateTime? modifiedAt;

  /// When the entity was last accessed (read).
  final DateTime? lastAccessedAt;

  /// Size of the entity in bytes.
  final int? sizeInBytes;

  /// Version number (for optimistic locking).
  final int? version;

  /// Entity tag (ETag) for HTTP-style caching.
  final String? etag;

  /// Custom metadata fields.
  final Map<String, dynamic> custom;

  const EntityMetadata({
    required this.id,
    this.createdAt,
    this.modifiedAt,
    this.lastAccessedAt,
    this.sizeInBytes,
    this.version,
    this.etag,
    this.custom = const {},
  });

  @override
  String toString() =>
      'EntityMetadata(id: $id, modified: $modifiedAt, version: $version)';
}

/// Optional capability for entity storages that support change watching.
///
/// **OPT-IN CAPABILITY**
/// Implement this to provide real-time notifications of entity changes.
abstract class WatchableEntityStorage<ID, T> implements EntityStorage<ID, T> {
  /// Creates a stream of changes for a specific entity.
  ///
  /// Stream emits:
  /// - [EntityChange] when the entity changes
  /// - `null` when the entity is deleted
  ///
  /// Stream continues until:
  /// - Storage is disposed
  /// - Subscription is cancelled
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  Stream<EntityChange<ID, T>?> watch(ID id);

  /// Creates a stream of all entity changes in storage.
  ///
  /// Stream emits [EntityChange] for any entity change.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  ///
  /// Warning: May be resource-intensive for large storages.
  Stream<EntityChange<ID, T>> watchAll();

  /// Creates a stream of entity changes matching a query.
  ///
  /// Stream emits [EntityChange] for entities matching the query.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageUnsupportedException] if query watching not supported
  Stream<EntityChange<ID, T>> watchQuery(EntityQuery<T> query);
}

/// Represents a change to an entity.
class EntityChange<ID, T> {
  /// The entity ID that changed.
  final ID id;

  /// The new entity value (null if deleted).
  final T? newEntity;

  /// The previous entity value (null if newly created).
  final T? oldEntity;

  /// The type of change.
  final EntityChangeType type;

  /// When the change occurred.
  final DateTime timestamp;

  /// Fields that changed (for updates).
  final Set<String>? changedFields;

  EntityChange({
    required this.id,
    required this.newEntity,
    required this.oldEntity,
    required this.type,
    DateTime? timestamp,
    this.changedFields,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Whether this change represents a creation.
  bool get isCreated => type == EntityChangeType.created;

  /// Whether this change represents an update.
  bool get isUpdated => type == EntityChangeType.updated;

  /// Whether this change represents a deletion.
  bool get isDeleted => type == EntityChangeType.deleted;

  @override
  String toString() => 'EntityChange($type: $id)';
}

/// Type of change to an entity.
enum EntityChangeType {
  /// A new entity was created.
  created,

  /// An existing entity was updated.
  updated,

  /// An entity was deleted.
  deleted,
}

/// Optional capability for entity storages that support optimistic locking.
///
/// **OPT-IN CAPABILITY**
/// Implement this for storages that track entity versions for concurrency control.
abstract class VersionedEntityStorage<ID, T> implements EntityStorage<ID, T> {
  /// Updates an entity only if the version matches.
  ///
  /// Prevents lost updates in concurrent scenarios.
  /// Version must match the current entity version in storage.
  ///
  /// Returns `true` if update succeeded (version matched).
  /// Returns `false` if update failed (version mismatch - concurrent modification).
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageNotFoundException] if entity doesn't exist
  /// - [StorageOperationException] if operation fails
  ///
  /// Example:
  /// ```dart
  /// final user = await storage.get(userId);
  /// final metadata = await storage.getMetadata(userId);
  /// final currentVersion = metadata?.version ?? 0;
  ///
  /// user.age = 26;
  /// final success = await storage.updateWithVersion(user, currentVersion);
  /// if (!success) {
  ///   // Someone else modified the entity, reload and retry
  /// }
  /// ```
  Future<bool> updateWithVersion(T entity, int expectedVersion);

  /// Gets an entity with its current version.
  ///
  /// Returns a tuple of [entity, version].
  /// Returns `null` if entity doesn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  Future<VersionedEntity<T>?> getWithVersion(ID id);
}

/// An entity bundled with its version number.
class VersionedEntity<T> {
  /// The entity data.
  final T entity;

  /// The version number.
  final int version;

  const VersionedEntity(this.entity, this.version);

  @override
  String toString() => 'VersionedEntity(version: $version)';
}

/// Optional capability for deleting entities by predicate.
///
/// **OPT-IN CAPABILITY**
/// Implement this for storages that support predicate-based deletion.
abstract class PredicateDeletableStorage<ID, T> implements EntityStorage<ID, T> {
  /// Deletes all entities matching a predicate.
  ///
  /// Returns the number of entities deleted.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageConstraintException] if deletion violates constraints
  ///
  /// Warning: This operation may be slow for large datasets.
  /// Consider using queries instead for better performance.
  ///
  /// Example:
  /// ```dart
  /// final count = await storage.deleteWhere((user) => user.age < 18);
  /// ```
  Future<int> deleteWhere(bool Function(T entity) predicate);
}
