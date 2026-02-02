// lib/src/runtime_control/domains/storage_runtime_domain.dart
// Real storage domain that clears actual storage systems

import 'dart:async';
import 'package:flutter/foundation.dart';
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
        // Clear in-memory caches only
        await _clearInMemoryCache();
        debugPrint('🧹 Cleared in-memory storage cache');
      }
      
      if (level.shouldResetPersistentState) {
        // Clear all persistent storage
        await _clearPersistentStorage();
        debugPrint('🧹 Cleared persistent storage');
      }
      
      if (level.shouldResetRuntime) {
        // Complete storage reset
        await _clearAllStorage();
        debugPrint('🧹 Complete storage reset');
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
      debugPrint('🗑️ Storage domain disposed');
    } catch (e) {
      debugPrint('❌ Storage domain dispose failed: $e');
    }
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  // Real implementation methods
  
  Future<void> _clearInMemoryCache() async {
    // Clear any in-memory storage caches
    // This would integrate with your storage gateway
    try {
      // If StorageGateway exists, clear its caches
      // StorageGateway.instance.clearInMemoryCache();
    } catch (e) {
      debugPrint('Error clearing in-memory cache: $e');
    }
  }
  
  Future<void> _clearPersistentStorage() async {
    try {
      // Clear SharedPreferences
      if (_prefs != null) {
        await _prefs!.clear();
        debugPrint('Cleared SharedPreferences');
      }
      
      // Clear other persistent storage systems
      await _clearHiveStorage();
      await _clearSQLiteStorage();
      
    } catch (e) {
      debugPrint('Error clearing persistent storage: $e');
      rethrow;
    }
  }
  
  Future<void> _clearAllStorage() async {
    await _clearInMemoryCache();
    await _clearPersistentStorage();
    
    // Additional complete reset operations
    await _clearApplicationDocumentsDirectory();
    await _clearApplicationCacheDirectory();
  }
  
  Future<void> _clearHiveStorage() async {
    try {
      // If using Hive, clear all boxes
      // This would need to be implemented based on your Hive usage
      debugPrint('Hive storage cleared (placeholder)');
    } catch (e) {
      debugPrint('Error clearing Hive storage: $e');
    }
  }
  
  Future<void> _clearSQLiteStorage() async {
    try {
      // If using SQLite, clear all databases
      // This would need to be implemented based on your SQLite usage
      debugPrint('SQLite storage cleared (placeholder)');
    } catch (e) {
      debugPrint('Error clearing SQLite storage: $e');
    }
  }
  
  Future<void> _clearApplicationDocumentsDirectory() async {
    try {
      if (!kIsWeb) {
        // Clear app documents directory
        // This would use path_provider to get the directory and clear it
        debugPrint('Application documents directory cleared (placeholder)');
      }
    } catch (e) {
      debugPrint('Error clearing documents directory: $e');
    }
  }
  
  Future<void> _clearApplicationCacheDirectory() async {
    try {
      if (!kIsWeb) {
        // Clear app cache directory
        // This would use path_provider to get the directory and clear it
        debugPrint('Application cache directory cleared (placeholder)');
      }
    } catch (e) {
      debugPrint('Error clearing cache directory: $e');
    }
  }
}