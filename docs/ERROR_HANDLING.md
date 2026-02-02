# Error Handling & Exception System

## Overview

The **AppException System** is a comprehensive, production-grade error handling architecture designed to prevent app crashes, standardize error handling across modules, and provide rich, typed exceptions with unified responses.

## Architecture Principles

- **Crash Prevention**: No raw exceptions are ever thrown outside modules
- **Unified Interface**: All errors implement the `AppException` interface
- **Rich Context**: Each exception includes severity, source, recovery flags, and metadata
- **External Exception Wrapping**: Automatically maps known external exceptions (Dio, Platform, Socket, etc.)
- **Type Safety**: Pattern-matchable, typed exception hierarchy
- **Safe Responses**: UI-safe error responses without exposing internal details

## Core Components

### 1. AppException Interface

The base interface that all exceptions implement:

```dart
abstract class AppException implements Exception {
  String get message;           // Human-readable error message
  String get code;             // Stable error code for programmatic handling
  AppExceptionSeverity get severity;  // info, warning, error, critical
  AppExceptionSource get source;      // network, storage, auth, etc.
  bool get isRecoverable;             // Whether the operation can be retried
  Exception? get originalException;   // Preserved original exception context
  StackTrace? get stackTrace;         // Debug information
  
  AppException copyWith({...});       // Immutable updates
  Map<String, dynamic> toMap();       // Serialization-safe representation
}
```

### 2. Exception Hierarchy

#### Network Exceptions
- `NetworkException` - Base network error
- `TimeoutException` - Request timeouts
- `OfflineException` - No internet connection
- `NetworkTimeoutException` - Network-specific timeouts
- `NetworkOfflineException` - Network offline state
- `NetworkBackendException` - Server-side errors
- `NetworkAuthFailedException` - Network authentication failures
- `NetworkValidationException` - Network validation errors

#### Authentication Exceptions
- `AuthException` - Base auth error
- `TokenExpiredException` - Auth token expired
- `PermissionException` - Insufficient permissions

#### Storage Exceptions
- `StorageException` - Base storage error
- File system, database, cache errors

#### Validation Exceptions
- `ValidationException` - Input validation errors
- Includes `fieldErrors` map for form validation

#### Backend Exceptions
- `BackendException` - Server/API errors
- Includes HTTP status codes and response data

#### Fallback
- `UnknownAppException` - Unmapped or unknown errors

### 3. Exception Mapper

Automatically wraps external exceptions into AppExceptions:

```dart
class ExceptionMapper {
  static AppException mapException(dynamic error, [StackTrace? stackTrace]);
  static AppException mapDioException(dynamic error, [StackTrace? stackTrace]);
}
```

**Supported External Exceptions:**
- `SocketException` → `OfflineException`
- `TimeoutException` → `TimeoutException`
- `FormatException` → `ValidationException`
- `PlatformException` → Context-specific exceptions
- `HttpException` → `NetworkException`
- `FileSystemException` → `StorageException`
- `DioException` → Context-specific network exceptions

### 4. Error Response Model

Safe, UI-friendly error representation:

```dart
class AppErrorResponse {
  final String safeMessage;           // UI-safe message
  final String errorCode;             // Stable code
  final bool isRecoverable;           // Retry capability
  final AppExceptionSeverity severity; // User attention level
  final AppExceptionSource source;     // Error domain
  final DateTime timestamp;           // When error occurred
  final Map<String, dynamic>? metadata; // Additional context
}
```

### 5. Error Handler

Centralized error processing:

```dart
abstract class ErrorHandler {
  void handleError(dynamic error, {StackTrace? stackTrace});
  AppException parseError(dynamic error, {StackTrace? stackTrace});
  AppErrorResponse createErrorResponse(AppException exception);
  void logError(AppException exception);
}
```

## Usage Patterns

### 1. Service Implementation Pattern

**✅ CORRECT - Service throws AppException:**

```dart
class UserService {
  Future<User> getUser(String id) async {
    try {
      // Validate input
      if (id.isEmpty) {
        throw ValidationException(
          message: 'User ID cannot be empty',
          code: 'VALIDATION_EMPTY_USER_ID',
        );
      }
      
      // Make network call
      final userData = await _apiCall(id);
      return User.fromJson(userData);
      
    } on AppException {
      // Re-throw known app exceptions
      rethrow;
    } catch (e, stackTrace) {
      // Map unknown errors to AppException
      throw ExceptionMapper.mapException(e, stackTrace);
    }
  }
}
```

