// lib/src/core/errors/exception_mapper.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'app_exception.dart';
import 'network_exception.dart';
import 'auth_exception.dart';
import 'storage_exception.dart';
import 'validation_exception.dart';
import 'backend_exception.dart';
import 'unknown_app_exception.dart';

class ExceptionMapper {
  static AppException mapException(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    if (error is SocketException) {
      return OfflineException(
        message: 'No internet connection available',
        originalException: error,
        stackTrace: stackTrace,
      );
    }

    if (error is TimeoutException) {
      return TimeoutException(
        message: 'Request timed out',
        originalException: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return ValidationException(
        message: 'Invalid data format: ${error.message}',
        code: 'VALIDATION_FORMAT_ERROR',
        originalException: error,
        stackTrace: stackTrace,
      );
    }

    if (error is PlatformException) {
      return _mapPlatformException(error, stackTrace);
    }

    if (error is HttpException) {
      return NetworkException(
        message: 'HTTP error: ${error.message}',
        code: 'NETWORK_HTTP_ERROR',
        originalException: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FileSystemException) {
      return StorageException(
        message: 'File system error: ${error.message}',
        code: 'STORAGE_FILE_SYSTEM_ERROR',
        originalException: error,
        stackTrace: stackTrace,
      );
    }

    return UnknownAppException(
      message: error?.toString() ?? 'An unknown error occurred',
      originalException: error is Exception ? error : null,
      stackTrace: stackTrace,
    );
  }

  static AppException _mapPlatformException(PlatformException error, StackTrace? stackTrace) {
    switch (error.code) {
      case 'permission_denied':
      case 'PERMISSION_DENIED':
        return PermissionException(
          message: error.message ?? 'Permission denied',
          code: 'AUTH_PERMISSION_DENIED',
          originalException: error,
          stackTrace: stackTrace,
        );
      case 'not_available':
      case 'NOT_AVAILABLE':
        return StorageException(
          message: error.message ?? 'Service not available',
          code: 'STORAGE_SERVICE_UNAVAILABLE',
          originalException: error,
          stackTrace: stackTrace,
        );
      case 'channel-error':
      case 'CHANNEL_ERROR':
        return NetworkException(
          message: error.message ?? 'Communication error',
          code: 'NETWORK_CHANNEL_ERROR',
          originalException: error,
          stackTrace: stackTrace,
        );
      default:
        return UnknownAppException(
          message: error.message ?? 'Platform error: ${error.code}',
          code: 'PLATFORM_${error.code.toUpperCase()}',
          originalException: error,
          stackTrace: stackTrace,
        );
    }
  }

  static AppException mapDioException(dynamic error, [StackTrace? stackTrace]) {
    final errorType = error.type?.toString() ?? '';
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    final Exception? exceptionToWrap = error is Exception ? error : null;

    switch (errorType) {
      case 'DioExceptionType.connectionTimeout':
      case 'DioExceptionType.sendTimeout':
      case 'DioExceptionType.receiveTimeout':
        return TimeoutException(
          message: 'Request timeout',
          originalException: exceptionToWrap,
          stackTrace: stackTrace,
        );
      case 'DioExceptionType.connectionError':
        return OfflineException(
          message: 'Connection error',
          originalException: exceptionToWrap,
          stackTrace: stackTrace,
        );
      case 'DioExceptionType.badResponse':
        if (statusCode != null) {
          if (statusCode == 401) {
            return TokenExpiredException(
              originalException: exceptionToWrap,
              stackTrace: stackTrace,
            );
          } else if (statusCode == 403) {
            return PermissionException(
              originalException: exceptionToWrap,
              stackTrace: stackTrace,
            );
          } else if (statusCode >= 400 && statusCode < 500) {
            return ValidationException(
              message: 'Client error: $statusCode',
              code: 'VALIDATION_CLIENT_ERROR',
              originalException: exceptionToWrap,
              stackTrace: stackTrace,
            );
          } else if (statusCode >= 500) {
            return BackendException(
              message: 'Server error: $statusCode',
              code: 'BACKEND_SERVER_ERROR',
              statusCode: statusCode,
              responseData: responseData,
              originalException: exceptionToWrap,
              stackTrace: stackTrace,
            );
          }
        }
        return BackendException(
          message: 'Bad response from server',
          code: 'BACKEND_BAD_RESPONSE',
          statusCode: statusCode,
          responseData: responseData,
          originalException: exceptionToWrap,
          stackTrace: stackTrace,
        );
      case 'DioExceptionType.cancel':
        return NetworkException(
          message: 'Request was cancelled',
          code: 'NETWORK_REQUEST_CANCELLED',
          severity: AppExceptionSeverity.info,
          isRecoverable: true,
          originalException: exceptionToWrap,
          stackTrace: stackTrace,
        );
      default:
        return NetworkException(
          message: error.message?.toString() ?? 'Network error',
          code: 'NETWORK_UNKNOWN_ERROR',
          originalException: exceptionToWrap,
          stackTrace: stackTrace,
        );
    }
  }
}