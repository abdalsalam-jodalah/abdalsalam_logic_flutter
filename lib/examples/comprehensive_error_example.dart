// lib/examples/comprehensive_error_example.dart

import 'dart:io';
import 'package:flutter/services.dart';
import '../src/core/errors/app_exception.dart';
import '../src/core/errors/app_error_response.dart';
import '../src/core/errors/exception_mapper.dart';
import '../src/core/errors/network_exception.dart';
import '../src/core/errors/auth_exception.dart';
import '../src/core/errors/storage_exception.dart';
import '../src/core/errors/validation_exception.dart';
import '../src/core/errors/backend_exception.dart';
import '../src/core/errors/unknown_app_exception.dart';
import '../src/core/errors/error_handler_impl.dart';

class ComprehensiveErrorExample {
  final _errorHandler = ErrorHandlerImpl();

  void demonstrateWrappingExternalExceptions() {
    print('=== Wrapping External Exceptions ===');

    // Wrap SocketException
    try {
      throw SocketException('Network unreachable');
    } catch (e, stackTrace) {
      final appException = ExceptionMapper.mapException(e, stackTrace);
      final response = _errorHandler.createErrorResponse(appException);
      print('SocketException -> ${response.safeMessage} (${response.errorCode})');
    }

    // Wrap FormatException
    try {
      throw FormatException('Invalid JSON format');
    } catch (e, stackTrace) {
      final appException = ExceptionMapper.mapException(e, stackTrace);
      final response = _errorHandler.createErrorResponse(appException);
      print('FormatException -> ${response.safeMessage} (${response.errorCode})');
    }

    // Wrap PlatformException
    try {
      throw PlatformException(code: 'permission_denied', message: 'Camera access denied');
    } catch (e, stackTrace) {
      final appException = ExceptionMapper.mapException(e, stackTrace);
      final response = _errorHandler.createErrorResponse(appException);
      print('PlatformException -> ${response.safeMessage} (${response.errorCode})');
    }
  }

  void demonstrateCustomExceptions() {
    print('\\n=== Custom App Exceptions ===');

    // Network timeout
    final timeoutError = TimeoutException(
      message: 'API request timed out after 30 seconds',
    );
    _printErrorResponse(timeoutError);

    // Token expiry
    final tokenError = TokenExpiredException(
      message: 'Session has expired, please login again',
    );
    _printErrorResponse(tokenError);

    // Validation with field errors
    final validationError = ValidationException(
      message: 'User registration failed validation',
      code: 'VALIDATION_REGISTRATION_ERROR',
      fieldErrors: {
        'email': 'Email format is invalid',
        'password': 'Password must be at least 8 characters',
        'username': 'Username already taken',
      },
    );
    _printErrorResponse(validationError);

    // Storage error
    final storageError = StorageException(
      message: 'Failed to save user preferences',
      code: 'STORAGE_SAVE_ERROR',
      severity: AppExceptionSeverity.warning,
      isRecoverable: true,
    );
    _printErrorResponse(storageError);

    // Backend error with response data
    final backendError = BackendException(
      message: 'Payment processing failed',
      code: 'BACKEND_PAYMENT_ERROR',
      statusCode: 422,
      responseData: {
        'error_type': 'insufficient_funds',
        'account_balance': 25.50,
        'required_amount': 99.99,
      },
    );
    _printErrorResponse(backendError);
  }

  void demonstrateErrorRecovery() {
    print('\\n=== Error Recovery Patterns ===');

    final recoverableErrors = [
      TimeoutException(),
      OfflineException(),
      StorageException(
        message: 'Database temporarily unavailable',
        code: 'STORAGE_TEMP_UNAVAILABLE',
        isRecoverable: true,
      ),
    ];

    final nonRecoverableErrors = [
      PermissionException(),
      ValidationException(
        message: 'Invalid API key',
        code: 'VALIDATION_API_KEY_INVALID',
        isRecoverable: false,
      ),
      BackendException(
        message: 'Account suspended',
        code: 'BACKEND_ACCOUNT_SUSPENDED',
        statusCode: 403,
        isRecoverable: false,
      ),
    ];

    print('Recoverable errors:');
    for (final error in recoverableErrors) {
      final response = _errorHandler.createErrorResponse(error);
      print('  ${error.runtimeType}: ${response.isRecoverable ? "CAN RETRY" : "CANNOT RETRY"}');
    }

    print('\\nNon-recoverable errors:');
    for (final error in nonRecoverableErrors) {
      final response = _errorHandler.createErrorResponse(error);
      print('  ${error.runtimeType}: ${response.isRecoverable ? "CAN RETRY" : "CANNOT RETRY"}');
    }
  }

