// lib/examples/logging_comprehensive_guide.dart
// Comprehensive guide to the strict logging system with all required parameters

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// ============================================================================
// COMPREHENSIVE LOGGING EXAMPLES - STRICT CONFIGURATION PATTERN
// ============================================================================
//
// Key Principles:
// 1. ALL parameters are REQUIRED - no defaults
// 2. Environment must be EXPLICITLY specified (no auto-detection)
// 3. NO factory methods - only explicit constructors
// 4. ALL configurations are IMMUTABLE and validated at runtime
// ============================================================================

void runComprehensiveLoggingGuide() {
  print('\n╔════════════════════════════════════════════════════════════╗');
  print('║    COMPREHENSIVE LOGGING SYSTEM GUIDE                      ║');
  print('║    Strict Configuration Pattern - All Parameters Required  ║');
  print('╚════════════════════════════════════════════════════════════╝\n');

  // Run all examples
  example1_BasicConfiguration();
  example2_DevelopmentEnvironment();
  example3_ProfileEnvironment();
  example4_ReleaseEnvironment();
  example5_StrictModeEnforcement();
  example6_MemoryBufferDebugging();
  example7_ServiceIntegration();
  example8_AdvancedFiltering();
  example9_CompleteProductionSetup();
}

// ============================================================================
// EXAMPLE 1: Basic Configuration (Minimal)
// ============================================================================
void example1_BasicConfiguration() {
  print('\n┌─ EXAMPLE 1: Basic Configuration ─────────────────────────┐');
  print('│ Shows minimal required configuration                      │');
  print('└──────────────────────────────────────────────────────────┘\n');

  // Step 1: Define core configuration (HOW the logger behaves)
  final coreConfig = LoggerCoreConfig(
    environment: LogEnvironment.development, // REQUIRED - explicit
    environmentLevels: {
      // REQUIRED - map all environments you use
      LogEnvironment.development: LogLevel.info,
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      // REQUIRED - specify output targets per environment
      LogEnvironment.development: {LogTarget.console},
      LogEnvironment.profile: {LogTarget.console},
      LogEnvironment.release: {LogTarget.file},
    },
    allowUnregisteredModules: true, // REQUIRED - no default
    strictMode: false, // REQUIRED - no default
  );

  // Step 2: Define module configuration (WHAT can log)
  final moduleConfig = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.info, // REQUIRED - no default
    enableColors: true, // REQUIRED - no default
    modules: const {}, // REQUIRED - can be empty map
  );

  // Step 3: Combine into unified config (BOTH required)
  final config = LogConfig(
    coreConfig: coreConfig,
    moduleConfig: moduleConfig,
  );

  // Step 4: Initialize the logger
  LoggerImpl.initialize(config);

  // Step 5: Create module-scoped logger
  final logger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'BasicExample',
      moduleType: ModuleType.service,
    ),
  );

  // Step 6: Use the logger
  logger.trace(() => 'This trace is filtered out (level > info)');
  logger.info(() => '✓ Basic configuration initialized');
  logger.warning(() => '⚠ This is a warning message');

  // Cleanup
  LoggerImpl.dispose();
  print('✓ Basic configuration example completed\n');
}

// ============================================================================
// EXAMPLE 2: Development Environment (Verbose)
// ============================================================================
void example2_DevelopmentEnvironment() {
  print('\n┌─ EXAMPLE 2: Development Environment Setup ────────────────┐');
  print('│ All log levels, colors, console + memory output            │');
  print('└──────────────────────────────────────────────────────────┘\n');

  final coreConfig = LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.trace, // Everything visible
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console, LogTarget.memory},
      LogEnvironment.profile: {LogTarget.console, LogTarget.file},
      LogEnvironment.release: {LogTarget.file},
    },
    allowUnregisteredModules: true,
    strictMode: false,
  );

  final moduleConfig = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.trace, // Capture everything
    enableColors: true, // Colorful output
    modules: {
      // Override for specific modules
      'DatabaseService': const LogModuleConfig(
        type: ModuleType.database,
        level: LogLevel.trace, // Extra verbose
        enabled: true,
      ),
    },
  );

  final config = LogConfig(
    coreConfig: coreConfig,
    moduleConfig: moduleConfig,
  );

  LoggerImpl.initialize(config);

  // Simulate different services logging
  _simulateAuthServiceDev();
  _simulateDatabaseServiceDev();
  _simulateNetworkServiceDev();

  LoggerImpl.dispose();
  print('✓ Development environment example completed\n');
}

