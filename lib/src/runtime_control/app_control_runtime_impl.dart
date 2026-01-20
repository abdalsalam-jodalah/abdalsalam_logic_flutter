// lib/src/runtime_control/app_control_runtime_impl.dart
// Implementation of the application runtime control system

import 'dart:async';

import 'app_control_runtime.dart';
import 'domain_registry.dart';
import 'lifecycle_phase.dart';
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
    _uiController = UITreeController();
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
    if (_isStarted) {
      throw RuntimeException('Runtime already started');
    }
    
    await _transitionTo(LifecyclePhase.initializing);
    _emitEvent(RuntimeEvent.starting());
    
    try {
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
  Future<void> restart() async {
    await _transitionTo(LifecyclePhase.restarting);
    _emitEvent(RuntimeEvent.restarting());
    
    try {
      await _stateController.disposeAll();
      await _uiController.recreateAllTrees();
      
      await _transitionTo(LifecyclePhase.uninitialized);
      
      _isStarted = false;
      
      await start();
      
      _emitEvent(RuntimeEvent.restarted());
    } catch (e) {
      await _transitionTo(LifecyclePhase.error);
      _emitEvent(RuntimeEvent.error('Failed to restart runtime', e));
      rethrow;
    }
  }
  
  @override
  Future<void> refreshApp() async {
    await resetStates(ResetLevel.soft);
  }
  
  @override
  Future<void> refreshUI() async {
    await _transitionTo(LifecyclePhase.refreshing);
    _emitEvent(RuntimeEvent.refreshing(ResetLevel.uiOnly));
    
    try {
      await _uiController.refreshUI();
      
      await _transitionTo(LifecyclePhase.running);
      _emitEvent(RuntimeEvent.refreshed(ResetLevel.uiOnly));
    } catch (e) {
      _emitEvent(RuntimeEvent.error('Failed to refresh UI', e));
      rethrow;
    }
  }
  
  @override
  Future<void> refreshAllTrees() async {
    await _transitionTo(LifecyclePhase.refreshing);
    _emitEvent(RuntimeEvent.refreshing(ResetLevel.soft));
    
    try {
      await _uiController.rebuildAllTrees();
      
      await _transitionTo(LifecyclePhase.running);
      _emitEvent(RuntimeEvent.refreshed(ResetLevel.soft));
    } catch (e) {
      _emitEvent(RuntimeEvent.error('Failed to refresh all trees', e));
      rethrow;
    }
  }
  
  @override
  Future<void> resetStates(ResetLevel level) async {
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
  
  @override
  Future<void> resetRuntime() async {
    await resetStates(ResetLevel.complete);
  }
  
  @override
  Future<void> stop() async {
    await _transitionTo(LifecyclePhase.disposing);
    _emitEvent(RuntimeEvent.stopping());
    
    try {
      await _stateController.disposeAll();
      _uiController.dispose();
      
      await _transitionTo(LifecyclePhase.disposed);
      
      _isStarted = false;
      _emitEvent(RuntimeEvent.stopped());
      
      _phaseStream.close();
      _eventStream.close();
    } catch (e) {
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
    _phaseStream.add(newPhase);
    _emitEvent(RuntimeEvent.phaseChange(newPhase));
  }
  
  void _validateTransition(LifecyclePhase from, LifecyclePhase to) {
    if (from.isTerminal && to != LifecyclePhase.uninitialized) {
      throw IllegalLifecycleTransitionException(from.toString(), to.toString());
    }
  }
  
  void _emitEvent(RuntimeEvent event) {
    _eventStream.add(event);
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
}
