// lib/src/core/errors/auth_exception.dart

import 'app_exception.dart';

class AuthException implements AppException {
  @override
  final String message;
  @override
  final String code;
  @override
  final AppExceptionSeverity severity;
  @override
  final AppExceptionSource source = AppExceptionSource.auth;
  @override
  final bool isRecoverable;
  @override
  final Exception? originalException;
  @override
  final StackTrace? stackTrace;

  const AuthException({
    required this.message,
    required this.code,
    this.severity = AppExceptionSeverity.error,
    this.isRecoverable = false,
    this.originalException,
    this.stackTrace,
  });

  @override
  AuthException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  }) {
    return AuthException(
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
  String toString() => 'AuthException: $message (code: $code)';
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException({
    String message = 'Authentication token has expired',
    String code = 'AUTH_TOKEN_EXPIRED',
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

class PermissionException extends AuthException {
  const PermissionException({
    String message = 'Insufficient permissions',
    String code = 'AUTH_PERMISSION_DENIED',
    AppExceptionSeverity severity = AppExceptionSeverity.error,
    bool isRecoverable = false,
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