void _simulateAuthServiceDev() {
  final logger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'AuthService',
      moduleType: ModuleType.authentication,
    ),
  );

  logger.trace(() => 'trace: Entering login method');
  logger.debug(() => 'debug: Validating email format');
  logger.info(() => 'info: User login initiated');
  logger.warning(() => 'warning: Password is weak');
}

void _simulateDatabaseServiceDev() {
  final logger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'DatabaseService',
      moduleType: ModuleType.database,
    ),
  );

  logger.trace(() => 'trace: Opening connection to SQLite');
  logger.debug(() => 'debug: Executing query: SELECT * FROM users');
  logger.info(() => 'info: Query executed in 45ms');
}

void _simulateNetworkServiceDev() {
  final logger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'NetworkClient',
      moduleType: ModuleType.network,
    ),
  );

  logger.debug(() => 'debug: Preparing GET request to /api/users');
  logger.info(() => 'info: Response received: 200 OK in 234ms');
}

// ============================================================================
// EXAMPLE 3: Profile Environment (Balanced)
// ============================================================================
void example3_ProfileEnvironment() {
  print('\n┌─ EXAMPLE 3: Profile Environment Setup ──────────────────┐');
  print('│ Debug and above, console + file output                    │');
  print('└──────────────────────────────────────────────────────────┘\n');

  final coreConfig = LoggerCoreConfig(
    environment: LogEnvironment.profile,
    environmentLevels: {
      LogEnvironment.development: LogLevel.trace,
      LogEnvironment.profile: LogLevel.debug, // Debug and above
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
      LogEnvironment.profile: {LogTarget.console, LogTarget.file},
      LogEnvironment.release: {LogTarget.file},
    },
    allowUnregisteredModules: true,
    strictMode: false,
  );

  final moduleConfig = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.debug,
    enableColors: true,
    modules: const {},
    disabledModuleTypes: {ModuleType.analytics}, // Reduce noise
  );

  final config = LogConfig(
    coreConfig: coreConfig,
    moduleConfig: moduleConfig,
  );

  LoggerImpl.initialize(config);

  final logger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'ProfileExample',
      moduleType: ModuleType.service,
    ),
  );

  logger.trace(() => 'trace: This is filtered out in profile');
  logger.debug(() => 'debug: ✓ Debug visible in profile');
  logger.info(() => 'info: ✓ Info visible in profile');
  logger.warning(() => 'warning: ✓ Warning visible in profile');
  logger.error(() => 'error: ✓ Error visible in profile');

  LoggerImpl.dispose();
  print('✓ Profile environment example completed\n');
}

// ============================================================================
// EXAMPLE 4: Release Environment (Minimal, Secure)
// ============================================================================
void example4_ReleaseEnvironment() {
  print('\n┌─ EXAMPLE 4: Release Environment Setup ──────────────────┐');
  print('│ Errors only, file + remote output, strict registration    │');
  print('└──────────────────────────────────────────────────────────┘\n');

  final coreConfig = LoggerCoreConfig(
    environment: LogEnvironment.release,
    environmentLevels: {
      LogEnvironment.development: LogLevel.trace,
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error, // Errors only
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
      LogEnvironment.profile: {LogTarget.console, LogTarget.file},
      LogEnvironment.release: {LogTarget.file, LogTarget.remote},
    },
    allowUnregisteredModules: false, // Strict registration
    strictMode: true, // Throw on violations
  );

  final moduleConfig = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.error,
    enableColors: false, // No colors in release
    modules: {
      // Only critical services can log
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
      ModuleType.cache,
    },
    disabledLevels: {
      LogLevel.trace,
      LogLevel.debug,
      LogLevel.info,
      LogLevel.warning,
    },
  );

  final config = LogConfig(
    coreConfig: coreConfig,
    moduleConfig: moduleConfig,
  );

  LoggerImpl.initialize(config);

  final logger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'PaymentService',
      moduleType: ModuleType.payment,
    ),
  );

  logger.info(() => 'info: This is filtered out in release');
  logger.warning(() => 'warning: This is filtered out in release');
  logger.error(() => 'error: ✓ Only errors are logged');
  logger.fatal(() => 'fatal: ✓ Critical errors logged');

  LoggerImpl.dispose();
  print('✓ Release environment example completed\n');
}

