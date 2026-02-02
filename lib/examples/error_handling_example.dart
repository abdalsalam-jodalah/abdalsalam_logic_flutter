// lib/examples/error_handling_example.dart

import 'dart:io';
import '../src/core/errors/app_exception.dart';
import '../src/core/errors/app_error_response.dart';
import '../src/core/errors/exception_mapper.dart';
import '../src/core/errors/network_exception.dart';
import '../src/core/errors/auth_exception.dart';
import '../src/core/errors/storage_exception.dart';
import '../src/core/errors/validation_exception.dart';
import '../src/core/errors/error_handler.dart';
import '../src/core/errors/error_handler_impl.dart';

void demonstrateErrorHandling() {
  final errorHandler = ErrorHandlerImpl();

  // Example 1: Wrapping a socket exception
  try {
    throw SocketException('Connection failed');
  } catch (e, stackTrace) {
    final appException = ExceptionMapper.mapException(e, stackTrace);
    final response = errorHandler.createErrorResponse(appException);
    print('Mapped SocketException: ${response.safeMessage}');
  }

  // Example 2: Custom network exception
  final networkError = NetworkException(
    message: 'API endpoint not found',
    code: 'NETWORK_404',
    severity: AppExceptionSeverity.warning,
    isRecoverable: true,
  );
  final networkResponse = errorHandler.createErrorResponse(networkError);
  print('Network error: ${networkResponse.safeMessage}');

  // Example 3: Token expired scenario
  final tokenError = TokenExpiredException();
  final tokenResponse = errorHandler.createErrorResponse(tokenError);
  print('Auth error: ${tokenResponse.safeMessage}, Recoverable: ${tokenResponse.isRecoverable}');

  // Example 4: Validation with field errors
  final validationError = ValidationException(
    message: 'Form validation failed',
    code: 'VALIDATION_FORM_ERROR',
    fieldErrors: {
      'email': 'Invalid email format',
      'password': 'Password too short',
    },
  );
  final validationResponse = errorHandler.createErrorResponse(validationError);
  print('Validation error: ${validationResponse.safeMessage}');

  // Example 5: Storage exception
  final storageError = StorageException(
    message: 'Database connection failed',
    code: 'STORAGE_CONNECTION_ERROR',
    severity: AppExceptionSeverity.critical,
    isRecoverable: false,
  );
  final storageResponse = errorHandler.createErrorResponse(storageError);
  print('Storage error: ${storageResponse.safeMessage}');
}

class NetworkServiceExample {
  final ErrorHandler _errorHandler = ErrorHandlerImpl();

  Future<String> fetchData() async {
    try {
      // Simulated network call that might fail
      throw SocketException('No internet connection');
    } catch (e, stackTrace) {
      // Never throw raw exceptions outside the module
      final appException = ExceptionMapper.mapException(e, stackTrace);
      throw appException;
    }
  }

  Future<void> handleNetworkCall() async {
    try {
      final data = await fetchData();
      print('Success: $data');
    } on AppException catch (e) {
      // Handle known app exceptions
      final response = _errorHandler.createErrorResponse(e);
      if (response.isRecoverable) {
        print('Recoverable error: ${response.safeMessage}');
        // Implement retry logic
      } else {
        print('Non-recoverable error: ${response.safeMessage}');
        // Show user-friendly error message
      }
    }
  }
}