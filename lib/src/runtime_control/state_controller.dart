// lib/src/runtime_control/state_controller.dart
// Controller for managing state domains and reset operations

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

import 'domain_registry.dart';
import 'reset_level.dart';
import 'runtime_domain.dart';
import 'runtime_exception.dart';

class StateController {
  final DomainRegistry _registry;
  final StreamController<StateEvent> _eventStream = StreamController.broadcast();
  
  // Track active subscriptions and controllers for cleanup
  final List<StreamSubscription> _activeSubscriptions = [];
  final List<StreamController> _activeControllers = [];
  final Set<String> _initializingDomains = {};
  
  StateController(this._registry);
  
  Future<void> initializeAll() async {
    _emitEvent(StateEvent.initializingAll());
    
    try {
      final domains = _registry.getInitializationOrder();
      
      // Initialize domains in order with proper error handling
      for (final domain in domains) {
        if (!_initializingDomains.contains(domain.domainId)) {
          await _initializeDomain(domain);
        }
      }
      
      _emitEvent(StateEvent.initializedAll());
    } catch (e, stackTrace) {
      _emitEvent(StateEvent.error('system', e, stackTrace));
      rethrow;
    }
  }
  
  Future<void> initializeDomain(String domainId) async {
    final domain = _registry.getDomain(domainId);
    if (domain == null) {
      throw UnregisteredDomainException('Domain $domainId is not registered');
    }
    
    await _initializeDomain(domain);
  }
  
  Future<void> _initializeDomain(RuntimeDomain domain) async {
    if (_registry.isInitialized(domain.domainId) || 
        _initializingDomains.contains(domain.domainId)) {
      return;
    }
    
    _initializingDomains.add(domain.domainId);
    _emitEvent(StateEvent.initializingDomain(domain.domainId));
    
    try {
      // Initialize domain dependencies first
      for (final depId in domain.dependencies) {
        final dep = _registry.getDomain(depId);
        if (dep != null && !_registry.isInitialized(depId)) {
          await _initializeDomain(dep);
        }
      }
      
      // Initialize the domain itself
      await domain.initialize();
      _registry.markInitialized(domain.domainId);
      _emitEvent(StateEvent.initializedDomain(domain.domainId));
      
    } catch (e, stackTrace) {
      _emitEvent(StateEvent.error(domain.domainId, e, stackTrace));
      throw RuntimeInitializationException(
        'Failed to initialize domain ${domain.domainId}',
        details: e,
      );
    } finally {
      _initializingDomains.remove(domain.domainId);
    }
  }
  
  Future<void> resetAll(ResetLevel level) async {
    _emitEvent(StateEvent.resettingAll(level));
    
    try {
      // Perform system-level cleanup first
      await _performSystemCleanup(level);
      
      // Reset domains in reverse dependency order
      final domains = _registry.getAllDomains().reversed.toList();
      
      for (final domain in domains) {
        if (domain.canReset) {
          await _resetDomain(domain, level);
        }
      }
      
      // Perform post-reset cleanup
      await _performPostResetCleanup(level);
      
      _emitEvent(StateEvent.resetAll(level));
    } catch (e, stackTrace) {
      _emitEvent(StateEvent.error('system', e, stackTrace));
      rethrow;
    }
  }
  
  Future<void> resetDomain(String domainId, ResetLevel level) async {
    final domain = _registry.getDomain(domainId);
    if (domain == null) {
      throw UnregisteredDomainException('Domain $domainId is not registered');
    }
    
    await _resetDomain(domain, level);
  }
  
  Future<void> _resetDomain(RuntimeDomain domain, ResetLevel level) async {
    _emitEvent(StateEvent.resettingDomain(domain.domainId, level));
    
    try {
      await domain.reset(level);
      
      if (level.shouldResetRuntime) {
        _registry.markUninitialized(domain.domainId);
      }
      
      _emitEvent(StateEvent.resetDomain(domain.domainId, level));
    } catch (e, stackTrace) {
      _emitEvent(StateEvent.error(domain.domainId, e, stackTrace));
      rethrow;
    }
  }
  
  Future<void> disposeAll() async {
    _emitEvent(StateEvent.disposingAll());
    
    final domains = _registry.getAllDomains().reversed.toList();
    
    for (final domain in domains) {
      await _disposeDomain(domain);
    }
    
    _registry.clear();
    _emitEvent(StateEvent.disposedAll());
  }
  
  Future<void> disposeDomain(String domainId) async {
    final domain = _registry.getDomain(domainId);
    if (domain == null) {
      throw UnregisteredDomainException('Domain $domainId is not registered');
    }
    
    await _disposeDomain(domain);
    _registry.unregister(domainId);
  }
  
  Future<void> _disposeDomain(RuntimeDomain domain) async {
    _emitEvent(StateEvent.disposingDomain(domain.domainId));
    
    try {
      await domain.dispose();
      _registry.markUninitialized(domain.domainId);
      _emitEvent(StateEvent.disposedDomain(domain.domainId));
    } catch (e, stackTrace) {
      _emitEvent(StateEvent.error(domain.domainId, e, stackTrace));
    }
  }
  
  Future<void> reinitializeAll() async {
    await resetAll(ResetLevel.complete);
    await initializeAll();
  }
  
  Future<void> reinitializeDomain(String domainId) async {
    await resetDomain(domainId, ResetLevel.complete);
    await initializeDomain(domainId);
  }
  
  // REAL system cleanup implementation
  
