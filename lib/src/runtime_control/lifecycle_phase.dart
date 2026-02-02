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
  
  bool get isTerminal => this == LifecyclePhase.disposed;
  
  /// Returns valid transitions from this phase
  Set<LifecyclePhase> get validTransitions {
    switch (this) {
      case LifecyclePhase.uninitialized:
        return {LifecyclePhase.initializing};
      case LifecyclePhase.initializing:
        return {LifecyclePhase.initialized, LifecyclePhase.error};
      case LifecyclePhase.initialized:
        return {LifecyclePhase.running, LifecyclePhase.disposing, LifecyclePhase.error};
      case LifecyclePhase.running:
        return {
          LifecyclePhase.paused,
          LifecyclePhase.refreshing,
          LifecyclePhase.restarting,
          LifecyclePhase.resetting,
          LifecyclePhase.disposing,
          LifecyclePhase.error,
        };
      case LifecyclePhase.paused:
        return {
          LifecyclePhase.running,
          LifecyclePhase.refreshing,
          LifecyclePhase.restarting,
          LifecyclePhase.resetting,
          LifecyclePhase.disposing,
          LifecyclePhase.error,
        };
      case LifecyclePhase.refreshing:
        return {LifecyclePhase.running, LifecyclePhase.error};
      case LifecyclePhase.restarting:
        return {LifecyclePhase.uninitialized, LifecyclePhase.running, LifecyclePhase.error};
      case LifecyclePhase.resetting:
        return {LifecyclePhase.running, LifecyclePhase.error};
      case LifecyclePhase.disposing:
        return {LifecyclePhase.disposed, LifecyclePhase.error};
      case LifecyclePhase.disposed:
        return {LifecyclePhase.uninitialized, LifecyclePhase.initializing}; // Allow direct restart
      case LifecyclePhase.error:
        return {
          LifecyclePhase.uninitialized, 
          LifecyclePhase.disposing,
          LifecyclePhase.running,      // Allow recovery to running
          LifecyclePhase.restarting,   // Allow restart from error
          LifecyclePhase.refreshing,   // Allow refresh from error
          LifecyclePhase.resetting,    // Allow reset from error
        };
    }
  }
  
  bool canTransitionToPhase(LifecyclePhase target) {
    return validTransitions.contains(target);
  }
}