**❌ WRONG - Raw exception leakage:**

```dart
// DON'T DO THIS
class BadService {
  Future<User> getUser(String id) async {
    final response = await http.get('/users/$id'); // Raw exception can leak
    return User.fromJson(response.data);
  }
}
```

### 2. Controller/UI Layer Pattern

```dart
class UserController {
  final _errorHandler = ErrorHandlerImpl();
  
  Future<void> loadUser(String userId) async {
    try {
      final user = await _userService.getUser(userId);
      _showUserProfile(user);
      
    } on ValidationException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      _showValidationError(response, e.fieldErrors);
      
    } on TimeoutException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      if (response.isRecoverable) {
        _showRetryDialog('Request timed out', () => loadUser(userId));
      }
      
    } on OfflineException catch (e) {
      _showOfflineMessage();
      
    } on TokenExpiredException catch (e) {
      _redirectToLogin();
      
    } on AppException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      _handleGenericError(response);
      
    } catch (e, stackTrace) {
      // This should never happen if services are properly implemented
      final appException = ExceptionMapper.mapException(e, stackTrace);
      final response = _errorHandler.createErrorResponse(appException);
      _handleGenericError(response);
    }
  }
}
```

### 3. Error Severity Handling

```dart
void _handleGenericError(AppErrorResponse response) {
  switch (response.severity) {
    case AppExceptionSeverity.info:
      _showInfoMessage(response.safeMessage);
      break;
    case AppExceptionSeverity.warning:
      _showWarningDialog(response.safeMessage);
      break;
    case AppExceptionSeverity.error:
      _showErrorDialog(response.safeMessage);
      break;
    case AppExceptionSeverity.critical:
      _showCriticalErrorDialog(response.safeMessage);
      _logCriticalError(response);
      break;
  }
}
```

### 4. Recovery Pattern

```dart
Future<void> _handleRecoverableError(AppErrorResponse response, VoidCallback retryAction) async {
  if (response.isRecoverable) {
    final shouldRetry = await _showRetryDialog(response.safeMessage);
    if (shouldRetry) {
      retryAction();
    }
  } else {
    _showPermanentErrorMessage(response.safeMessage);
  }
}
```

## Exception Types Reference

### Network Exceptions

#### TimeoutException
```dart
const TimeoutException({
  String message = 'Request timeout',
  String code = 'NETWORK_TIMEOUT',
  AppExceptionSeverity severity = AppExceptionSeverity.warning,
  bool isRecoverable = true,
})
```

#### OfflineException
```dart
const OfflineException({
  String message = 'No internet connection',
  String code = 'NETWORK_OFFLINE', 
  AppExceptionSeverity severity = AppExceptionSeverity.warning,
  bool isRecoverable = true,
})
```

### Authentication Exceptions

#### TokenExpiredException
```dart
const TokenExpiredException({
  String message = 'Authentication token has expired',
  String code = 'AUTH_TOKEN_EXPIRED',
  AppExceptionSeverity severity = AppExceptionSeverity.warning,
  bool isRecoverable = true,
})
```

#### PermissionException
```dart
const PermissionException({
  String message = 'Insufficient permissions',
  String code = 'AUTH_PERMISSION_DENIED',
  AppExceptionSeverity severity = AppExceptionSeverity.error,
  bool isRecoverable = false,
})
```

### Storage Exceptions

#### StorageException
```dart
const StorageException({
  required String message,
  required String code,
  AppExceptionSeverity severity = AppExceptionSeverity.error,
  bool isRecoverable = true,
})
```

### Validation Exceptions

#### ValidationException
```dart
const ValidationException({
  required String message,
  required String code,
  AppExceptionSeverity severity = AppExceptionSeverity.warning,
  bool isRecoverable = true,
  Map<String, String>? fieldErrors, // Form field validation errors
})
```

### Backend Exceptions

#### BackendException
```dart
const BackendException({
  required String message,
  required String code,
  AppExceptionSeverity severity = AppExceptionSeverity.error,
  bool isRecoverable = false,
  int? statusCode,                    // HTTP status code
  Map<String, dynamic>? responseData, // Server response data
})
```

