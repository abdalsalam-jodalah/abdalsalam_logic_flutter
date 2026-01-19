# Logging System Documentation

## Overview

The logging system is a high-performance, configurable logging solution for Flutter/Dart applications with strict initialization requirements, module-based organization, environment-aware behavior, and multiple output targets.

## Core Principles

1. **Mandatory Initialization**: Logger will not work until explicitly initialized with a `LogConfig`
2. **Strongly Typed Configuration**: Immutable configuration passed exactly once
3. **Performance Optimized**: Lazy message evaluation, zero overhead when filtered
4. **Environment Aware**: Separate configurations for development, profile, and release modes
5. **Module-Based**: Every logging source must register with module name and type
6. **Centralized Control**: Single configuration file controls all logging behavior
7. **Multiple Outputs**: Console, file, and remote logging with flexible configuration

## Architecture

### Class Responsibilities

#### Core Classes
- **Logger**: Abstract interface for module-scoped logging operations
- **LoggerImpl**: Singleton implementation with strict initialization contract and strict mode support
- **LogConfig**: Unified configuration wrapper supporting both split and simple configuration patterns

#### Split Configuration (NEW - Recommended)
- **LoggerCoreConfig**: Defines HOW the logger behaves
  - Environment detection (dev/profile/release)
  - Per-environment log levels
  - Per-environment output targets
  - Unregistered module policy
  - Strict mode enforcement
- **LoggerModuleRegistryConfig**: Defines WHAT can log
  - Global log level
  - Color settings
  - Module-specific configurations
  - Disabled module types
  - Disabled log levels

#### Supporting Classes
- **LogModuleConfig**: Configuration for individual modules
- **LogModule**: Registration information for logging sources (immutable)
- **LogLevel**: Severity levels (trace, debug, info, warning, error, fatal)
- **ModuleType**: Classification with 27 specialized categories
- **LogTarget**: Output target enum (console, file, memory, remote)
- **LogFilter**: Filtering logic based on level, module, and configuration
- **LogFormatter**: Message formatting with structured output and colors
- **LogOutput**: Output sink abstraction with multiple implementations
  - **ConsoleOutput**: Terminal/debug console output
  - **FileOutput**: File-based logging with rotation
  - **MemoryOutput**: In-memory circular buffer (NEW)
  - **RemoteOutput**: Remote logging endpoint
  - **MultiOutput**: Multiple simultaneous outputs

### Logger Lifecycle

```
1. App Start
   ↓
2. Create LogConfig
   ↓
3. LoggerImpl.initialize(config) ← MANDATORY
   ↓
4. Create module-scoped loggers
   ↓
5. Log messages (lazy evaluation)
   ↓
6. App Shutdown → LoggerImpl.dispose()
```

## Log Levels

- **trace** (0): Finest granularity, detailed execution flow
- **debug** (1): Debug information for development
- **info** (2): General information about app state
- **warning** (3): Potentially harmful situations
- **error** (4): Error events that might still allow app to continue
- **fatal** (5): Severe errors that may lead to app termination

## Module Types (27 Categories)

### Core System
- **service** - General business logic services
- **repository** - Data access layer
- **state** - State management
- **other** - Uncategorized modules

### UI Layer
- **view** - UI components
- **viewModel** - Presentation layer

### Networking
- **network** - Network operations
- **api** - API clients
- **websocket** - Real-time communication

### Data Layer
- **storage** - Data persistence
- **database** - Database operations
- **cache** - Caching layer
- **fileSystem** - File system operations

### Authentication & Security
- **authentication** - User authentication
- **authorization** - Permissions & roles
- **biometric** - Biometric authentication
- **encryption** - Data encryption

### Background Processing
- **background** - Background tasks
- **scheduler** - Task scheduling
- **sync** - Data synchronization
- **prefetch** - Data prefetching

### Integrations
- **analytics** - Analytics tracking
- **crashReporting** - Error reporting
- **payment** - Payment processing
- **media** - Media processing
- **location** - Location services
- **push** - Push notifications
- **deepLink** - Deep link handling

## Configuration

### Split Configuration Architecture

The logging system uses a strict split configuration pattern that separates concerns:

**IMPORTANT**: All configuration parameters are required. There are no factory methods, no default values, and no auto-detection. You must explicitly specify every parameter.

