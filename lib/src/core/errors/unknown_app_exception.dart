// lib/src/core/errors/unknown_app_exception.dart

import 'app_exception.dart';

class UnknownAppException implements AppException {
  @override
  final String message;
  @override
  final String code;
  @override
  final AppExceptionSeverity severity;
  @override
  final AppExceptionSource source = AppExceptionSource.unknown;
  @override
  final bool isRecoverable;
  @override
  final Exception? originalException;
  @override
  final StackTrace? stackTrace;

  const UnknownAppException({
    this.message = 'An unknown error occurred',
    this.code = 'UNKNOWN_ERROR',
    this.severity = AppExceptionSeverity.error,
    this.isRecoverable = false,
    this.originalException,
    this.stackTrace,
  });

  @override
  UnknownAppException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return UnknownAppException(
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
  String toString() => 'UnknownAppException: $message (code: $code)';
}