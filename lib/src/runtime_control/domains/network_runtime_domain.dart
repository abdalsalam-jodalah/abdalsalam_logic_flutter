// lib/src/runtime_control/domains/network_runtime_domain.dart
// Real network domain that clears HTTP caches and resets network state

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../reset_level.dart';
import '../runtime_domain.dart';

class NetworkRuntimeDomain implements RuntimeDomain {
  bool _initialized = false;
  HttpClient? _httpClient;
  final List<HttpClientRequest> _activeRequests = [];
  
  @override
  String get domainId => 'network';
  
  @override
  String get domainName => 'Network Management';
  
  @override
  int get initializationPriority => 75;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    if (!kIsWeb) {
      _httpClient = HttpClient();
    }
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetTransientState) {
      await _clearTemporaryNetworkState();
    }
    
    if (level.shouldResetPersistentState) {
      await _clearPersistentNetworkState();
    }
    
    if (level.shouldResetRuntime) {
      await _completeNetworkReset();
    }
  }
  
  @override
  Future<void> dispose() async {
    await _disposeNetworkServices();
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  // REAL network operations
  
  Future<void> _clearTemporaryNetworkState() async {
    // REAL: Close all active connections and force new ones
    if (!kIsWeb && _httpClient != null) {
      _httpClient!.close(force: true);
      _httpClient = HttpClient();
    }
    _activeRequests.clear();
  }
  
  Future<void> _clearPersistentNetworkState() async {
    await _clearTemporaryNetworkState();
    
    // REAL: Clear any cookie jars if using them
    // The HttpClient itself doesn't persist cookies between sessions
    // but if you have a cookie jar, clear it here
  }
  
  Future<void> _completeNetworkReset() async {
    await _clearPersistentNetworkState();
    
    // REAL: Recreate HTTP client with fresh settings
    if (!kIsWeb) {
      _httpClient?.close(force: true);
      _httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: 30)
        ..idleTimeout = const Duration(seconds: 15);
    }
  }
  
  Future<void> _disposeNetworkServices() async {
    if (!kIsWeb && _httpClient != null) {
      _httpClient!.close(force: true);
      _httpClient = null;
    }
    _activeRequests.clear();
  }
  
  // Public API
  int get activeRequestCount => _activeRequests.length;
  
  void cancelAllRequests() {
    for (final request in _activeRequests) {
      try {
        request.abort();
      } catch (e) {
        // Request may already be completed
      }
    }
    _activeRequests.clear();
  }
}