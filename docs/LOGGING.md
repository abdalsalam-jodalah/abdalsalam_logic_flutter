# Logging System Documentation

## Overview

The logging system is a high-performance, configurable logging solution for Flutter/Dart applications with strict initialization requirements, module-based organization, and environment-aware behavior.

## Core Principles

1. **Mandatory Initialization**: Logger will not work until explicitly initialized with a `LogConfig`
2. **Strongly Typed Configuration**: Immutable configuration passed exactly once
3. **Performance Optimized**: Lazy message evaluation, zero overhead when filtered
4. **Environment Aware**: Automatic behavior adjustment for dev/profile/release modes
5. **Module-Based**: Every logging source must register with module name and type
6. **Centralized Control**: Single configuration file controls all logging behavior

## Architecture

### Class Responsibilities

- **Logger**: Abstract interface for module-scoped logging operations
- **LoggerImpl**: Singleton implementation with strict initialization contract
- **LogConfig**: Immutable configuration for the entire logging system
- **LogModuleConfig**: Configuration for individual modules
- **LogModule**: Registration information for logging sources
- **LogLevel**: Severity levels (trace, debug, info, warning, error, fatal)
- **ModuleType**: Classification (service, repository, view, viewModel, state, network, storage, websocket, other)
- **LogFilter**: Filtering logic based on level, module, and configuration
- **LogFormatter**: Message formatting with structured output and colors
- **LogOutput**: Output sink abstraction (console, file, remote)

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

## Module Types

- **service**: Business logic services
- **repository**: Data access layer
- **view**: UI components
- **viewModel**: Presentation layer
- **state**: State management
- **network**: Network operations
- **storage**: Data persistence
- **websocket**: Real-time communication
- **other**: Uncategorized modules

## Configuration

### Basic Configuration

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

LoggerImpl.initialize(logConfig);
```

### Configuration Options

- **globalLevel**: Default log level for all modules
- **enableColors**: Enable ANSI colors in console output (auto-disabled in release)
- **modules**: Per-module configuration overrides
- **rejectUnregisteredModules**: If true, logs from unregistered modules are rejected
- **enableConsoleInRelease**: Enable console output in release mode (default: false)
- **disabledModuleTypes**: Disable all modules of specific types

### Module Configuration

```dart
LogModuleConfig(
  type: ModuleType.service,      // Module classification
  enabled: true,                  // Enable/disable this module
  level: LogLevel.debug,          // Override global level
)
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
        moduleType: ModuleType.service,
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
LogConfig(
  globalLevel: LogLevel.warning, // Only warning, error, fatal
)
```

### Per-Module Filtering

```dart
LogConfig(
  globalLevel: LogLevel.info,
  modules: {
    'AuthService': LogModuleConfig(
      type: ModuleType.service,
      level: LogLevel.debug, // More verbose for this module
    ),
    'NetworkClient': LogModuleConfig(
      type: ModuleType.network,
      enabled: false, // Completely disabled
    ),
  },
)
```

### Module Type Filtering

```dart
LogConfig(
  globalLevel: LogLevel.info,
  disabledModuleTypes: {
    ModuleType.view,
    ModuleType.viewModel,
  }, // Disable all UI logging
)
```

### Strict Mode

```dart
LogConfig(
  globalLevel: LogLevel.info,
  rejectUnregisteredModules: true, // Only configured modules can log
  modules: {
    'AuthService': LogModuleConfig(
      type: ModuleType.service,
      enabled: true,
    ),
  },
)
```

## Performance Optimization

### Lazy Message Evaluation

Messages are built using function builders to avoid string construction when logs are filtered:

```dart
// ✅ Good - Message only built if log level passes filter
_log.debug(() => 'Processing ${items.length} items: ${items.map((i) => i.id).join(", ")}');

// ❌ Bad - String always constructed, even if filtered
_log.debug('Processing ${items.length} items: ${items.map((i) => i.id).join(", ")}');
```

### Zero Overhead When Filtered

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
      const LogModule(
        moduleName: 'ErrorHandler',
        moduleType: ModuleType.other,
      ),
    );
  }

  void handleError(Object error, StackTrace stackTrace) {
    if (error is NetworkException) {
      _log.warning(() => 'Network error occurred', error, stackTrace);
    } else if (error is ValidationException) {
      _log.info(() => 'Validation failed', error);
    } else {
      _log.error(() => 'Unexpected error', error, stackTrace);
    }
  }
}
```

## Testing

```dart
void main() {
  setUp(() {
    LoggerImpl.initialize(LogConfig(
      globalLevel: LogLevel.trace,
      enableColors: false,
    ));
  });

  tearDown(() {
    LoggerImpl.dispose();
  });

  test('logger filters by level', () {
    // Test implementation
  });
}
```

## Best Practices

1. **Always use lazy message builders** for performance
2. **Register modules at service/class initialization**
3. **Use appropriate log levels** (don't overuse trace/debug)
4. **Include context** in log messages (user IDs, request IDs, etc.)
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