  void demonstrateSeverityLevels() {
    print('\\n=== Error Severity Levels ===');

    final errors = [
      NetworkException(
        message: 'Request cancelled by user',
        code: 'NETWORK_CANCELLED',
        severity: AppExceptionSeverity.info,
        isRecoverable: true,
      ),
      ValidationException(
        message: 'Form field validation warning',
        code: 'VALIDATION_WARNING',
        severity: AppExceptionSeverity.warning,
      ),
      StorageException(
        message: 'Failed to update user profile',
        code: 'STORAGE_UPDATE_ERROR',
        severity: AppExceptionSeverity.error,
      ),
      BackendException(
        message: 'Database connection lost',
        code: 'BACKEND_DB_CONNECTION_LOST',
        severity: AppExceptionSeverity.critical,
        statusCode: 500,
      ),
    ];

    for (final error in errors) {
      final response = _errorHandler.createErrorResponse(error);
      print('${error.severity.name.toUpperCase()}: ${response.safeMessage}');
    }
  }

  void demonstrateCopyWithFunctionality() {
    print('\\n=== CopyWith Functionality ===');

    final originalError = NetworkException(
      message: 'Connection failed',
      code: 'NETWORK_CONNECTION_FAILED',
      severity: AppExceptionSeverity.error,
      isRecoverable: true,
    );

    final modifiedError = originalError.copyWith(
      message: 'Connection failed - retry available',
      severity: AppExceptionSeverity.warning,
    );

    print('Original: ${originalError.message} (${originalError.severity.name})');
    print('Modified: ${modifiedError.message} (${modifiedError.severity.name})');
  }

  void demonstrateSerializationSafety() {
    print('\\n=== Serialization Safety ===');

    final error = BackendException(
      message: 'API rate limit exceeded',
      code: 'BACKEND_RATE_LIMIT',
      statusCode: 429,
      responseData: {
        'limit': 1000,
        'remaining': 0,
        'reset_time': '2026-02-02T15:30:00Z',
      },
    );

    final response = _errorHandler.createErrorResponse(error);
    final serialized = response.toMap();

    print('Serialized error response:');
    serialized.forEach((key, value) {
      print('  $key: $value');
    });
  }

  void _printErrorResponse(AppException error) {
    final response = _errorHandler.createErrorResponse(error);
    print('${error.runtimeType}: ${response.safeMessage}');
    print('  Code: ${response.errorCode}');
    print('  Severity: ${response.severity.name}');
    print('  Recoverable: ${response.isRecoverable}');
    print('  Source: ${response.source.name}');
  }
}

Future<void> demonstrateServiceIntegration() async {
  print('\\n=== Service Integration Pattern ===');

  final networkService = NetworkServiceWithErrorHandling();
  await networkService.fetchUserData('user123');

  final storageService = StorageServiceWithErrorHandling();
  await storageService.saveUserPreferences({'theme': 'dark'});
}

class NetworkServiceWithErrorHandling {
  final _errorHandler = ErrorHandlerImpl();

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    try {
      // Simulate network call that fails
      throw SocketException('No route to host');
    } catch (e, stackTrace) {
      // Map to AppException
      final appException = ExceptionMapper.mapException(e, stackTrace);
      
      // Create safe error response
      final errorResponse = _errorHandler.createErrorResponse(appException);
      
      print('Network Service Error: ${errorResponse.safeMessage}');
      print('Error is ${errorResponse.isRecoverable ? "recoverable" : "not recoverable"}');
      
      // Never throw raw exceptions outside service
      throw appException;
    }
  }
}

class StorageServiceWithErrorHandling {
  final _errorHandler = ErrorHandlerImpl();

  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      // Simulate storage operation that fails
      throw FileSystemException('Disk full', '/path/to/file');
    } catch (e, stackTrace) {
      // Map to AppException
      final appException = ExceptionMapper.mapException(e, stackTrace);
      
      // Handle based on recoverability
      final errorResponse = _errorHandler.createErrorResponse(appException);
      
      if (errorResponse.isRecoverable) {
        print('Storage warning: ${errorResponse.safeMessage} - will retry later');
        // Implement retry logic or queue for later
      } else {
        print('Storage error: ${errorResponse.safeMessage} - operation failed');
        // Show user error message and alternative options
      }
      
      throw appException;
    }
  }
}

void main() {
  final example = ComprehensiveErrorExample();
  
  example.demonstrateWrappingExternalExceptions();
  example.demonstrateCustomExceptions();
  example.demonstrateErrorRecovery();
  example.demonstrateSeverityLevels();
  example.demonstrateCopyWithFunctionality();
  example.demonstrateSerializationSafety();
  
  demonstrateServiceIntegration();
}