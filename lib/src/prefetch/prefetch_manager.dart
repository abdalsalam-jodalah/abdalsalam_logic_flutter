// lib/src/prefetch/prefetch_manager.dart
import '../core/interfaces/service_interface.dart';

abstract class PrefetchManager extends ServiceInterface {
  Future<void> prefetchData(String key, Future<dynamic> Function() fetcher);
  Future<T?> getPrefetchedData<T>(String key);
  Future<void> clearPrefetchedData(String key);
  Future<void> clearAllPrefetchedData();
}