#### Configuration Example

```dart
// Core configuration: HOW the logger behaves (ALL parameters required)
final coreConfig = LoggerCoreConfig(
  environment: LogEnvironment.development,  // REQUIRED - no auto-detection
  environmentLevels: {  // REQUIRED - must provide all environments you use
    LogEnvironment.development: LogLevel.trace,
    LogEnvironment.profile: LogLevel.debug,
    LogEnvironment.release: LogLevel.error,
  },
  targetsPerEnvironment: {  // REQUIRED - must specify targets for each environment
    LogEnvironment.development: {LogTarget.console, LogTarget.memory},
    LogEnvironment.profile: {LogTarget.console, LogTarget.file},
    LogEnvironment.release: {LogTarget.file, LogTarget.remote},
  },
  allowUnregisteredModules: true,  // REQUIRED - no default
  strictMode: false,  // REQUIRED - no default (set true to throw on violations)
);

// Module configuration: WHAT can log (ALL parameters required)
final moduleConfig = LoggerModuleRegistryConfig(
  globalLevel: LogLevel.debug,  // REQUIRED - no default
  enableColors: true,  // REQUIRED - no default
  modules: const {},  // REQUIRED - can be empty map
  // Optional filters
  disabledModuleTypes: {ModuleType.analytics},
  disabledLevels: {LogLevel.trace},
);

// Combine into unified config (BOTH configs required)
final config = LogConfig(
  coreConfig: coreConfig,
  moduleConfig: moduleConfig,
);

LoggerImpl.initialize(config);
```

### LoggerCoreConfig Options

- **environment**: Current environment - REQUIRED, must be explicitly specified (no auto-detection)
- **environmentLevels**: Map of log level per environment - REQUIRED
- **targetsPerEnvironment**: Map of output targets per environment - REQUIRED
- **allowUnregisteredModules**: Allow logs from unregistered modules - REQUIRED (no default)
- **strictMode**: Throw errors on violations vs silent degradation - REQUIRED (no default)

### LoggerModuleRegistryConfig Options

- **globalLevel**: Default log level threshold - REQUIRED (no default)
- **enableColors**: Enable ANSI colors in console output - REQUIRED (no default)
- **modules**: Per-module configuration overrides - REQUIRED (can be empty map)
- **disabledModuleTypes**: Disable all modules of specific types - OPTIONAL
- **disabledLevels**: Disable specific log levels entirely - OPTIONAL

### LogTarget Enum (NEW)

Explicit output target specification:
- **LogTarget.console**: Terminal/debug console
- **LogTarget.file**: File-based logging
- **LogTarget.memory**: In-memory circular buffer
- **LogTarget.remote**: Remote logging endpoint

### Strict Mode (NEW)

Control error handling behavior:
- **strictMode = true**: Throws StateError on violations (recommended for dev/test)
- **strictMode = false**: Silent degradation (recommended for production)

Violations include:
- Re-initialization attempts
- Using logger before initialization (dev/profile only)
- Output write failures
- Invalid configurations



### Configuration Options (Per Environment)ut(), FileOutput()],
    allowUnregisteredModules: true,
  ),
  
  // OPTIONAL: Release environment config (defaults to development if not provided)
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
        allowedLevels: {'ERROR', 'FATAL'},
      ),
    ],
    allowUnregisteredModules: false,
  ),
  
  // OPTIONAL: Per-module configuration overrides
  modules: {
    'AuthService': LogModuleConfig(
      type: ModuleType.authentication,
      enabled: true,
      level: LogLevel.debug,
    ),
  },
);

LoggerImpl.initialize(config);
```

### EnvironmentLogConfig Options

- **globalLevel**: Log level threshold for this environment
- **enableColors**: Enable ANSI colors in console output
- **outputs**: List of output targets (console, file, remote, or multiple)
- **allowUnregisteredModules**: Allow logs from unregistered modules (default: true)
- **disabledModuleTypes**: Disable all modules of specific types
- **disabledLevels**: Disable specific log levels entirely

### Basic Configuration (Legacy Style)

```dart
final logConfig = LogConfig(
  globalLevel: LogLevel.info,
  enableColors: true,
  modules: {
    'AuthService': LogModuleConfig(
      type: ModuleType.service,
      enabled: true,
      level: LogLevel.debug,
    ),
  },
);

