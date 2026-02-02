// lib/src/core/errors/storage_exception.dart

import 'app_exception.dart';

class StorageException implements AppException {
  @override
  final String message;
  @override
  final String code;
  @override
  final AppExceptionSeverity severity;
  @override
  final AppExceptionSource source = AppExceptionSource.storage;
  @override
  final bool isRecoverable;
  @override
  final Exception? originalException;
  @override
  final StackTrace? stackTrace;

  const StorageException({
    required this.message,
    required this.code,
    this.severity = AppExceptionSeverity.error,
    this.isRecoverable = true,
    this.originalException,
    this.stackTrace,
  });

  @override
  StorageException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return StorageException(
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
  String toString() => 'StorageException: $message (code: $code)';
}