// lib/src/networking/exceptions/networking_exceptions.dart
import '../../core/errors/app_exception.dart';

class NetworkTimeoutException extends NetworkException {
  NetworkTimeoutException(super.message, {super.code, super.originalError});
}

class NetworkOfflineException extends NetworkException {
  NetworkOfflineException(super.message, {super.code, super.originalError});
}

class NetworkManagerDisabledException extends NetworkException {
  NetworkManagerDisabledException(super.message, {super.code, super.originalError});
}

class NetworkBackendException extends NetworkException {
  NetworkBackendException(super.message, {super.code, super.originalError});
}

class NetworkAuthFailedException extends NetworkException {
  NetworkAuthFailedException(super.message, {super.code, super.originalError});
}

class NetworkValidationException extends NetworkException {
  NetworkValidationException(super.message, {super.code, super.originalError});
}

class NetworkUnregisteredApiException extends NetworkException {
  NetworkUnregisteredApiException(super.message, {super.code, super.originalError});
}