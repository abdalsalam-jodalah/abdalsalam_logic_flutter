// lib/src/core/interfaces/repository_interface.dart
abstract class RepositoryInterface<T> {
  Future<T?> get(String id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(String id);
  Future<void> clear();
}

