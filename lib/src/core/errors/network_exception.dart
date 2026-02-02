// lib/src/core/errors/network_exception.dart

import 'app_exception.dart';

class NetworkException implements AppException {
  @override
  final String message;
  @override
  final String code;
  @override
  final AppExceptionSeverity severity;
  @override
  final AppExceptionSource source = AppExceptionSource.network;
  @override
  final bool isRecoverable;
  @override
  final Exception? originalException;
  @override
  final StackTrace? stackTrace;

  const NetworkException({
    required this.message,
    required this.code,
    this.severity = AppExceptionSeverity.error,
    this.isRecoverable = true,
    this.originalException,
    this.stackTrace,
  });

  @override
  NetworkException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return NetworkException(
      message: message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      originalException: originalException ?? this.originalException,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'code': code,
      'severity': severity.name,
      'source': source.name,
      'isRecoverable': isRecoverable,
      'hasOriginalException': originalException != null,
      'hasStackTrace': stackTrace != null,
    };
  }

  @override
  String toString() => 'NetworkException: $message (code: $code)';
}

class TimeoutException extends NetworkException {
  const TimeoutException({
    String message = 'Request timeout',
    String code = 'NETWORK_TIMEOUT',
    AppExceptionSeverity severity = AppExceptionSeverity.warning,
    bool isRecoverable = true,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          severity: severity,
          isRecoverable: isRecoverable,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

class OfflineException extends NetworkException {
  const OfflineException({
    String message = 'No internet connection',
    String code = 'NETWORK_OFFLINE',
    AppExceptionSeverity severity = AppExceptionSeverity.warning,
    bool isRecoverable = true,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          severity: severity,
          isRecoverable: isRecoverable,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}