// lib/src/runtime_control/domains/storage_runtime_domain.dart
// Real storage domain that clears actual storage systems

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reset_level.dart';
import '../runtime_domain.dart';

class StorageRuntimeDomain implements RuntimeDomain {
  bool _initialized = false;
  SharedPreferences? _prefs;
  
  @override
  String get domainId => 'storage';
  
  @override
  String get domainName => 'Storage Management';
  
  @override
  int get initializationPriority => 50;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      debugPrint('✅ Storage domain initialized');
    } catch (e) {
      debugPrint('❌ Storage domain initialization failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    try {
      if (level.shouldResetTransientState) {
        await _clearInMemoryCache();
      }
      
      if (level.shouldResetPersistentState) {
        await _clearPersistentStorage();
      }
      
      if (level.shouldResetRuntime) {
        await _clearAllStorage();
      }
      
    } catch (e) {
      debugPrint('❌ Storage domain reset failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> dispose() async {
    try {
      _prefs = null;
      _initialized = false;
    } catch (e) {
      debugPrint('❌ Storage domain dispose failed: $e');
    }
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  Future<void> _clearInMemoryCache() async {
    // Reload SharedPreferences to clear in-memory cache
    if (_prefs != null) {
      await _prefs!.reload();
    }
  }
  
  Future<void> _clearPersistentStorage() async {
    // REAL: Clear SharedPreferences completely
    if (_prefs != null) {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        await _prefs!.remove(key);
      }
    }
  }
  
  Future<void> _clearAllStorage() async {
    await _clearInMemoryCache();
    await _clearPersistentStorage();
    
    // REAL: Clear application cache directory
    if (!kIsWeb) {
      await _clearCacheDirectory();
      await _clearTempDirectory();
    }
  }
  
  Future<void> _clearCacheDirectory() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        final files = cacheDir.listSync();
        for (final file in files) {
          try {
            if (file is File) {
              await file.delete();
            } else if (file is Directory) {
              await file.delete(recursive: true);
            }
          } catch (e) {
            // Skip files that can't be deleted
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing cache directory: $e');
    }
  }
  
  Future<void> _clearTempDirectory() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        final files = tempDir.listSync();
        for (final file in files) {
          try {
            if (file is File) {
              await file.delete();
            } else if (file is Directory) {
              await file.delete(recursive: true);
            }
          } catch (e) {
            // Skip files that can't be deleted
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing temp directory: $e');
    }
  }
  
  // Public method to clear specific data
  Future<void> clearKey(String key) async {
    if (_prefs != null) {
      await _prefs!.remove(key);
    }
  }
  
  // Get count of stored keys
  int get storedKeyCount => _prefs?.getKeys().length ?? 0;
}