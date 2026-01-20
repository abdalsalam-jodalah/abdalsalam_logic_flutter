// lib/src/runtime_control/state_controller.dart
// Controller for managing state domains and reset operations

import 'dart:async';

import 'domain_registry.dart';
import 'reset_level.dart';
import 'runtime_domain.dart';
import 'runtime_exception.dart';

class StateController {
  final DomainRegistry _registry;
  final StreamController<StateEvent> _eventStream = StreamController.broadcast();
  
  StateController(this._registry);
  
  Future<void> initializeAll() async {
    _emitEvent(StateEvent.initializingAll());
    
    final domains = _registry.getInitializationOrder();
    
    for (final domain in domains) {
      await _initializeDomain(domain);
    }
    
    _emitEvent(StateEvent.initializedAll());
  }
  
  Future<void> initializeDomain(String domainId) async {
    final domain = _registry.getDomain(domainId);
    if (domain == null) {
      throw UnregisteredDomainException('Domain $domainId is not registered');
    }
    
    await _initializeDomain(domain);
  }
  
  Future<void> _initializeDomain(RuntimeDomain domain) async {
    if (_registry.isInitialized(domain.domainId)) {
      return;
    }
    
    _emitEvent(StateEvent.initializingDomain(domain.domainId));
    
    try {
      await domain.initialize();
      _registry.markInitialized(domain.domainId);
      _emitEvent(StateEvent.initializedDomain(domain.domainId));
    } catch (e, stackTrace) {
      _emitEvent(StateEvent.error(domain.domainId, e, stackTrace));
      throw RuntimeInitializationException(
        'Failed to initialize domain ${domain.domainId}',
        details: e,
      );
    }
  }
  
  Future<void> resetAll(ResetLevel level) async {
    _emitEvent(StateEvent.resettingAll(level));
    
    final domains = _registry.getAllDomains().reversed.toList();
    
    for (final domain in domains) {
      if (domain.canReset) {
        await _resetDomain(domain, level);
      }
    }
    
    _emitEvent(StateEvent.resetAll(level));
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
  
  void _emitEvent(StateEvent event) {
    _eventStream.add(event);
  }
  
  Stream<StateEvent> get eventStream => _eventStream.stream;
  
  DomainRegistry get registry => _registry;
  
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
