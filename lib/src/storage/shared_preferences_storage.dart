// lib/src/storage/shared_preferences_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'abstractions/key_value_storage_comprehensive.dart';
import 'types/storage_metadata.dart';
import 'exceptions/storage_exceptions.dart';
import 'implementations/batch_operations_mixin.dart';
import 'implementations/watchable_storage_mixin.dart'
    hide KeyValueChange, KeyValueChangeType;
import 'implementations/expirable_storage_mixin.dart';

class SharedPreferencesStorage extends KeyValueStorage<dynamic>
    with
        BatchKeyValueOperationsMixin,
        WatchableKeyValueStorageMixin,
        ExpirableKeyValueStorageMixin {
  SharedPreferences? _prefs;
  bool _initialized = false;
  bool _disposed = false;

  SharedPreferencesStorage();

  @override
  bool get isInitialized => _initialized;

  @override
  bool get isDisposed => _disposed;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;

    await disposeWatchable();
    await disposeExpirable();
    _prefs = null;
    _disposed = true;
    _initialized = false;
  }

  @override
  Future<void> clear() async {
    try {
      if (_prefs == null) {
        throw Exception('SharedPreferences not initialized');
      }
      await _prefs!.clear();
    } catch (e) {
      rethrow;
    }
  }

  @override
  StorageMetadata? getMetadata() {
    return null;
  }

  @override
  StorageMetadata? getStorageMetadata() {
    return null;
  }

  @override
  Future<dynamic> get(String key) async {
    try {
      if (_prefs == null) {
        throw Exception('SharedPreferences not initialized');
      }

      final expired = isExpired(key);
      if (expired) {
        await delete(key);
        return null;
      }

      // Try each type
      final stringVal = _prefs!.getString(key);
      if (stringVal != null) return stringVal;

      final intVal = _prefs!.getInt(key);
      if (intVal != null) return intVal;

      final doubleVal = _prefs!.getDouble(key);
      if (doubleVal != null) return doubleVal;

      final boolVal = _prefs!.getBool(key);
      if (boolVal != null) return boolVal;

      final listVal = _prefs!.getStringList(key);
      if (listVal != null) return listVal;

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> set(String key, dynamic value) async {
    try {
      if (_prefs == null) {
        throw Exception('SharedPreferences not initialized');
      }

      final oldValue = await get(key);

      if (value is String) {
        await _prefs!.setString(key, value);
      } else if (value is int) {
        await _prefs!.setInt(key, value);
      } else if (value is double) {
        await _prefs!.setDouble(key, value);
      } else if (value is bool) {
        await _prefs!.setBool(key, value);
      } else if (value is List<String>) {
        await _prefs!.setStringList(key, value);
      }

      emitKeyValueChanged(key, value, oldValue);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> delete(String key) async {
    try {
      if (_prefs == null) {
        throw Exception('SharedPreferences not initialized');
      }

      final oldValue = await get(key);
      final result = await _prefs!.remove(key);

      if (result) {
        // Remove expiration metadata
        await _prefs!.remove('$key:expiry');
        emitKeyValueDeleted(key, oldValue);
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> contains(String key) async {
    try {
      if (_prefs == null) {
        throw Exception('SharedPreferences not initialized');
      }

      if (!_prefs!.containsKey(key)) return false;

      final expired = isExpired(key);
      if (expired) {
        await delete(key);
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getKeys() async {
    try {
      if (_prefs == null) {
        throw Exception('SharedPreferences not initialized');
      }
      return _prefs!.getKeys().toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getAll() async {
    try {
      if (_prefs == null) {
        throw Exception('SharedPreferences not initialized');
      }

      final Map<String, dynamic> result = {};
      for (final key in _prefs!.getKeys()) {
        final expired = isExpired(key);
        if (!expired) {
          result[key] = _prefs!.get(key);
        } else {
          await delete(key);
        }
      }
      return result;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<int> count() async {
    final keys = await getKeys();
    return keys.length;
  }

  @override
  Future<Map<String, dynamic>> getMultiple(List<String> keys) async {
    return await getMultipleBatch<dynamic>(keys);
  }

  @override
  Future<void> setMultiple(Map<String, dynamic> entries) async {
    await setMultipleBatch<dynamic>(entries);
  }

  Future<int> removeMultiple(List<String> keys) async {
    return await removeMultipleBatch(keys);
  }

  Stream<KeyValueChange<dynamic>?> watchKey(String key) {
    return watchKeyValue(key).map(
      (change) => change == null
          ? null
          : KeyValueChange<dynamic>(
              key: change.key,
              newValue: change.newValue,
              oldValue: change.oldValue,
              type: _mapChangeType(change.type),
            ),
    );
  }

  Stream<KeyValueChange<dynamic>> watchAll() {
    return watchAllKeyValues().map(
      (change) => KeyValueChange<dynamic>(
        key: change.key,
        newValue: change.newValue,
        oldValue: change.oldValue,
        type: _mapChangeType(change.type),
      ),
    );
  }

  Stream<KeyValueChange<dynamic>> watchPrefix(String prefix) {
    return watchKeyValuePrefix(prefix).map(
      (change) => KeyValueChange<dynamic>(
        key: change.key,
        newValue: change.newValue,
        oldValue: change.oldValue,
        type: _mapChangeType(change.type),
      ),
    );
  }

  KeyValueChangeType _mapChangeType(dynamic mixinType) {
    final typeStr = mixinType.toString();
    if (typeStr.contains('created')) {
      return KeyValueChangeType.created;
    } else if (typeStr.contains('deleted')) {
      return KeyValueChangeType.deleted;
    } else {
      return KeyValueChangeType.updated;
    }
  }

  Future<void> setWithExpiration<T>(
    String key,
    T value,
    Duration expiration,
  ) async {
    await setKeyWithExpiration(key, value, expiration);
  }

  Future<Duration?> getTimeToLive(String key) async {
    return await getKeyTimeToLive(key);
  }

  @override
  Future<bool> setIfAbsent(String key, dynamic value) async {
    if (!await contains(key)) {
      await set(key, value);
      return true;
    }
    return false;
  }

  @override
  Future<bool> setIfPresent(String key, dynamic value) async {
    if (await contains(key)) {
      await set(key, value);
      return true;
    }
    return false;
  }

  @override
  Future<int> deleteMultiple(List<String> keys) async {
    return await removeMultiple(keys);
  }

  @override
  Future<List<String>> keys() async {
    return await getKeys();
  }

  @override
  Future<bool> isEmpty() async {
    return (await count()) == 0;
  }

  @override
  Future<List<String>> keysWithPrefix(String prefix) async {
    final allKeys = await keys();
    return allKeys.where((key) => key.startsWith(prefix)).toList();
  }

  @override
  Future<List<String>> keysMatching(String pattern) async {
    throw StorageUnsupportedException(
      operation: 'keysMatching',
      message: 'Pattern matching not supported by SharedPreferences',
    );
  }

  @override
  Future<KeyValueMetadata?> getKeyMetadata(String key) async {
    return null; // SharedPreferences doesn't support metadata
  }

  Future<bool> removeExpiration(String key) async {
    if (_prefs == null) return false;
    return await _prefs!.remove('$key:expiry');
  }
}
