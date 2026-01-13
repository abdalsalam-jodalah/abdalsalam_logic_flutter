// lib/src/storage/implementations/refreshable_storage_mixin.dart

import '../abstractions/storage_capabilities.dart';
import '../exceptions/storage_exceptions.dart';

/// Mixin providing refresh and incremental sync capabilities.
///
/// Suitable for caching scenarios or when storage needs explicit refresh.
mixin RefreshableStorageMixin implements RefreshableStorage {
  // Cache tracking
  DateTime? _lastRefreshTime;
  final Map<String, dynamic> _cache = {};
  bool _cacheValid = false;

  @override
  Future<void> refresh() async {
    try {
      // Clear cache
      _cache.clear();
      _cacheValid = false;

      // Reload data from source
      await reloadFromSource();

      _lastRefreshTime = DateTime.now();
      _cacheValid = true;
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to refresh storage: $e',
      );
    }
  }

  @override
  Future<List<dynamic>> getModifiedSince(DateTime since) async {
    try {
      final allData = await getAllDataWithTimestamps();

      return allData.where((item) {
        final timestamp = extractTimestamp(item);
        return timestamp != null && timestamp.isAfter(since);
      }).toList();
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to get modified data: $e',
      );
    }
  }

  /// Get last refresh time.
  DateTime? get lastRefreshTime => _lastRefreshTime;

  /// Check if cache is valid.
  bool get isCacheValid => _cacheValid;

  /// Reload data from underlying source.
  /// Must be implemented by storage class.
  Future<void> reloadFromSource();

  /// Get all data with timestamps.
  /// Must be implemented by storage class.
  Future<List<dynamic>> getAllDataWithTimestamps();

  /// Extract timestamp from data item.
  /// Must be implemented by storage class.
  DateTime? extractTimestamp(dynamic item);

  /// Mark cache as invalid.
  void invalidateCache() {
    _cacheValid = false;
  }
}