## Common Error Codes

### Network Codes
- `NETWORK_TIMEOUT` - Request timeout
- `NETWORK_OFFLINE` - No internet connection
- `NETWORK_CONNECTION_FAILED` - Connection establishment failed
- `NETWORK_REQUEST_CANCELLED` - User cancelled request
- `NETWORK_UNKNOWN_ERROR` - Unmapped network error

### Authentication Codes
- `AUTH_TOKEN_EXPIRED` - Token needs refresh
- `AUTH_PERMISSION_DENIED` - Insufficient permissions
- `AUTH_SIGNIN_FAILED` - Sign-in operation failed
- `AUTH_SIGNUP_FAILED` - Registration failed
- `AUTH_PASSWORD_RESET_FAILED` - Password reset failed

### Storage Codes
- `STORAGE_CONNECTION_ERROR` - Database connection failed
- `STORAGE_SAVE_ERROR` - Save operation failed
- `STORAGE_READ_ERROR` - Read operation failed
- `FILE_NOT_FOUND` - Requested file doesn't exist
- `STORAGE_SERVICE_UNAVAILABLE` - Storage service not available

### Validation Codes
- `VALIDATION_EMPTY_FIELD` - Required field is empty
- `VALIDATION_INVALID_FORMAT` - Data format is invalid
- `VALIDATION_FORMAT_ERROR` - General format error
- `VALIDATION_CLIENT_ERROR` - HTTP 4xx client error

### Backend Codes
- `BACKEND_SERVER_ERROR` - HTTP 5xx server error
- `BACKEND_BAD_RESPONSE` - Unexpected response format
- `BACKEND_RATE_LIMIT` - Rate limit exceeded
- `BACKEND_SYNC_CONFLICT` - Data synchronization conflict

## Best Practices

### For Service Developers

1. **Always Use AppException**: Never throw raw exceptions
2. **Map External Exceptions**: Use `ExceptionMapper.mapException()`
3. **Choose Appropriate Types**: Select the most specific exception type
4. **Set Recovery Flags**: Mark operations as recoverable when appropriate
5. **Provide Clear Messages**: Write user-friendly error messages
6. **Use Stable Codes**: Error codes should not change between versions

### For UI/Controller Developers

1. **Handle Known Exceptions**: Catch specific AppException types first
2. **Check Recoverability**: Offer retry for recoverable errors
3. **Respect Severity**: Handle critical errors differently than warnings
4. **Use Safe Messages**: Display `AppErrorResponse.safeMessage` to users
5. **Log Appropriately**: Log errors with proper context
6. **Provide Fallbacks**: Always have a catch-all handler

### For Testing

1. **Test Error Paths**: Verify error handling logic
2. **Mock Exceptions**: Test with various AppException types
3. **Verify Mapping**: Ensure external exceptions map correctly
4. **Test Recovery**: Verify retry logic works as expected
5. **Check Messages**: Ensure error messages are user-friendly

## Advanced Usage

### Custom Exception Types

Create domain-specific exceptions by extending base types:

```dart
class PaymentException extends BackendException {
  final String transactionId;
  final double amount;
  
  const PaymentException({
    required String message,
    required String code,
    required this.transactionId,
    required this.amount,
    int? statusCode,
    Map<String, dynamic>? responseData,
  }) : super(
    message: message,
    code: code,
    statusCode: statusCode,
    responseData: responseData,
  );
}
```

### Error Context Enhancement

Add context using the `copyWith` method:

```dart
catch (e, stackTrace) {
  final appException = ExceptionMapper.mapException(e, stackTrace);
  throw appException.copyWith(
    message: 'Failed to process user data: ${appException.message}',
  );
}
```

### Batch Error Handling

Handle multiple operations with consistent error handling:

```dart
Future<List<AppErrorResponse>> processMultipleItems(List<Item> items) async {
  final errors = <AppErrorResponse>[];
  
  for (final item in items) {
    try {
      await processItem(item);
    } on AppException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      errors.add(response);
    }
  }
  
  return errors;
}
```

## Migration Guide

### From Raw Exceptions

