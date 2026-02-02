// lib/src/runtime_control/domains/memory_runtime_domain.dart
// Memory management domain for proper cleanup and garbage collection

import 'dart:async';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../reset_level.dart';
import '../runtime_domain.dart';

class MemoryRuntimeDomain implements RuntimeDomain {
  bool _initialized = false;
  
  @override
  String get domainId => 'memory';
  
  @override
  String get domainName => 'Memory Management';
  
  @override
  int get initializationPriority => 25;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetTransientState) {
      await _basicMemoryCleanup();
    }
    
    if (level.shouldResetPersistentState) {
      await _comprehensiveMemoryCleanup();
    }
    
    if (level.shouldResetRuntime) {
      await _fullMemoryReset();
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  // REAL memory cleanup implementations
  
  Future<void> _basicMemoryCleanup() async {
    // REAL: Clear Flutter image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  Future<void> _comprehensiveMemoryCleanup() async {
    await _basicMemoryCleanup();
    
    // REAL: Evict all cached images
    PaintingBinding.instance.imageCache.maximumSize = 0;
    PaintingBinding.instance.imageCache.maximumSize = 100;
    
    // REAL: Clear asset bundle cache
    rootBundle.clear();
  }
  
  Future<void> _fullMemoryReset() async {
    await _comprehensiveMemoryCleanup();
    
    // REAL: Clear and reset image cache completely
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.clearLiveImages();
    
    // Force eviction by setting to 0 then back
    final oldMaxSize = imageCache.maximumSize;
    final oldMaxBytes = imageCache.maximumSizeBytes;
    imageCache.maximumSize = 0;
    imageCache.maximumSizeBytes = 0;
    imageCache.maximumSize = oldMaxSize;
    imageCache.maximumSizeBytes = oldMaxBytes;
    
    // REAL: Clear root bundle
    rootBundle.clear();
    
    // Wait for GC opportunity
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  // Public API to get current memory info
  int get currentCacheSize => PaintingBinding.instance.imageCache.currentSize;
  int get currentCacheBytes => PaintingBinding.instance.imageCache.currentSizeBytes;
  int get maxCacheSize => PaintingBinding.instance.imageCache.maximumSize;
  int get maxCacheBytes => PaintingBinding.instance.imageCache.maximumSizeBytes;
  
  // Evict specific image from cache
  bool evictImage(String key) {
    return PaintingBinding.instance.imageCache.evict(key);
  }
}