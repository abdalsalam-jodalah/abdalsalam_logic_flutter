// lib/src/runtime_control/app_control_runtime_impl.dart
// Implementation of the application runtime control system

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'app_control.dart';
import 'app_control_runtime.dart';
import 'domain_registry.dart';
import 'lifecycle_phase.dart';
import 'platform_restart.dart';
import 'reset_level.dart';
import 'runtime_domain.dart';
import 'runtime_exception.dart';
import 'state_controller.dart';
import 'ui_tree_controller.dart';

class AppControlRuntimeImpl implements AppControlRuntime {
  late final DomainRegistry _registry;
  late final StateController _stateController;
  late final UITreeController _uiController;
  
  final StreamController<LifecyclePhase> _phaseStream = StreamController.broadcast();
  final StreamController<RuntimeEvent> _eventStream = StreamController.broadcast();
  
  LifecyclePhase _currentPhase = LifecyclePhase.uninitialized;
  
  bool _isStarted = false;
  
  AppControlRuntimeImpl() {
    _registry = DomainRegistry();
    _uiController = UITreeController.instance;
    _stateController = StateController(_registry);
  }
  
  @override
  LifecyclePhase get currentPhase => _currentPhase;
  
  @override
  Stream<LifecyclePhase> get phaseStream => _phaseStream.stream;
  
  @override
  Stream<RuntimeEvent> get eventStream => _eventStream.stream;
  
  @override
  Future<void> start() async {
    // Handle already started case gracefully
    if (_isStarted && _currentPhase == LifecyclePhase.running) {
      debugPrint('Runtime already running, skipping start');
      _emitEvent(RuntimeEvent.started()); // Emit event anyway
      return;
    }
    
    // Reset if in disposed state
    if (_currentPhase == LifecyclePhase.disposed) {
      _currentPhase = LifecyclePhase.uninitialized;
      _isStarted = false;
    }

    await _transitionTo(LifecyclePhase.initializing);
    _emitEvent(RuntimeEvent.starting());
    
    try {
      // STRICT ENFORCEMENT: Validate all domains before starting
      _registry.validateConsistency();
      
      // Enforce minimum required domains if configured
      _enforceRequiredDomains();
      
      await _stateController.initializeAll();
      
      await _transitionTo(LifecyclePhase.initialized);
      await _transitionTo(LifecyclePhase.running);
      
      _isStarted = true;
      _emitEvent(RuntimeEvent.started());
    } catch (e) {
      await _transitionTo(LifecyclePhase.error);
      _emitEvent(RuntimeEvent.error('Failed to start runtime', e));
      rethrow;
    }
  }
  
  @override
  Future<void> platformRestart() async {
    try {
      _emitEvent(RuntimeEvent.platformRestarting());
      await _platformRestart();
    } catch (e) {
      await _transitionTo(LifecyclePhase.error);
      _emitEvent(RuntimeEvent.error('Platform restart failed', e));
      rethrow;
    }
  }
  
  @override
  Future<void> restart() async {
    // Allow restart from any state for recovery
    if (_currentPhase == LifecyclePhase.error || _currentPhase == LifecyclePhase.disposed) {
      // Reset to allow restart
      _currentPhase = LifecyclePhase.uninitialized;
      _isStarted = false;
    }
    
    await _transitionTo(LifecyclePhase.restarting);
    _emitEvent(RuntimeEvent.restarting());
    
    try {
      // First try graceful restart
      await _gracefulRestart();
      
    } catch (e) {
      // If graceful restart fails, try platform restart
      try {
        await _platformRestart();
      } catch (platformError) {
        await _transitionTo(LifecyclePhase.error);
        _emitEvent(RuntimeEvent.error('Failed to restart runtime', platformError));
        rethrow;
      }
    }
  }
  
  Future<void> _gracefulRestart() async {
    // Dispose all domains
    await _stateController.disposeAll();
    
    // Clear UI completely
    await _uiController.recreateAllTrees();
    
    // Reset to uninitialized state
    await _transitionTo(LifecyclePhase.uninitialized);
    _isStarted = false;
    
    // Restart
    await start();
    _emitEvent(RuntimeEvent.restarted());
  }
  