**Before:**
```dart
Future<User> getUser(String id) async {
  final response = await http.get('/users/$id');
  if (response.statusCode != 200) {
    throw Exception('Failed to load user');
  }
  return User.fromJson(response.data);
}
```

**After:**
```dart
Future<User> getUser(String id) async {
  try {
    final response = await http.get('/users/$id');
    if (response.statusCode != 200) {
      throw BackendException(
        message: 'Failed to load user',
        code: 'USER_LOAD_FAILED',
        statusCode: response.statusCode,
      );
    }
    return User.fromJson(response.data);
  } catch (e, stackTrace) {
    throw ExceptionMapper.mapException(e, stackTrace);
  }
}
```

### From String Error Messages

**Before:**
```dart
String handleError(dynamic error) {
  if (error is SocketException) return 'No internet connection';
  if (error is TimeoutException) return 'Request timed out';
  return 'Unknown error occurred';
}
```

**After:**
```dart
AppErrorResponse handleError(dynamic error, [StackTrace? stackTrace]) {
  final appException = ExceptionMapper.mapException(error, stackTrace);
  return ErrorHandlerImpl().createErrorResponse(appException);
}
```

## Integration Examples

### With State Management

```dart
// Riverpod example
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  try {
    return await ref.read(userServiceProvider).getUser(userId);
  } on AppException catch (e) {
    ref.read(errorHandlerProvider).logError(e);
    throw e; // Let Riverpod handle the error state
  }
});

// Usage in widget
class UserWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));
    
    return userAsync.when(
      data: (user) => UserDisplayWidget(user),
      loading: () => LoadingWidget(),
      error: (error, stack) {
        if (error is OfflineException) {
          return OfflineWidget();
        } else if (error is AppException) {
          final response = ref.read(errorHandlerProvider).createErrorResponse(error);
          return ErrorWidget(response);
        }
        return GenericErrorWidget();
      },
    );
  }
}
```

### With Dio Interceptor

```dart
class AppExceptionInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = ExceptionMapper.mapDioException(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: appException,
    ));
  }
}
```

### With Background Services

```dart
class BackgroundSyncService {
  final _errorHandler = ErrorHandlerImpl();
  
  Future<void> syncData() async {
    try {
      await _performSync();
    } on AppException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      
      if (response.severity == AppExceptionSeverity.critical) {
        await _notifyUserOfCriticalError(response);
      } else if (response.isRecoverable) {
        await _scheduleRetry();
      }
      
      _errorHandler.logError(e);
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Raw exceptions still being thrown**
   - Ensure all service methods use try-catch with ExceptionMapper
   - Check for `rethrow` statements that should be replaced

2. **Inconsistent error messages**
   - Use consistent error codes across similar operations
   - Standardize message formats within each domain

3. **Over-catching exceptions**
   - Don't catch AppException and re-throw as different AppException
   - Let AppExceptions bubble up naturally

4. **Missing error context**
   - Always pass StackTrace to ExceptionMapper when available
   - Include relevant metadata in custom exceptions

### Debugging

Enable verbose error logging:

```dart
class DebugErrorHandler extends ErrorHandlerImpl {
  @override
  void logError(AppException exception) {
    print('=== AppException Debug Info ===');
    print('Type: ${exception.runtimeType}');
    print('Message: ${exception.message}');
    print('Code: ${exception.code}');
    print('Severity: ${exception.severity}');
    print('Source: ${exception.source}');
    print('Recoverable: ${exception.isRecoverable}');
    print('Original: ${exception.originalException}');
    print('Stack: ${exception.stackTrace}');
    print('Map: ${exception.toMap()}');
    print('==============================');
  }
}
```

## Performance Considerations

- Exception creation is lightweight - no performance concerns for normal usage
- Stack trace capture has minimal overhead when exceptions are infrequent
- Error mapping is O(1) for known exception types
- Serialization via `toMap()` is safe for logging and analytics

## Conclusion

The AppException system provides a robust, scalable foundation for error handling in Flutter applications. By following these patterns and practices, you'll build resilient apps that handle errors gracefully and provide excellent user experiences even when things go wrong.

For more examples and implementation details, see:
- `lib/examples/error_handling_example.dart`
- `lib/examples/comprehensive_error_example.dart` 
- `lib/examples/realistic_usage_example.dart`