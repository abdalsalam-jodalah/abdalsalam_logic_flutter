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
    super.message = 'Request timeout',
    super.code = 'NETWORK_TIMEOUT',
    super.severity = AppExceptionSeverity.warning,
    super.isRecoverable = true,
    super.originalException,
    super.stackTrace,
  });
}

class OfflineException extends NetworkException {
  const OfflineException({
    super.message = 'No internet connection',
    super.code = 'NETWORK_OFFLINE',
    super.severity = AppExceptionSeverity.warning,
    super.isRecoverable = true,
    super.originalException,
    super.stackTrace,
  });
}