LoggerImpl.initialize(logConfig); in this environment
- **enableColors**: Enable ANSI colors in console output
- **outputs**: List of LogOutput instances (console, file, remote)
- **allowUnregisteredModules**: If false, logs from unregistered modules are rejected
- **disabledModuleTypes**: Disable all modules of specific types
- **disabledLevels**: Disable specific log level
- **enableColors**: Enable ANSI colors in console output (auto-disabled in release)
- **modules**: Per-module configuration overrides
- **rejectUnregisteredModules**: If true, logs from unregistered modules are rejected
- **enableConsoleInRelease**: Enable console output in release mode (default: false)
- **disabledModuleTypes**: Disable all modules of specific types
authentication,  // Module classification (use specific types)
  enabled: true,                     // Enable/disable this module
  level: LogLevel.debug,             // Override environment's global level
)
```

## Output Targets

### 1. Console Output

```dart
const ConsoleOutput(
  enableInRelease: false, // Disable in production (default)
)
```

**When to use**: Development and profile modes  
**Supports colors**: Yes  
**Performance**: Instant output

### 2. File Output

```dart
FileOutput(
  fileName: 'app_logs.txt',              // Log file name
  maxFileSizeBytes: 10 * 1024 * 1024,    // 10MB max size
  maxBackupFiles: 5,                      // Keep 5 rotated backups
  enableInRelease: true,                  // Keep enabled in production
)
```

**When to use**: Persistent logging, debugging production issues  
**Features**:
- Automatic file rotation when size limit reached
- Keeps configured number of backup files
- Async writing with buffering
- Stored in app's documents directory under `logs/`

**File rotation**: `app_logs.txt` → `app_logs.txt.1` → `app_logs.txt.2` → ...

### 3. Remote Output

```dart
RemoteOutput(
  endpoint: 'https://crashreports.example.com/api/logs',
  headers: {'Authorization': 'Bearer token'},
  batchInterval: Duration(seconds: 30),   // Send batch every 30s
  maxBatchSize: 100,                      // Or when 100 logs accumulated
  allowedLevels: {'ERROR', 'FATAL'},      // Only send errors
  enableInRelease: true,
)
```

**When to use**: Error monitoring, crash reporting  
**Features**:
- Batch processing to reduce network calls
- Filter by log level (typically ERROR/FATAL only)
- Automatic retry on failure
- Configurable headers for authentication

### 4. Multiple Outputs

```dart
// Using split configuration with multiple targets
final config = LogConfig(
  coreConfig: LoggerCoreConfig.simple(
    targets: {LogTarget.console, LogTarget.file, LogTarget.memory},
  ),
  moduleConfig: LoggerModuleRegistryConfig.minimal(),
);
```

Logs are sent to ALL configured outputs simultaneously.

### 5. Memory Output (NEW)

```dart
// In-memory circular buffer for debugging
MemoryOutput(
  maxEntries: 1000,  // Default: 1000 entries
)
```

**When to use**: In-app debugging, crash report context, testing  
**Features**:
- Circular buffer (oldest logs overwritten when full)
- Retrieve all logs or recent N logs
- Clear buffer on demand
- Zero disk I/O
- Accessible via `LoggerImpl.getMemoryOutput()`

**Usage Example**:
```dart
// Configure with memory target
final config = LogConfig(
  coreConfig: LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.debug,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console, LogTarget.memory},
    },
    allowUnregisteredModules: true,
    strictMode: false,
  ),
  moduleConfig: LoggerModuleRegistryConfig(
    globalLevel: LogLevel.debug,
    enableColors: true,
    modules: const {},
  ),
);

LoggerImpl.initialize(config);

// Log messages
logger.info(() => 'Message 1');
logger.debug(() => 'Message 2');

// Retrieve from buffer
final memoryOutput = LoggerImpl.getMemoryOutput();
if (memoryOutput != null) {
  final allLogs = memoryOutput.getLogs();
  final recentLogs = memoryOutput.getRecentLogs(50);
  print('Total logs: ${memoryOutput.logCount}');
  memoryOutput.clear();  // Clear buffer
}
```

### LogModuleConfig Options
```

