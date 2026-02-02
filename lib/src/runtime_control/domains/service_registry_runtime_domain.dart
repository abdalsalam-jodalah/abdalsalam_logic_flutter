// lib/src/runtime_control/domains/service_registry_runtime_domain.dart
// Service registry domain for GetIt service clearing and re-registration

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../reset_level.dart';
import '../runtime_domain.dart';

typedef ServiceRegistrationCallback = Future<void> Function();

class ServiceRegistryRuntimeDomain implements RuntimeDomain {
  bool _initialized = false;
  final List<ServiceRegistrationCallback> _registrationCallbacks = [];
  
  @override
  String get domainId => 'service_registry';
  
  @override
  String get domainName => 'Service Registry';
  
  @override
  int get initializationPriority => 10;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetTransientState) {
      // Nothing to do for transient
    }
    
    if (level.shouldResetPersistentState) {
      // Nothing to do for persistent
    }
    
    if (level.shouldResetRuntime) {
      await _fullServiceReset();
    }
  }
  
  @override
  Future<void> dispose() async {
    _registrationCallbacks.clear();
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  // REAL GetIt reset
  Future<void> _fullServiceReset() async {
    final getIt = GetIt.instance;
    
    // REAL: Reset GetIt completely
    await getIt.reset(dispose: true);
    
    // Re-register services using callbacks
    for (final callback in _registrationCallbacks) {
      try {
        await callback();
      } catch (e) {
        debugPrint('Error in service registration callback: $e');
      }
    }
  }
  
  // Public API
  void addServiceRegistrationCallback(ServiceRegistrationCallback callback) {
    _registrationCallbacks.add(callback);
  }
  
  void removeServiceRegistrationCallback(ServiceRegistrationCallback callback) {
    _registrationCallbacks.remove(callback);
  }
  
  Future<bool> isServiceRegistered<T extends Object>() async {
    return GetIt.instance.isRegistered<T>();
  }
  
  Future<void> resetSpecificService<T extends Object>() async {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<T>()) {
      await getIt.resetLazySingleton<T>();
    }
  }
  
  Future<void> unregisterSpecificService<T extends Object>() async {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<T>()) {
      await getIt.unregister<T>();
    }
  }
  
  int get registrationCallbackCount => _registrationCallbacks.length;
}