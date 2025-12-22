// lib/src/prefetch/prefetch_manager_impl.dart
import '../logging/logger_service.dart';
import 'prefetch_manager.dart';

class PrefetchManagerImpl implements PrefetchManager {
  final LoggerService _logger;
  final Map<String, dynamic> _cache = {};

  PrefetchManagerImpl(this._logger);

  @override
  Future<void> initialize() async {
    _logger.info('Prefetch manager initialized');
  }

  @override
  Future<void> dispose() async {
    _cache.clear();
    _logger.info('Prefetch manager disposed');
  }

  @override
  Future<void> prefetchData(
    String key,
    Future<dynamic> Function() fetcher,
  ) async {
    try {
      _logger.info('Prefetching data for key: $key');
      final data = await fetcher();
      _cache[key] = data;
      _logger.info('Data prefetched successfully for key: $key');
    } catch (e) {
      _logger.error('Failed to prefetch data for key: $key', error: e);
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
      _logger.error('Failed to get prefetched data for key: $key', error: e);
      return null;
    }
  }

  @override
  Future<void> clearPrefetchedData(String key) async {
    _cache.remove(key);
    _logger.info('Prefetched data cleared for key: $key');
  }

  @override
  Future<void> clearAllPrefetchedData() async {
    _cache.clear();
    _logger.info('All prefetched data cleared');
  }
}