  Future<void> _platformRestart() async {
    final platformRestart = PlatformRestart.instance;
    
    if (platformRestart.supportsRestart) {
      _emitEvent(RuntimeEvent.platformRestarting());
      
      // Give a moment for the event to be processed
      await Future.delayed(const Duration(milliseconds: 100));
      
      final success = await platformRestart.restartApp();
      if (!success) {
        throw RuntimeException('Platform restart failed');
      }
    } else {
      throw RuntimeException('Platform restart not supported on ${platformRestart.platformName}');
    }
  }
  
  @override
  Future<void> refreshApp() async {
    await resetStates(ResetLevel.soft);
  }
  
  @override
  Future<void> refreshUI() async {
    _ensureRunning('refreshUI');
    
    await _transitionTo(LifecyclePhase.refreshing);
    _emitEvent(RuntimeEvent.refreshing(ResetLevel.uiOnly));
    
    try {
      await _uiController.refreshUI();
      
      await _transitionTo(LifecyclePhase.running);
      _emitEvent(RuntimeEvent.refreshed(ResetLevel.uiOnly));
    } catch (e) {
      await _transitionTo(LifecyclePhase.error);
      _emitEvent(RuntimeEvent.error('Failed to refresh UI', e));
      rethrow;
    }
  }
  
  @override
  Future<void> refreshAllTrees() async {
    _ensureRunning('refreshAllTrees');
    
    await _transitionTo(LifecyclePhase.refreshing);
    _emitEvent(RuntimeEvent.refreshing(ResetLevel.soft));
    
    try {
      await _uiController.rebuildAllTrees();
      
      await _transitionTo(LifecyclePhase.running);
      _emitEvent(RuntimeEvent.refreshed(ResetLevel.soft));
    } catch (e) {
      await _transitionTo(LifecyclePhase.error);
      _emitEvent(RuntimeEvent.error('Failed to refresh all trees', e));
      rethrow;
    }
  }
  
  @override
  Future<void> resetStates(ResetLevel level) async {
    _ensureRunning('resetStates');
    
    await _transitionTo(LifecyclePhase.resetting);
    _emitEvent(RuntimeEvent.refreshing(level));
    
    try {
      if (level.shouldResetUI) {
        await _uiController.rebuildAllTrees();
      }
      
      if (level.shouldResetTransientState || level.shouldResetPersistentState) {
        await _stateController.resetAll(level);
      }
      
      if (level.shouldResetRuntime) {
        await _stateController.reinitializeAll();
      }
      
      await _transitionTo(LifecyclePhase.running);
      _emitEvent(RuntimeEvent.refreshed(level));
    } catch (e) {
      await _transitionTo(LifecyclePhase.error);
      _emitEvent(RuntimeEvent.error('Failed to reset states', e));
      rethrow;
    }
  }
  
  void _ensureRunning(String operation) {
    // Allow operations if not started but allow recovery from error
    if (!_isStarted && _currentPhase == LifecyclePhase.uninitialized) {
      // Auto-start if needed
      start();
      return;
    }
    
    // Allow operations in error state for recovery
    if (_currentPhase == LifecyclePhase.error) {
      // Reset to running state for recovery
      _currentPhase = LifecyclePhase.running;
      _isStarted = true;
      return;
    }
    
    if (_currentPhase != LifecyclePhase.running && 
        _currentPhase != LifecyclePhase.paused && 
        _currentPhase != LifecyclePhase.initialized) {
      throw RuntimeException('Cannot call $operation while in phase: $_currentPhase');
    }
  }
  
  @override
  Future<void> resetRuntime() async {
    await resetStates(ResetLevel.complete);
  }
  
  @override
  Future<void> stop() async {
    if (!_isStarted && _currentPhase == LifecyclePhase.uninitialized) {
      throw RuntimeException('Cannot stop - runtime not started');
    }
    
    await _transitionTo(LifecyclePhase.disposing);
    _emitEvent(RuntimeEvent.stopping());
    
    try {
      await _stateController.disposeAll();
      _uiController.dispose();
      
      await _transitionTo(LifecyclePhase.disposed);
      
      _isStarted = false;
      _emitEvent(RuntimeEvent.stopped());
      
      // Don't close streams - keep them open for restart
      // _phaseStream.close();
      // _eventStream.close();
    } catch (e) {
      await _transitionTo(LifecyclePhase.error);
      _emitEvent(RuntimeEvent.error('Failed to stop runtime', e));
      rethrow;
    }
  }
  
