// lib/src/storage/abstractions/key_value_storage_comprehensive.dart

import 'dart:async';
import 'storage_interface.dart';
import '../exceptions/storage_exceptions.dart';
import '../types/storage_metadata.dart';

/// Comprehensive key-value storage abstraction.
///
/// **FULL-FEATURED INTERFACE** for key-value operations with:
/// - Basic CRUD (get, set, delete)
/// - Batch operations
/// - Type safety with generics
/// - Key enumeration and search
/// - Value metadata
/// - Change notifications (optional)
///
/// Generic type [T] specifies the value type:
/// - Use concrete type for type-safe storage: `KeyValueStorage<String>`
/// - Use `Object` for mixed-type storage: `KeyValueStorage<Object>`
///
/// All methods throw [StorageException] subclasses on errors.
///
/// Example:
/// ```dart
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
  // ============================================================================
  // SINGLE OPERATIONS
  // ============================================================================

  /// Gets a value by key.
  ///
  /// Returns the stored value if the key exists.
  /// Returns `null` if the key doesn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  Future<T?> get(String key);

  /// Gets a value by key with a default fallback.
  ///
  /// Returns the stored value if the key exists.
  /// Returns [defaultValue] if the key doesn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  Future<T> getOrDefault(String key, T defaultValue) async {
    final value = await get(key);
    return value ?? defaultValue;
  }

  /// Sets a value for the given key.
  ///
  /// Creates a new entry if key doesn't exist.
  /// Overwrites existing value if key exists.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageSpaceException] if insufficient space
  /// - [StorageConstraintException] if value violates constraints
  Future<void> set(String key, T value);

  /// Sets a value only if the key doesn't already exist.
  ///
  /// Returns `true` if the value was set (key didn't exist).
  /// Returns `false` if the value was not set (key already exists).
  ///
  /// Atomic operation - no race condition.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageSpaceException] if insufficient space
  Future<bool> setIfAbsent(String key, T value);

  /// Sets a value only if the key already exists.
  ///
  /// Returns `true` if the value was updated (key existed).
  /// Returns `false` if the value was not set (key didn't exist).
  ///
  /// Atomic operation - no race condition.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageSpaceException] if insufficient space
  Future<bool> setIfPresent(String key, T value);

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

  // ============================================================================
  // BATCH OPERATIONS
  // ============================================================================

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

  // ============================================================================
  // KEY ENUMERATION
  // ============================================================================

  /// Gets all keys currently in storage.
  ///
  /// Returns a list of all key strings.
  /// Order is not guaranteed unless storage explicitly maintains order.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// Note: May be expensive for large datasets.
  Future<List<String>> keys();

  /// Gets all key-value pairs from storage.
  ///
  /// Returns a complete map of all stored data.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// Note: May be expensive for large datasets.
  Future<Map<String, T>> getAll();

  /// Gets the total count of keys in storage.
  ///
  /// Returns the number of stored keys.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// More efficient than keys().length for large datasets.
  Future<int> count();

  /// Checks if storage is empty.
  ///
  /// Returns `true` if no keys are stored.
  /// Returns `false` if at least one key exists.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// More efficient than count() == 0 for some implementations.
  Future<bool> isEmpty();

  // ============================================================================
  // KEY SEARCH & FILTERING
  // ============================================================================

  /// Gets all keys matching a prefix.
  ///
  /// Returns keys where key.startsWith(prefix) is true.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageUnsupportedException] if prefix search not supported
  Future<List<String>> keysWithPrefix(String prefix);

  /// Gets all keys matching a pattern.
  ///
  /// Pattern syntax depends on implementation (glob, regex, etc).
  /// Check [StorageMetadata.supportsKeyPattern] before using.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageUnsupportedException] if pattern matching not supported
  Future<List<String>> keysMatching(String pattern);

  // ============================================================================
  // VALUE METADATA (Optional)
  // ============================================================================

  /// Gets metadata for a key (size, timestamps, version, etc).
  ///
  /// Returns [KeyValueMetadata] if metadata is available.
  /// Returns `null` if key doesn't exist or metadata not supported.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  ///
  /// Check [StorageMetadata.supportsValueMetadata] before using.
  Future<KeyValueMetadata?> getKeyMetadata(String key);

  // ============================================================================
  // STORAGE METADATA
  // ============================================================================

  /// Gets metadata about the storage implementation.
  ///
  /// Returns information about:
  /// - Storage type and version
  /// - Supported features and capabilities
  /// - Limits (max key size, max value size, max keys)
  /// - Performance characteristics
  ///
  /// Returns `null` if metadata is unavailable.
  StorageMetadata? getStorageMetadata();
}

