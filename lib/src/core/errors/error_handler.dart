// lib/src/core/errors/error_handler.dart

import 'app_exception.dart';
import 'app_error_response.dart';

abstract class ErrorHandler {
  void handleError(dynamic error, {StackTrace? stackTrace});
  AppException parseError(dynamic error, {StackTrace? stackTrace});
  AppErrorResponse createErrorResponse(AppException exception);
  void logError(AppException exception);
}


