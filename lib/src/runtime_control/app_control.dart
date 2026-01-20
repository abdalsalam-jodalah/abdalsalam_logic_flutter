// lib/src/runtime_control/app_control.dart
// Singleton access point for App Control Runtime system

import 'app_control_runtime.dart';
import 'app_control_runtime_impl.dart';
import 'domain_registry.dart';
import 'lifecycle_phase.dart';
import 'reset_level.dart';
import 'runtime_config.dart';
import 'runtime_domain.dart';
import 'state_controller.dart';
import 'ui_tree_controller.dart';

class AppControl {
  static AppControlRuntime? _instance;
  static RuntimeConfig _config = const RuntimeConfig();
  
  static void initialize({RuntimeConfig? config}) {
    if (_instance != null) {
      throw StateError('AppControl already initialized');
    }
    
    _config = config ?? const RuntimeConfig();
    _instance = AppControlRuntimeImpl();
  }
  
  static AppControlRuntime get instance {
    if (_instance == null) {
      throw StateError('AppControl not initialized. Call AppControl.initialize() first.');
    }
    return _instance!;
  }
  
  static RuntimeConfig get config => _config;
  
  static Future<void> start() => instance.start();
  
  static Future<void> restart() => instance.restart();
  
  static Future<void> refreshApp() => instance.refreshApp();
  
  static Future<void> refreshUI() => instance.refreshUI();
  
  static Future<void> refreshAllTrees() => instance.refreshAllTrees();
  
  static Future<void> resetStates([ResetLevel? level]) => 
      instance.resetStates(level ?? _config.defaultResetLevel);
  
  static Future<void> resetRuntime() => instance.resetRuntime();
  
  static Future<void> stop() => instance.stop();
  
  static void registerDomain(RuntimeDomain domain) => 
      instance.registerDomain(domain);
  
  static void registerDomains(List<RuntimeDomain> domains) => 
      instance.registerDomains(domains);
  
  static UITreeController get uiController => instance.uiController;
  
  static StateController get stateController => instance.stateController;
  
  static DomainRegistry get registry => instance.registry;
  
  static LifecyclePhase get currentPhase => instance.currentPhase;
  
  static Stream<LifecyclePhase> get phaseStream => instance.phaseStream;
  
  static Stream<RuntimeEvent> get eventStream => instance.eventStream;
  
  static bool get isRunning => instance.isRunning;
  
  static bool get isInitialized => instance.isInitialized;
  
  static void reset() {
    _instance = null;
  }
}