## Usage Examples

### Service Example

```dart
class AuthService {
  late final Logger _log;

  AuthService() {
    _log = LoggerImpl.forModule(
      const LogModule(
        moduleName: 'AuthService',
        moduleType: ModuleType.authentication,  // Use specific module type
      ),
    );
  }

  Future<void> login(String email) async {
    _log.info(() => 'Login attempt for user: $email');
    
    try {
      // ... login logic
      _log.info(() => 'Login successful');
    } catch (e, stackTrace) {
      _log.error(() => 'Login failed', e, stackTrace);
      rethrow;
    }
  }
}
```

### ViewModel Example

```dart
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
    _log.debug(() => 'Fetching user profile...');
    
    try {
      // ... load logic
      _log.info(() => 'User profile loaded successfully');
    } catch (e, stackTrace) {
      _log.error(() => 'Failed to load user profile', e, stackTrace);
      rethrow;
    }
  }
}
```

### Network Layer Example

```dart
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

  Future<Response> get(String endpoint) async {
    _log.debug(() => 'GET request to: $endpoint');
    
    try {
      // ... network call
      _log.trace(() => 'Response received with status: 200');
      _log.info(() => 'GET request successful');
      return response;
    } catch (e, stackTrace) {
      _log.error(() => 'GET request failed', e, stackTrace);
      rethrow;
    }
  }
}
```

## Output Format

```
[HH:mm:ss.SSS] [LEVEL] [ModuleName] [TYPE] Message
```

Example:
```
[14:32:15.234] [INFO ] [AuthService] [SVC] Login attempt for user: user@example.com
[14:32:15.456] [DEBUG] [NetworkClient] [NET] GET request to: /api/users/123
[14:32:15.789] [ERROR] [UserViewModel] [VM] Failed to load user profile
Error: Network timeout
[14:32:15.790] [FATAL] [DatabaseService] [STRG] Database connection lost
```

## Filtering Strategies

### Global Level Filtering

```dart
// Only warning, error, fatal
final config = LogConfig(
  coreConfig: LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.warning,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
    },
    allowUnregisteredModules: true,
    strictMode: false,
  ),
  moduleConfig: LoggerModuleRegistryConfig(
    globalLevel: LogLevel.warning,
    enableColors: true,
    modules: const {},
  ),
);
```

### Per-Module Filtering

```dart
final config = LogConfig(
  coreConfig: LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.info,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
    },
    allowUnregisteredModules: true,
    strictMode: false,
  ),
  moduleConfig: LoggerModuleRegistryConfig(
    globalLevel: LogLevel.info,
    enableColors: true,
    modules: {
      'AuthService': LogModuleConfig(
        type: ModuleType.authentication,
        level: LogLevel.debug,  // More verbose for this module
        enabled: true,
      ),
      'NetworkClient': LogModuleConfig(
        type: ModuleType.network,
        level: LogLevel.info,
        enabled: false,  // Completely disabled
      ),
    },
  ),
);
```

### Module Type Filtering

```dart
final config = LogConfig(
  coreConfig: LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.info,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console},
    },
    allowUnregisteredModules: true,
    strictMode: false,
  ),
  moduleConfig: LoggerModuleRegistryConfig(
    globalLevel: LogLevel.info,
    enableColors: true,
    modules: const {},
    disabledModuleTypes: {
      ModuleType.view,
      ModuleType.viewModel,
      ModuleType.analytics,
    },  // Disable all UI and analytics logging
  ),
);
```

### Log Level Filtering

```dart
final config = LogConfig(
  coreConfig: LoggerCoreConfig(
    environment: LogEnvironment.release,
    environmentLevels: {
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.release: {LogTarget.file},
    },
  ),
  moduleConfig: LoggerModuleRegistryConfig(
    globalLevel: LogLevel.error,
    disabledLevels: {
      LogLevel.trace,
      LogLevel.debug,
      LogLevel.info,
    },  // Only warnings and above in release
  ),
);
```

### Strict Module Registration