/// Metadata about a key-value entry.
///
/// Provides information about a stored value beyond the value itself.
class KeyValueMetadata {
  /// The key this metadata describes.
  final String key;

  /// Size of the value in bytes.
  final int? sizeInBytes;

  /// When the entry was created.
  final DateTime? createdAt;

  /// When the entry was last modified.
  final DateTime? modifiedAt;

  /// When the entry was last accessed (read).
  final DateTime? lastAccessedAt;

  /// Version number for optimistic locking.
  final int? version;

  /// Time-to-live (TTL) expiration time.
  final DateTime? expiresAt;

  /// Custom metadata fields.
  final Map<String, dynamic> custom;

  const KeyValueMetadata({
    required this.key,
    this.sizeInBytes,
    this.createdAt,
    this.modifiedAt,
    this.lastAccessedAt,
    this.version,
    this.expiresAt,
    this.custom = const {},
  });

  /// Whether this entry has expired (based on TTL).
  bool get isExpired {
    final expires = expiresAt;
    return expires != null && DateTime.now().isAfter(expires);
  }

  @override
  String toString() =>
      'KeyValueMetadata(key: $key, size: $sizeInBytes, modified: $modifiedAt)';
}

/// Optional capability for key-value storages that support change watching.
///
/// **OPT-IN CAPABILITY**
/// Implement this to provide real-time notifications of storage changes.
abstract class WatchableKeyValueStorage<T> implements KeyValueStorage<T> {
  /// Creates a stream of changes for a specific key.
  ///
  /// Stream emits:
  /// - [KeyValueChange] when the key's value changes
  /// - `null` when the key is deleted
  ///
  /// Stream continues until:
  /// - Storage is disposed
  /// - Subscription is cancelled
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  Stream<KeyValueChange<T>?> watch(String key);

  /// Creates a stream of changes for all keys matching a prefix.
  ///
  /// Stream emits [KeyValueChange] for any key change under the prefix.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  Stream<KeyValueChange<T>> watchPrefix(String prefix);

  /// Creates a stream of all storage changes.
  ///
  /// Stream emits [KeyValueChange] for any key change in the storage.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  ///
  /// Warning: May be resource-intensive for large storages.
  Stream<KeyValueChange<T>> watchAll();
}

/// Represents a change to a key-value entry.
class KeyValueChange<T> {
  /// The key that changed.
  final String key;

  /// The new value (null if deleted).
  final T? newValue;

  /// The previous value (null if newly created).
  final T? oldValue;

  /// The type of change.
  final KeyValueChangeType type;

  /// When the change occurred.
  final DateTime timestamp;

  KeyValueChange({
    required this.key,
    required this.newValue,
    required this.oldValue,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Whether this change represents a creation.
  bool get isCreated => type == KeyValueChangeType.created;

  /// Whether this change represents an update.
  bool get isUpdated => type == KeyValueChangeType.updated;

  /// Whether this change represents a deletion.
  bool get isDeleted => type == KeyValueChangeType.deleted;

  @override
  String toString() => 'KeyValueChange($type: $key)';
}

/// Type of change to a key-value entry.
enum KeyValueChangeType {
  /// A new key was created.
  created,

  /// An existing key's value was updated.
  updated,

  /// A key was deleted.
  deleted,
}

/// Optional capability for key-value storages that support expiration (TTL).
///
/// **OPT-IN CAPABILITY**
/// Implement this for storages that can automatically expire entries.
abstract class ExpirableKeyValueStorage<T> implements KeyValueStorage<T> {
  /// Sets a value with automatic expiration.
  ///
  /// Entry will be automatically deleted after [duration].
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  /// - [StorageSpaceException] if insufficient space
  Future<void> setWithExpiration(String key, T value, Duration duration);

  /// Sets expiration time for an existing key.
  ///
  /// Returns `true` if expiration was set (key exists).
  /// Returns `false` if key doesn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if operation fails
  Future<bool> setExpiration(String key, Duration duration);

  /// Gets the remaining time until expiration.
  ///
  /// Returns [Duration] until expiration.
  /// Returns `null` if key doesn't exist or has no expiration.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  Future<Duration?> getTimeToLive(String key);

  /// Removes expiration from a key (makes it persist indefinitely).
  ///
  /// Returns `true` if expiration was removed (key exists).
  /// Returns `false` if key doesn't exist.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  Future<bool> removeExpiration(String key);
}