// ============================================================================
// EXAMPLE 5: Strict Mode Enforcement
// ============================================================================
void example5_StrictModeEnforcement() {
  print('\n┌─ EXAMPLE 5: Strict Mode (Validation & Errors) ──────────┐');
  print('│ strictMode=true: throws errors on violations              │');
  print('│ strictMode=false: silent degradation (default)            │');
  print('└──────────────────────────────────────────────────────────┘\n');

  // Example 5a: Strict mode OFF (silent degradation)
  print('5a) Strict Mode OFF - Silent Degradation:\n');

  final coreConfigLenient = LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.info,
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
      LogEnvironment.profile: {LogTarget.console},
      LogEnvironment.release: {LogTarget.file},
    },
    allowUnregisteredModules: false,
    strictMode: false, // Lenient mode
  );

  final moduleConfigLenient = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.info,
    enableColors: true,
    modules: {
      'RegisteredService': const LogModuleConfig(
        type: ModuleType.service,
        enabled: true,
      ),
    },
  );

  final configLenient = LogConfig(
    coreConfig: coreConfigLenient,
    moduleConfig: moduleConfigLenient,
  );

  LoggerImpl.initialize(configLenient);

  // This works (registered module)
  final registeredLogger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'RegisteredService',
      moduleType: ModuleType.service,
    ),
  );
  registeredLogger.info(() => '✓ Registered module can log');

  // This is silently ignored (unregistered module, but strictMode=false)
  final unregisteredLogger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'UnregisteredService',
      moduleType: ModuleType.service,
    ),
  );
  unregisteredLogger.info(() => '✗ Unregistered module (silently ignored)');

  LoggerImpl.dispose();

  // Example 5b: Strict mode ON (validation)
  print('\n5b) Strict Mode ON - Throws on Violations:\n');

  final coreConfigStrict = LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.info,
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
      LogEnvironment.profile: {LogTarget.console},
      LogEnvironment.release: {LogTarget.file},
    },
    allowUnregisteredModules: false,
    strictMode: true, // Strict mode
  );

  final moduleConfigStrict = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.info,
    enableColors: true,
    modules: {
      'AuthService': const LogModuleConfig(
        type: ModuleType.authentication,
        enabled: true,
      ),
    },
  );

  final configStrict = LogConfig(
    coreConfig: coreConfigStrict,
    moduleConfig: moduleConfigStrict,
  );

  LoggerImpl.initialize(configStrict);

  final strictLogger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'AuthService',
      moduleType: ModuleType.authentication,
    ),
  );
  strictLogger.info(() => '✓ Registered module logs successfully');

  LoggerImpl.dispose();

  print('✓ Strict mode example completed\n');
}

// ============================================================================
// EXAMPLE 6: Memory Buffer for Debugging
// ============================================================================
void example6_MemoryBufferDebugging() {
  print('\n┌─ EXAMPLE 6: Memory Buffer (In-App Debugging) ────────────┐');
  print('│ Capture logs in circular buffer for crash reports         │');
  print('└──────────────────────────────────────────────────────────┘\n');

  final coreConfig = LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.debug,
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console, LogTarget.memory},
      LogEnvironment.profile: {LogTarget.console, LogTarget.memory},
      LogEnvironment.release: {LogTarget.file, LogTarget.memory},
    },
    allowUnregisteredModules: true,
    strictMode: false,
  );

  final moduleConfig = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.debug,
    enableColors: true,
    modules: const {},
  );

  final config = LogConfig(
    coreConfig: coreConfig,
    moduleConfig: moduleConfig,
  );

  LoggerImpl.initialize(config);

  final logger = LoggerImpl.forModule(
    const LogModule(
      moduleName: 'MemoryDebug',
      moduleType: ModuleType.service,
    ),
  );

  // Generate logs
  print('Generating logs...\n');
  for (int i = 1; i <= 5; i++) {
    logger.debug(() => 'Debug message #$i');
    logger.info(() => 'Info message #$i');
  }

  // Retrieve from memory buffer
  final memoryOutput = LoggerImpl.getMemoryOutput();
  if (memoryOutput != null) {
    print('Memory Buffer Contents:');
    print('─────────────────────');
    print('Total logs captured: ${memoryOutput.logCount}');
    print('\nRecent 3 logs:');
    final recentLogs = memoryOutput.getRecentLogs(3);
    for (int i = 0; i < recentLogs.length; i++) {
      final log = recentLogs[i];
      print('  ${i + 1}. ${log.substring(0, log.length > 70 ? 70 : log.length)}');
    }

    print('\nAll logs (${memoryOutput.logCount} total):');
    final allLogs = memoryOutput.getLogs();
    for (int i = 0; i < allLogs.length; i++) {
      print('  ${i + 1}. ${allLogs[i].substring(0, allLogs[i].length > 70 ? 70 : allLogs[i].length)}');
    }
  }

  LoggerImpl.dispose();
  print('\n✓ Memory buffer example completed\n');
}

