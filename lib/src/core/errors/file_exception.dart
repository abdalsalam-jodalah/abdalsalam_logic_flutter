// lib/src/core/errors/file_exception.dart

import 'app_exception.dart';

abstract class FileException implements AppException {
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

  const FileException({
    required this.message,
    required this.code,
    this.severity = AppExceptionSeverity.error,
    this.isRecoverable = true,
    this.originalException,
    this.stackTrace,
  });

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
  String toString() => '${runtimeType}: $message (code: $code)';
}

class FileDownloadException extends FileException {
  const FileDownloadException({
    required super.message,
    required super.code,
    super.severity = AppExceptionSeverity.error,
    super.isRecoverable = true,
    super.originalException,
    super.stackTrace,
  });

  @override
  FileDownloadException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return FileDownloadException(
      message: message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      originalException: originalException ?? this.originalException,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

class InvalidFileUrlException extends FileException {
  const InvalidFileUrlException({
    required super.message,
    required super.code,
    super.severity = AppExceptionSeverity.warning,
    super.isRecoverable = true,
    super.originalException,
    super.stackTrace,
  });

  @override
  InvalidFileUrlException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return InvalidFileUrlException(
      message: message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      originalException: originalException ?? this.originalException,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

class FilePermissionException extends FileException {
  const FilePermissionException({
    required super.message,
    required super.code,
    super.severity = AppExceptionSeverity.error,
    super.isRecoverable = false,
    super.originalException,
    super.stackTrace,
  });

  @override
  FilePermissionException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return FilePermissionException(
      message: message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      originalException: originalException ?? this.originalException,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

class FileNotFoundException extends FileException {
  const FileNotFoundException({
    required super.message,
    required super.code,
    super.severity = AppExceptionSeverity.error,
    super.isRecoverable = true,
    super.originalException,
    super.stackTrace,
  });

  @override
  FileNotFoundException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return FileNotFoundException(
      message: message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      originalException: originalException ?? this.originalException,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

class FileOpenException extends FileException {
  const FileOpenException({
    required super.message,
    required super.code,
    super.severity = AppExceptionSeverity.warning,
    super.isRecoverable = true,
    super.originalException,
    super.stackTrace,
  });

  @override
  FileOpenException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return FileOpenException(
      message: message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      originalException: originalException ?? this.originalException,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

class UnsupportedFileTypeException extends FileException {
  const UnsupportedFileTypeException({
    required super.message,
    required super.code,
    super.severity = AppExceptionSeverity.warning,
    super.isRecoverable = true,
    super.originalException,
    super.stackTrace,
  });

  @override
  UnsupportedFileTypeException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return UnsupportedFileTypeException(
      message: message ?? this.message,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      originalException: originalException ?? this.originalException,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}