// lib/examples/logging_example.dart
// Comprehensive logging system usage examples

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class AuthService {
  late final Logger _log;

  AuthService() {
    _log = LoggerImpl.forModule(
      const LogModule(
        moduleName: 'AuthService',
        moduleType: ModuleType.service,
      ),
    );
  }

  Future<void> login(String email, String password) async {
    _log.info(() => 'Login attempt for user: $email');

    try {
      _log.debug(() => 'Validating credentials...');

      await Future.delayed(const Duration(seconds: 1));

      _log.info(() => 'Login successful for user: $email');
    } catch (e, stackTrace) {
      _log.error(() => 'Login failed for user: $email', e, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    _log.info(() => 'User logout initiated');
    await Future.delayed(const Duration(milliseconds: 500));
    _log.info(() => 'User logged out successfully');
  }
}

class UserViewModel {
  late final Logger _log;

  UserViewModel() {
    _log = LoggerImpl.forModule(
      const LogModule(
        moduleName: 'UserViewModel',
        moduleType: ModuleType.viewModel,
      ),
    );
  }

  Future<void> loadUserProfile(String userId) async {
    _log.trace(() => 'loadUserProfile called with userId: $userId');
    _log.debug(() => 'Fetching user profile from repository...');

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _log.info(() => 'User profile loaded successfully');
    } catch (e, stackTrace) {
      _log.error(() => 'Failed to load user profile', e, stackTrace);
      rethrow;
    }
  }

  void updateUserName(String newName) {
    _log.debug(() => 'Updating user name to: $newName');
    _log.info(() => 'User name updated successfully');
  }
}

class NetworkClient {
  late final Logger _log;

  NetworkClient() {
    _log = LoggerImpl.forModule(
      const LogModule(
        moduleName: 'NetworkClient',
        moduleType: ModuleType.network,
      ),
    );
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    _log.debug(() => 'GET request to: $endpoint');

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _log.trace(() => 'Response received with status: 200');
      _log.info(() => 'GET request successful: $endpoint');

      return {'status': 'success'};
    } catch (e, stackTrace) {
      _log.error(() => 'GET request failed: $endpoint', e, stackTrace);
      rethrow;
    }
  }

  Future<void> post(String endpoint, Map<String, dynamic> data) async {
    _log.debug(() => 'POST request to: $endpoint');
    _log.trace(() => 'Request payload: $data');

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _log.info(() => 'POST request successful: $endpoint');
    } catch (e, stackTrace) {
      _log.fatal(() => 'Critical POST failure: $endpoint', e, stackTrace);
      rethrow;
    }
  }
}

void demonstrateLoggingSystem() {
  final config = LogConfig(
    globalLevel: LogLevel.debug,
    enableColors: true,
    modules: {
      'AuthService': const LogModuleConfig(
        type: ModuleType.service,
        enabled: true,
        level: LogLevel.trace,
      ),
      'UserViewModel': const LogModuleConfig(
        type: ModuleType.viewModel,
        enabled: true,
        level: LogLevel.debug,
      ),
      'NetworkClient': const LogModuleConfig(
        type: ModuleType.network,
        enabled: true,
        level: LogLevel.info,
      ),
    },
    rejectUnregisteredModules: false,
    enableConsoleInRelease: false,
  );

  LoggerImpl.initialize(config);

  final authService = AuthService();
  final userViewModel = UserViewModel();
  final networkClient = NetworkClient();

  authService.login('user@example.com', 'password123');
  userViewModel.loadUserProfile('user-123');
  userViewModel.updateUserName('John Doe');
  networkClient.get('/api/users/123');
  networkClient.post('/api/users', {'name': 'Jane Doe'});

  authService.logout();
}

void demonstrateModuleFiltering() {
  final config = LogConfig(
    globalLevel: LogLevel.info,
    enableColors: true,
    modules: {
      'AuthService': const LogModuleConfig(
        type: ModuleType.service,
        enabled: true,
      ),
      'NetworkClient': const LogModuleConfig(
        type: ModuleType.network,
        enabled: false,
      ),
    },
    disabledModuleTypes: {ModuleType.viewModel},
  );

  LoggerImpl.initialize(config);
}

void demonstrateStrictMode() {
  final config = LogConfig(
    globalLevel: LogLevel.warning,
    enableColors: true,
    rejectUnregisteredModules: true,
    modules: {
      'AuthService': const LogModuleConfig(
        type: ModuleType.service,
        enabled: true,
        level: LogLevel.debug,
      ),
    },
  );

  LoggerImpl.initialize(config);
}
