// lib/examples/logging_advanced_example.dart
// Advanced logging examples showcasing new split configuration architecture
// NOTE: This file uses deprecated LogConfig API and needs to be updated.
// @deprecated - Under maintenance

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

void demonstrateNewLoggingArchitecture() {
  print('=== Advanced Logging Architecture Examples ===\n');

  example1SimpleConfiguration();
  example2SplitConfiguration();
  example3ProductionReadyConfiguration();
  example4StrictModeConfiguration();
  example5MemoryBufferUsage();
}

void example1SimpleConfiguration() {
  print('Example 1: Simple Configuration');
  print('--------------------------------');

  final config = LogConfig.simple(
    globalLevel: LogLevel.info,
    enableColors: true,
    allowUnregisteredModules: true,
  );

  LoggerImpl.initialize(config);

  final logger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'SimpleExample',
      moduleType: ModuleType.service,
    ),
  );

  logger.info(() => 'Simple configuration initialized');

  LoggerImpl.dispose();
  print('✓ Simple configuration completed\n');
}

void example2SplitConfiguration() {
  print('Example 2: Split Core + Module Configuration');
  print('---------------------------------------------');

  final coreConfig = LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.trace,
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
      LogEnvironment.profile: {LogTarget.console, LogTarget.file},
      LogEnvironment.release: {LogTarget.file, LogTarget.memory},
    },
    allowUnregisteredModules: true,
    strictMode: false,
  );

  final moduleConfig = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.debug,
    enableColors: true,
    modules: {
      'AuthService': const LogModuleConfig(
        type: ModuleType.authentication,
        level: LogLevel.trace,
        enabled: true,
      ),
      'NetworkClient': const LogModuleConfig(
        type: ModuleType.network,
        level: LogLevel.debug,
        enabled: true,
      ),
    },
  );

  final config = LogConfig(coreConfig: coreConfig, moduleConfig: moduleConfig);

  LoggerImpl.initialize(config);

  final authLogger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'AuthService',
      moduleType: ModuleType.authentication,
    ),
  );

  authLogger.trace(() => 'Trace level log from AuthService');
  authLogger.info(() => 'Info level log from AuthService');

  LoggerImpl.dispose();
  print('✓ Split configuration completed\n');
}

void example3ProductionReadyConfiguration() {
  print('Example 3: Production-Ready Multi-Environment');
  print('---------------------------------------------');

  final coreConfig = LoggerCoreConfig(
    environment: LogEnvironment.release,
    environmentLevels: {
      LogEnvironment.development: LogLevel.trace,
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
      LogEnvironment.profile: {LogTarget.console, LogTarget.file},
      LogEnvironment.release: {LogTarget.file, LogTarget.remote},
    },
    allowUnregisteredModules: false,
    strictMode: true,
  );

  final moduleConfig = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.warning,
    enableColors: false,
    modules: {
      'PaymentService': const LogModuleConfig(
        type: ModuleType.payment,
        level: LogLevel.error,
        enabled: true,
      ),
      'AuthService': const LogModuleConfig(
        type: ModuleType.authentication,
        level: LogLevel.error,
        enabled: true,
      ),
    },
    disabledModuleTypes: {
      ModuleType.view,
      ModuleType.viewModel,
      ModuleType.analytics,
    },
    disabledLevels: {LogLevel.trace, LogLevel.debug, LogLevel.info},
  );

  final config = LogConfig(coreConfig: coreConfig, moduleConfig: moduleConfig);

  LoggerImpl.initialize(config);

  final paymentLogger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'PaymentService',
      moduleType: ModuleType.payment,
    ),
  );

  paymentLogger.error(() => 'Payment processing failed');
  paymentLogger.fatal(() => 'Critical payment system error');

  LoggerImpl.dispose();
  print('✓ Production configuration completed\n');
}

void example4StrictModeConfiguration() {
  print('Example 4: Strict Mode with Validation');
  print('---------------------------------------');

  final config = LogConfig.simple(
    globalLevel: LogLevel.info,
    strictMode: true,
    allowUnregisteredModules: false,
  );

  LoggerImpl.initialize(config);

  final logger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'ValidatedService',
      moduleType: ModuleType.service,
    ),
  );

  try {
    logger.info(() => 'This will be filtered (unregistered in strict mode)');
  } catch (e) {
    print('Expected behavior: $e');
  }

  LoggerImpl.dispose();
  print('✓ Strict mode completed\n');
}

void example5MemoryBufferUsage() {
  print('Example 5: Memory Buffer for In-App Debugging');
  print('---------------------------------------------');

  final coreConfig = LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {LogEnvironment.development: LogLevel.debug},
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console, LogTarget.memory},
    },
    allowUnregisteredModules: true,
  );

  final moduleConfig = LoggerModuleRegistryConfig.minimal(
    globalLevel: LogLevel.debug,
  );

  final config = LogConfig(coreConfig: coreConfig, moduleConfig: moduleConfig);

  LoggerImpl.initialize(config);

  final logger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'MemoryExample',
      moduleType: ModuleType.service,
    ),
  );

  logger.debug(() => 'Log entry 1');
  logger.info(() => 'Log entry 2');
  logger.warning(() => 'Log entry 3');

  final memoryOutput = LoggerImpl.getMemoryOutput();
  if (memoryOutput != null) {
    print('Captured logs in memory: ${memoryOutput.logCount}');
    final recentLogs = memoryOutput.getRecentLogs(2);
    print('Recent logs:');
    for (final log in recentLogs) {
      print('  - ${log.substring(0, log.length > 60 ? 60 : log.length)}...');
    }
  }

  LoggerImpl.dispose();
  print('✓ Memory buffer example completed\n');
}

void demonstrateUsageInServices() {
  print('=== Service Integration Examples ===\n');

  final config = LogConfig.recommended();
  LoggerImpl.initialize(config);

  final authService = MockAuthService();
  authService.login('user@example.com', 'password');

  final networkService = MockNetworkService();
  networkService.fetchData('/api/users');

  LoggerImpl.dispose();
}

class MockAuthService {
  late final Logger _log;

  MockAuthService() {
    _log = LoggerImpl.forModule(
      const LogModule(
        moduleName: 'AuthService',
        moduleType: ModuleType.authentication,
      ),
    );
  }

  Future<void> login(String email, String password) async {
    _log.info(() => 'Login attempt for: $email');
    _log.debug(() => 'Validating credentials');
    _log.info(() => 'Login successful');
  }
}

class MockNetworkService {
  late final Logger _log;

  MockNetworkService() {
    _log = LoggerImpl.forModule(
      const LogModule(
        moduleName: 'NetworkClient',
        moduleType: ModuleType.network,
      ),
    );
  }

  Future<void> fetchData(String endpoint) async {
    _log.debug(() => 'GET request to: $endpoint');
    _log.info(() => 'Response received: 200 OK');
  }
}
