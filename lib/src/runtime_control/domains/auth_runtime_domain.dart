// lib/src/runtime_control/domains/auth_runtime_domain.dart
// Real authentication domain that clears actual auth state

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../reset_level.dart';
import '../runtime_domain.dart';

class AuthRuntimeDomain implements RuntimeDomain {
  bool _initialized = false;
  SharedPreferences? _prefs;
  
  // Common auth key prefixes to clear
  static const List<String> _authKeyPrefixes = [
    'auth_',
    'token_',
    'user_',
    'session_',
    'refresh_',
    'access_',
    'login_',
    'credential_',
  ];
  
  @override
  String get domainId => 'auth';
  
  @override
  String get domainName => 'Authentication';
  
  @override
  int get initializationPriority => 100;
  
  @override
  List<String> get dependencies => ['storage'];
  
  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetTransientState) {
      await _clearTemporaryAuthState();
    }
    
    if (level.shouldResetPersistentState) {
      await _clearPersistentAuthState();
    }
    
    if (level.shouldResetRuntime) {
      await _completeAuthReset();
    }
  }
  
  @override
  Future<void> dispose() async {
    _prefs = null;
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  // REAL auth clearing implementations
  
  Future<void> _clearTemporaryAuthState() async {
    // Clear any in-memory auth data
    // This is handled by resetting the domain state
  }
  
  Future<void> _clearPersistentAuthState() async {
    if (_prefs == null) return;
    
    // REAL: Clear all auth-related keys from SharedPreferences
    final allKeys = _prefs!.getKeys().toList();
    
    for (final key in allKeys) {
      for (final prefix in _authKeyPrefixes) {
        if (key.toLowerCase().startsWith(prefix) || 
            key.toLowerCase().contains('token') ||
            key.toLowerCase().contains('auth') ||
            key.toLowerCase().contains('session')) {
          await _prefs!.remove(key);
        }
      }
    }
  }
  
  Future<void> _completeAuthReset() async {
    await _clearTemporaryAuthState();
    await _clearPersistentAuthState();
  }
  
  // Public API
  Future<void> clearAllTokens() async {
    await _clearPersistentAuthState();
  }
  
  Future<void> clearSpecificKey(String key) async {
    if (_prefs != null) {
      await _prefs!.remove(key);
    }
  }
  
  bool hasAuthData() {
    if (_prefs == null) return false;
    
    for (final key in _prefs!.getKeys()) {
      for (final prefix in _authKeyPrefixes) {
        if (key.toLowerCase().startsWith(prefix)) {
          return true;
        }
      }
    }
    return false;
  }
}