// ============================================================================
// EXAMPLE 7: Service Integration Pattern
// ============================================================================
void example7_ServiceIntegration() {
  print('\n┌─ EXAMPLE 7: Service Integration Pattern ─────────────────┐');
  print('│ How to use logging in your services                       │');
  print('└──────────────────────────────────────────────────────────┘\n');

  final coreConfig = LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.debug,
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
      LogEnvironment.profile: {LogTarget.console},
      LogEnvironment.release: {LogTarget.file},
    },
    allowUnregisteredModules: true,
    strictMode: false,
  );

  final moduleConfig = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.debug,
    enableColors: true,
    modules: const {},
  );

  final config = LogConfig(
    coreConfig: coreConfig,
    moduleConfig: moduleConfig,
  );

  LoggerImpl.initialize(config);

  // Create service instance
  final authService = AuthServiceExample();
  authService.login('user@example.com', 'password123');

  print('\n');

  final networkService = NetworkServiceExample();
  networkService.fetchUserProfile('user123');

  print('\n');

  final paymentService = PaymentServiceExample();
  paymentService.processPayment(amount: 99.99);

  LoggerImpl.dispose();
  print('✓ Service integration example completed\n');
}

class AuthServiceExample {
  late final Logger _log;

  AuthServiceExample() {
    _log = LoggerImpl.forModule(
      const LogModule(
        moduleName: 'AuthService',
        moduleType: ModuleType.authentication,
      ),
    );
  }

  void login(String email, String password) {
    _log.debug(() => 'Validating credentials for: $email');
    _log.info(() => 'User login initiated');
    if (_validateEmail(email)) {
      _log.debug(() => 'Email validation passed');
      _log.info(() => 'Login successful for: $email');
    } else {
      _log.warning(() => 'Invalid email format: $email');
      _log.error(() => 'Login failed for: $email');
    }
  }

  bool _validateEmail(String email) => email.contains('@');
}

class NetworkServiceExample {
  late final Logger _log;

  NetworkServiceExample() {
    _log = LoggerImpl.forModule(
      const LogModule(
        moduleName: 'NetworkClient',
        moduleType: ModuleType.network,
      ),
    );
  }

  void fetchUserProfile(String userId) {
    _log.debug(() => 'GET request to: /api/users/$userId');
    _log.debug(() => 'Waiting for response...');
    _log.info(() => 'Response received: 200 OK (156ms)');
    _log.debug(() => 'Parsing JSON response');
  }
}

class PaymentServiceExample {
  late final Logger _log;

  PaymentServiceExample() {
    _log = LoggerImpl.forModule(
      const LogModule(
        moduleName: 'PaymentService',
        moduleType: ModuleType.payment,
      ),
    );
  }

  void processPayment({required double amount}) {
    _log.info(() => 'Payment processing started: \$$amount');
    _log.debug(() => 'Validating payment details');
    _log.debug(() => 'Connecting to payment gateway');
    _log.info(() => 'Payment successful: Transaction #TX123456');
  }
}

