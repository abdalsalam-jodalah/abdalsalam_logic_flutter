// lib/src/prefetch/prefetch_manager_impl.dart
import 'prefetch_manager.dart';

class PrefetchManagerImpl implements PrefetchManager {
  final Map<String, dynamic> _cache = {};

  PrefetchManagerImpl();

  @override
  Future<void> initialize() async {
  }

  @override
  Future<void> dispose() async {
    _cache.clear();
  }

  @override
  Future<void> prefetchData(
    String key,
    Future<dynamic> Function() fetcher,
  ) async {
    try {
      final data = await fetcher();
      _cache[key] = data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<T?> getPrefetchedData<T>(String key) async {
    try {
      if (_cache.containsKey(key)) {
        return _cache[key] as T?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearPrefetchedData(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> clearAllPrefetchedData() async {
    _cache.clear();
  }
}