```dart
final config = LogConfig(
  coreConfig: LoggerCoreConfig(
    environment: LogEnvironment.release,
    environmentLevels: {
      LogEnvironment.release: LogLevel.info,
    },
    targetsPerEnvironment: {
      LogEnvironment.release: {LogTarget.file},
    },
    allowUnregisteredModules: false,  // Only configured modules can log
    strictMode: true,  // Throw on violations
  ),
  moduleConfig: LoggerModuleRegistryConfig(
    globalLevel: LogLevel.info,
    modules: {
      'AuthService': LogModuleConfig(
        type: ModuleType.authentication,
        enabled: true,
      ),
    },
  ),
);
```

## Environment-Specific Recommendations

### Development Mode (kDebugMode)

**Recommended Configuration**:
```dart
final config = LogConfig(
  coreConfig: LoggerCoreConfig(
    environment: LogEnvironment.development,
    environmentLevels: {
      LogEnvironment.development: LogLevel.trace,
    },
    targetsPerEnvironment: {
      LogEnvironment.development: {LogTarget.console, LogTarget.memory},
    },
    allowUnregisteredModules: true,
  ),
  moduleConfig: LoggerModuleRegistryConfig(
    globalLevel: LogLevel.trace,
    enableColors: true,
  ),
);
```

**Characteristics**:
- All log levels available
- Colorful console output
- Memory buffer for debugging
- Throws StateError if used before initialization
- Permissive (allows unregistered modules)

### Profile Mode (kProfileMode)

**Recommended Configuration**:
```dart
final config = LogConfig(
  coreConfig: LoggerCoreConfig(
    environment: LogEnvironment.profile,
    environmentLevels: {
      LogEnvironment.profile: LogLevel.debug,
    },
    targetsPerEnvironment: {
      LogEnvironment.profile: {LogTarget.console, LogTarget.file},
    },
    allowUnregisteredModules: true,
  ),
  moduleConfig: LoggerModuleRegistryConfig(
    globalLevel: LogLevel.debug,
    enableColors: true,
  ),
);
```

**Characteristics**:
- Debug and above
- Colors enabled
- Both console and file output
- Good for performance profiling with logs
- Throws StateError if used before initialization

### Release Mode (kReleaseMode)

**Recommended Configuration**:
```dart
final config = LogConfig(
  coreConfig: LoggerCoreConfig(
    environment: LogEnvironment.release,
    environmentLevels: {
      LogEnvironment.release: LogLevel.error,
    },
    targetsPerEnvironment: {
      LogEnvironment.release: {LogTarget.file, LogTarget.remote},
    },
    allowUnregisteredModules: false,
    strictMode: true,
  ),
  moduleConfig: LoggerModuleRegistryConfig(
    globalLevel: LogLevel.error,
    enableColors: false,
    disabledModuleTypes: {
      ModuleType.view,
      ModuleType.viewModel,
      ModuleType.analytics,
    },
  ),
);

```dart
// Create custom JSON formatter for log aggregation
class JsonLogFormatter implements LogFormatter {
  @override
  String format({
    required DateTime timestamp,
    required LogLevel level,
    required LogModule module,
    required String message,
    bool enableColors = true,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return jsonEncode({
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'module': module.moduleName,
      'type': module.moduleType.name,
      'message': message,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    });
  }
}
```

### Custom Output Targets

```dart
// Create custom database output for persistent structured logs
class DatabaseOutput implements LogOutput {
  final Database db;
  
  DatabaseOutput(this.db);
  
