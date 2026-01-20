// lib/src/runtime_control/lifecycle_phase.dart
// Defines all possible lifecycle phases for the application runtime

enum LifecyclePhase {
  uninitialized,
  
  initializing,
  
  initialized,
  
  running,
  
  paused,
  
  refreshing,
  
  restarting,
  
  resetting,
  
  disposing,
  
  disposed,
  
  error,
}

extension LifecyclePhaseExtension on LifecyclePhase {
  bool get canTransitionTo => this == LifecyclePhase.initialized || 
                              this == LifecyclePhase.running ||
                              this == LifecyclePhase.paused;
  
  bool get isActive => this == LifecyclePhase.running || 
                       this == LifecyclePhase.paused;
  
  bool get isTransitioning => this == LifecyclePhase.initializing ||
                              this == LifecyclePhase.refreshing ||
                              this == LifecyclePhase.restarting ||
                              this == LifecyclePhase.resetting ||
                              this == LifecyclePhase.disposing;
  
  bool get isTerminal => this == LifecyclePhase.disposed || 
                         this == LifecyclePhase.error;
}
