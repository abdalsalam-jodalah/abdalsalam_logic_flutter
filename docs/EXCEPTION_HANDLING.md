# Exception Handling System Documentation

## Overview

The `abdalsalam_logic_flutter` package provides a comprehensive exception handling system that standardizes error management across all services. The system uses typed exceptions with detailed metadata, automatic error mapping, and integrated logging capabilities.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Core Components](#core-components)
- [Exception Types](#exception-types)
- [Error Handler System](#error-handler-system)
- [Exception Mapper](#exception-mapper)
- [Error Response System](#error-response-system)
- [Best Practices](#best-practices)
- [Integration Guide](#integration-guide)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

## Architecture Overview

The exception system follows a layered architecture:

```
┌─────────────────────────────────────┐
│            Service Layer            │
│  (Throws specific AppExceptions)    │
└─────────────────────────────────────┘
                    │
┌─────────────────────────────────────┐
│         Exception Mapper            │
│  (Maps external → AppException)     │
└─────────────────────────────────────┘
                    │
┌─────────────────────────────────────┐
│          Error Handler              │
│    (Processes & logs errors)        │
└─────────────────────────────────────┘
                    │
┌─────────────────────────────────────┐
│        Error Response               │
│   (User-friendly messages)          │
└─────────────────────────────────────┘
```

### Key Principles

1. **Type Safety** - All exceptions implement `AppException` interface
2. **Structured Data** - Rich metadata for debugging and analytics
3. **User-Friendly** - Separate developer and user-facing messages
4. **Automatic Mapping** - External exceptions converted to typed errors
5. **Integrated Logging** - Automatic error logging with context
6. **Recovery Information** - Clear indication if errors are recoverable

## Core Components

### AppException Interface

The base interface all exceptions must implement:

```dart
abstract class AppException implements Exception {
  String get message;              // Developer message
  String get code;                 // Unique error code
  AppExceptionSeverity get severity; // Error severity level
  AppExceptionSource get source;   // Error source/domain
  bool get isRecoverable;         // Can user recover?
  Exception? get originalException; // Wrapped exception
  StackTrace? get stackTrace;     // Stack trace
  
  AppException copyWith({...});   // Immutable updates
  Map<String, dynamic> toMap();   // Serialization
}
```

### Exception Severity Levels

```dart
enum AppExceptionSeverity { 
  info,     // Informational (e.g., cache miss)
  warning,  // Warning (e.g., deprecated API)
  error,    // Error (e.g., validation failed)
  critical  // Critical (e.g., system failure)
}
```

### Exception Sources

```dart
enum AppExceptionSource { 
  network,     // HTTP/network errors
  storage,     // Database/file errors  
  auth,        // Authentication errors
  validation,  // Input validation errors
  permission,  // Permission/access errors
  backend,     // Server/API errors
  unknown      // Unclassified errors
}
```

## Exception Types

### NetworkException

Handles all network-related errors including HTTP, connectivity, and API issues.

```dart
class NetworkException implements AppException {
  @override
  final AppExceptionSource source = AppExceptionSource.network;
  
  // Additional network-specific properties
  final int? statusCode;
  final String? requestUrl;
  final Duration? timeout;
}
```

**Common Error Codes:**
- `NETWORK_TIMEOUT` - Request timeout
- `NETWORK_NO_CONNECTION` - No internet connection
- `NETWORK_SERVER_ERROR` - Server returned 5xx
- `NETWORK_CLIENT_ERROR` - Client error 4xx
- `NETWORK_UNKNOWN_HOST` - DNS resolution failed

**Example Usage:**
```dart
try {
  await apiService.getData();
} catch (e) {
  if (e is NetworkException) {
    switch (e.code) {
      case 'NETWORK_TIMEOUT':
        // Show retry option
        break;
      case 'NETWORK_NO_CONNECTION':
        // Show offline mode
        break;
      case 'NETWORK_SERVER_ERROR':
        // Show server maintenance message
        break;
    }
  }
}
```

### AuthException

Handles authentication and authorization errors.

```dart
class AuthException implements AppException {
  @override
  final AppExceptionSource source = AppExceptionSource.auth;
  
  // Auth-specific properties
  final String? userId;
  final String? tokenType;
  final bool requiresReauth;
}
```

**Common Error Codes:**
- `AUTH_TOKEN_EXPIRED` - Access token expired
- `AUTH_REFRESH_FAILED` - Refresh token invalid
- `AUTH_INVALID_CREDENTIALS` - Login failed
- `AUTH_UNAUTHORIZED` - Insufficient permissions
- `AUTH_ACCOUNT_LOCKED` - Account temporarily locked

**Example Usage:**
```dart
try {
  await authService.authenticate(credentials);
} catch (e) {
  if (e is AuthException) {
    if (e.requiresReauth) {
      // Redirect to login
      navigateToLogin();
    } else if (e.code == 'AUTH_ACCOUNT_LOCKED') {
      // Show account locked message
      showAccountLockedDialog();
    }
  }
}
```

### StorageException

Handles database, file system, and persistent storage errors.

```dart
class StorageException implements AppException {
  @override
  final AppExceptionSource source = AppExceptionSource.storage;
  
  // Storage-specific properties  
  final String? tableName;
  final String? operation;
  final int? affectedRows;
}
```

**Common Error Codes:**
- `STORAGE_DISK_FULL` - Insufficient storage space
- `STORAGE_PERMISSION_DENIED` - No write permissions
- `STORAGE_CORRUPTION` - Database corruption detected
- `STORAGE_MIGRATION_FAILED` - Schema migration failed
- `STORAGE_CONNECTION_FAILED` - Cannot connect to database

**Example Usage:**
```dart
try {
  await storageService.saveData(data);
} catch (e) {
  if (e is StorageException) {
    if (e.code == 'STORAGE_DISK_FULL') {
      // Prompt user to free space
      showDiskFullDialog();
    } else if (e.code == 'STORAGE_CORRUPTION') {
      // Offer to rebuild database
      showDatabaseRepairDialog();
    }
  }
}
```

### ValidationException

Handles input validation and data format errors.

```dart
class ValidationException implements AppException {
  @override
  final AppExceptionSource source = AppExceptionSource.validation;
  
  // Validation-specific properties
  final String? fieldName;
  final dynamic rejectedValue;
  final List<String>? constraints;
}
```

**Common Error Codes:**
- `VALIDATION_REQUIRED_FIELD` - Required field missing
- `VALIDATION_INVALID_FORMAT` - Invalid data format
- `VALIDATION_OUT_OF_RANGE` - Value outside valid range
- `VALIDATION_DUPLICATE_VALUE` - Value already exists
- `VALIDATION_INVALID_TYPE` - Wrong data type

**Example Usage:**
```dart
try {
  await userService.createUser(userData);
} catch (e) {
  if (e is ValidationException) {
    // Show field-specific error
    showFieldError(e.fieldName, e.message);
  }
}
```

### BackendException

Handles server-side business logic errors and API-specific issues.

```dart
class BackendException implements AppException {
  @override
  final AppExceptionSource source = AppExceptionSource.backend;
  
  // Backend-specific properties
  final String? apiEndpoint;
  final String? requestId;
  final Map<String, dynamic>? serverDetails;
}
```

**Common Error Codes:**
- `BACKEND_BUSINESS_RULE_VIOLATION` - Business logic error
- `BACKEND_RESOURCE_NOT_FOUND` - Resource doesn't exist
- `BACKEND_CONFLICT` - Resource conflict (e.g., concurrent update)
- `BACKEND_RATE_LIMITED` - Too many requests
- `BACKEND_MAINTENANCE` - Server under maintenance

### FileException

Handles file operations, downloads, and file system errors.

```dart
abstract class FileException implements AppException {
  @override
  final AppExceptionSource source = AppExceptionSource.storage;
}

// Specific file exception types
class FileDownloadException extends FileException { }
class InvalidFileUrlException extends FileException { }
class FilePermissionException extends FileException { }
class FileNotFoundException extends FileException { }
class FileOpenException extends FileException { }
class UnsupportedFileTypeException extends FileException { }
```

**Common Error Codes:**
- `FILE_DOWNLOAD_FAILED` - Download failed
- `FILE_INVALID_URL` - Malformed URL
- `FILE_NOT_FOUND` - File doesn't exist
- `FILE_PERMISSION_DENIED` - Access denied
- `FILE_UNSUPPORTED_TYPE` - File type not supported

### UnknownAppException

Fallback for unclassified errors that couldn't be mapped to specific types.

```dart
class UnknownAppException implements AppException {
  @override
  final AppExceptionSource source = AppExceptionSource.unknown;
  
  // Always includes original exception for debugging
  @override
  final Exception originalException;
}
```

## Error Handler System

### ErrorHandler Interface

```dart
abstract class ErrorHandler {
  void handleError(dynamic error, {StackTrace? stackTrace});
  AppException parseError(dynamic error, {StackTrace? stackTrace});
  AppErrorResponse createErrorResponse(AppException exception);
  void logError(AppException exception);
}
```

### ErrorHandlerImpl

The default implementation that:
- Parses raw errors into typed exceptions
- Logs errors with integrated logging service
- Creates user-friendly error responses
- Provides extensibility for custom handling

```dart
final errorHandler = ErrorHandlerImpl(logger: logger);

// Handle any error
try {
  await riskyOperation();
} catch (error, stackTrace) {
  errorHandler.handleError(error, stackTrace: stackTrace);
}
```

### Custom Error Handling

Extend `ErrorHandlerImpl` for custom behavior:

```dart
class CustomErrorHandler extends ErrorHandlerImpl {
  @override
  void logError(AppException exception) {
    super.logError(exception);
    
    // Custom logging (e.g., analytics)
    if (exception.severity == AppExceptionSeverity.critical) {
      analytics.trackCriticalError(exception);
    }
  }
  
  @override
  AppErrorResponse createErrorResponse(AppException exception) {
    // Custom user messages
    if (exception is NetworkException && exception.statusCode == 503) {
      return AppErrorResponse(
        userMessage: 'Our servers are currently under maintenance. Please try again later.',
        shouldShowToUser: true,
      );
    }
    
    return super.createErrorResponse(exception);
  }
}
```

## Exception Mapper

The `ExceptionMapper` automatically converts external exceptions to typed `AppException` instances.

### Mapping Rules

```dart
class ExceptionMapper {
  static AppException mapException(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error; // Already mapped
    }
    
    if (error is SocketException) {
      return NetworkException(
        message: 'Network connection failed',
        code: 'NETWORK_CONNECTION_FAILED',
        originalException: error,
        stackTrace: stackTrace,
      );
    }
    
    if (error is TimeoutException) {
      return NetworkException(
        message: 'Request timeout',
        code: 'NETWORK_TIMEOUT',
        originalException: error,
        stackTrace: stackTrace,
      );
    }
    
    if (error is HttpException) {
      return NetworkException(
        message: 'HTTP error: ${error.message}',
        code: 'NETWORK_HTTP_ERROR',
        statusCode: error.statusCode,
        originalException: error,
        stackTrace: stackTrace,
      );
    }
    
    if (error is FileSystemException) {
      return StorageException(
        message: 'File system error: ${error.message}',
        code: 'STORAGE_FILE_SYSTEM_ERROR',
        originalException: error,
        stackTrace: stackTrace,
      );
    }
    
    // Default fallback
    return UnknownAppException(
      message: 'Unknown error occurred: ${error.toString()}',
      code: 'UNKNOWN_ERROR',
      originalException: error is Exception ? error : Exception(error.toString()),
      stackTrace: stackTrace,
    );
  }
}
```

### Usage in Services

```dart
class ApiService {
  final Dio _dio;
  
  Future<Data> fetchData() async {
    try {
      final response = await _dio.get('/api/data');
      return Data.fromJson(response.data);
    } catch (error, stackTrace) {
      // Automatically map to AppException
      throw ExceptionMapper.mapException(error, stackTrace);
    }
  }
}
```

## Error Response System

### AppErrorResponse

Provides user-friendly error information separate from developer details:

```dart
class AppErrorResponse {
  final String userMessage;        // User-facing message
  final String developerMessage;   // Technical details
  final String errorCode;          // Error code
  final bool shouldShowToUser;     // Should display to user
  final bool isRecoverable;        // Can user take action
  final Map<String, dynamic>? context; // Additional context
  
  // Factory constructors for common scenarios
  factory AppErrorResponse.fromException(AppException exception);
  factory AppErrorResponse.userFriendly(String message);
  factory AppErrorResponse.technical(String details);
}
```

### Usage Examples

```dart
// Create response from exception
final response = AppErrorResponse.fromException(networkException);

// Show appropriate message to user
if (response.shouldShowToUser) {
  showSnackBar(response.userMessage);
} else {
  logger.error(response.developerMessage);
}

// Check if user can take action
if (response.isRecoverable) {
  showRetryButton();
}
```

## Best Practices

### 1. Always Use Typed Exceptions

```dart
// ❌ Bad - Generic exception
throw Exception('Network failed');

// ✅ Good - Typed exception
throw NetworkException(
  message: 'Network request failed',
  code: 'NETWORK_REQUEST_FAILED',
  statusCode: response.statusCode,
);
```

### 2. Provide Meaningful Error Codes

```dart
// ❌ Bad - Generic codes
throw ValidationException(code: 'ERROR');

// ✅ Good - Specific codes  
throw ValidationException(
  code: 'VALIDATION_EMAIL_INVALID',
  fieldName: 'email',
  rejectedValue: userInput,
);
```

### 3. Include Recovery Information

```dart
// ❌ Bad - No recovery guidance
throw NetworkException(
  message: 'Request failed',
  isRecoverable: true, // But how?
);

// ✅ Good - Clear recovery path
throw NetworkException(
  message: 'Request timeout - check connection and retry',
  code: 'NETWORK_TIMEOUT',
  isRecoverable: true,
);
```

### 4. Preserve Original Exceptions

```dart
// ❌ Bad - Lose original context
try {
  await apiCall();
} catch (e) {
  throw NetworkException(message: 'Failed');
}

// ✅ Good - Preserve context
try {
  await apiCall();
} catch (e, stackTrace) {
  throw ExceptionMapper.mapException(e, stackTrace);
}
```

### 5. Use Exception Mapper Consistently

```dart
class Service {
  Future<Data> operation() async {
    try {
      // Risky operation
      return await externalService.fetch();
    } catch (error, stackTrace) {
      // Always use mapper for consistency
      throw ExceptionMapper.mapException(error, stackTrace);
    }
  }
}
```

### 6. Handle Exceptions at Appropriate Levels

```dart
// Service layer - Convert to typed exceptions
class UserService {
  Future<User> getUser(String id) async {
    try {
      return await userRepository.findById(id);
    } catch (e, stack) {
      throw ExceptionMapper.mapException(e, stack);
    }
  }
}

// Controller layer - Handle business logic
class UserController {
  Future<void> displayUser(String id) async {
    try {
      final user = await userService.getUser(id);
      view.showUser(user);
    } catch (e) {
      if (e is ValidationException && e.code == 'USER_NOT_FOUND') {
        view.showUserNotFoundMessage();
      } else {
        errorHandler.handleError(e);
      }
    }
  }
}

// View layer - Display user-friendly messages
class UserView {
  void handleError(AppException exception) {
    final response = AppErrorResponse.fromException(exception);
    
    if (response.shouldShowToUser) {
      showDialog(response.userMessage);
    } else {
      logger.error(response.developerMessage);
    }
  }
}
```

## Integration Guide

### Setup Error Handling

```dart
// 1. Initialize error handler with logger
final logger = LoggerImpl(config: logConfig);
final errorHandler = ErrorHandlerImpl(logger: logger);

// 2. Register with dependency injection
GetIt.instance.registerSingleton<ErrorHandler>(errorHandler);

// 3. Use in services
class ApiService {
  final ErrorHandler _errorHandler = GetIt.instance<ErrorHandler>();
  
  Future<Data> fetchData() async {
    try {
      final response = await http.get(url);
      return parseResponse(response);
    } catch (error, stackTrace) {
      _errorHandler.handleError(error, stackTrace: stackTrace);
      rethrow;
    }
  }
}
```

### Global Error Handling

```dart
// Catch unhandled errors
void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorHandler = GetIt.instance<ErrorHandler>();
    errorHandler.handleError(details.exception, stackTrace: details.stack);
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorHandler = GetIt.instance<ErrorHandler>();
    errorHandler.handleError(error, stackTrace: stack);
    return true;
  };
  
  runApp(MyApp());
}
```

### Custom Exception Types

Create domain-specific exceptions:

```dart
class PaymentException implements AppException {
  @override
  final String message;
  @override
  final String code;
  @override
  final AppExceptionSeverity severity;
  @override
  final AppExceptionSource source = AppExceptionSource.backend;
  @override
  final bool isRecoverable;
  
  // Payment-specific properties
  final String? transactionId;
  final String? paymentMethod;
  final double? amount;
  
  const PaymentException({
    required this.message,
    required this.code,
    this.severity = AppExceptionSeverity.error,
    this.isRecoverable = true,
    this.transactionId,
    this.paymentMethod,
    this.amount,
  });
  
  // Implement required methods...
}

// Register in exception mapper
class CustomExceptionMapper extends ExceptionMapper {
  @override
  static AppException mapException(dynamic error, [StackTrace? stackTrace]) {
    if (error is StripeException) {
      return PaymentException(
        message: 'Payment failed: ${error.message}',
        code: 'PAYMENT_STRIPE_ERROR',
        transactionId: error.paymentIntent?.id,
        originalException: error,
        stackTrace: stackTrace,
      );
    }
    
    return super.mapException(error, stackTrace);
  }
}
```

## Examples

### Complete Service Implementation

```dart
class UserService {
  final UserRepository _repository;
  final ErrorHandler _errorHandler;
  
  UserService(this._repository, this._errorHandler);
  
  Future<User> createUser(CreateUserRequest request) async {
    try {
      // Validate request
      _validateCreateUserRequest(request);
      
      // Check for existing user
      final existingUser = await _repository.findByEmail(request.email);
      if (existingUser != null) {
        throw ValidationException(
          message: 'User with email ${request.email} already exists',
          code: 'VALIDATION_USER_EMAIL_EXISTS',
          fieldName: 'email',
          rejectedValue: request.email,
        );
      }
      
      // Create user
      final user = User.fromRequest(request);
      return await _repository.save(user);
      
    } catch (error, stackTrace) {
      // Log and rethrow as typed exception
      final appException = ExceptionMapper.mapException(error, stackTrace);
      _errorHandler.logError(appException);
      throw appException;
    }
  }
  
  void _validateCreateUserRequest(CreateUserRequest request) {
    if (request.email.isEmpty) {
      throw ValidationException(
        message: 'Email is required',
        code: 'VALIDATION_EMAIL_REQUIRED',
        fieldName: 'email',
        rejectedValue: request.email,
      );
    }
    
    if (!_isValidEmail(request.email)) {
      throw ValidationException(
        message: 'Invalid email format',
        code: 'VALIDATION_EMAIL_INVALID',
        fieldName: 'email',
        rejectedValue: request.email,
      );
    }
    
    if (request.password.length < 8) {
      throw ValidationException(
        message: 'Password must be at least 8 characters',
        code: 'VALIDATION_PASSWORD_TOO_SHORT',
        fieldName: 'password',
        constraints: ['minLength:8'],
      );
    }
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
```

### Error Handling in UI

```dart
class UserRegistrationWidget extends StatefulWidget {
  @override
  _UserRegistrationWidgetState createState() => _UserRegistrationWidgetState();
}

class _UserRegistrationWidgetState extends State<UserRegistrationWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserService _userService = GetIt.instance<UserService>();
  
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};
  
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _fieldErrors.clear();
    });
    
    try {
      final request = CreateUserRequest(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      final user = await _userService.createUser(request);
      _showSuccessMessage('Registration successful!');
      Navigator.pushReplacementNamed(context, '/dashboard');
      
    } catch (error) {
      _handleRegistrationError(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _handleRegistrationError(dynamic error) {
    if (error is ValidationException) {
      // Show field-specific errors
      if (error.fieldName != null) {
        setState(() {
          _fieldErrors[error.fieldName!] = error.message;
        });
      } else {
        _showErrorMessage(error.message);
      }
    } else if (error is NetworkException) {
      // Handle network errors
      if (error.code == 'NETWORK_NO_CONNECTION') {
        _showErrorMessage('No internet connection. Please check your network and try again.');
      } else if (error.code == 'NETWORK_TIMEOUT') {
        _showErrorMessage('Request timeout. Please try again.');
      } else {
        _showErrorMessage('Network error occurred. Please try again later.');
      }
    } else if (error is BackendException) {
      // Handle server errors
      if (error.code == 'BACKEND_MAINTENANCE') {
        _showErrorMessage('Server is under maintenance. Please try again later.');
      } else {
        _showErrorMessage('Server error occurred. Please try again.');
      }
    } else {
      // Handle unknown errors
      _showErrorMessage('An unexpected error occurred. Please try again.');
    }
  }
  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
  
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _fieldErrors['email'],
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: _fieldErrors['password'],
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Password is required';
                  if ((value?.length ?? 0) < 8) return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading 
                  ? CircularProgressIndicator()
                  : Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Analytics Integration

```dart
class AnalyticsErrorHandler extends ErrorHandlerImpl {
  final AnalyticsService _analytics;
  
  AnalyticsErrorHandler(this._analytics, {Logger? logger}) : super(logger: logger);
  
  @override
  void logError(AppException exception) {
    // Standard logging
    super.logError(exception);
    
    // Analytics tracking
    _analytics.trackError(
      errorCode: exception.code,
      errorMessage: exception.message,
      errorSource: exception.source.name,
      severity: exception.severity.name,
      isRecoverable: exception.isRecoverable,
      metadata: _extractMetadata(exception),
    );
    
    // Critical error alerts
    if (exception.severity == AppExceptionSeverity.critical) {
      _analytics.trackCriticalError(
        code: exception.code,
        message: exception.message,
        stackTrace: exception.stackTrace?.toString(),
      );
    }
  }
  
  Map<String, dynamic> _extractMetadata(AppException exception) {
    final metadata = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
    };
    
    if (exception is NetworkException) {
      metadata['statusCode'] = exception.statusCode;
      metadata['requestUrl'] = exception.requestUrl;
    } else if (exception is ValidationException) {
      metadata['fieldName'] = exception.fieldName;
      metadata['rejectedValue'] = exception.rejectedValue?.toString();
    } else if (exception is StorageException) {
      metadata['tableName'] = exception.tableName;
      metadata['operation'] = exception.operation;
    }
    
    return metadata;
  }
}
```

## Troubleshooting

### Common Issues

#### Unhandled Exceptions

**Problem**: Raw exceptions not being converted to AppException
**Solution**: Ensure all service methods use ExceptionMapper

```dart
// ❌ Problem
Future<Data> fetchData() async {
  final response = await http.get(url); // May throw SocketException
  return parseResponse(response);
}

// ✅ Solution  
Future<Data> fetchData() async {
  try {
    final response = await http.get(url);
    return parseResponse(response);
  } catch (error, stackTrace) {
    throw ExceptionMapper.mapException(error, stackTrace);
  }
}
```

#### Missing Error Context

**Problem**: Exceptions don't provide enough debugging information
**Solution**: Include relevant context in exception creation

```dart
// ❌ Problem
throw ValidationException(
  message: 'Invalid input',
  code: 'VALIDATION_ERROR',
);

// ✅ Solution
throw ValidationException(
  message: 'Email format is invalid',
  code: 'VALIDATION_EMAIL_INVALID',
  fieldName: 'email',
  rejectedValue: userInput,
  constraints: ['format:email'],
);
```

#### Inconsistent Error Handling

**Problem**: Different parts of app handle errors differently
**Solution**: Centralize error handling logic

```dart
// Create centralized error handler
class AppErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    final response = AppErrorResponse.fromException(error);
    
    if (response.shouldShowToUser) {
      _showUserError(context, response);
    } else {
      _logTechnicalError(response);
    }
  }
  
  static void _showUserError(BuildContext context, AppErrorResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(response.userMessage),
        actions: [
          if (response.isRecoverable)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

### Debugging Tips

#### Enable Detailed Error Logging

```dart
final logger = LoggerImpl(
  config: LogConfig(
    level: LogLevel.debug,
    includeStackTrace: true,
    includeTimestamp: true,
  ),
);

final errorHandler = ErrorHandlerImpl(logger: logger);
```

#### Create Error Reports

```dart
String createErrorReport(AppException exception) {
  final buffer = StringBuffer();
  
  buffer.writeln('=== ERROR REPORT ===');
  buffer.writeln('Code: ${exception.code}');
  buffer.writeln('Message: ${exception.message}');
  buffer.writeln('Severity: ${exception.severity}');
  buffer.writeln('Source: ${exception.source}');
  buffer.writeln('Recoverable: ${exception.isRecoverable}');
  buffer.writeln('Timestamp: ${DateTime.now().toIso8601String()}');
  
  if (exception.originalException != null) {
    buffer.writeln('Original: ${exception.originalException}');
  }
  
  if (exception.stackTrace != null) {
    buffer.writeln('Stack Trace:');
    buffer.writeln(exception.stackTrace);
  }
  
  buffer.writeln('Details: ${exception.toMap()}');
  buffer.writeln('==================');
  
  return buffer.toString();
}
```

#### Test Error Scenarios

```dart
// Create test exceptions for different scenarios
void testErrorHandling() {
  final scenarios = [
    NetworkException(code: 'NETWORK_TIMEOUT', message: 'Request timeout'),
    AuthException(code: 'AUTH_TOKEN_EXPIRED', message: 'Token expired'),
    ValidationException(code: 'VALIDATION_REQUIRED', fieldName: 'email'),
    StorageException(code: 'STORAGE_DISK_FULL', message: 'Disk full'),
  ];
  
  for (final exception in scenarios) {
    print('Testing: ${exception.runtimeType}');
    final response = AppErrorResponse.fromException(exception);
    print('User message: ${response.userMessage}');
    print('Recoverable: ${response.isRecoverable}');
    print('---');
  }
}
```

### Performance Considerations

#### Exception Creation Overhead

Keep exception creation lightweight:

```dart
// ❌ Expensive - Complex object creation
throw ValidationException(
  message: 'Validation failed',
  code: 'VALIDATION_FAILED',
  metadata: await heavyComputationForMetadata(), // Avoid async in constructor
);

// ✅ Lightweight - Simple data
throw ValidationException(
  message: 'Validation failed', 
  code: 'VALIDATION_FAILED',
  fieldName: fieldName,
  rejectedValue: value,
);
```

#### Stack Trace Handling

Control stack trace capture:

```dart
// For non-critical errors, avoid capturing stack trace
throw ValidationException(
  message: 'Invalid email format',
  code: 'VALIDATION_EMAIL_INVALID',
  // Don't capture stack trace for validation errors
);

// For critical errors, always include stack trace
try {
  criticalOperation();
} catch (error, stackTrace) {
  throw ExceptionMapper.mapException(error, stackTrace);
}
```

---

**Package**: `abdalsalam_logic_flutter`  
**Documentation Version**: 1.0.0  
**Last Updated**: February 2026