  @override
  void write(String message) {
    db.insert('logs', {
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  @override
  Future<void> close() async {
    await db.close(mplete Configuration Examples

### Example 1: Development-Focused

```dart
final config = LogConfig(
  developmentConfig: EnvironmentLogConfig(
    globalLevel: LogLevel.trace,
    enableColors: true,
    outputs: [ConsoleOutput()],
    allowUnregisteredModules: true,
  ),
  modules: {
    'AuthService': LogModuleConfig(
      type: ModuleType.authentication,
      enabled: true,
    ),
  },
);

LoggerImpl.initialize(config);
```

### Example 2: Production-Ready

```dart
final config = LogConfig(
  developmentConfig: EnvironmentLogConfig(
    globalLevel: LogLevel.debug,
    enableColors: true,
    outputs: [
      ConsoleOutput(),
      FileOutput(fileName: 'dev_logs.txt'),
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
        headers: {
          'Authorization': 'Bearer your-api-key',
          'X-App-Version': '1.0.0',
        },
        batchInterval: Duration(minutes: 1),
        maxBatchSize: 50,
        allowedLevels: {'ERROR', 'FATAL'},
      ),
    ],
    allowUnregisteredModules: false,
    disabledModuleTypes: {
      ModuleType.view,
      ModuleType.viewModel,
      ModuleType.analytics,
    },
  ),
  
  modules: {
    'AuthService': LogModuleConfig(
      type: ModuleType.authentication,
      enabled: true,
      level: LogLevel.info,
    ),
    'PaymentService': LogModuleConfig(
      type: ModuleType.payment,
      enabled: true,
      level: LogLevel.debug,
    ),
    'DatabaseService': LogModuleConfig(
      type: ModuleType.database,
      enabled: true,
      level: LogLevel.warning,
    ),
  },
);

LoggerImpl.initialize(config);
```

### Example 3: Multi-Output with Filtering

```dart
final config = LogConfig(
  developmentConfig: EnvironmentLogConfig(
    globalLevel: LogLevel.debug,
    enableColors: true,
    outputs: [
      ConsoleOutput(),
      FileOutput(
        fileName: 'all_logs.txt',
        maxFileSizeBytes: 10 * 1024 * 1024,
      ),
    ],
    allowUnregisteredModules: true,
  ),
  
  releaseConfig: EnvironmentLogConfig(
    globalLevel: LogLevel.warning,
    enableColors: false,
    outputs: [
      FileOutput(fileName: 'warnings.txt'),
      RemoteOutput(
        endpoint: 'https://api.example.com/logs',
        allowedLevels: {'ERROR', 'FATAL'},
      ),
    ],
    allowUnregisteredModules: false,
    disabledLevels: {LogLevel.trace, LogLevel.debug, LogLevel.info},
  ),
);

LoggerImpl.initialize(config);
```

If a log statement doesn't pass the filter:
1. Message builder is never called
2. No string formatting occurs
3. No memory allocations
4. Minimal CPU cost (just the filter check)

## Environment Behavior

### Development Mode (kDebugMode)

- All log levels available
- Colors enabled (if configured)
- Console output enabled
- Throws StateError if used before initialization

### Profile Mode (kProfileMode)

- All log levels available
- Colors enabled (if configured)
- Console output enabled
- Throws StateError if used before initialization

### Release Mode (kReleaseMode)

- Console output disabled by default (unless `enableConsoleInRelease: true`)
- Colors always disabled
- Silent no-op if used before initialization (no crash)
- Error/Fatal paths preserved for crash reporting integration

## Advanced Scenarios

### Multiple Output Sinks

```dart
// Future enhancement - write to console AND file
final output = MultiOutput([
  ConsoleOutput(),
  FileOutput('/path/to/log.txt'),
]);
```

### Custom Formatters

```dart
// Future enhancement - JSON formatting for log aggregation
class JsonLogFormatter implements LogFormatter {
  @override
  String format(...) {
    return jsonEncode({
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'module': module.moduleName,
      'message': message,
    });
  }
}
```

## Integration with Error Handling

```dart
class ErrorHandler {
  late final Logger _log;

  ErrorHandler() {
    _log = LoggerImpl.forModule(
      developmentConfig: EnvironmentLogConfig(
        globalLevel: LogLevel.trace,
        enableColors: false,
        outputs: [ConsoleOutput()],
      ),
    ));
  });

  tearDown(() async {
    await
  void handleError(Object error, StackTrace stackTrace) {
    if (error is NetworkException) {
      _log.warning(() => 'Network error occurred', error, stackTrace);
    } else if (error is ValidationException) {
      _log.info(() => 'Validation failed', error);
    } else {
      _log.error(() => 'Unexpected error', error, stackTrace);
    }
  } with appropriate module types
3. **Use appropriate log levels** (don't overuse trace/debug)
4. **Include context** in log messages (user IDs, request IDs, etc.)
5. **Use structured logging** for important data points
6. **Configure different settings per environment** (verbose in dev, minimal in release)
7. **Keep module names consistent** and descriptive
8. **Use specific module types** for better filtering (avoid overusing `other`)
9. **Test logging configuration** in different environments
10. **Document module naming conventions** in your project
11. **Use FileOutput for persistent debugging** in production
12. **Use RemoteOutput only for critical errors** (ERROR/FATAL) to avoid overwhelming servers
13. **Disable console output in release** to save resources
14. **Enable strict mode in production** (`allowUnregisteredModules: false`)
15. **Configure file rotation** to prevent disk space issues

## Environment-Specific Best Practices

### Development
✅ **DO**: Use console output with colors  
✅ **DO**: Set global level to trace or debug  
✅ **DO**: Allow unregistered modules  
❌ **DON'T**: Use file or remote outputs unless debugging specific issues

### Profile
✅ **DO**: Use both console and file outputs  
✅ **DO**: Set global level to debug  
✅ **DO**: Enable colors for better readability  
❌ **DON'T**: Send logs to remote in profile mode

### Release
✅ **DO**: Use file and remote outputs only  
✅ **DO**: Set global level to error or warning  
✅ **DO**: Disable console output  
✅ **DO**: Enable strict module registration  
✅ **DO**: Filter module types to reduce noise  
✅ **DO**: Configure file rotation for disk management  
❌ **DON'T**: Log sensitive data  
❌ **DON'T**: Send trace/debug logs to remote  
❌ **DON'T**: Enable colors (no effect anyway)
    LoggerImpl.initialize(LogConfig(
      globalLevel: LogLevel.trace,
      enableColors: false,
    ));
  });

  tearDown(() {
    LoggerImpl.dispose();
  });
 with environment configs:
   ```dart
   void main() {
     LoggerImpl.initialize(LogConfig(
       developmentConfig: EnvironmentLogConfig(
         globalLevel: LogLevel.info,
         outputs: [ConsoleOutput()],
       ),
       releaseConfig: EnvironmentLogConfig(
         globalLevel: LogLevel.error,
         outputs: [FileOutput()],
       )
```

## Best Practices

1. **Always use lazy message builders** for performance
2. **Register modules at service/class initialization**
3. **Use appropriate log levels** (don't overuse trace/debug)
4. **Include context** in log messages  // Or more specific type (user IDs, request IDs, etc.)
5. **Use structured logging** for important data points
6. **Disable verbose logging in production** via configuration
7. **Keep module names consistent** and descriptive
8. **Use module types correctly** for category-based filtering
9. **Test logging configuration** in different environments
10. **Document module naming conventions** in your project

## Migration from Old Logger

If migrating from `logger_service.dart`:

1. Update imports:
   ```dart
   // Old
   import 'package:abdalsalam_logic_flutter/src/logging/logger_service.dart';
   
   // New
   import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
   ```

2. Initialize logger at app start:
   ```dart
   void main() {
     LoggerImpl.initialize(LogConfig(
       globalLevel: LogLevel.info,
     ));
     runApp(MyApp());
   }
   ```

3. Update logger instantiation:
   ```dart
   // Old
   final log = LoggerService();
   
   // New
   final log = LoggerImpl.forModule(
     const LogModule(
       moduleName: 'MyService',
       moduleType: ModuleType.service,
     ),
   );
   ```

4. Update log calls to use lazy evaluation:
   ```dart
   // Old
   log.info('Message: $value');
   
   // New
   log.info(() => 'Message: $value');
   ```

---

## Summary

The logging system provides 100% strict, production-grade compliance:

✅ **Mandatory explicit configuration** - No defaults, no auto-detection, no helper methods  
✅ **Split configuration architecture** - Separated core (HOW) and module (WHAT) concerns  
✅ **Strict mode enforcement** - Choose between throw vs silent degradation  
✅ **Memory output target** - Circular buffer for in-app debugging  
✅ **Explicit target mapping** - Per-environment output control  
✅ **Immutable configurations** - Thread-safe, predictable behavior  
✅ **Runtime validation** - Throws StateError for missing configurations  
✅ **27 specialized module types** - Fine-grained categorization  
✅ **Multiple output targets** - Console, file, memory, remote  

**Key Principles**:
- Every parameter must be explicitly specified
- No factory methods or convenience constructors
- Environment must be manually specified (no auto-detection)
- All configurations are immutable and validated at runtime
- Strict initialization contract enforced

For complete examples, see:
- `lib/examples/logging_advanced_example.dart`
- `lib/examples/logging_example.dart`