// ============================================================================
// EXAMPLE 8: Advanced Filtering Strategies
// ============================================================================
void example8_AdvancedFiltering() {
  print('\n┌─ EXAMPLE 8: Advanced Filtering Strategies ────────────────┐');
  print('│ Filter by level, module type, or specific modules         │');
  print('└──────────────────────────────────────────────────────────┘\n');

  // Strategy 1: Disable specific module types
  print('Strategy 1: Disable UI and Analytics modules\n');

  final coreConfig1 = LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.debug,
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
      LogEnvironment.profile: {LogTarget.console},
      LogEnvironment.release: {LogTarget.file},
    },
    allowUnregisteredModules: true,
    strictMode: false,
  );

  final moduleConfig1 = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.debug,
    enableColors: true,
    modules: const {},
    disabledModuleTypes: {
      ModuleType.view,
      ModuleType.viewModel,
      ModuleType.analytics,
    },
  );

  final config1 = LogConfig(
    coreConfig: coreConfig1,
    moduleConfig: moduleConfig1,
  );

  LoggerImpl.initialize(config1);

  final authLogger = LoggerImpl.forModule(
    const LogModule(moduleName: 'AuthService', moduleType: ModuleType.authentication),
  );
  authLogger.info(() => '✓ Authentication logs enabled');

  final viewLogger = LoggerImpl.forModule(
    const LogModule(moduleName: 'HomeView', moduleType: ModuleType.view),
  );
  viewLogger.info(() => '✗ View logs disabled (type filtered)');

  LoggerImpl.dispose();

  // Strategy 2: Disable specific log levels
  print('\nStrategy 2: Disable trace/debug in production\n');

  final coreConfig2 = LoggerCoreConfig(
    environment: LogEnvironment.release,
    environmentLevels: {
      LogEnvironment.development: LogLevel.trace,
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
      LogEnvironment.profile: {LogTarget.console},
      LogEnvironment.release: {LogTarget.file},
    },
    allowUnregisteredModules: false,
    strictMode: true,
  );

  final moduleConfig2 = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.error,
    enableColors: false,
    modules: {
      'PaymentService': const LogModuleConfig(
        type: ModuleType.payment,
        enabled: true,
      ),
    },
    disabledLevels: {
      LogLevel.trace,
      LogLevel.debug,
      LogLevel.info,
      LogLevel.warning,
    },
  );

  final config2 = LogConfig(
    coreConfig: coreConfig2,
    moduleConfig: moduleConfig2,
  );

  LoggerImpl.initialize(config2);

  final paymentLogger = LoggerImpl.forModule(
    const LogModule(moduleName: 'PaymentService', moduleType: ModuleType.payment),
  );
  paymentLogger.debug(() => '✗ Debug filtered out');
  paymentLogger.error(() => '✓ Only errors logged');

  LoggerImpl.dispose();
  print('✓ Advanced filtering example completed\n');
}

// ============================================================================
// EXAMPLE 9: Complete Production Setup
// ============================================================================
void example9_CompleteProductionSetup() {
  print('\n┌─ EXAMPLE 9: Complete Production Setup ───────────────────┐');
  print('│ Multi-environment configuration for production apps       │');
  print('└──────────────────────────────────────────────────────────┘\n');

  final coreConfig = LoggerCoreConfig(
    environment: LogEnvironment.release,
    environmentLevels: {
      LogEnvironment.development: LogLevel.trace,
      LogEnvironment.profile: LogLevel.debug,
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console, LogTarget.memory},
      LogEnvironment.profile: {LogTarget.console, LogTarget.file, LogTarget.memory},
      LogEnvironment.release: {LogTarget.file, LogTarget.remote, LogTarget.memory},
    },
    allowUnregisteredModules: false,
    strictMode: true,
  );

  final moduleConfig = LoggerModuleRegistryConfig(
    globalLevel: LogLevel.error,
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
      'ApiClient': const LogModuleConfig(
        type: ModuleType.api,
        level: LogLevel.error,
        enabled: true,
      ),
      'DatabaseService': const LogModuleConfig(
        type: ModuleType.database,
        level: LogLevel.error,
        enabled: true,
      ),
    },
    disabledModuleTypes: {
      ModuleType.view,
      ModuleType.viewModel,
      ModuleType.analytics,
      ModuleType.cache,
      ModuleType.fileSystem,
    },
    disabledLevels: {
      LogLevel.trace,
      LogLevel.debug,
      LogLevel.info,
      LogLevel.warning,
    },
  );

  final config = LogConfig(
    coreConfig: coreConfig,
    moduleConfig: moduleConfig,
  );

  LoggerImpl.initialize(config);

  print('Production Setup:');
  print('─────────────────');
  print('• Environment: Release');
  print('• Minimum Level: Error');
  print('• Output Targets: File, Remote, Memory');
  print('• Registered Services: 4 (Payment, Auth, API, Database)');
  print('• Disabled Module Types: 5 (UI, Analytics, Cache, FileSystem)');
  print('• Disabled Levels: 4 (Trace, Debug, Info, Warning)');
  print('• Strict Mode: Enabled (validates all violations)');
  print('\nBehavior:');
  print('✓ Only ERROR and FATAL logs are recorded');
  print('✓ Logs sent to file + remote + memory simultaneously');
  print('✓ Sensitive debug info not exposed in production');
  print('✓ All unregistered modules rejected');
  print('✓ Violations throw StateError with strict mode');

  LoggerImpl.dispose();
  print('\n✓ Complete production setup example completed\n');
}

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================

void main() {
  runComprehensiveLoggingGuide();
  print('\n╔════════════════════════════════════════════════════════════╗');
  print('║    All Examples Completed Successfully                     ║');
  print('╚════════════════════════════════════════════════════════════╝\n');
}
