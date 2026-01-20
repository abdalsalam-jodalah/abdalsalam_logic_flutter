// lib/src/runtime_control/reset_level.dart
// Defines graduated reset levels for state and UI control

enum ResetLevel {
  uiOnly,
  
  soft,
  
  medium,
  
  hard,
  
  complete,
}

extension ResetLevelExtension on ResetLevel {
  bool get shouldResetUI => true;
  
  bool get shouldResetTransientState => 
      this == ResetLevel.medium || 
      this == ResetLevel.hard || 
      this == ResetLevel.complete;
  
  bool get shouldResetPersistentState => 
      this == ResetLevel.hard || 
      this == ResetLevel.complete;
  
  bool get shouldResetRuntime => this == ResetLevel.complete;
  
  String get description {
    switch (this) {
      case ResetLevel.uiOnly:
        return 'UI refresh only - no state loss';
      case ResetLevel.soft:
        return 'UI rebuild - preserve all state';
      case ResetLevel.medium:
        return 'Clear transient and feature state - preserve persistent data';
      case ResetLevel.hard:
        return 'Clear all state - rebuild runtime and UI from scratch';
      case ResetLevel.complete:
        return 'Complete reset - reinitialize as if freshly launched';
    }
  }
}
