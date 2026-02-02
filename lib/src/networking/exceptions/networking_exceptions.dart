// lib/src/networking/exceptions/networking_exceptions.dart
import '../../core/errors/network_exception.dart';

class NetworkTimeoutException extends NetworkException {
  const NetworkTimeoutException({
    String message = 'Network request timed out',
    String code = 'NETWORK_TIMEOUT',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  }) : super(message: message, code: code);
}

class NetworkOfflineException extends NetworkException {
  const NetworkOfflineException({
    String message = 'Network is offline',
    String code = 'NETWORK_OFFLINE',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  }) : super(message: message, code: code);
}

class NetworkManagerDisabledException extends NetworkException {
  const NetworkManagerDisabledException({
    String message = 'Network manager is disabled',
    String code = 'NETWORK_MANAGER_DISABLED',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  }) : super(message: message, code: code);
}

class NetworkBackendException extends NetworkException {
  const NetworkBackendException({
    String message = 'Backend error occurred',
    String code = 'NETWORK_BACKEND_ERROR',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  }) : super(message: message, code: code);
}

class NetworkAuthFailedException extends NetworkException {
  const NetworkAuthFailedException({
    String message = 'Network authentication failed',
    String code = 'NETWORK_AUTH_FAILED',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  }) : super(message: message, code: code);
}

class NetworkValidationException extends NetworkException {
  const NetworkValidationException({
    String message = 'Network validation error',
    String code = 'NETWORK_VALIDATION_ERROR',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  }) : super(message: message, code: code);
}

class NetworkUnregisteredApiException extends NetworkException {
  const NetworkUnregisteredApiException({
    String message = 'Unregistered API endpoint',
    String code = 'NETWORK_UNREGISTERED_API',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  }) : super(message: message, code: code);
}