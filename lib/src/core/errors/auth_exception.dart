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
    super.message = 'Authentication token has expired',
    super.code = 'AUTH_TOKEN_EXPIRED',
    super.severity = AppExceptionSeverity.warning,
    super.isRecoverable = true,
    super.originalException,
    super.stackTrace,
  });
}

class PermissionException extends AuthException {
  const PermissionException({
    super.message = 'Insufficient permissions',
    super.code = 'AUTH_PERMISSION_DENIED',
    super.severity = AppExceptionSeverity.error,
    super.isRecoverable = false,
    super.originalException,
    super.stackTrace,
  });
}