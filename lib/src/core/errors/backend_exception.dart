// lib/src/core/errors/backend_exception.dart

import 'app_exception.dart';

class BackendException implements AppException {
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
  @override
  final Exception? originalException;
  @override
  final StackTrace? stackTrace;
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  const BackendException({
    required this.message,
    required this.code,
    this.severity = AppExceptionSeverity.error,
    this.isRecoverable = false,
    this.originalException,
    this.stackTrace,
    this.statusCode,
    this.responseData,
  });

  @override
  BackendException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return BackendException(
      message: message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      originalException: originalException ?? this.originalException,
      stackTrace: stackTrace ?? this.stackTrace,
      statusCode: statusCode,
      responseData: responseData,
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
      'statusCode': statusCode,
      'responseData': responseData,
    };
  }

  @override
  String toString() => 'BackendException: $message (code: $code, status: $statusCode)';
}