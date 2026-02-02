// lib/src/runtime_control/app_control_runtime.dart
// Main orchestrator for application runtime control and lifecycle management

import 'dart:async';

import 'domain_registry.dart';
import 'lifecycle_phase.dart';
import 'reset_level.dart';
import 'runtime_domain.dart';
import 'state_controller.dart';
import 'ui_tree_controller.dart';

abstract class AppControlRuntime {
  LifecyclePhase get currentPhase;
  
  Stream<LifecyclePhase> get phaseStream;
  
  Stream<RuntimeEvent> get eventStream;
  
  Future<void> start();
  
  Future<void> restart();
  
  Future<void> platformRestart();
  
  Future<void> refreshApp();
  
  Future<void> refreshUI();
  
  Future<void> refreshAllTrees();
  
  Future<void> resetStates(ResetLevel level);
  
  Future<void> resetRuntime();
  
  Future<void> stop();
  
  void registerDomain(RuntimeDomain domain);
  
  void registerDomains(List<RuntimeDomain> domains);
  
  UITreeController get uiController;
  
  StateController get stateController;
  
  DomainRegistry get registry;
  
  bool get isRunning;
  
  bool get isInitialized;
}

class RuntimeEvent {
  final RuntimeEventType type;
  final LifecyclePhase? phase;
  final ResetLevel? resetLevel;
  final String? message;
  final dynamic data;
  final DateTime timestamp;
  
  RuntimeEvent._({
    required this.type,
    this.phase,
    this.resetLevel,
    this.message,
    this.data,
  }) : timestamp = DateTime.now();
  
  factory RuntimeEvent.phaseChange(LifecyclePhase phase) => RuntimeEvent._(
        type: RuntimeEventType.phaseChange,
        phase: phase,
      );
  
  factory RuntimeEvent.starting() => RuntimeEvent._(
        type: RuntimeEventType.starting,
      );
  
  factory RuntimeEvent.started() => RuntimeEvent._(
        type: RuntimeEventType.started,
      );
  
  factory RuntimeEvent.restarting() => RuntimeEvent._(
        type: RuntimeEventType.restarting,
      );
  
  factory RuntimeEvent.restarted() => RuntimeEvent._(
        type: RuntimeEventType.restarted,
      );
  
  factory RuntimeEvent.platformRestarting() => RuntimeEvent._(
        type: RuntimeEventType.platformRestarting,
      );
  
  factory RuntimeEvent.refreshing(ResetLevel level) => RuntimeEvent._(
        type: RuntimeEventType.refreshing,
        resetLevel: level,
      );
  
  factory RuntimeEvent.refreshed(ResetLevel level) => RuntimeEvent._(
        type: RuntimeEventType.refreshed,
        resetLevel: level,
      );
  
  factory RuntimeEvent.stopping() => RuntimeEvent._(
        type: RuntimeEventType.stopping,
      );
  
  factory RuntimeEvent.stopped() => RuntimeEvent._(
        type: RuntimeEventType.stopped,
      );
  
  factory RuntimeEvent.error(String message, dynamic data) => RuntimeEvent._(
        type: RuntimeEventType.error,
        message: message,
        data: data,
      );
}

enum RuntimeEventType {
  phaseChange,
  starting,
  started,
  restarting,
  restarted,
  platformRestarting,
  refreshing,
  refreshed,
  stopping,
  stopped,
  error,
}

