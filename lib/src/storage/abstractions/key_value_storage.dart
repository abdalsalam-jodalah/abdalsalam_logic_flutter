// lib/src/storage/abstractions/key_value_storage.dart

import 'storage_interface.dart';
import '../exceptions/storage_exceptions.dart';

/// Abstraction for key-value storage.
///
/// Supports storing and retrieving typed values by string keys.
/// Implements [Storage] base contract.
///
/// Responsibilities:
/// - Store and retrieve values by key
/// - Type-safe get/set operations
/// - Atomic get/set semantics
/// - Support for null values (if applicable)
///
/// Supported value types depend on implementation:
/// - Primitives: String, int, double, bool
/// - Collections: List<T>, Map<String, T>
/// - Custom types via serialization
///
/// Generic type [T] specifies the value type this storage holds.
/// Use [dynamic] for storage that holds multiple types.
///
/// Example:
/// ```dart
/// abstract class KeyValueStorage<T> extends Storage {
///   Future<T?> get(String key);
///   Future<void> set(String key, T value);
///   Future<bool> delete(String key);
/// }
/// ```
abstract class KeyValueStorage<T> extends Storage {
  /// Gets a value by key.
  ///
  /// Returns the stored value if the key exists.
  /// Returns `null` if the key doesn't exist (and null is allowed).
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if get operation fails
  /// - [StorageNotFoundException] if key doesn't exist and null is not allowed
  /// - Type casting error if value type doesn't match [T]
  Future<T?> get(String key);

  /// Gets multiple values by keys in a single operation.
  ///
  /// Returns a map of keys to values.
  /// Missing keys are omitted from the result (not included with null value).
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// May be more efficient than multiple [get] calls.
  /// Implementations should batch the operation when possible.
  Future<Map<String, T>> getMultiple(List<String> keys);

  /// Gets all key-value pairs from storage.
  ///
  /// Returns a complete map of all stored data.
  /// May be expensive for large datasets.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  Future<Map<String, T>> getAll();

  /// Sets a value for the given key.
  ///
  /// If the key already exists, the value is overwritten.
  /// Atomic operation - either the entire value is set or nothing.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if set operation fails
  /// - [StorageSpaceException] if insufficient storage space
  /// - [StorageConstraintException] if value violates constraints
  /// - Type error if [value] is not of type [T]
  Future<void> set(String key, T value);

  /// Sets multiple values in a single operation.
  ///
  /// All key-value pairs are set atomically.
  /// Existing keys are overwritten.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageSpaceException] if insufficient storage space
  ///
  /// May be more efficient than multiple [set] calls.
  /// Implementations should batch the operation when possible.
  Future<void> setMultiple(Map<String, T> entries);

  /// Deletes a value by key.
  ///
  /// Returns `true` if the key existed and was deleted.
  /// Returns `false` if the key didn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if delete operation fails
  Future<bool> delete(String key);

  /// Deletes multiple values by keys.
  ///
  /// Returns the number of keys that were actually deleted.
  /// Non-existent keys are silently ignored.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// May be more efficient than multiple [delete] calls.
  Future<int> deleteMultiple(List<String> keys);

  /// Checks if a key exists in storage.
  ///
  /// Returns `true` if the key exists, `false` otherwise.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  Future<bool> contains(String key);

  /// Gets all keys in storage.
  ///
  /// Returns a list of all keys currently stored.
  /// May be empty if storage has no entries.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  Future<List<String>> getAllKeys();

  /// Deletes entries matching a predicate.
  ///
  /// Iterates through all entries and deletes those where [predicate]
  /// returns `true` for the value.
  ///
  /// Returns the number of entries that were deleted.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// Note: This operation may be slow for large datasets.
  /// Consider implementing custom deletion logic for better performance.
  Future<int> deleteWhere(bool Function(T value) predicate);

  /// Gets the number of entries in storage.
  ///
  /// Returns the count of stored key-value pairs.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  Future<int> count();

  /// Gets an entry with metadata.
  ///
  /// Returns the value along with information like:
  /// - Last access time
  /// - Last modified time
  /// - Storage size
  ///
  /// Returns `null` if key doesn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or is disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageUnsupportedException] if metadata is not supported
  Future<KeyValueEntry<T>?> getWithMetadata(String key);
}

/// A key-value entry with optional metadata.
class KeyValueEntry<T> {
  /// The key.
  final String key;

  /// The value.
  final T value;

  /// When this entry was last read.
  final DateTime? lastAccessTime;

  /// When this entry was last modified.
  final DateTime? lastModifiedTime;

  /// Size of the value in bytes, if known.
  final int? sizeInBytes;

  /// Additional metadata as key-value pairs.
  final Map<String, dynamic> metadata;

  KeyValueEntry({
    required this.key,
    required this.value,
    this.lastAccessTime,
    this.lastModifiedTime,
    this.sizeInBytes,
    this.metadata = const {},
  });

  @override
  String toString() =>
      'KeyValueEntry(key: $key, modified: $lastModifiedTime, size: $sizeInBytes bytes)';
}
