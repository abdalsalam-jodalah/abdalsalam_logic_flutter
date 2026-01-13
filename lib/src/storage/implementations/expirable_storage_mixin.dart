// lib/src/storage/implementations/expirable_storage_mixin.dart

import 'dart:async';
import '../abstractions/key_value_storage_comprehensive.dart';
import '../exceptions/storage_exceptions.dart';

mixin ExpirableKeyValueStorageMixin<T> on KeyValueStorage<T> {
  final Map<String, DateTime> _expirationTimes = {};
  Timer? _cleanupTimer;

  Future<void> setKeyWithExpiration(
    String key,
    T value,
    Duration duration,
  ) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      await set(key, value);
      final expirationTime = DateTime.now().add(duration);
      _expirationTimes[key] = expirationTime;

      _scheduleCleanup();
    } catch (e) {
      throw StorageOperationException(
        operation: 'setWithExpiration',
        message: 'Failed to set with expiration: $e',
      );
    }
  }

  Future<bool> setKeyExpiration(String key, Duration duration) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      final exists = await contains(key);
      if (!exists) return false;

      final expirationTime = DateTime.now().add(duration);
      _expirationTimes[key] = expirationTime;

      _scheduleCleanup();
      return true;
    } catch (e) {
      throw StorageOperationException(
        operation: 'setExpiration',
        message: 'Failed to set expiration: $e',
      );
    }
  }

  Future<Duration?> getKeyTimeToLive(String key) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      final expirationTime = _expirationTimes[key];
      if (expirationTime == null) return null;

      final now = DateTime.now();
      if (expirationTime.isBefore(now)) {
        await delete(key);
        _expirationTimes.remove(key);
        return null;
      }

      return expirationTime.difference(now);
    } catch (e) {
      return null;
    }
  }

  Future<bool> removeKeyExpiration(String key) async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    try {
      final exists = await contains(key);
      if (!exists) return false;

      _expirationTimes.remove(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isExpired(String key) {
    final expirationTime = _expirationTimes[key];
    if (expirationTime == null) return false;
    return DateTime.now().isAfter(expirationTime);
  }

  void _scheduleCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanupExpiredKeys(),
    );
  }

  Future<void> _cleanupExpiredKeys() async {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _expirationTimes.entries) {
      if (entry.value.isBefore(now)) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      await delete(key);
      _expirationTimes.remove(key);
    }

    if (expiredKeys.isNotEmpty) {}
  }

  Future<void> disposeExpirable() async {
    _cleanupTimer?.cancel();
    _expirationTimes.clear();
  }
}
