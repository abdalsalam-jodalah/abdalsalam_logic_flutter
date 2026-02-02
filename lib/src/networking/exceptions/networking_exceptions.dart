// lib/src/networking/exceptions/networking_exceptions.dart
import '../../core/errors/network_exception.dart';

class NetworkTimeoutException extends NetworkException {
  const NetworkTimeoutException({
    super.message = 'Network request timed out',
    super.code = 'NETWORK_TIMEOUT',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  });
}

class NetworkOfflineException extends NetworkException {
  const NetworkOfflineException({
    super.message = 'Network is offline',
    super.code = 'NETWORK_OFFLINE',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  });
}

class NetworkManagerDisabledException extends NetworkException {
  const NetworkManagerDisabledException({
    super.message = 'Network manager is disabled',
    super.code = 'NETWORK_MANAGER_DISABLED',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  });
}

class NetworkBackendException extends NetworkException {
  const NetworkBackendException({
    super.message = 'Backend error occurred',
    super.code = 'NETWORK_BACKEND_ERROR',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  });
}

class NetworkAuthFailedException extends NetworkException {
  const NetworkAuthFailedException({
    super.message = 'Network authentication failed',
    super.code = 'NETWORK_AUTH_FAILED',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  });
}

class NetworkValidationException extends NetworkException {
  const NetworkValidationException({
    super.message = 'Network validation error',
    super.code = 'NETWORK_VALIDATION_ERROR',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  });
}

class NetworkUnregisteredApiException extends NetworkException {
  const NetworkUnregisteredApiException({
    super.message = 'Unregistered API endpoint',
    super.code = 'NETWORK_UNREGISTERED_API',
    super.severity,
    super.isRecoverable,
    super.originalException,
    super.stackTrace,
  });
}