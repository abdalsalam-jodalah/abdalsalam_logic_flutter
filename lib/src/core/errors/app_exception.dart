// lib/src/core/errors/app_exception.dart
import 'package:equatable/equatable.dart';

abstract class AppException implements Exception {
  String get message;
  String? get code;
  dynamic get originalError;
}

class BaseAppException extends AppException with EquatableMixin {
  @override
  final String message;
  @override
  final String? code;
  @override
  final dynamic originalError;

  BaseAppException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code, originalError];

  @override
  String toString() => message;
}

class NetworkException extends BaseAppException {
  NetworkException(super.message, {super.code, super.originalError});
}

class StorageException extends BaseAppException {
  StorageException(super.message, {super.code, super.originalError});
}

class AuthException extends BaseAppException {
  AuthException(super.message, {super.code, super.originalError});
}

class ValidationException extends BaseAppException {
  ValidationException(super.message, {super.code, super.originalError});
}

class PermissionException extends BaseAppException {
  PermissionException(super.message, {super.code, super.originalError});
}

