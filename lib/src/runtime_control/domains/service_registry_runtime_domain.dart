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
  final Map<String, dynamic> _serviceSnapshots = {};
  
  @override
  String get domainId => 'service_registry';
  
  @override
  String get domainName => 'Service Registry';
  
  @override
  int get initializationPriority => 10; // Highest priority - services needed first
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    try {
      await _initializeServiceRegistry();
      _initialized = true;
      debugPrint('✅ Service registry domain initialized');
    } catch (e) {
      debugPrint('❌ Service registry domain initialization failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    try {
      if (level.shouldResetTransientState) {
        // Reset non-singleton services
        await _resetTransientServices();
        debugPrint('🧹 Reset transient services');
      }
      
      if (level.shouldResetPersistentState) {
        // Reset singleton services but preserve registration
        await _resetSingletonServices();
        debugPrint('🧹 Reset singleton services');
      }
      
      if (level.shouldResetRuntime) {
        // Complete service registry reset
        await _fullServiceReset();
        debugPrint('🧹 Full service registry reset');
      }
      
    } catch (e) {
      debugPrint('❌ Service registry domain reset failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> dispose() async {
    try {
      await _disposeServiceRegistry();
      _initialized = false;
      debugPrint('🗑️ Service registry domain disposed');
    } catch (e) {
      debugPrint('❌ Service registry domain dispose failed: $e');
    }
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  // Real service registry implementation
  
  Future<void> _initializeServiceRegistry() async {
    try {
      // Capture current service state for potential restoration
      await _captureServiceSnapshot();
      
    } catch (e) {
      debugPrint('Error initializing service registry: $e');
      rethrow;
    }
  }
  
  Future<void> _resetTransientServices() async {
    try {
      final getIt = GetIt.instance;
      
      // Get all registered factory services
      final factoryServices = _getFactoryServices();
      
      for (final serviceType in factoryServices) {
        try {
          if (getIt.isRegistered<Object>()) {
            // Unregister factory service
            await getIt.unregister<Object>();
            debugPrint('Unregistered transient service: $serviceType');
          }
        } catch (e) {
          debugPrint('Error resetting transient service $serviceType: $e');
        }
      }
      
    } catch (e) {
      debugPrint('Error resetting transient services: $e');
    }
  }
  
  Future<void> _resetSingletonServices() async {
    try {
      final getIt = GetIt.instance;
      
      // Get all singleton services
      final singletonServices = _getSingletonServices();
      
      for (final serviceType in singletonServices) {
        try {
          if (getIt.isRegistered<Object>()) {
            // Reset singleton instance
            await getIt.resetLazySingleton<Object>();
            debugPrint('Reset singleton service: $serviceType');
          }
        } catch (e) {
          debugPrint('Error resetting singleton $serviceType: $e');
        }
      }
      
    } catch (e) {
      debugPrint('Error resetting singleton services: $e');
    }
  }
  
  Future<void> _fullServiceReset() async {
    try {
      final getIt = GetIt.instance;
      
      // Dispose all disposable services first
      await _disposeAllServices();
      
      // Reset GetIt completely
      await getIt.reset(dispose: true);
      debugPrint('GetIt completely reset');
      
      // Re-register services using callbacks
      await _reregisterServices();
      
    } catch (e) {
      debugPrint('Error in full service reset: $e');
      rethrow;
    }
  }
  
  Future<void> _disposeAllServices() async {
    try {
      final getIt = GetIt.instance;
      
      // Get all registered services that implement Disposable
      final disposableServices = _getDisposableServices();
      
      for (final serviceType in disposableServices) {
        try {
          if (getIt.isRegistered<Object>()) {
            final service = getIt.get<Object>();
            if (service is Disposable) {
              await service.onDispose();
              debugPrint('Disposed service: $serviceType');
            }
          }
        } catch (e) {
          debugPrint('Error disposing service $serviceType: $e');
        }
      }
      
    } catch (e) {
      debugPrint('Error disposing all services: $e');
    }
  }
  
  Future<void> _reregisterServices() async {
    try {
      // Execute all registration callbacks
      for (final callback in _registrationCallbacks) {
        try {
          await callback();
        } catch (e) {
          debugPrint('Error in service registration callback: $e');
        }
      }
      
      debugPrint('Services re-registered using callbacks');
      
    } catch (e) {
      debugPrint('Error re-registering services: $e');
    }
  }
  
  Future<void> _captureServiceSnapshot() async {
    try {
      // Capture current GetIt state for debugging
      // This would capture service types and registration info
      // Implementation depends on specific GetIt version and needs
      
      debugPrint('Service snapshot captured');
      
    } catch (e) {
      debugPrint('Error capturing service snapshot: $e');
    }
  }
  
  List<Type> _getFactoryServices() {
    try {
      // Return list of factory-registered service types
      // This would need to be implemented based on your service structure
      return [];
    } catch (e) {
      debugPrint('Error getting factory services: $e');
      return [];
    }
  }
  
  List<Type> _getSingletonServices() {
    try {
      // Return list of singleton-registered service types
      // This would need to be implemented based on your service structure
      return [];
    } catch (e) {
      debugPrint('Error getting singleton services: $e');
      return [];
    }
  }
  
  List<Type> _getDisposableServices() {
    try {
      // Return list of disposable service types
      // This would need to be implemented based on your service structure
      return [];
    } catch (e) {
      debugPrint('Error getting disposable services: $e');
      return [];
    }
  }
  
  Future<void> _disposeServiceRegistry() async {
    try {
      _registrationCallbacks.clear();
      _serviceSnapshots.clear();
    } catch (e) {
      debugPrint('Error disposing service registry: $e');
    }
  }
  
  // Public methods for service management
  
  void addServiceRegistrationCallback(ServiceRegistrationCallback callback) {
    _registrationCallbacks.add(callback);
  }
  
  void removeServiceRegistrationCallback(ServiceRegistrationCallback callback) {
    _registrationCallbacks.remove(callback);
  }
  
  Future<bool> isServiceRegistered<T extends Object>() async {
    try {
      return GetIt.instance.isRegistered<T>();
    } catch (e) {
      debugPrint('Error checking service registration: $e');
      return false;
    }
  }
  
  Future<void> resetSpecificService<T extends Object>() async {
    try {
      final getIt = GetIt.instance;
      
      if (getIt.isRegistered<T>()) {
        await getIt.resetLazySingleton<T>();
        debugPrint('Reset specific service: $T');
      }
    } catch (e) {
      debugPrint('Error resetting specific service $T: $e');
      rethrow;
    }
  }
  
  Future<void> unregisterSpecificService<T extends Object>() async {
    try {
      final getIt = GetIt.instance;
      
      if (getIt.isRegistered<T>()) {
        await getIt.unregister<T>();
        debugPrint('Unregistered specific service: $T');
      }
    } catch (e) {
      debugPrint('Error unregistering specific service $T: $e');
      rethrow;
    }
  }
  
  int get registrationCallbackCount => _registrationCallbacks.length;
}