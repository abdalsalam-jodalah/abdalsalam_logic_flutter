// lib/src/core/errors/app_exception.dart

enum AppExceptionSeverity { info, warning, error, critical }

enum AppExceptionSource { network, storage, auth, validation, permission, backend, unknown }

abstract class AppException implements Exception {
  String get message;
  String get code;
  AppExceptionSeverity get severity;
  AppExceptionSource get source;
  bool get isRecoverable;
  Exception? get originalException;
  StackTrace? get stackTrace;

  AppException copyWith({
    String? message,
    String? code,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    bool? isRecoverable,
    Exception? originalException,
    StackTrace? stackTrace,
  });

  Map<String, dynamic> toMap();
}

