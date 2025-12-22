// lib/src/app_state/app_state_manager_impl.dart
import 'package:flutter/foundation.dart';
import 'app_state_manager.dart';
import '../logging/logger_service.dart';

class AppStateManagerImpl implements AppStateManager {
  final LoggerService _logger;
  final ValueNotifier<AppState> _state = ValueNotifier(AppState.uninitialized);
  bool _isInitialized = false;
  bool _isAuthenticated = false;

  AppStateManagerImpl(this._logger);

  @override
  ValueNotifier<AppState> get state => _state;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> initialize() async {
    try {
      _state.value = AppState.initializing;
      _logger.info('Initializing app state...');
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      _isInitialized = true;
      _state.value = AppState.initialized;
      _logger.info('App state initialized');
    } catch (e) {
      _state.value = AppState.error;
      _logger.error('Failed to initialize app state', error: e);
      rethrow;
    }
  }

  @override
  Future<void> setAuthenticated(bool value) async {
    _isAuthenticated = value;
    _state.value = value ? AppState.authenticated : AppState.unauthenticated;
    _logger.info('Authentication state changed: $value');
  }

  @override
  Future<void> reset() async {
    _isInitialized = false;
    _isAuthenticated = false;
    _state.value = AppState.uninitialized;
    _logger.info('App state reset');
  }

  void dispose() {
    _state.dispose();
  }
}

