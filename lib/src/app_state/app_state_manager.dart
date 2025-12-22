// lib/src/app_state/app_state_manager.dart
import 'package:flutter/foundation.dart';

abstract class AppStateManager {
  ValueNotifier<AppState> get state;
  bool get isInitialized;
  bool get isAuthenticated;
  
  Future<void> initialize();
  Future<void> setAuthenticated(bool value);
  Future<void> reset();
}

enum AppState {
  uninitialized,
  initializing,
  initialized,
  authenticated,
  unauthenticated,
  error,
}


