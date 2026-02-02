// lib/src/core/errors/validation_exception.dart

import 'app_exception.dart';

class ValidationException implements AppException {
  @override
  final String message;
  @override
  final String code;
  @override
  final AppExceptionSeverity severity;
  @override
  final AppExceptionSource source = AppExceptionSource.validation;
  @override
  final bool isRecoverable;
  @override
  final Exception? originalException;
  @override
  final StackTrace? stackTrace;
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required this.message,
    required this.code,
    this.severity = AppExceptionSeverity.warning,
    this.isRecoverable = true,
    this.originalException,
    this.stackTrace,
    this.fieldErrors,
  });

  @override
  ValidationException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return ValidationException(
      message: message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      originalException: originalException ?? this.originalException,
      stackTrace: stackTrace ?? this.stackTrace,
      fieldErrors: fieldErrors,
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
      'fieldErrors': fieldErrors,
    };
  }

  @override
  String toString() => 'ValidationException: $message (code: $code)';
}