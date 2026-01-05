// lib/src/storage/abstractions/key_value_storage_minimal.dart

import 'storage_interface.dart';
import '../exceptions/storage_exceptions.dart';

/// Minimal key-value storage abstraction.
///
/// **THIN INTERFACE** - Only essential key-value operations.
/// Stores and retrieves typed values by string keys.
///
/// Core responsibilities:
/// - Get/set values by key
/// - Delete values by key
/// - Check key existence
/// - Type-safe operations
///
/// Generic type [T] specifies the value type:
/// - Use concrete type for type-safe storage: `KeyValueStorage<String>`
/// - Use `dynamic` for mixed-type storage: `KeyValueStorage<dynamic>`
///
/// Implementations decide:
/// - Serialization strategy
/// - Null value handling
/// - Value size limits
///
/// Example:
/// ```dart
/// // String storage
/// class PreferencesStorage implements KeyValueStorage<String> {
///   @override
///   Future<String?> get(String key) async {
///     return prefs.getString(key);
///   }
///
///   @override
///   Future<void> set(String key, String value) async {
///     await prefs.setString(key, value);
///   }
/// }
/// ```
abstract class KeyValueStorage<T> extends Storage {
  /// Gets a value by key.
  ///
  /// Returns the stored value if the key exists.
  /// Returns `null` if the key doesn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  Future<T?> get(String key);

  /// Sets a value for the given key.
  ///
  /// Creates a new entry if key doesn't exist.
  /// Overwrites existing value if key exists.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageSpaceException] if insufficient space
  /// - [StorageConstraintException] if value violates constraints (e.g., size limit)
  Future<void> set(String key, T value);

  /// Deletes a value by key.
  ///
  /// Returns `true` if the key existed and was deleted.
  /// Returns `false` if the key didn't exist (no-op).
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  Future<bool> delete(String key);

  /// Checks if a key exists in storage.
  ///
  /// Returns `true` if the key exists (regardless of value).
  /// Returns `false` if the key doesn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  Future<bool> contains(String key);

  /// Gets all keys currently in storage.
  ///
  /// Returns a list of all key strings.
  /// Order is not guaranteed.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// Note: May be expensive for large datasets.
  Future<List<String>> keys();
}

/// Batch operations capability for key-value storage.
///
/// **OPTIONAL CAPABILITY**
/// Implement this for efficient batch operations on key-value storage.
abstract class BatchKeyValueStorage<T> implements KeyValueStorage<T> {
  /// Gets multiple values by keys in a single operation.
  ///
  /// Returns a map of keys to values.
  /// Missing keys are omitted from the result.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// More efficient than multiple [get] calls for many keys.
  Future<Map<String, T>> getMultiple(List<String> keys);

  /// Sets multiple key-value pairs in a single operation.
  ///
  /// All entries are set atomically (where supported).
  /// Existing keys are overwritten.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageSpaceException] if insufficient space
  ///
  /// More efficient than multiple [set] calls for many entries.
  Future<void> setMultiple(Map<String, T> entries);

  /// Deletes multiple keys in a single operation.
  ///
  /// Returns the number of keys that were actually deleted.
  /// Non-existent keys are silently ignored.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// More efficient than multiple [delete] calls for many keys.
  Future<int> deleteMultiple(List<String> keys);
}
