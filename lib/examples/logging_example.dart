// lib/examples/logging_example.dart
// Comprehensive logging system usage examples

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class AuthService {
  late final Logger _log;

  AuthService() {
    _log = LoggerImpl.forModule(
      const LogModule(
        moduleName: 'AuthService',
        moduleType: ModuleType.authentication,
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

void demonstrateBasicLogging() {
  final config = LogConfig(
    developmentConfig: const EnvironmentLogConfig(
      globalLevel: LogLevel.trace,
      enableColors: true,
      outputs: [ConsoleOutput()],
      allowUnregisteredModules: true,
    ),
    profileConfig: const EnvironmentLogConfig(
      globalLevel: LogLevel.debug,
      enableColors: true,
      outputs: [ConsoleOutput()],
      allowUnregisteredModules: true,
    ),
    releaseConfig: EnvironmentLogConfig(
      globalLevel: LogLevel.error,
      enableColors: false,
      outputs: [
        FileOutput(
          fileName: 'app_logs.txt',
          maxFileSizeBytes: 5 * 1024 * 1024,
        ),
        RemoteOutput(
          endpoint: 'https://api.example.com/logs',
          allowedLevels: {'ERROR', 'FATAL'},
        ),
      ],
      allowUnregisteredModules: false,
    ),
    modules: {
      'AuthService': const LogModuleConfig(
        type: ModuleType.authentication,
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

void demonstrateMultipleOutputs() {
  final config = LogConfig(
    developmentConfig: EnvironmentLogConfig(
      globalLevel: LogLevel.debug,
      enableColors: true,
      outputs: [
        const ConsoleOutput(),
        FileOutput(
          fileName: 'dev_logs.txt',
          maxFileSizeBytes: 10 * 1024 * 1024,
          maxBackupFiles: 3,
        ),
      ],
      allowUnregisteredModules: true,
    ),
    releaseConfig: EnvironmentLogConfig(
      globalLevel: LogLevel.error,
      enableColors: false,
      outputs: [
        FileOutput(
          fileName: 'production_logs.txt',
          maxFileSizeBytes: 20 * 1024 * 1024,
          maxBackupFiles: 10,
        ),
        RemoteOutput(
          endpoint: 'https://crashreports.example.com/api/logs',
          headers: {'Authorization': 'Bearer your-token-here'},
          batchInterval: Duration(seconds: 60),
          maxBatchSize: 50,
          allowedLevels: {'ERROR', 'FATAL'},
        ),
      ],
      allowUnregisteredModules: false,
    ),
  );

  LoggerImpl.initialize(config);
}

void demonstrateModuleTypeFiltering() {
  final config = LogConfig(
    developmentConfig: const EnvironmentLogConfig(
      globalLevel: LogLevel.debug,
      enableColors: true,
      outputs: [ConsoleOutput()],
      allowUnregisteredModules: true,
      disabledModuleTypes: {
        ModuleType.view,
        ModuleType.analytics,
      },
    ),
    releaseConfig: const EnvironmentLogConfig(
      globalLevel: LogLevel.warning,
      enableColors: false,
      outputs: [ConsoleOutput()],
      allowUnregisteredModules: false,
      disabledModuleTypes: {
        ModuleType.view,
        ModuleType.viewModel,
        ModuleType.analytics,
        ModuleType.cache,
      },
    ),
  );

  LoggerImpl.initialize(config);
}

void demonstrateStrictMode() {
  final config = LogConfig(
    developmentConfig: const EnvironmentLogConfig(
      globalLevel: LogLevel.info,
      enableColors: true,
      outputs: [ConsoleOutput()],
      allowUnregisteredModules: false,
    ),
    modules: {
      'AuthService': const LogModuleConfig(
        type: ModuleType.authentication,
        enabled: true,
        level: LogLevel.debug,
      ),
      'PaymentService': const LogModuleConfig(
        type: ModuleType.payment,
        enabled: true,
        level: LogLevel.trace,
      ),
    },
  );

  LoggerImpl.initialize(config);
}

void demonstrateLevelFiltering() {
  final config = LogConfig(
    developmentConfig: const EnvironmentLogConfig(
      globalLevel: LogLevel.trace,
      enableColors: true,
      outputs: [ConsoleOutput()],
      allowUnregisteredModules: true,
    ),
    releaseConfig: const EnvironmentLogConfig(
      globalLevel: LogLevel.error,
      enableColors: false,
      outputs: [ConsoleOutput()],
      allowUnregisteredModules: false,
      disabledLevels: {
        LogLevel.trace,
        LogLevel.debug,
        LogLevel.info,
      },
    ),
  );

  LoggerImpl.initialize(config);
}

void demonstrateComprehensiveModuleTypes() {
  final config = LogConfig(
    developmentConfig: const EnvironmentLogConfig(
      globalLevel: LogLevel.debug,
      enableColors: true,
      outputs: [ConsoleOutput()],
      allowUnregisteredModules: true,
    ),
    modules: {
      'AuthService': const LogModuleConfig(
        type: ModuleType.authentication,
        enabled: true,
      ),
      'PermissionManager': const LogModuleConfig(
        type: ModuleType.authorization,
        enabled: true,
      ),
      'ApiClient': const LogModuleConfig(
        type: ModuleType.api,
        enabled: true,
      ),
      'DatabaseService': const LogModuleConfig(
        type: ModuleType.database,
        enabled: true,
      ),
      'CacheManager': const LogModuleConfig(
        type: ModuleType.cache,
        enabled: true,
      ),
      'BackgroundWorker': const LogModuleConfig(
        type: ModuleType.background,
        enabled: true,
      ),
      'TaskScheduler': const LogModuleConfig(
        type: ModuleType.scheduler,
        enabled: true,
      ),
      'AnalyticsService': const LogModuleConfig(
        type: ModuleType.analytics,
        enabled: false,
      ),
      'CrashReporter': const LogModuleConfig(
        type: ModuleType.crashReporting,
        enabled: true,
        level: LogLevel.error,
      ),
      'PaymentGateway': const LogModuleConfig(
        type: ModuleType.payment,
        enabled: true,
        level: LogLevel.info,
      ),
      'MediaProcessor': const LogModuleConfig(
        type: ModuleType.media,
        enabled: true,
      ),
      'LocationService': const LogModuleConfig(
        type: ModuleType.location,
        enabled: true,
      ),
      'PushNotifications': const LogModuleConfig(
        type: ModuleType.push,
        enabled: true,
      ),
      'DeepLinkHandler': const LogModuleConfig(
        type: ModuleType.deepLink,
        enabled: true,
      ),
      'BiometricAuth': const LogModuleConfig(
        type: ModuleType.biometric,
        enabled: true,
      ),
      'EncryptionService': const LogModuleConfig(
        type: ModuleType.encryption,
        enabled: true,
        level: LogLevel.warning,
      ),
      'SyncEngine': const LogModuleConfig(
        type: ModuleType.sync,
        enabled: true,
      ),
      'PrefetchManager': const LogModuleConfig(
        type: ModuleType.prefetch,
        enabled: true,
      ),
      'FileManager': const LogModuleConfig(
        type: ModuleType.fileSystem,
        enabled: true,
      ),
    },
  );

  LoggerImpl.initialize(config);
}