  @override
  void registerDomain(RuntimeDomain domain) {
    if (_isStarted) {
      throw RuntimeException('Cannot register domains after runtime has started');
    }
    _registry.register(domain);
  }
  
  @override
  void registerDomains(List<RuntimeDomain> domains) {
    if (_isStarted) {
      throw RuntimeException('Cannot register domains after runtime has started');
    }
    _registry.registerAll(domains);
  }
  
  Future<void> _transitionTo(LifecyclePhase newPhase) async {
    _validateTransition(_currentPhase, newPhase);
    _currentPhase = newPhase;
    
    // Safely add to phase stream
    try {
      if (!_phaseStream.isClosed) {
        _phaseStream.add(newPhase);
      }
    } catch (e) {
      debugPrint('Error adding to phase stream: $e');
    }
    
    _emitEvent(RuntimeEvent.phaseChange(newPhase));
  }
  
  void _validateTransition(LifecyclePhase from, LifecyclePhase to) {
    if (!from.canTransitionToPhase(to)) {
      throw IllegalLifecycleTransitionException(from.toString(), to.toString());
    }
  }
  
  void _emitEvent(RuntimeEvent event) {
    try {
      if (!_eventStream.isClosed) {
        _eventStream.add(event);
      }
    } catch (e) {
      debugPrint('Error emitting event: $e');
    }
  }
  
  @override
  UITreeController get uiController => _uiController;
  
  @override
  StateController get stateController => _stateController;
  
  @override
  DomainRegistry get registry => _registry;
  
  @override
  bool get isRunning => _currentPhase == LifecyclePhase.running;
  
  @override
  bool get isInitialized => _currentPhase.index >= LifecyclePhase.initialized.index;
  
  /// STRICT ENFORCEMENT: Ensures USER-CONFIGURED required domains are registered
  void _enforceRequiredDomains() {
    // Get required domains from USER CONFIG (not hard-coded)
    final config = AppControl.config;
    
    // If strict validation is enabled, enforce USER requirements
    if (config.enableStrictValidation) {
      final registeredIds = _registry.getAllDomains().map((d) => d.domainId).toSet();
      
      // Enforce ONLY domains that USER explicitly required in config
      for (final requiredId in config.requiredDomains) {
        if (!registeredIds.contains(requiredId)) {
          throw RuntimeException(
            'Required domain "$requiredId" is not registered. '
            'This is YOUR requirement from RuntimeConfig.requiredDomains. '
            'Either register a domain with ID "$requiredId" or remove it from requiredDomains.',
          );
        }
      }
      
      // Optional suggestions (USER can ignore these)
      if (config.requiredDomains.isEmpty) {
        const optionalSuggestions = {
          'storage': 'Consider a domain for data persistence',
          'logging': 'Consider a domain for error tracking',
        };
        
        for (final entry in optionalSuggestions.entries) {
          if (!registeredIds.contains(entry.key)) {
            debugPrint('💡 Optional: ${entry.value} (you can ignore this)');
          }
        }
      }
      
      // Only enforce minimum if user hasn't configured specific requirements
      if (registeredIds.isEmpty && config.requiredDomains.isEmpty) {
        throw RuntimeException(
          'No domains registered and no specific requirements configured. '
          'Either register domains or set requiredDomains in RuntimeConfig, or disable strict validation.',
        );
      }
      
      // Additional user-helpful validation
      _validateUserDomainPatterns(registeredIds);
    }
  }
  
  void _validateUserDomainPatterns(Set<String> registeredIds) {
    // These are just SUGGESTIONS based on common patterns - user can ignore
    
    // Pattern suggestion: auth usually needs storage
    if (registeredIds.contains('auth') && !registeredIds.contains('storage')) {
      debugPrint('💡 Pattern suggestion: Auth domains often need storage for tokens (optional)');
    }
    
    // Pattern suggestion: network usually needs auth  
    if (registeredIds.contains('network') && !registeredIds.contains('auth')) {
      debugPrint('💡 Pattern suggestion: Network domains often need auth for APIs (optional)');
    }
    
    // Performance note (not a requirement)
    if (registeredIds.length > 20) {
      debugPrint('ℹ️ Performance note: ${registeredIds.length} domains. Consider grouping for faster startup (optional)');
    }
    
    // Note: All of these are suggestions - user has complete control
  }
}
