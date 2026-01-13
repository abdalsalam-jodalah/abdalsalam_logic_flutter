// lib/src/storage/implementations/predicate_deletable_mixin.dart

import '../abstractions/entity_storage_comprehensive.dart';
import '../exceptions/storage_exceptions.dart';

/// Mixin providing predicate-based deletion capability.
///
/// Allows deleting entities that match a predicate function.
mixin PredicateDeletableMixin<ID, T>
    implements PredicateDeletableStorage<ID, T> {
  @override
  Future<int> deleteWhere(bool Function(T entity) predicate) async {
    try {
      // Get all entities
      final allEntities = await getAll();

      int deletedCount = 0;

      // Find entities matching predicate and delete them
      for (final entity in allEntities) {
        if (predicate(entity)) {
          final id = extractId(entity);
          final deleted = await delete(id);
          if (deleted) {
            deletedCount++;
          }
        }
      }

      return deletedCount;
    } catch (e) {
      throw StorageOperationException(operation: 'storage', message: 'Failed to delete entities: $e');
    }
  }

  /// Extract ID from entity.
  /// Must be implemented by the storage class.
  ID extractId(T entity);

  /// Get all entities.
  /// Must be available from EntityStorage interface.
  Future<List<T>> getAll();

  /// Delete entity by ID.
  /// Must be available from EntityStorage interface.
  Future<bool> delete(ID id);
}
