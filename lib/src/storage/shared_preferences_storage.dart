// lib/src/storage/shared_preferences_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../logging/logger_service.dart';
import 'storage_service.dart';

class SharedPreferencesStorage implements StorageService {
  final LoggerService _logger;
  SharedPreferences? _prefs;

  SharedPreferencesStorage(this._logger);

  @override
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _logger.info('SharedPreferences storage initialized');
    } catch (e) {
      _logger.error('Failed to initialize SharedPreferences', error: e);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    _prefs = null;
  }

  @override
  Future<T?> get<T>(String key) async {
    try {
      if (_prefs == null) await initialize();
      
      if (T == String) {
        return _prefs!.getString(key) as T?;
      } else if (T == int) {
        return _prefs!.getInt(key) as T?;
      } else if (T == double) {
        return _prefs!.getDouble(key) as T?;
      } else if (T == bool) {
        return _prefs!.getBool(key) as T?;
      } else if (T == List<String>) {
        return _prefs!.getStringList(key) as T?;
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get value for key: $key', error: e);
      return null;
    }
  }

  @override
  Future<void> set<T>(String key, T value) async {
    try {
      if (_prefs == null) await initialize();
      
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
    } catch (e) {
      _logger.error('Failed to set value for key: $key', error: e);
      rethrow;
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      if (_prefs == null) await initialize();
      await _prefs!.remove(key);
    } catch (e) {
      _logger.error('Failed to remove key: $key', error: e);
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      if (_prefs == null) await initialize();
      await _prefs!.clear();
    } catch (e) {
      _logger.error('Failed to clear storage', error: e);
      rethrow;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      if (_prefs == null) await initialize();
      return _prefs!.containsKey(key);
    } catch (e) {
      _logger.error('Failed to check key: $key', error: e);
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getAll() async {
    try {
      if (_prefs == null) await initialize();
      final Map<String, dynamic> result = {};
      for (final key in _prefs!.getKeys()) {
        result[key] = _prefs!.get(key);
      }
      return result;
    } catch (e) {
      _logger.error('Failed to get all values', error: e);
      return {};
    }
  }
}