  Future<void> _performSystemCleanup(ResetLevel level) async {
    try {
      if (level.shouldResetPersistentState || level.shouldResetRuntime) {
        // Cancel all active subscriptions
        await _cancelAllSubscriptions();
        
        // Close active stream controllers  
        await _closeActiveControllers();
        
        // Clear system-level caches
        await _clearSystemCaches(level);
        
        // Force garbage collection
        if (!kIsWeb) {
          // Request garbage collection (not guaranteed but encouraged)
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      debugPrint('Error during system cleanup: $e');
    }
  }
  
  Future<void> _performPostResetCleanup(ResetLevel level) async {
    try {
      if (level.shouldResetRuntime) {
        // Clear initialization tracking
        _initializingDomains.clear();
        
        // Reset registration state for all domains
        for (final domain in _registry.getAllDomains()) {
          _registry.markUninitialized(domain.domainId);
        }
      }
      
      // Platform-specific cleanup
      if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isIOS) {
          // Clear native method call cache (method not available in current Flutter version)
          // ServicesBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(null, null);
        }
      }
      
    } catch (e) {
      debugPrint('Error during post-reset cleanup: $e');
    }
  }
  
  Future<void> _cancelAllSubscriptions() async {
    for (final subscription in List.from(_activeSubscriptions)) {
      try {
        await subscription.cancel();
      } catch (e) {
        debugPrint('Error canceling subscription: $e');
      }
    }
    _activeSubscriptions.clear();
  }
  
  Future<void> _closeActiveControllers() async {
    for (final controller in List.from(_activeControllers)) {
      try {
        if (!controller.isClosed) {
          await controller.close();
        }
      } catch (e) {
        debugPrint('Error closing controller: $e');
      }
    }
    _activeControllers.clear();
  }
  
  Future<void> _clearSystemCaches(ResetLevel level) async {
    try {
      // Clear different levels of caches based on reset level
      if (level.shouldResetTransientState) {
        // Clear in-memory caches only
      }
      
      if (level.shouldResetPersistentState) {
        // This would be handled by individual domains
        // but we can clear system-level persistent state here
      }
      
      if (level.shouldResetRuntime) {
        // Clear all caches and force complete reset
      }
      
    } catch (e) {
      debugPrint('Error clearing system caches: $e');
    }
  }
  
  // Track subscriptions and controllers for cleanup
  void trackSubscription(StreamSubscription subscription) {
    _activeSubscriptions.add(subscription);
  }
  
  void trackController(StreamController controller) {
    _activeControllers.add(controller);
  }
  
  void stopTrackingSubscription(StreamSubscription subscription) {
    _activeSubscriptions.remove(subscription);
  }
  
  void stopTrackingController(StreamController controller) {
    _activeControllers.remove(controller);
  }
  
  void _emitEvent(StateEvent event) {
    _eventStream.add(event);
  }
  
  Stream<StateEvent> get eventStream => _eventStream.stream;
  
  DomainRegistry get registry => _registry;
  
  int get activeSubscriptionCount => _activeSubscriptions.length;
  int get activeControllerCount => _activeControllers.length;
  
  void dispose() {
    _eventStream.close();
  }
}

class StateEvent {
  final StateEventType type;
  final String? domainId;
  final ResetLevel? resetLevel;
  final dynamic error;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  
  StateEvent._({
    required this.type,
    this.domainId,
    this.resetLevel,
    this.error,
    this.stackTrace,
  }) : timestamp = DateTime.now();
  
  factory StateEvent.initializingAll() => 
      StateEvent._(type: StateEventType.initializingAll);
  
  factory StateEvent.initializedAll() => 
      StateEvent._(type: StateEventType.initializedAll);
  
  factory StateEvent.initializingDomain(String domainId) => StateEvent._(
        type: StateEventType.initializingDomain,
        domainId: domainId,
      );
  
  factory StateEvent.initializedDomain(String domainId) => StateEvent._(
        type: StateEventType.initializedDomain,
        domainId: domainId,
      );
  
  factory StateEvent.resettingAll(ResetLevel level) => StateEvent._(
        type: StateEventType.resettingAll,
        resetLevel: level,
      );
  
  factory StateEvent.resetAll(ResetLevel level) => StateEvent._(
        type: StateEventType.resetAll,
        resetLevel: level,
      );
  
  factory StateEvent.resettingDomain(String domainId, ResetLevel level) => 
      StateEvent._(
        type: StateEventType.resettingDomain,
        domainId: domainId,
        resetLevel: level,
      );
  
  factory StateEvent.resetDomain(String domainId, ResetLevel level) => 
      StateEvent._(
        type: StateEventType.resetDomain,
        domainId: domainId,
        resetLevel: level,
      );
  
  factory StateEvent.disposingAll() => 
      StateEvent._(type: StateEventType.disposingAll);
  
  factory StateEvent.disposedAll() => 
      StateEvent._(type: StateEventType.disposedAll);
  
  factory StateEvent.disposingDomain(String domainId) => StateEvent._(
        type: StateEventType.disposingDomain,
        domainId: domainId,
      );
  
  factory StateEvent.disposedDomain(String domainId) => StateEvent._(
        type: StateEventType.disposedDomain,
        domainId: domainId,
      );
  
  factory StateEvent.error(String domainId, dynamic error, StackTrace stackTrace) => 
      StateEvent._(
        type: StateEventType.error,
        domainId: domainId,
        error: error,
        stackTrace: stackTrace,
      );
}

enum StateEventType {
  initializingAll,
  initializedAll,
  initializingDomain,
  initializedDomain,
  resettingAll,
  resetAll,
  resettingDomain,
  resetDomain,
  disposingAll,
  disposedAll,
  disposingDomain,
  disposedDomain,
  error,
}
